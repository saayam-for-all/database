-- Test: Ireland request ID generator (REQ-XXX-XXX-XXX-XXXX).
-- Requires: Ireland schema deployed.

BEGIN;

INSERT INTO ireland_dev_saayam_rdbms.request_for (req_for_id, req_for, req_for_desc) VALUES (1, 'SELF', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_isleadvol (req_islead_id, req_islead, req_islead_desc) VALUES (1, 'NO', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_type (req_type_id, req_type, req_type_desc) VALUES (1, 'INPERSON', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_priority (req_priority_id, req_priority, req_priority_desc) VALUES (1, 'LOW', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_status (req_status_id, req_status, req_status_desc) VALUES (1, 'CREATED', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.help_categories (cat_id, cat_name, cat_desc) VALUES ('1', 'TEST_CATEGORY', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.users DEFAULT VALUES;

SELECT setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1000000000000, false);  -- next = 1T

-- T1  Sequential mint in Ireland range -------------------------------------
DO $$
DECLARE
    a TEXT;
    b TEXT;
    uid TEXT;
BEGIN
    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;

    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'IE-1', 'T1')
    RETURNING req_id INTO a;

    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'IE-2', 'T1')
    RETURNING req_id INTO b;

    IF a = 'REQ-100-000-000-0000' AND b = 'REQ-100-000-000-0001' THEN
        RAISE NOTICE 'T1 PASS  Ireland sequential (%, %)', a, b;
    ELSE
        RAISE NOTICE 'T1 FAIL  got %, %', a, b;
    END IF;
END$$;

-- T2  Format shape + fixed length -------------------------------------------
DO $$
DECLARE
    id TEXT;
    uid TEXT;
BEGIN
    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;
    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1000000000010, true);

    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'fmt', 'T2')
    RETURNING req_id INTO id;

    IF id ~ '^REQ-\d{3}-\d{3}-\d{3}-\d{4}$' AND length(id) = 20 THEN
        RAISE NOTICE 'T2 PASS  format + length (%, len=%)', id, length(id);
    ELSE
        RAISE NOTICE 'T2 FAIL  format/length mismatch (%)', id;
    END IF;
END$$;

-- T3  Zero-padding / mid-value exact IDs ------------------------------------
DO $$
DECLARE
    a TEXT;
    b TEXT;
    uid TEXT;
BEGIN
    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;

    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1000000000041, true);
    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'pad-42', 'T3')
    RETURNING req_id INTO a;

    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1123456789011, true);
    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'mid-big', 'T3')
    RETURNING req_id INTO b;

    IF a = 'REQ-100-000-000-0042' AND b = 'REQ-112-345-678-9012' THEN
        RAISE NOTICE 'T3 PASS  zero-pad / mid-value (%, %)', a, b;
    ELSE
        RAISE NOTICE 'T3 FAIL  got %, %', a, b;
    END IF;
END$$;

-- T4  Uniqueness across a burst of inserts ----------------------------------
DO $$
DECLARE
    uid TEXT;
    unique_count INT;
BEGIN
    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;
    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1000000000200, true);

    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    )
    SELECT uid, 1, 1, '1', 1, 1, 1, 'burst-' || g, 'T4'
    FROM generate_series(1, 5) AS g;

    SELECT COUNT(DISTINCT req_id) INTO unique_count
    FROM ireland_dev_saayam_rdbms.request
    WHERE req_subj LIKE 'burst-%';

    IF unique_count = 5 THEN
        RAISE NOTICE 'T4 PASS  5 burst inserts all unique';
    ELSE
        RAISE NOTICE 'T4 FAIL  expected 5 unique ids, found %', unique_count;
    END IF;
END$$;

-- T5  Segment rollover at 1T+1,000 / 1T+10,000 / 1T+1,000,000 ---------------
DO $$
DECLARE
    a TEXT;
    b TEXT;
    c TEXT;
    uid TEXT;
BEGIN
    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;

    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1000000000999, true);
    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'r1k', 'T5')
    RETURNING req_id INTO a;

    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1000000009999, true);
    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'r10k', 'T5')
    RETURNING req_id INTO b;

    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1000000999999, true);
    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'r1m', 'T5')
    RETURNING req_id INTO c;

    IF a = 'REQ-100-000-000-1000' AND b = 'REQ-100-000-001-0000' AND c = 'REQ-100-000-100-0000' THEN
        RAISE NOTICE 'T5 PASS  rollover correct (%, %, %)', a, b, c;
    ELSE
        RAISE NOTICE 'T5 FAIL  got %, %, %', a, b, c;
    END IF;
END$$;

-- T6  Exhaustion hard wall at MAXVALUE 1,999,999,999,999 --------------------
DO $$
DECLARE
    last_id TEXT;
    uid TEXT;
BEGIN
    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;
    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1999999999998, true);  -- next = MAXVALUE

    INSERT INTO ireland_dev_saayam_rdbms.request (
        req_user_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'last', 'T6')
    RETURNING req_id INTO last_id;

    IF last_id <> 'REQ-199-999-999-9999' THEN
        RAISE NOTICE 'T6 FAIL  last mint expected REQ-199-999-999-9999 got %', last_id;
        RETURN;
    END IF;

    BEGIN
        INSERT INTO ireland_dev_saayam_rdbms.request (
            req_user_id, req_for_id, req_islead_id, req_cat_id,
            req_type_id, req_priority_id, req_status_id, req_subj, req_desc
        ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'over', 'T6');
        RAISE NOTICE 'T6 FAIL  sequence did not exhaust';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'T6 PASS  hard wall hit as designed: %', SQLERRM;
    END;
END$$;

ROLLBACK;
ALTER SEQUENCE ireland_dev_saayam_rdbms.request_id_dr_seq RESTART WITH 1000000000000;
