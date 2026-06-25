-- Table: users (Main table for user details)
-- NOTE: Sequences user_id_seq and user_id_seq_eu_dr are created in
-- migrate_virginia_users.sql and carry forward their state.
-- Do not recreate them here as it will reset the counter and cause ID collisions.

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.users (
    user_id VARCHAR(25) PRIMARY KEY,
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

CREATE TRIGGER before_insert_users
BEFORE INSERT ON virginia_dev_saayam_rdbms.users
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_sid();