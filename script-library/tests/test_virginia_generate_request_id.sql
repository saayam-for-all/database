-- Smoke test: Virginia request ID generator (band-from-sequence)
-- Requires: Virginia schema deployed (ddl_request.sql + FK lookup tables + users).

--
-- HOW TO RUN:
--   run the whole file via psql to see all results in the terminal. 
--   OR
--   1) Highlight "SETUP" block below (BEGIN through both request INSERTs) → Execute
--   2) Highlight each numbered check (-- 1) through -- 8)) one at a time →
--      Expect one row: OK: ... or FAIL: ...
--   3) Optional: run the inspect SELECT to view req_id values
--   4) Highlight CLEANUP (ROLLBACK + ALTER SEQUENCE) → F5 (same query tab / session as step 1)
--
-- Prerequisites: CREATE SCHEMA + Virginia DDL (users, lookup tables, ddl_request.sql)

-- === SETUP ===
BEGIN;

-- ddl_users.sql creates user_id_seq in virginia_dev_saayam_rdbms but generate_sid()
-- calls nextval('user_id_seq') unqualified; search_path must include that schema.
SET LOCAL search_path TO virginia_dev_saayam_rdbms, public;

INSERT INTO virginia_dev_saayam_rdbms.request_for (req_for_id, req_for, req_for_desc) VALUES (1, 'SELF', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_isleadvol (req_islead_id, req_islead, req_islead_desc) VALUES (1, 'NO', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_type (req_type_id, req_type, req_type_desc) VALUES (1, 'INPERSON', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_priority (req_priority_id, req_priority, req_priority_desc) VALUES (1, 'LOW', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.request_status (req_status_id, req_status, req_status_desc) VALUES (1, 'CREATED', 'Test fixture');
INSERT INTO virginia_dev_saayam_rdbms.help_categories (cat_id, cat_name, cat_desc) VALUES ('1', 'TEST_CATEGORY', 'Test fixture');

INSERT INTO virginia_dev_saayam_rdbms.users DEFAULT VALUES;

WITH test_user AS (
    SELECT user_id
    FROM virginia_dev_saayam_rdbms.users
    ORDER BY user_id DESC
    LIMIT 1
)
INSERT INTO virginia_dev_saayam_rdbms.request (
    req_user_id, req_for_id, req_islead_id, req_cat_id,
    req_type_id, req_priority_id, req_status_id, req_subj, req_desc
)
SELECT
    user_id, 1, 1, '1', 1, 1, 1, 'Test subject A', 'Test description A'
FROM test_user;

WITH test_user AS (
    SELECT user_id
    FROM virginia_dev_saayam_rdbms.users
    ORDER BY user_id DESC
    LIMIT 1
)
INSERT INTO virginia_dev_saayam_rdbms.request (
    req_user_id, req_for_id, req_islead_id, req_cat_id,
    req_type_id, req_priority_id, req_status_id, req_subj, req_desc
)
SELECT
    user_id, 1, 1, '1', 1, 1, 1, 'Test subject B', 'Test description B'
FROM test_user;

-- === CHECKS (run one at a time; each should return OK: or FAIL:) ===

-- 1) First insert: req_id is not null
SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM virginia_dev_saayam_rdbms.request
        WHERE req_subj = 'Test subject A' AND req_id IS NOT NULL
    ) THEN 'OK: Virginia band 00: req_id is not null'
    ELSE 'FAIL: Virginia band 00: req_id is null'
END AS check_req_id_a_not_null;

-- 2) First insert: starts with REQ-00
SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM virginia_dev_saayam_rdbms.request
        WHERE req_subj = 'Test subject A' AND req_id ~ '^REQ-00-'
    ) THEN 'OK: Virginia band 00: req_id starts with REQ-00'
    ELSE 'FAIL: Virginia band 00: req_id does not start with REQ-00'
END AS check_req_id_a_prefix;

-- 3) First insert: full format
SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM virginia_dev_saayam_rdbms.request
        WHERE req_subj = 'Test subject A'
          AND req_id ~ '^REQ-00-\d{3}-\d{3}-\d{3}-\d{3}$'
    ) THEN 'OK: Virginia band 00: req_id matches REQ-00-XXX-XXX-XXX-XXX format'
    ELSE 'FAIL: Virginia band 00: req_id format mismatch'
END AS check_req_id_a_format;

-- 4) First insert: length within VARCHAR(255)
SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM virginia_dev_saayam_rdbms.request
        WHERE req_subj = 'Test subject A' AND LENGTH(req_id) <= 255
    ) THEN 'OK: Virginia band 00: req_id length within VARCHAR(255)'
    ELSE 'FAIL: Virginia band 00: req_id exceeds VARCHAR(255)'
END AS check_req_id_a_length;

-- 5) Second insert: req_id is not null
SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM virginia_dev_saayam_rdbms.request
        WHERE req_subj = 'Test subject B' AND req_id IS NOT NULL
    ) THEN 'OK: Virginia band 00: second insert req_id is not null'
    ELSE 'FAIL: Virginia band 00: second insert req_id is null'
END AS check_req_id_b_not_null;

-- 6) Second insert: starts with REQ-00
SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM virginia_dev_saayam_rdbms.request
        WHERE req_subj = 'Test subject B' AND req_id ~ '^REQ-00-'
    ) THEN 'OK: Virginia band 00: second insert starts with REQ-00'
    ELSE 'FAIL: Virginia band 00: second insert does not start with REQ-00'
END AS check_req_id_b_prefix;

-- 7) Second insert: full format
SELECT CASE
    WHEN EXISTS (
        SELECT 1 FROM virginia_dev_saayam_rdbms.request
        WHERE req_subj = 'Test subject B'
          AND req_id ~ '^REQ-00-\d{3}-\d{3}-\d{3}-\d{3}$'
    ) THEN 'OK: Virginia band 00: second insert matches full format'
    ELSE 'FAIL: Virginia band 00: second insert format mismatch'
END AS check_req_id_b_format;

-- 8) Two inserts produce unique req_ids
SELECT CASE
    WHEN COUNT(DISTINCT req_id) = 2 THEN 'OK: Virginia: two inserts produce unique req_ids'
    ELSE 'FAIL: Virginia: expected 2 unique req_ids, found ' || COUNT(DISTINCT req_id)
END AS check_unique_req_ids
FROM virginia_dev_saayam_rdbms.request
WHERE req_subj IN ('Test subject A', 'Test subject B');

-- === inspect generated IDs (before ROLLBACK) ===
SELECT req_id, req_subj
FROM virginia_dev_saayam_rdbms.request
WHERE req_subj IN ('Test subject A', 'Test subject B')
ORDER BY req_subj;

-- === CLEANUP ===
ROLLBACK;
-- Sequences are not rolled back by ROLLBACK; restart after local test runs.
ALTER SEQUENCE virginia_dev_saayam_rdbms.request_id_seq RESTART WITH 1;
