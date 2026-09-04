-- =========================================================
-- MIGRATION: users table
-- Schema: ireland_dev_saayam_rdbms
-- Adds is_eu, replaces single-sequence EU-only ID generator
-- with a conditional EU/non-EU generator
-- =========================================================

BEGIN;

-- -----------------------------------------------------
-- 1. Drop the old insert trigger (depends on generate_eu_id)
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS before_insert_users ON ireland_dev_saayam_rdbms.users;

-- -----------------------------------------------------
-- 2. Add is_eu column
-- -----------------------------------------------------
ALTER TABLE ireland_dev_saayam_rdbms.users
    ADD COLUMN is_eu BOOLEAN DEFAULT FALSE;

-- -----------------------------------------------------
-- 3. Drop the old function (no longer used)
--    NOTE: safe to drop now that the trigger referencing it is gone
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS ireland_dev_saayam_rdbms.generate_eu_id();

-- -----------------------------------------------------
-- 4. Drop the old sequence
--    NOTE: this was created WITHOUT schema qualification
--    (CREATE SEQUENCE user_id_seq), so it lives in whatever
--    schema was on the search_path at creation time — verify
--    with \ds on all schemas if this DROP doesn't find it.
-- -----------------------------------------------------
DROP SEQUENCE IF EXISTS ireland_dev_saayam_rdbms.user_id_seq;
DROP SEQUENCE IF EXISTS public.user_id_seq;  -- fallback if it landed in public

-- -----------------------------------------------------
-- 5. Create the two new sequences
-- -----------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS ireland_dev_saayam_rdbms.user_id_eu_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 19999999999
    NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS ireland_dev_saayam_rdbms.user_id_dr_seq
    START WITH 20000000000
    INCREMENT BY 1
    MINVALUE 20000000000
    MAXVALUE 39999999999
    NO CYCLE;

-- -----------------------------------------------------
-- 6. Create the conditional generate_sid() function
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_sid()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    padded TEXT;
    prefix TEXT;
BEGIN
    IF NEW.is_eu THEN
        seq_id := nextval('ireland_dev_saayam_rdbms.user_id_eu_seq');
        prefix := 'SID-EU-';
    ELSE
        seq_id := nextval('ireland_dev_saayam_rdbms.user_id_dr_seq');
        prefix := 'SID-00-';
    END IF;

    padded := LPAD(seq_id::TEXT, 15, '0');
    NEW.user_id := prefix ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 3) || '-' ||
        SUBSTRING(padded FROM 13 FOR 3);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. Recreate the insert trigger against the new function
-- -----------------------------------------------------
CREATE TRIGGER before_insert_users
    BEFORE INSERT ON ireland_dev_saayam_rdbms.users
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_sid();

COMMIT;

-- =========================================================
-- MIGRATION: request_isleadvol table
-- Schema: ireland_dev_saayam_rdbms
-- Rename last_updated_date -> last_updated_at, add default,
-- attach set_updated_at trigger
-- =========================================================

BEGIN;

-- -----------------------------------------------------
-- 1. Rename column
-- -----------------------------------------------------
ALTER TABLE ireland_dev_saayam_rdbms.request_isleadvol
    RENAME COLUMN last_updated_date TO last_updated_at;

-- -----------------------------------------------------
-- 2. Set type explicitly (no-op if already TIMESTAMP) + default
-- -----------------------------------------------------
ALTER TABLE ireland_dev_saayam_rdbms.request_isleadvol
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

-- -----------------------------------------------------
-- 3. Attach the updated_at trigger
--    NOTE: relies on ireland_dev_saayam_rdbms.set_updated_at()
--    already existing (per the function context you shared)
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS trg_request_isleadvol_updated_at ON ireland_dev_saayam_rdbms.request_isleadvol;

CREATE TRIGGER trg_request_isleadvol_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_isleadvol
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

COMMIT;


-- =========================================================
-- MIGRATION: help_categories table
-- Schema: ireland_dev_saayam_rdbms
-- Add last_updated_at column + attach set_updated_at trigger
-- =========================================================

BEGIN;

-- -----------------------------------------------------
-- 1. Add new column
-- -----------------------------------------------------
ALTER TABLE ireland_dev_saayam_rdbms.help_categories
    ADD COLUMN last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC');

-- -----------------------------------------------------
-- 2. Attach the updated_at trigger
--    NOTE: relies on ireland_dev_saayam_rdbms.set_updated_at()
--    already existing
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS trg_help_categories_updated_at ON ireland_dev_saayam_rdbms.help_categories;

CREATE TRIGGER trg_help_categories_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.help_categories
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

COMMIT;


-- =========================================================
-- MIGRATION: help_category_map table
-- Schema: ireland_dev_saayam_rdbms
-- Add last_updated_at column + attach set_updated_at trigger
-- =========================================================

BEGIN;

-- -----------------------------------------------------
-- 1. Add new column
-- -----------------------------------------------------
ALTER TABLE ireland_dev_saayam_rdbms.help_category_map
    ADD COLUMN last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC');

