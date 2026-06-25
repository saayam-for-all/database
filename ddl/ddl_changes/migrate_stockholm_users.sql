BEGIN;

-- Step 1: Add is_eu flag
ALTER TABLE stockholm_dev_saayam_rdbms.users
ADD COLUMN is_eu BOOLEAN DEFAULT TRUE;

-- Step 2: Rename existing sequence out of the way
ALTER SEQUENCE stockholm_dev_saayam_rdbms.user_id_seq
RENAME TO user_id_seq_old;

-- Step 3: Create new sequence
CREATE SEQUENCE stockholm_dev_saayam_rdbms.user_id_seq
    START WITH 3999999999999
    INCREMENT BY -1
    MINVALUE 2000000000001
    MAXVALUE 3999999999999
    NO CYCLE;

-- Step 4: Update generate_sid()
CREATE OR REPLACE FUNCTION stockholm_dev_saayam_rdbms.generate_sid()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id VARCHAR(25);
BEGIN
    seq_id := nextval('stockholm_dev_saayam_rdbms.user_id_seq');

    new_id := 'SID-002-' ||
        LPAD(FLOOR((seq_id % 1000000000000) / 1000000000)::TEXT, 3, '0') || '-' ||
        LPAD(FLOOR((seq_id % 1000000000) / 1000000)::TEXT, 3, '0') || '-' ||
        LPAD(FLOOR((seq_id % 1000000) / 1000)::TEXT, 3, '0') || '-' ||
        LPAD((seq_id % 1000)::TEXT, 3, '0');

    NEW.user_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 5: Rename old user_id to user_id_old
ALTER TABLE stockholm_dev_saayam_rdbms.users
RENAME COLUMN user_id TO user_id_old;

-- Step 6: Add new user_id column
ALTER TABLE stockholm_dev_saayam_rdbms.users
ADD COLUMN user_id VARCHAR(25);

-- Step 7: Backfill new user_id for existing rows
UPDATE stockholm_dev_saayam_rdbms.users
SET user_id = (
    'SID-002-' ||
    LPAD(FLOOR((nextval('stockholm_dev_saayam_rdbms.user_id_seq') % 1000000000000) / 1000000000)::TEXT, 3, '0') || '-' ||
    LPAD(FLOOR((currval('stockholm_dev_saayam_rdbms.user_id_seq') % 1000000000) / 1000000)::TEXT, 3, '0') || '-' ||
    LPAD(FLOOR((currval('stockholm_dev_saayam_rdbms.user_id_seq') % 1000000) / 1000)::TEXT, 3, '0') || '-' ||
    LPAD((currval('stockholm_dev_saayam_rdbms.user_id_seq') % 1000)::TEXT, 3, '0')
);

-- Step 8: Add primary key constraint on new user_id
ALTER TABLE stockholm_dev_saayam_rdbms.users
ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);

-- Step 9: Drop old user_id_old column
ALTER TABLE stockholm_dev_saayam_rdbms.users
DROP COLUMN user_id_old;

-- Step 10: Drop old sequence
DROP SEQUENCE IF EXISTS stockholm_dev_saayam_rdbms.user_id_seq_old;

COMMIT;