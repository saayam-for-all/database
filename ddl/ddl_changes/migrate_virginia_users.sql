BEGIN;

-- Step 1: Add is_eu flag
ALTER TABLE virginia_dev_saayam_rdbms.users
ADD COLUMN is_eu BOOLEAN DEFAULT FALSE;

-- Step 2: Rename existing sequence out of the way
ALTER SEQUENCE virginia_dev_saayam_rdbms.user_id_seq
RENAME TO user_id_seq_old;

-- Step 3: Create new sequences
CREATE SEQUENCE virginia_dev_saayam_rdbms.user_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 1000000000000
    NO CYCLE;

CREATE SEQUENCE virginia_dev_saayam_rdbms.user_id_seq_eu_dr
    START WITH 5000000000000
    INCREMENT BY -1
    MINVALUE 4000000000001
    MAXVALUE 5000000000000
    NO CYCLE;

-- Step 4: Update generate_sid()
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_sid()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id VARCHAR(25);
    sid_prefix TEXT;
BEGIN
    IF NEW.is_eu = TRUE THEN
        seq_id     := nextval('virginia_dev_saayam_rdbms.user_id_seq_eu_dr');
        sid_prefix := 'SID-002-';
    ELSE
        seq_id     := nextval('virginia_dev_saayam_rdbms.user_id_seq');
        sid_prefix := 'SID-001-';
    END IF;

    new_id := sid_prefix ||
        LPAD(FLOOR((seq_id % 1000000000000) / 1000000000)::TEXT, 3, '0') || '-' ||
        LPAD(FLOOR((seq_id % 1000000000) / 1000000)::TEXT, 3, '0') || '-' ||
        LPAD(FLOOR((seq_id % 1000000) / 1000)::TEXT, 3, '0') || '-' ||
        LPAD((seq_id % 1000)::TEXT, 3, '0');

    NEW.user_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 5: Rename old user_id to user_id_old
ALTER TABLE virginia_dev_saayam_rdbms.users
RENAME COLUMN user_id TO user_id_old;

-- Step 6: Add new user_id column
ALTER TABLE virginia_dev_saayam_rdbms.users
ADD COLUMN user_id VARCHAR(25);

-- Step 7: Backfill new user_id for existing rows
UPDATE virginia_dev_saayam_rdbms.users
SET user_id = (
    CASE
        WHEN is_eu = TRUE THEN
            'SID-002-' ||
            LPAD(FLOOR((nextval('virginia_dev_saayam_rdbms.user_id_seq_eu_dr') % 1000000000000) / 1000000000)::TEXT, 3, '0') || '-' ||
            LPAD(FLOOR((currval('virginia_dev_saayam_rdbms.user_id_seq_eu_dr') % 1000000000) / 1000000)::TEXT, 3, '0') || '-' ||
            LPAD(FLOOR((currval('virginia_dev_saayam_rdbms.user_id_seq_eu_dr') % 1000000) / 1000)::TEXT, 3, '0') || '-' ||
            LPAD((currval('virginia_dev_saayam_rdbms.user_id_seq_eu_dr') % 1000)::TEXT,