-- -----------------------------------------------------
-- 2. Attach the updated_at trigger
--    NOTE: relies on ireland_dev_saayam_rdbms.set_updated_at()
--    already existing
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS trg_help_category_map_updated_at ON ireland_dev_saayam_rdbms.help_category_map;

CREATE TRIGGER trg_help_category_map_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.help_category_map
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

COMMIT;


-- =========================================================
-- COMBINED MIGRATION SCRIPT
-- Schema: ireland_dev_saayam_rdbms
-- Tables: users, request_isleadvol, help_categories, help_category_map
-- =========================================================

BEGIN;

-- ============================================================
-- 1. users table
--    Adds is_eu, replaces single-sequence EU-only ID generator
--    with a conditional EU/non-EU generator
-- ============================================================

-- 1.1 Drop the old insert trigger (depends on generate_eu_id)
DROP TRIGGER IF EXISTS before_insert_users ON ireland_dev_saayam_rdbms.users;

-- 1.2 Add is_eu column
ALTER TABLE ireland_dev_saayam_rdbms.users
    ADD COLUMN is_eu BOOLEAN DEFAULT FALSE;

-- 1.3 Drop the old function (no longer used)
--     NOTE: safe to drop now that the trigger referencing it is gone
DROP FUNCTION IF EXISTS ireland_dev_saayam_rdbms.generate_eu_id();

-- 1.4 Drop the old sequence
--     NOTE: this was created WITHOUT schema qualification
--     (CREATE SEQUENCE user_id_seq), so it lives in whatever
--     schema was on the search_path at creation time — verify
--     with \ds on all schemas if this DROP doesn't find it.
DROP SEQUENCE IF EXISTS ireland_dev_saayam_rdbms.user_id_seq;

-- 1.5 Create the two new sequences
CREATE SEQUENCE IF NOT EXISTS ireland_dev_saayam_rdbms.user_id_eu_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 19999999999
    NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS ireland_dev_saayam_rdbms.user_id_dr_seq
    START WITH 20000000000
    INCREMENT BY 1
    MINVALUE 20000000000
    MAXVALUE 39999999999
    NO CYCLE;

-- 1.6 Create the conditional generate_sid() function
CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_sid()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    padded TEXT;
    prefix TEXT;
BEGIN
    IF NEW.is_eu THEN
        seq_id := nextval('ireland_dev_saayam_rdbms.user_id_eu_seq');
        prefix := 'SID-EU-';
    ELSE
        seq_id := nextval('ireland_dev_saayam_rdbms.user_id_dr_seq');
        prefix := 'SID-00-';
    END IF;

    padded := LPAD(seq_id::TEXT, 15, '0');
    NEW.user_id := prefix ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 3) || '-' ||
        SUBSTRING(padded FROM 13 FOR 3);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1.7 Recreate the insert trigger against the new function
CREATE TRIGGER before_insert_users
    BEFORE INSERT ON ireland_dev_saayam_rdbms.users
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_sid();


-- ============================================================
-- 2. request_isleadvol table
--    Rename last_updated_date -> last_updated_at, add default,
--    attach set_updated_at trigger
-- ============================================================

-- 2.1 Rename column
ALTER TABLE ireland_dev_saayam_rdbms.request_isleadvol
    RENAME COLUMN last_updated_date TO last_updated_at;

-- 2.2 Set type explicitly (no-op if already TIMESTAMP) + default
ALTER TABLE ireland_dev_saayam_rdbms.request_isleadvol
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

-- 2.3 Attach the updated_at trigger
--     NOTE: relies on ireland_dev_saayam_rdbms.set_updated_at() already existing
DROP TRIGGER IF EXISTS trg_request_isleadvol_updated_at ON ireland_dev_saayam_rdbms.request_isleadvol;

CREATE TRIGGER trg_request_isleadvol_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_isleadvol
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();


-- ============================================================
-- 3. help_categories table
--    Add last_updated_at column + attach set_updated_at trigger
-- ============================================================

-- 3.1 Add new column
ALTER TABLE ireland_dev_saayam_rdbms.help_categories
    ADD COLUMN last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC');

-- 3.2 Attach the updated_at trigger
DROP TRIGGER IF EXISTS trg_help_categories_updated_at ON ireland_dev_saayam_rdbms.help_categories;

CREATE TRIGGER trg_help_categories_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.help_categories
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();


-- ============================================================
-- 4. help_category_map table
--    Add last_updated_at column + attach set_updated_at trigger
-- ============================================================

-- 4.1 Add new column
ALTER TABLE ireland_dev_saayam_rdbms.help_category_map
    ADD COLUMN last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC');

-- 4.2 Attach the updated_at trigger
DROP TRIGGER IF EXISTS trg_help_category_map_updated_at ON ireland_dev_saayam_rdbms.help_category_map;

CREATE TRIGGER trg_help_category_map_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.help_category_map
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

COMMIT;