BEGIN;

-- =============================================
-- 0. action
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.action
    RENAME COLUMN created_date TO created_at;

ALTER TABLE virginia_dev_saayam_rdbms.action
    RENAME COLUMN last_update_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.action
    ALTER COLUMN created_at SET DEFAULT (now() AT TIME ZONE 'UTC'),
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

CREATE TRIGGER trg_action_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.action
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 1. country
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.country
    RENAME COLUMN last_update_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.country
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

CREATE TRIGGER trg_country_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.country
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 2. identity_type
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.identity_type
    RENAME COLUMN identity_type_dsc TO identity_type_desc;

ALTER TABLE virginia_dev_saayam_rdbms.identity_type
    RENAME COLUMN last_updated_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.identity_type
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

CREATE TRIGGER trg_identity_type_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.identity_type
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 3. request_priority
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.request_priority
    RENAME COLUMN last_updated_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.request_priority
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

CREATE TRIGGER trg_request_priority_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.request_priority
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 4. user_status
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.user_status
    RENAME COLUMN last_update_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.user_status
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

CREATE TRIGGER trg_user_status_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.user_status
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 5. user_category
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.user_category
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

CREATE TRIGGER trg_user_category_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.user_category
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 6. state
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.state
    RENAME COLUMN last_update_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.state
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

CREATE TRIGGER trg_state_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.state
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 7. city
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.city
    RENAME COLUMN last_update_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.city
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

-- Change state_id type from INT to VARCHAR(50)
ALTER TABLE virginia_dev_saayam_rdbms.city
    DROP CONSTRAINT IF EXISTS city_state_id_fkey;

ALTER TABLE virginia_dev_saayam_rdbms.city
    ALTER COLUMN state_id TYPE VARCHAR(50);

ALTER TABLE virginia_dev_saayam_rdbms.city
    ADD CONSTRAINT city_state_id_fkey
    FOREIGN KEY (state_id) REFERENCES virginia_dev_saayam_rdbms.state (state_id);

CREATE TRIGGER trg_city_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.city
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 8. supporting_languages
-- =============================================
ALTER TABLE virginia_dev_saayam_rdbms.supporting_languages
    RENAME COLUMN iso_639_1_code TO iso_code;

ALTER TABLE virginia_dev_saayam_rdbms.supporting_languages
    ALTER COLUMN created_at TYPE TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN created_at SET DEFAULT (now() AT TIME ZONE 'UTC'),
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

-- Drop old unqualified trigger and recreate with schema
DROP TRIGGER IF EXISTS trg_supporting_lang_updated_at
    ON virginia_dev_saayam_rdbms.supporting_languages;

CREATE TRIGGER trg_supporting_lang_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.supporting_languages
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- =============================================
-- 9. users
-- =============================================

-- Rename timestamp columns
ALTER TABLE virginia_dev_saayam_rdbms.users
    RENAME COLUMN last_update_date TO last_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.users
    RENAME COLUMN promotion_wizard_last_update_date TO promotion_wizard_last_updated_at;

-- Set defaults
ALTER TABLE virginia_dev_saayam_rdbms.users
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC'),
    ALTER COLUMN promotion_wizard_last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

-- Comment out user_category_id foreign key
ALTER TABLE virginia_dev_saayam_rdbms.users
    DROP CONSTRAINT IF EXISTS users_user_category_id_fkey;

ALTER TABLE virginia_dev_saayam_rdbms.users
    DROP COLUMN IF EXISTS user_category_id;

-- Change language columns from VARCHAR to BIGINT
ALTER TABLE virginia_dev_saayam_rdbms.users
    ALTER COLUMN language_1 TYPE BIGINT USING language_1::BIGINT,
    ALTER COLUMN language_2 TYPE BIGINT USING language_2::BIGINT,
    ALTER COLUMN language_3 TYPE BIGINT USING language_3::BIGINT;

-- Add foreign keys for language columns
ALTER TABLE virginia_dev_saayam_rdbms.users
    ADD CONSTRAINT users_language_1_fkey
    FOREIGN KEY (language_1) REFERENCES virginia_dev_saayam_rdbms.supporting_languages(language_id) ON DELETE SET NULL,
    ADD CONSTRAINT users_language_2_fkey
    FOREIGN KEY (language_2) REFERENCES virginia_dev_saayam_rdbms.supporting_languages(language_id) ON DELETE SET NULL,
    ADD CONSTRAINT users_language_3_fkey
    FOREIGN KEY (language_3) REFERENCES virginia_dev_saayam_rdbms.supporting_languages(language_id) ON DELETE SET NULL;

-- Add new columns
ALTER TABLE virginia_dev_saayam_rdbms.users
    ADD COLUMN IF NOT EXISTS external_auth_provider VARCHAR(20) NULL,
    ADD COLUMN IF NOT EXISTS dob DATE,
    ADD COLUMN IF NOT EXISTS is_eu BOOLEAN DEFAULT FALSE;

-- Add triggers
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.set_promo_wizard_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.promotion_wizard_last_updated_at IS DISTINCT FROM OLD.promotion_wizard_last_updated_at)
    THEN NEW.promotion_wizard_last_updated_at = (NOW() AT TIME ZONE 'UTC');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.users
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

CREATE TRIGGER trg_users_promo_wizard_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.users
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_promo_wizard_updated_at();

-- Update sequence
ALTER SEQUENCE virginia_dev_saayam_rdbms.user_id_seq
    RENAME TO user_id_seq_old;

CREATE SEQUENCE virginia_dev_saayam_rdbms.user_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 19999999999
    NO CYCLE;

-- Replace generate_sid()
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_sid()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    padded TEXT;
BEGIN
    seq_id := nextval('virginia_dev_saayam_rdbms.user_id_seq');
    padded := LPAD(seq_id::TEXT, 15, '0');
    NEW.user_id := 'SID-00-' ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 3) || '-' ||
        SUBSTRING(padded FROM 13 FOR 3);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP SEQUENCE IF EXISTS virginia_dev_saayam_rdbms.user_id_seq_old;

COMMIT;