-- Smoke test: Virginia request ID generator (band-from-sequence)
-- Requires: Virginia schema deployed (ddl_request.sql + FK lookup tables + users).

-- === SETUP ===
BEGIN;

SET LOCAL search_path TO virginia_dev_saayam_rdbms, public;

INSERT INTO virginia_dev_saayam_rdbms.request_for (req_for_id, req_for, req_for_desc) VALUES (1, 'SELF', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_isleadvol (req_islead_id, req_islead, req_islead_desc) VALUES (1, 'NO', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_type (req_type_id, req_type, req_type_desc) VALUES (1, 'INPERSON', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_priority (req_priority_id, req_priority, req_priority_desc) VALUES (1, 'LOW', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_status (req_status_id, req_status, req_status_desc) VALUES (1, 'CREATED', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.help_categories (cat_id, cat_name, cat_desc) VALUES ('1', 'TEST_CATEGORY', 'Test fixture');

INSERT INTO virginia_dev_saayam_rdbms.users DEFAULT VALUES;

WITH test_user AS (
    SELECT user_id FROM virginia_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1
)
INSERT INTO virginia_dev_saayam_rdbms.request (
    req_user_id, req_for_id, req_islead_id, req_cat_id,
    req_type_id, req_priority_id, req_status_id, req_subj, req_desc
)
SELECT user_id, 1, 1, '1', 1, 1, 1, 'Test subject A', 'Test description A' FROM test_user;

WITH test_user AS (
    SELECT user_id FROM virginia_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1
)
INSERT INTO virginia_dev_saayam_rdbms.request (
    req_user_id, req_for_id, req_islead_id, req_cat_id,
    req_type_id, req_priority_id, req_status_id, req_subj, req_desc
)
SELECT user_id, 1, 1, '1', 1, 1, 1, 'Test subject B', 'Test description B' FROM test_user;

-- === ASSERTIONS (all results in Messages tab via RAISE NOTICE) ===
DO $$
DECLARE
    req_a TEXT;
    req_b TEXT;
    boundary_1k TEXT;
    boundary_1m TEXT;
    uid TEXT;
    unique_count INT;
BEGIN
    SELECT req_id INTO req_a FROM virginia_dev_saayam_rdbms.request
    WHERE req_subj = 'Test subject A' LIMIT 1;

    SELECT req_id INTO req_b FROM virginia_dev_saayam_rdbms.request
    WHERE req_subj = 'Test subject B' LIMIT 1;

    -- Test 1: first insert req_id is not null
    IF req_a IS NOT NULL THEN
        RAISE NOTICE 'Test 1 PASS: Virginia band 00 — req_id is not null (%)', req_a;
    ELSE
        RAISE NOTICE 'Test 1 FAIL: Virginia band 00 — req_id is null';
    END IF;

    -- Test 2: first insert starts with REQ-00
    IF req_a ~ '^REQ-00-' THEN
        RAISE NOTICE 'Test 2 PASS: Virginia band 00 — req_id starts with REQ-00 (%)', req_a;
    ELSE
        RAISE NOTICE 'Test 2 FAIL: Virginia band 00 — req_id does not start with REQ-00 (%)', req_a;
    END IF;

    -- Test 3: first insert full format
    IF req_a ~ '^REQ-00-\d{3}-\d{3}-\d{3}-\d{3}$' THEN
        RAISE NOTICE 'Test 3 PASS: Virginia band 00 — req_id matches REQ-00-XXX-XXX-XXX-XXX (%)', req_a;
    ELSE
        RAISE NOTICE 'Test 3 FAIL: Virginia band 00 — req_id format mismatch (%)', req_a;
    END IF;

    -- Test 4: second insert starts with REQ-00
    IF req_b ~ '^REQ-00-' THEN
        RAISE NOTICE 'Test 4 PASS: Virginia band 00 — second insert starts with REQ-00 (%)', req_b;
    ELSE
        RAISE NOTICE 'Test 4 FAIL: Virginia band 00 — second insert does not start with REQ-00 (%)', req_b;
    END IF;

    -- Test 5: second insert full format
    IF req_b ~ '^REQ-00-\d{3}-\d{3}-\d{3}-\d{3}$' THEN
        RAISE NOTICE 'Test 5 PASS: Virginia band 00 — second insert matches full format (%)', req_b;
    ELSE
        RAISE NOTICE 'Test 5 FAIL: Virginia band 00 — second insert format mismatch (%)', req_b;
    END IF;

    -- Test 6: two inserts produce unique req_ids
    SELECT COUNT(DISTINCT req_id) INTO unique_count
    FROM virginia_dev_saayam_rdbms.request
    WHERE req_subj IN ('Test subject A', 'Test subject B');

    IF unique_count = 2 THEN
        RAISE NOTICE 'Test 6 PASS: Virginia — two inserts produce unique req_ids';
    ELSE
        RAISE NOTICE 'Test 6 FAIL: Virginia — expected 2 unique req_ids, found %', unique_count;
    END IF;

    -- Test 7: segment rollover at 999 → 1000 and 999999 → 1000000
    SELECT user_id INTO uid FROM virginia_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;

    PERFORM setval('virginia_dev_saayam_rdbms.request_id_seq', 999, true);
    INSERT INTO virginia_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'Boundary 1k', 'Test boundary 1000')
    RETURNING req_id INTO boundary_1k;

    PERFORM setval('virginia_dev_saayam_rdbms.request_id_seq', 999999, true);
    INSERT INTO virginia_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'Boundary 1m', 'Test boundary 1000000')
    RETURNING req_id INTO boundary_1m;

    IF boundary_1k = 'REQ-00-000-000-001-000' AND boundary_1m = 'REQ-00-000-001-000-000' THEN
        RAISE NOTICE 'Test 7 PASS: Virginia segment rollover correct (%, %)', boundary_1k, boundary_1m;
    ELSE
        RAISE NOTICE 'Test 7 FAIL: Virginia segment rollover got %, %', boundary_1k, boundary_1m;
    END IF;
END$$;

-- === CLEANUP ===
ROLLBACK;
ALTER SEQUENCE virginia_dev_saayam_rdbms.request_id_seq RESTART WITH 1;
