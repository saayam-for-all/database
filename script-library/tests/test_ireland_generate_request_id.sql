-- Test: Ireland request ID generator (REQ-XXX-XXX-XXX-XXXX).
-- Requires: Ireland schema deployed.
-- Sequence changes survive ROLLBACK; snapshot and restore pre-test state.

BEGIN;

DROP TABLE IF EXISTS _ie_req_id_seq_snapshot;
CREATE TEMP TABLE _ie_req_id_seq_snapshot AS
SELECT last_value, is_called
FROM ireland_dev_saayam_rdbms.request_id_dr_seq;

INSERT INTO ireland_dev_saayam_rdbms.request_for (req_for_id, req_for, req_for_desc) VALUES (1, 'SELF', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_isleadvol (req_islead_id, req_islead, req_islead_desc) VALUES (1, 'NO', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_type (req_type_id, req_type, req_type_desc) VALUES (1, 'INPERSON', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_priority (req_priority_id, req_priority, req_priority_desc) VALUES (1, 'LOW', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.request_status (req_status_id, req_status, req_status_desc) VALUES (1, 'CREATED', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.help_categories (cat_id, cat_name, cat_desc) VALUES ('1', 'TEST_CATEGORY', 'Test fixture');
INSERT INTO ireland_dev_saayam_rdbms.users DEFAULT VALUES;

-- T1  Sequential mint (next two values from current sequence) --------------
DO $$
DECLARE
    a TEXT;
    b TEXT;
    uid TEXT;
    next_id BIGINT;
    expected_a TEXT;
    expected_b TEXT;
    padded TEXT;
BEGIN
    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO next_id
    FROM ireland_dev_saayam_rdbms.request_id_dr_seq;

    RAISE NOTICE 'T1 setup  next seq_id=%', next_id;

    padded := LPAD(next_id::TEXT, 13, '0');
    expected_a := 'REQ-' ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 4);

    padded := LPAD((next_id + 1)::TEXT, 13, '0');
    expected_b := 'REQ-' ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 4);

    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;

    INSERT INTO ireland_dev_saayam_rdbms.request (
        creator_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'IE-1', 'T1')
    RETURNING req_id INTO a;

    INSERT INTO ireland_dev_saayam_rdbms.request (
        creator_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'IE-2', 'T1')
    RETURNING req_id INTO b;

    IF a = expected_a AND b = expected_b THEN
        RAISE NOTICE 'T1 PASS  Ireland sequential (%, %)', a, b;
    ELSE
        RAISE NOTICE 'T1 FAIL  expected %, %; got %, %', expected_a, expected_b, a, b;
    END IF;
END$$;

-- T2  Exhaustion hard wall at MAXVALUE 1,999,999,999,999 --------------------
DO $$
DECLARE
    last_id TEXT;
    uid TEXT;
BEGIN
    SELECT user_id INTO uid FROM ireland_dev_saayam_rdbms.users ORDER BY user_id DESC LIMIT 1;
    PERFORM setval('ireland_dev_saayam_rdbms.request_id_dr_seq', 1999999999998, true);  -- next = MAXVALUE

    INSERT INTO ireland_dev_saayam_rdbms.request (
        creator_id, req_for_id, req_islead_id, req_cat_id,
        req_type_id, req_priority_id, req_status_id, req_subj, req_desc
    ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'last', 'T2')
    RETURNING req_id INTO last_id;

    IF last_id <> 'REQ-199-999-999-9999' THEN
        RAISE NOTICE 'T2 FAIL  last mint expected REQ-199-999-999-9999 got %', last_id;
        RETURN;
    END IF;

    BEGIN
        INSERT INTO ireland_dev_saayam_rdbms.request (
            creator_id, req_for_id, req_islead_id, req_cat_id,
            req_type_id, req_priority_id, req_status_id, req_subj, req_desc
        ) VALUES (uid, 1, 1, '1', 1, 1, 1, 'over', 'T2');
        RAISE NOTICE 'T2 FAIL  sequence did not exhaust';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'T2 PASS  hard wall hit as designed: %', SQLERRM;
    END;
END$$;

-- Restore sequence before ROLLBACK (pgAdmin may wrap the script in one
-- transaction; ROLLBACK would drop the temp snapshot table).
SELECT setval(
    'ireland_dev_saayam_rdbms.request_id_dr_seq',
    last_value,
    is_called
)
FROM _ie_req_id_seq_snapshot;

DROP TABLE IF EXISTS _ie_req_id_seq_snapshot;

ROLLBACK;
