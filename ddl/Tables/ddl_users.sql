-- =============================================
-- Virginia Users Table
-- Handles non-EU users only
-- Range: 1 to 19,999,999,999
-- =============================================

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.users (
    user_id VARCHAR(255) PRIMARY KEY,
    state_id VARCHAR(30) NULL,
    country_id INT NULL,
    user_status_id INT NULL,
    user_category_id INT NULL,
    full_name VARCHAR(255) NULL,
    first_name VARCHAR(255) NULL,
    middle_name VARCHAR(255) NULL,
    last_name VARCHAR(255) NULL,
    primary_email_address VARCHAR(255) NULL,
    primary_phone_number VARCHAR(255) NULL,
    addr_ln1 VARCHAR(255) NULL,
    addr_ln2 VARCHAR(255) NULL,
    addr_ln3 VARCHAR(255) NULL,
    city_name VARCHAR(255) NULL,
    zip_code VARCHAR(255) NULL,
    last_location POINT,
    last_update_date TIMESTAMP,
    time_zone VARCHAR(255) NULL,
    profile_picture_path VARCHAR(255) NULL,
    gender VARCHAR(255) NULL,
    language_1 VARCHAR(255) NULL,
    language_2 VARCHAR(255) NULL,
    language_3 VARCHAR(255) NULL,
    promotion_wizard_stage INT NULL,
    promotion_wizard_last_update_date TIMESTAMP,
    is_eu BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (country_id) REFERENCES virginia_dev_saayam_rdbms.country (country_id) ON DELETE SET NULL,
    FOREIGN KEY (state_id) REFERENCES virginia_dev_saayam_rdbms.state (state_id) ON DELETE SET NULL,
    FOREIGN KEY (user_status_id) REFERENCES virginia_dev_saayam_rdbms.user_status (user_status_id),
    FOREIGN KEY (user_category_id) REFERENCES virginia_dev_saayam_rdbms.user_category (user_category_id) ON DELETE SET NULL
);
-- Example: last_location (37.3382, -121.8863) for San Jose

-- Non-EU users: 1 to 19,999,999,999
CREATE SEQUENCE virginia_dev_saayam_rdbms.user_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 19999999999
    NO CYCLE;

-- =============================================
-- generate_sid() — SUBSTRING approach
-- Always generates SID-00-XXX-XXX-XXX-XXX-XXX
-- No is_eu branching needed — Virginia is
-- non-EU only
-- =============================================
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

CREATE TRIGGER before_insert_users
BEFORE INSERT ON virginia_dev_saayam_rdbms.users
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_sid();