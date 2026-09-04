-- PostgreSQL Script adapted for Ireland Region
-- User ID Generation, New columns in User Table 
-- Renaming tables with their attributes: region for better understanding
-- Changes in Table: volunteer_organizations 
-- Added WHEN clause to migrate data with existing IDs

-- CREATE EXTENSION postgis;

-- Drop schema if it exists
--DROP SCHEMA IF EXISTS proposed_saayam CASCADE;

-- Create schema
--CREATE SCHEMA IF NOT EXISTS proposed_saayam;

-- Set schema for following operations
-- SET search_path TO proposed_saayam;

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

GRANT pg_read_all_stats TO dbadmin_user;
GRANT pg_monitor TO dbadmin_user;

-- Keep updated_at fresh
CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Table: action # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ACTION CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.action (
    action_id SERIAL PRIMARY KEY,
    action_desc VARCHAR(30) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    created_by VARCHAR(30),
    last_update_by VARCHAR(30),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (action_id)
);
--DROP TRIGGER IF EXISTS trg_action_updated_at ON ireland_dev_saayam_rdbms.action;
CREATE TRIGGER trg_action_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.action
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: country # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS country CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    phone_code VARCHAR(5) NOT NULL,
    country_code VARCHAR(6) NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    is_eu_member BOOLEAN DEFAULT FALSE,
    UNIQUE (country_id)
);
--DROP TRIGGER IF EXISTS trg_country_updated_at ON ireland_dev_saayam_rdbms.country;
CREATE TRIGGER trg_country_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.country
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: identity_type # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS identity_type CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.identity_type (
    identity_type_id SERIAL PRIMARY KEY,
    identity_value VARCHAR(255) NOT NULL,
    identity_type_desc VARCHAR(255),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (identity_type_id)
);
--DROP TRIGGER IF EXISTS trg_identity_type_updated_at ON ireland_dev_saayam_rdbms.identity_type;
CREATE TRIGGER trg_identity_type_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.identity_type
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: request_priority # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS request_priority CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.request_priority (
    req_priority_id SERIAL PRIMARY KEY,
    req_priority VARCHAR(25) NOT NULL,
    req_priority_desc VARCHAR(125),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (req_priority_id)
);
--DROP TRIGGER IF EXISTS trg_request_priority_updated_at ON ireland_dev_saayam_rdbms.request_priority;
CREATE TRIGGER trg_request_priority_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_priority
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: user_status # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS user_status CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_status (
    user_status_id SERIAL PRIMARY KEY,
    user_status VARCHAR(255) NOT NULL,
    user_status_desc VARCHAR(255),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (user_status_id)
);

--DROP TRIGGER IF EXISTS trg_user_status_updated_at ON ireland_dev_saayam_rdbms.user_status;
CREATE TRIGGER trg_user_status_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_status
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: user_category # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS user_category CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_category (
user_category_id SERIAL PRIMARY KEY,
user_category VARCHAR(255) NOT NULL,
user_category_desc VARCHAR(255),
user_access_level SMALLINT, -- Permission hierarchy
category_code VARCHAR(50) UNIQUE, -- Short code, made UNIQUE for data integrity
is_deprecated BOOLEAN DEFAULT FALSE, -- Enable/disable flag
permissions JSONB, -- Stores granular permissions in JSON format
last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);
--DROP TRIGGER IF EXISTS trg_user_category_updated_at ON ireland_dev_saayam_rdbms.user_category;
CREATE TRIGGER trg_user_category_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_category
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: state # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS state CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.state (
    state_id VARCHAR(50) PRIMARY KEY,
    country_id INT NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(6),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (country_id) REFERENCES ireland_dev_saayam_rdbms.country (country_id)
);
--DROP TRIGGER IF EXISTS trg_state_updated_at ON ireland_dev_saayam_rdbms.state;
CREATE TRIGGER trg_state_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.state
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: city # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS city CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.city (
    city_id SERIAL PRIMARY KEY,
    state_id VARCHAR(50) NOT NULL,
    city_name VARCHAR(30) NOT NULL, 
    lattitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (city_id),
    FOREIGN KEY (state_id) REFERENCES ireland_dev_saayam_rdbms.state (state_id)
);
-- DROP TRIGGER IF EXISTS trg_city_updated_at ON ireland_dev_saayam_rdbms.city;
CREATE TRIGGER trg_city_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.city
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: supporting_languages   # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS supporting_languages CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.supporting_languages (
    language_id       BIGSERIAL PRIMARY KEY,
    language_name     VARCHAR(64)  NOT NULL,
    iso_code CHAR(2) NOT NULL,                 -- e.g., en, zh, hi
    locale_code       VARCHAR(10)  NOT NULL,                 -- e.g., en_US, zh_CN
    writing_direction VARCHAR(3)   NOT NULL DEFAULT 'LTR',   -- 'LTR' or 'RTL'
    total_speakers_m  NUMERIC(10,1),                         -- millions (optional)
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    CONSTRAINT uq_lang_unique UNIQUE (iso_code, locale_code),
    CONSTRAINT ck_direction CHECK (writing_direction IN ('LTR','RTL')),
    CONSTRAINT ck_iso6391 CHECK (iso_code ~ '^[A-Za-z]{2}$'),
    CONSTRAINT ck_locale CHECK (locale_code ~ '^[a-z]{2}_[A-Z]{2}$')
);

CREATE INDEX IF NOT EXISTS ix_supporting_languages_name
    ON ireland_dev_saayam_rdbms.supporting_languages (language_name);
-- DROP TRIGGER IF EXISTS trg_supporting_lang_updated_at ON ireland_dev_saayam_rdbms.supporting_languages;
CREATE TRIGGER trg_supporting_lang_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.supporting_languages
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: users # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS users CASCADE;

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.set_promo_wizard_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.promotion_wizard_last_updated_at IS DISTINCT FROM OLD.promotion_wizard_last_updated_at)
  THEN NEW.promotion_wizard_last_updated_at = (NOW() AT TIME ZONE 'UTC');
  END IF;
  RETURN NEW;
END ;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.users (
    user_id VARCHAR(255) PRIMARY KEY,
    state_id VARCHAR(30) NULL,
    country_id INT NULL,
    user_status_id INT NULL,
    -- user_category_id INT NULL,
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
    last_location point,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    time_zone VARCHAR(255) NULL,
    profile_picture_path VARCHAR(255) NULL,
    gender VARCHAR(255) NULL,
    language_1 BIGINT NULL,
    language_2 BIGINT NULL,
    language_3 BIGINT NULL,
    promotion_wizard_stage INT NULL,
    promotion_wizard_last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    external_auth_provider VARCHAR(20) NULL,
    dob date,
    is_eu BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (country_id) REFERENCES ireland_dev_saayam_rdbms.country (country_id) ON DELETE SET NULL,
    FOREIGN KEY (state_id) REFERENCES ireland_dev_saayam_rdbms.state (state_id) ON DELETE SET NULL,
    FOREIGN KEY (user_status_id) REFERENCES ireland_dev_saayam_rdbms.user_status (user_status_id),
    -- FOREIGN KEY (user_category_id) REFERENCES ireland_dev_saayam_rdbms.user_category (user_category_id) ON DELETE SET NULL,
	FOREIGN KEY (language_1) REFERENCES ireland_dev_saayam_rdbms.supporting_languages(language_id) ON DELETE SET NULL,
	FOREIGN KEY (language_2) REFERENCES ireland_dev_saayam_rdbms.supporting_languages(language_id) ON DELETE SET NULL,
	FOREIGN KEY (language_3) REFERENCES ireland_dev_saayam_rdbms.supporting_languages(language_id) ON DELETE SET NULL
);

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.users
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

CREATE TRIGGER trg_users_promo_wizard_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.users
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_promo_wizard_updated_at();

-- Sequence generator for Users # Updated as on 09/03/2026

CREATE SEQUENCE ireland_dev_saayam_rdbms.user_id_eu_seq
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

CREATE TRIGGER before_insert_users
BEFORE INSERT ON ireland_dev_saayam_rdbms.users
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_sid();




-- Table: user_additional_details  # Updated as on 05/21/2026
--DROP TABLE IF EXISTS user_additional_details CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_additional_details (
    additional_detail_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    secondary_email_1 VARCHAR(255) NULL,
    secondary_email_2 VARCHAR(255) NULL,
    secondary_phone_1 VARCHAR(255) NULL,
    secondary_phone_2 VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.updated_at_handler()
RETURNS TRIGGER AS $$
BEGIN
    -- check if the last_updated_at was explicitly changed in the UPDATE statement.
    -- if it WASN'T changed by the API, we force it to the current UTC.
    IF (NEW.last_updated_at IS NOT DISTINCT FROM OLD.last_updated_at) THEN
        NEW.last_updated_at = (now() AT TIME ZONE 'UTC');
    END IF;

    -- handle application table 
    IF (TG_TABLE_NAME = 'volunteer_applications') THEN
        -- Update path timestamp if path changed
        IF (NEW.govt_id_path IS DISTINCT FROM OLD.govt_id_path) THEN
            NEW.path_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;

        -- Update terms timestamp if accepted
        IF (NEW.terms_and_conditions IS TRUE AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;

    -- handle details table 
    ELSIF (TG_TABLE_NAME = 'volunteer_details') THEN
        -- update path1 timestamp if changed
        IF (NEW.govt_id_path1 IS DISTINCT FROM OLD.govt_id_path1) THEN
            NEW.path1_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        
        -- update path2 timestamp if changed
        IF (NEW.govt_id_path2 IS DISTINCT FROM OLD.govt_id_path2) THEN
            NEW.path2_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;

        -- update terms timestamp if accepted
        IF (NEW.terms_and_conditions IS TRUE AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Table: volunteer_details # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS volunteer_details CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteer_details (
    user_id VARCHAR(255) PRIMARY KEY,
    terms_and_conditions BOOLEAN,
    terms_accepted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    govt_id_path1 TEXT,
    govt_id_path2 TEXT,
    path1_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    path2_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    availability_days JSONB,
    availability_times JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'), 
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id) 
);

CREATE TRIGGER trg_volunteer_details_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteer_details
    FOR EACH ROW EXECUTE FUNCTION ireland_dev_saayam_rdbms.updated_at_handler();

-- Index for searching specific days (e.g., 'Monday')
CREATE INDEX idx_volunteer_availability_days 
ON ireland_dev_saayam_rdbms.volunteer_details USING GIN (availability_days);

-- Index for searching specific time slots
CREATE INDEX idx_volunteer_availability_times 
ON ireland_dev_saayam_rdbms.volunteer_details USING GIN (availability_times);

-- Table: user_volunteer_skills
/* CREATE TABLE IF NOT EXISTS user_volunteer_skills (
    skills JSONB
); */

-- Table: request_status # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS request_status CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.request_status (
    req_status_id SERIAL PRIMARY KEY,
    req_status VARCHAR(25) NOT NULL,
    req_status_desc VARCHAR(125),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);
-- DROP TRIGGER IF EXISTS trg_request_status_updated_at ON ireland_dev_saayam_rdbms.request_status;
CREATE TRIGGER trg_request_status_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_status
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: request_type # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS request_type CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.request_type (
    req_type_id SERIAL PRIMARY KEY,
    req_type VARCHAR(25),
    req_type_desc VARCHAR(125),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);
-- DROP TRIGGER IF EXISTS trg_request_status_updated_at ON ireland_dev_saayam_rdbms.request_status;
CREATE TRIGGER trg_request_type_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_type
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: request_category 
/* CREATE TABLE IF NOT EXISTS request_category (
    request_category_id SERIAL PRIMARY KEY,
    request_category VARCHAR(255) NOT NULL,
    request_category_desc VARCHAR(255),
    last_updated_date TIMESTAMP
); */

-- Table: request_for # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS request_for CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.request_for (
    req_for_id SERIAL PRIMARY KEY,
    req_for VARCHAR(25) NOT NULL,
    req_for_desc VARCHAR(125), --15words7charlength
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);
-- DROP TRIGGER IF EXISTS trg_request_for_updated_at ON ireland_dev_saayam_rdbms.request_for;
CREATE TRIGGER trg_request_for_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_for
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Request_isleadvol # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.request_isleadvol CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.request_isleadvol (
    req_islead_id SERIAL PRIMARY KEY,
    req_islead VARCHAR(15) NOT NULL,  
    req_islead_desc VARCHAR(100), 
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);
-- DROP TRIGGER IF EXISTS trg_request_isleadvol_updated_at ON ireland_dev_saayam_rdbms.request_isleadvol;
CREATE TRIGGER trg_request_isleadvol_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_isleadvol
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Help Categories # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS help_categories CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.help_categories (
    cat_id VARCHAR(50) PRIMARY KEY,           -- e.g., '1', '1.1', '1.1.1'
    cat_name VARCHAR(100) NOT NULL,                    -- string_key, e.g., 'DONATE_CLOTHES'
    cat_desc VARCHAR(150) NOT NULL,                     -- purpose or goal of the category
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TRIGGER trg_help_categories_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.help_categories
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: Help Category Map # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.help_category_map CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.help_category_map (
    parent_id VARCHAR(50),
    child_id VARCHAR(50) PRIMARY KEY, --one parent multiple child
    FOREIGN KEY (parent_id) REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id),
    FOREIGN KEY (child_id) REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')

);

CREATE TRIGGER trg_help_category_map_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.help_category_map
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

-- Table: Req_Add_Info_MetaData # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.req_add_info_metadata CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.req_add_info_metadata(
    field_id VARCHAR(70) PRIMARY KEY,                         --  primary key
    field_name_key VARCHAR(100),
    field_type VARCHAR(20),                                   -- examples: 'string', 'int', 'float', 'list'
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),  -- Fixed syntax
    cat_id VARCHAR(50),                                       
    FOREIGN KEY (cat_id) REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id)
);

-- Table: List Item Meta_Data  # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.list_item_metadata CASCADE;
CREATE TABLE ireland_dev_saayam_rdbms.list_item_metadata (
    item_id VARCHAR(100) PRIMARY KEY,
    field_id VARCHAR(70),
    item_value VARCHAR(100),
    item_type VARCHAR(20),  --examples: 'string', 'int', 'range', 'currency'
    FOREIGN KEY (field_id) REFERENCES ireland_dev_saayam_rdbms.req_add_info_metadata(field_id)
);

-- Table: request # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.request CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.request (
    req_id VARCHAR(255) PRIMARY KEY,
    req_user_id VARCHAR(255) NOT NULL,
	req_for_id INT NOT NULL,
	req_islead_id INT NOT NULL,
    req_cat_id VARCHAR(50) NOT NULL,
    req_type_id INT NOT NULL,
    req_priority_id INT NOT NULL,
    req_status_id INT NOT NULL,
	req_loc VARCHAR(125),
	iscalamity BOOLEAN,
	req_subj VARCHAR(125) NOT NULL,
    req_desc VARCHAR(255) NOT NULL,
	req_doc_link TEXT,
	audio_req_desc VARCHAR(255),
    submission_date TIMESTAMP,
    serviced_date TIMESTAMP, 						
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
	to_public BOOLEAN,
    UNIQUE (req_id),
    FOREIGN KEY (req_user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id),
    FOREIGN KEY (req_status_id) REFERENCES ireland_dev_saayam_rdbms.request_status (req_status_id),
    FOREIGN KEY (req_priority_id) REFERENCES ireland_dev_saayam_rdbms.request_priority (req_priority_id),
    FOREIGN KEY (req_type_id) REFERENCES ireland_dev_saayam_rdbms.request_type (req_type_id),
    FOREIGN KEY (req_cat_id) REFERENCES ireland_dev_saayam_rdbms.help_categories (cat_id),
    FOREIGN KEY (req_for_id) REFERENCES ireland_dev_saayam_rdbms.request_for (req_for_id),
	FOREIGN KEY (req_islead_id) REFERENCES ireland_dev_saayam_rdbms.request_isleadvol (req_islead_id)
);

-- Create the sequence for request IDs
CREATE SEQUENCE ireland_dev_saayam_rdbms.request_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

-- Create the function to generate the formatted request ID
CREATE FUNCTION ireland_dev_saayam_rdbms.generate_request_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id INT;
    new_id TEXT;
BEGIN
    seq_id := nextval('request_id_seq');
    new_id := 'REQ-' || LPAD(FLOOR(seq_id / 100000000)::TEXT, 2, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000000) / 100000)::TEXT, 3, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000) / 1000)::TEXT, 3, '0') || '-' || 
              LPAD((seq_id % 1000)::TEXT, 4, '0');
    NEW.req_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER before_insert_requests
BEFORE INSERT ON ireland_dev_saayam_rdbms.request
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_request_id();

-- DROP TRIGGER IF EXISTS trg_request_updated_at ON ireland_dev_saayam_rdbms.request;
CREATE TRIGGER trg_request_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: sentiment_codes # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS sentiment_codes CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.sentiment_codes (
    code INT PRIMARY KEY, -- 0, 1, 2, 3
    label VARCHAR(50)     NOT NULL, -- short human-readable name
    description VARCHAR(255)    NOT NULL -- what this code means
);

-- Seed data — the four known sentiment classifications
INSERT INTO ireland_dev_saayam_rdbms.sentiment_codes
    (code, label, description)
VALUES
    (0,   'Good Request',        'Request is clean, no harmful or negative content detected.'),
    (1,   'Foul Language',       'Request contains offensive or foul language.'),
    (2,   'Depressive or Suicidal', 'Request contains depressive or suicidal language.'),
    (3,   'Threatening',         'Request contains threatening language or references to weapons.');

-- Table: fraud_requests # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.fraud_requests CASCADE;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.fraud_requests (
    req_id VARCHAR(255) PRIMARY KEY,
    req_user_id VARCHAR(255) NOT NULL,
    req_for_id INT NOT NULL,
    req_islead_id INT NOT NULL,
    req_cat_id VARCHAR(50) NOT NULL,
    req_type_id INT NOT NULL,
    req_priority_id INT NOT NULL,
    req_status_id INT NOT NULL,
    req_loc VARCHAR(125),
    iscalamity BOOLEAN,
    req_subj VARCHAR(125) NOT NULL,
    req_desc VARCHAR(255) NOT NULL,
    req_doc_link TEXT,
    audio_req_desc VARCHAR(255),
    submission_date TIMESTAMP,
    serviced_date TIMESTAMP,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
	to_public BOOLEAN,
    ref_code INT NOT NULL,
    FOREIGN KEY (ref_code) REFERENCES ireland_dev_saayam_rdbms.sentiment_codes(code)
);

-- DROP TRIGGER IF EXISTS trg_fraud_requests_updated_at ON ireland_dev_saayam_rdbms.fraud_requests;
CREATE TRIGGER trg_fraud_requests_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.fraud_requests
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: volunteers_assigned # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS volunteers_assigned CASCADE;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteers_assigned (
    vol_assigned_id SERIAL PRIMARY KEY,
    req_id VARCHAR(255) NOT NULL,
    volunteer_id VARCHAR(255) NOT NULL,
    volunteer_type VARCHAR(255) NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (req_id) REFERENCES ireland_dev_saayam_rdbms.request (req_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
-- DROP TRIGGER IF EXISTS trg_volunteers_assigned_updated_at ON ireland_dev_saayam_rdbms.volunteers_assigned;
CREATE TRIGGER trg_volunteers_assigned_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteers_assigned
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: comments # Table no longer present in Virginia 
/* CREATE TABLE IF NOT EXISTS comments (
    comment_id SERIAL PRIMARY KEY,
    req_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    comment_desc TEXT NOT NULL,
    comment_date TIMESTAMP NOT NULL,
    FOREIGN KEY (req_id) REFERENCES request (req_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS fk_comments_request_id_idx ON comments (req_id);
CREATE INDEX IF NOT EXISTS fk_comments_user_id_idx ON comments (user_id); */

-- Table: volunteer_organizations  # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS volunteer_organizations CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteer_organizations (
    volunteer_organization_id SERIAL PRIMARY KEY,
    contact_id VARCHAR(255) NOT NULL,
    city_name VARCHAR(255) NOT NULL,
    addr_ln1 VARCHAR(255) NULL,
    addr_ln2 VARCHAR(255) NULL,
    addr_ln3 VARCHAR(255) NULL,
    zip_code VARCHAR(255) NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    time_zone VARCHAR(255) NULL,
    FOREIGN KEY (contact_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: notification_channels  # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.notification_channels CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.notification_channels (
    channel_id SERIAL PRIMARY KEY,
    channel_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- Table: notification_types  # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.notification_types CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.notification_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

CREATE TYPE ireland_dev_saayam_rdbms.status_type AS ENUM('unread', 'read');
-- Table: notifications   # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS notifications CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    type_id INT NOT NULL,
    channel_id INT NOT NULL,
    message TEXT NOT NULL,
    status ireland_dev_saayam_rdbms.status_type,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type_id) REFERENCES ireland_dev_saayam_rdbms.notification_types (type_id),
    FOREIGN KEY (channel_id) REFERENCES ireland_dev_saayam_rdbms.notification_channels (channel_id)
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON ireland_dev_saayam_rdbms.notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON ireland_dev_saayam_rdbms.notifications (status);
CREATE INDEX IF NOT EXISTS idx_notifications_type_id ON ireland_dev_saayam_rdbms.notifications (type_id);
CREATE INDEX IF NOT EXISTS idx_notifications_channel_id ON ireland_dev_saayam_rdbms.notifications (channel_id);

-- DROP TRIGGER IF EXISTS trg_notifications_updated_at ON ireland_dev_saayam_rdbms.notifications;
CREATE TRIGGER trg_notifications_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.notifications
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

CREATE TYPE ireland_dev_saayam_rdbms.preference_type AS ENUM('email', 'text', 'both');
-- Table: user_notification_preferences  # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.user_notification_preferences CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_notification_preferences (
    user_notification_preferences_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    channel_id INT NOT NULL,
    preference ireland_dev_saayam_rdbms.preference_type,
	last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id),
    FOREIGN KEY (channel_id) REFERENCES ireland_dev_saayam_rdbms.notification_channels (channel_id)
);

-- DROP TRIGGER IF EXISTS trg_user_notification_preferences_updated_at ON ireland_dev_saayam_rdbms.user_notification_preferences;
CREATE TRIGGER trg_user_notification_preferences_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_notification_preferences
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: skill_list  # Table not present in Virginia
/* CREATE TABLE IF NOT EXISTS skill_list (
    skill_list_id SERIAL PRIMARY KEY,
    request_category_id INT NOT NULL,
    skill_desc VARCHAR(100) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (skill_list_id),
    FOREIGN KEY (request_category_id) REFERENCES request_category (request_category_id)
); */

-- Table: sla # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.sla CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.sla (
    sla_id SERIAL PRIMARY KEY,
    sla_hours INT NOT NULL,
    sla_description VARCHAR(255) NOT NULL,
    no_of_cust_impct INT,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (sla_id)
);

-- DROP TRIGGER IF EXISTS trg_sla_updated_at ON ireland_dev_saayam_rdbms.sla;
CREATE TRIGGER trg_sla_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.sla
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

CREATE TYPE ireland_dev_saayam_rdbms.skill_levels AS ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT');
-- Table: user_skills # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS user_skills CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_skills (
    user_id VARCHAR(255),
    cat_id VARCHAR(50) NOT NULL,
	skill_level ireland_dev_saayam_rdbms.skill_levels,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    PRIMARY KEY (user_id, cat_id),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users(user_id),
    FOREIGN KEY (cat_id) REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id)
);

-- DROP TRIGGER IF EXISTS trg_user_skills_updated_at ON ireland_dev_saayam_rdbms.user_skills;
CREATE TRIGGER trg_user_skills_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_skills
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

CREATE INDEX idx_user_skills_cat_id  ON ireland_dev_saayam_rdbms.user_skills (cat_id);


CREATE TYPE ireland_dev_saayam_rdbms.rating_enum AS ENUM ('0', '1', '2', '3', '4', '5');
-- Table: volunteer_rating # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS volunteer_rating CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteer_rating (
    volunteer_rating_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    req_id VARCHAR(255) NOT NULL,
    rating ireland_dev_saayam_rdbms.rating_enum NOT NULL,
    feedback TEXT,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (req_id) REFERENCES ireland_dev_saayam_rdbms.request (req_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_volunteer_rating_user_id ON ireland_dev_saayam_rdbms.volunteer_rating (user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_rating_req_id ON ireland_dev_saayam_rdbms.volunteer_rating (req_id);

-- DROP TRIGGER IF EXISTS trg_volunteer_rating_updated_at ON ireland_dev_saayam_rdbms.volunteer_rating;
CREATE TRIGGER trg_volunteer_rating_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteer_rating
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: user_availability # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.user_availability CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_availability (
    user_availability_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    day_of_week VARCHAR(10) CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id)
);
CREATE INDEX IF NOT EXISTS idx_user_availability_user_id ON ireland_dev_saayam_rdbms.user_availability (user_id);

-- DROP TRIGGER IF EXISTS trg_user_availability_updated_at ON ireland_dev_saayam_rdbms.user_availability;
CREATE TRIGGER trg_user_availability_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_availability
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: Emergency Numbers # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.emergency_numbers CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.emergency_numbers(    
    en_id SERIAL PRIMARY KEY,       
    country_id INT NULL,              
    state_id VARCHAR(50) NULL,             
    en_name VARCHAR(100) NOT NULL UNIQUE,
    is_country BOOLEAN NOT NULL,
    police VARCHAR(75) NULL,
    ambulance VARCHAR(75) NULL,
    fire VARCHAR(75) NULL,
    non_emergency_police VARCHAR(75) NULL,
    cyber_police VARCHAR(75) NULL,
    medicare_support VARCHAR(75) NULL,
    gas_leak VARCHAR(75) NULL,
    electricity_outage VARCHAR(75) NULL,
    water_department VARCHAR(75) NULL,
    disaster_recovery VARCHAR(75) NULL,             
    flood_help VARCHAR(75) NULL,
    earthquake_info VARCHAR(75) NULL,
    hurricane_info VARCHAR(75) NULL,
    emergency_mgmt VARCHAR(75) NULL,
    environmental_hazards VARCHAR(75) NULL,
    transportation_assistance VARCHAR(75) NULL,
    roadside_assistance VARCHAR(75) NULL,
    highway_patrol VARCHAR(75) NULL,
    suicide VARCHAR(75) NULL,                      
    help_women VARCHAR(75) NULL,
    child_abuse VARCHAR(75) NULL,
    domestic_abuse VARCHAR(75) NULL,
    mental_health VARCHAR(75) NULL,
    elderly_abuse VARCHAR(75) NULL,           
    poison_control VARCHAR(75) NULL,      
    animal_control VARCHAR(75) NULL,
    wildlife_rescue VARCHAR(75) NULL,
    homeless_services VARCHAR(75) NULL,
    food_assistance VARCHAR(75) NULL,
	last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (country_id) REFERENCES ireland_dev_saayam_rdbms.country (country_id),
    FOREIGN KEY (state_id) REFERENCES ireland_dev_saayam_rdbms.state (state_id)
     );

-- DROP TRIGGER IF EXISTS trg_emergency_numbers_updated_at ON ireland_dev_saayam_rdbms.emergency_numbers;
CREATE TRIGGER trg_emergency_numbers_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.emergency_numbers
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();


-- Table: Organizations # Updated as on 05/21/2026
-- Create ENUM types
CREATE TYPE ireland_dev_saayam_rdbms.org_type_enum AS ENUM ('non_profit', 'for_profit');
CREATE TYPE ireland_dev_saayam_rdbms.org_size_enum AS ENUM ('small', 'medium', 'large');
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.organizations CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.organizations (
  org_id VARCHAR(255) PRIMARY KEY,
  org_name VARCHAR(125) NOT NULL,
  street VARCHAR(255),
  city_name VARCHAR(100),
  state_id VARCHAR(50),
  zip_code VARCHAR(10),
  mission TEXT,
  web_url VARCHAR(255) CHECK (web_url IS NULL OR web_url LIKE 'http%'),
  phone VARCHAR(20),
  email VARCHAR(255) CHECK (email IS NULL OR email LIKE '%@%'),
  org_type ireland_dev_saayam_rdbms.org_type_enum,
  org_size ireland_dev_saayam_rdbms.org_size_enum,
  org_rating INTEGER CHECK (org_rating >= 1 AND org_rating <= 5),
  is_collaborator BOOLEAN,
  is_contributor BOOLEAN,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
  last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),  
  FOREIGN KEY (state_id) REFERENCES ireland_dev_saayam_rdbms.state(state_id) ON DELETE SET NULL
);

-- DROP TRIGGER IF EXISTS trg_organizations_updated_at ON ireland_dev_saayam_rdbms.organizations;
CREATE TRIGGER trg_organizations_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.organizations
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Indexes
CREATE INDEX idx_org_name ON ireland_dev_saayam_rdbms.organizations(org_name);
CREATE INDEX idx_org_state_id ON ireland_dev_saayam_rdbms.organizations(state_id);
CREATE INDEX idx_org_city_state ON ireland_dev_saayam_rdbms.organizations(city_name, state_id);

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_org_id()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    seq_id INT;
    new_id VARCHAR(20);
BEGIN
    seq_id := nextval('org_id_seq');
    new_id := 'ORG-00-' || LPAD(FLOOR(seq_id / 1000000)::TEXT, 3, '0') || '-' || 
              LPAD(FLOOR((seq_id % 1000000) / 1000)::TEXT, 3, '0') || '-' || 
              LPAD((seq_id % 1000)::TEXT, 3, '0');
    NEW.org_id := new_id;
    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER before_insert_organizations
    BEFORE INSERT
    ON ireland_dev_saayam_rdbms.organizations
    FOR EACH ROW
    EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_org_id();

-- Table: Req_Add_Info # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.req_add_info CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.req_add_info (
    info_id               SERIAL         PRIMARY KEY,       
    req_id           VARCHAR(255)   NOT NULL,
    field_id         VARCHAR(70)    NOT NULL,
    item_id          VARCHAR(100)   NULL,               -- FK to list_item_metadata (list-type fields)
    field_value VARCHAR(255)   NULL,
	last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),  -- for string/int/float type fields
    UNIQUE (req_id, field_id, item_id),                 -- prevents duplicate answers
    FOREIGN KEY (req_id)   REFERENCES ireland_dev_saayam_rdbms.request(req_id),
    FOREIGN KEY (field_id) REFERENCES ireland_dev_saayam_rdbms.req_add_info_metadata(field_id),
    FOREIGN KEY (item_id)  REFERENCES ireland_dev_saayam_rdbms.list_item_metadata(item_id)  
);
-- DROP TRIGGER IF EXISTS trg_req_add_info_updated_at ON ireland_dev_saayam_rdbms.req_add_info;
CREATE TRIGGER trg_req_add_info_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.req_add_info
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: Request_Other_Details # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.request_other_details CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.request_other_details (
    -- The primary key is the foreign key to the request table (one-to-one relationship)
    req_id VARCHAR(255) PRIMARY KEY,
    req_fname VARCHAR(100),
    req_lname VARCHAR(100),
    req_email VARCHAR(100),
    req_phone VARCHAR(20),
    req_age INT,
    req_gender VARCHAR(50),
    req_pref_lang VARCHAR(50),
	last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (req_id) REFERENCES ireland_dev_saayam_rdbms.request (req_id) ON DELETE CASCADE
);

-- DROP TRIGGER IF EXISTS trg_request_other_details_updated_at ON ireland_dev_saayam_rdbms.request_other_details;
CREATE TRIGGER trg_request_other_details_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request_other_details
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: User Locations # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.user_locations CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_locations (
    user_id VARCHAR(255) NOT NULL PRIMARY KEY,
    prev_loc geography(Point, 4326),
    curr_loc geography(Point, 4326),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    CONSTRAINT user_locations_user_fk
        FOREIGN KEY (user_id)
        REFERENCES ireland_dev_saayam_rdbms.users (user_id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_locations_curr_gist
    ON ireland_dev_saayam_rdbms.user_locations USING GIST (curr_loc); 
CREATE INDEX IF NOT EXISTS idx_user_locations_prev_gist
    ON ireland_dev_saayam_rdbms.user_locations USING GIST (prev_loc);

-- DROP TRIGGER IF EXISTS trg_user_locations_updated_at ON ireland_dev_saayam_rdbms.user_locations;
CREATE TRIGGER trg_user_locations_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_locations
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.fn_shift_prev_loc_user() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.curr_loc IS DISTINCT FROM OLD.curr_loc THEN
        NEW.prev_loc := OLD.curr_loc; 
        NEW.last_updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;

--DROP TRIGGER IF EXISTS trg_shift_prev_loc_user ON ireland_dev_saayam_rdbms.user_locations; 
CREATE TRIGGER trg_shift_prev_loc_user
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_locations 
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.fn_shift_prev_loc_user();

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.fn_locations_insert_as_upsert_user() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$ 
DECLARE 
    k BIGINT;
BEGIN
    k := hashtextextended(NEW.user_id, 0);
    PERFORM pg_advisory_xact_lock(k);
    
    UPDATE user_locations l
       SET curr_loc = NEW.curr_loc 
    WHERE l.user_id = NEW.user_id;
    
    IF FOUND THEN
        RETURN NULL;
    END IF;
    
    RETURN NEW;
END;
$$;

-- DROP TRIGGER IF EXISTS trg_locations_insert_as_upsert_user ON user_locations; 
CREATE TRIGGER trg_locations_insert_as_upsert_user
BEFORE INSERT ON ireland_dev_saayam_rdbms.user_locations 
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.fn_locations_insert_as_upsert_user(); 

-- Table: User_Notification_Status # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.user_notification_status CASCADE;
CREATE TABLE ireland_dev_saayam_rdbms.user_notification_status (
    user_id VARCHAR(255) PRIMARY KEY,
    last_accessed_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users(user_id) ON DELETE CASCADE
);

-- Table: User_org_map  # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.user_org_map CASCADE;
CREATE TABLE ireland_dev_saayam_rdbms.user_org_map (
    user_id VARCHAR(255) NOT NULL,
    org_id VARCHAR(255) NOT NULL,
    user_role VARCHAR(50),        -- e.g. 'ADMIN', 'STAFF', 'VOLUNTEER'
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    CONSTRAINT user_org_map_pk PRIMARY KEY (user_id, org_id),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES ireland_dev_saayam_rdbms.organizations(org_id) ON DELETE CASCADE
);
-- DROP TRIGGER IF EXISTS trg_user_org_map_updated_at ON ireland_dev_saayam_rdbms.user_org_map;
CREATE TRIGGER trg_user_org_map_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_org_map
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: User Sign_Off # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.user_signoff CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_signoff (
	signoff_id SERIAL PRIMARY KEY,
    reason VARCHAR(250),
	is_external_auth BOOLEAN,
	last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);
-- DROP TRIGGER IF EXISTS trg_user_signoff_updated_at ON ireland_dev_saayam_rdbms.user_signoff;
CREATE TRIGGER trg_user_signoff_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_signoff
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: Volunteer locations table # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.volunteer_locations CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteer_locations (
    user_id VARCHAR(255) NOT NULL PRIMARY KEY, 
    prev_loc geography(Point, 4326),
    curr_loc geography(Point, 4326),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    CONSTRAINT volunteer_locations_user_fk
        FOREIGN KEY (user_id)
        REFERENCES ireland_dev_saayam_rdbms.volunteer_details (user_id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_volunteer_locations_curr_gist
    ON ireland_dev_saayam_rdbms.volunteer_locations USING GIST (curr_loc); 
CREATE INDEX IF NOT EXISTS idx_volunteer_locations_prev_gist
    ON ireland_dev_saayam_rdbms.volunteer_locations USING GIST (prev_loc);

-- DROP TRIGGER IF EXISTS trg_volunteer_locations_updated_at ON ireland_dev_saayam_rdbms.volunteer_locations;
CREATE TRIGGER trg_volunteer_locations_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteer_locations
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Trigger function to shift old curr_loc -> prev_loc on update
CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.fn_shift_prev_loc_volunteer() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.curr_loc IS DISTINCT FROM OLD.curr_loc THEN
        NEW.prev_loc := OLD.curr_loc; 
        NEW.last_updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;

-- DROP TRIGGER IF EXISTS trg_shift_prev_loc_volunteer ON ireland_dev_saayam_rdbms.volunteer_locations; 
CREATE TRIGGER trg_shift_prev_loc_volunteer
BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteer_locations 
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.fn_shift_prev_loc_volunteer();

-- Trigger function for INSERT upsert behavior

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.fn_locations_insert_as_upsert_volunteer() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$ 
DECLARE 
    k BIGINT;
BEGIN
    -- Serialize concurrent inserts for the same user
    k := hashtextextended(NEW.user_id, 0);
    PERFORM pg_advisory_xact_lock(k);
    
    -- If row exists, UPDATE only curr_loc (shift handled by BEFORE UPDATE trigger)
    UPDATE volunteer_locations l
       SET curr_loc = NEW.curr_loc 
    WHERE l.user_id = NEW.user_id;
    
    IF FOUND THEN
        RETURN NULL;  -- suppress the original INSERT
    END IF;
    
    -- No row yet → proceed with INSERT
    RETURN NEW;
END;
$$;

-- DROP TRIGGER IF EXISTS trg_locations_insert_as_upsert_volunteer ON volunteer_locations; 
CREATE TRIGGER trg_locations_insert_as_upsert_volunteer
BEFORE INSERT ON ireland_dev_saayam_rdbms.volunteer_locations 
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.fn_locations_insert_as_upsert_volunteer();

-- Table: req_comments table # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.req_comments CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.req_comments (
    -- comment_id is the primary key, using a BIGINT and auto-generated identity (like SERIAL)
    comment_id BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    req_id VARCHAR(255) NOT NULL,
    commenter_id VARCHAR(255) NOT NULL,
    comment_desc TEXT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    isdeleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_req_comment_request
        FOREIGN KEY (req_id) 
        REFERENCES ireland_dev_saayam_rdbms.request (req_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,    
    CONSTRAINT fk_req_comment_user
        FOREIGN KEY (commenter_id) 
        REFERENCES ireland_dev_saayam_rdbms.users (user_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

-- Index for efficient lookup by request ID
CREATE INDEX IF NOT EXISTS idx_req_comment_req_id
    ON ireland_dev_saayam_rdbms.req_comments (req_id);

-- Index for efficient lookup by commenter ID
CREATE INDEX IF NOT EXISTS idx_req_comment_commenter_id
    ON ireland_dev_saayam_rdbms.req_comments (commenter_id);

-- Index for filtering out soft-deleted comments
CREATE INDEX IF NOT EXISTS idx_req_comment_isdeleted
    ON ireland_dev_saayam_rdbms.req_comments (isdeleted);

-- DROP TRIGGER IF EXISTS trg_req_comments_updated_at ON ireland_dev_saayam_rdbms.req_comments;
CREATE TRIGGER trg_req_comments_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.req_comments
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: skill_list table # No longer exists as of 05/21/2026

/* CREATE SEQUENCE IF NOT EXISTS skill_list_skill_list_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

CREATE TABLE IF NOT EXISTS skill_list
(
    skill_list_id integer NOT NULL DEFAULT nextval('skill_list_skill_list_id_seq'::regclass),
    request_category_id integer NOT NULL,
    skill_desc character varying(100) COLLATE pg_catalog."default" NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    CONSTRAINT skill_list_pkey PRIMARY KEY (skill_list_id)
); */

-- Table: news_snippets # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.news_snippets CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.news_snippets (
-- Unique ID for each news entry
news_id SERIAL PRIMARY KEY,
    
-- The title or short headline of the news snippet
headline VARCHAR(255) NOT NULL,

-- The detailed text explaining the activity (a couple of sentences)
snippet_text TEXT NOT NULL,

-- The secure S3 path to the image file (URL or Key)
image_path TEXT,

-- JSON to store one or more LinkedIn URLs for mentioned people
-- E.g., [{"name": "PersonA", "url": "..."}]
profile_links JSONB DEFAULT '[]'::jsonb,

-- The date the event occurred, used for chronological ordering 
event_date DATE NOT NULL,
    
-- When the record was created in the DB
created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),

last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TRIGGER trg_news_snippets_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.news_snippets
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: org_skills  # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS org_skills CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.org_skills (
  org_id VARCHAR(255),
  cat_id VARCHAR(50),
  assigned_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
  last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
  PRIMARY KEY (org_id, cat_id),
  FOREIGN KEY (org_id) REFERENCES ireland_dev_saayam_rdbms.organizations(org_id) ON DELETE CASCADE,
  FOREIGN KEY (cat_id) REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id) ON DELETE CASCADE
);

-- Indexes for optimized Lookups/Joins
-- Note: (org_id, cat_id) is already indexed by the Primary Key.
-- We add an index on cat_id specifically for queries looking up all orgs for a specific skill.
CREATE INDEX idx_org_skills_cat_id ON ireland_dev_saayam_rdbms.org_skills(cat_id);
CREATE TRIGGER trg_org_skills_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.org_skills
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();


-- Table: volunteer_applications   # Updated as on 05/21/2026
-- DROP TABLE IF EXISTS volunteer_applications CASCADE;
-- ENUM for application status
CREATE TYPE ireland_dev_saayam_rdbms.app_status_type AS ENUM ('STARTED', 'IN_REVIEW', 'ACCEPTED', 'REJECTED');
CREATE TABLE ireland_dev_saayam_rdbms.volunteer_applications (
    user_id VARCHAR(255) PRIMARY KEY,
    terms_and_conditions BOOLEAN DEFAULT FALSE,
    terms_accepted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    govt_id_path TEXT,
    path_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    skill_codes JSON,
    availability JSONB,
    current_page INT DEFAULT 1, -- Changed from TEXT to INT for numerical tracking
    application_status ireland_dev_saayam_rdbms.app_status_type DEFAULT 'STARTED',    
    is_completed BOOLEAN DEFAULT FALSE, --extra precaution    
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users(user_id)
);

/*CREATE OR REPLACE FUNCTION updated_at_handler()
RETURNS TRIGGER AS $$
BEGIN
    -- check if the last_updated_at was explicitly changed in the UPDATE statement.
    -- if it WASN'T changed by the API, we force it to the current UTC.
    IF (NEW.last_updated_at IS NOT DISTINCT FROM OLD.last_updated_at) THEN
        NEW.last_updated_at = (now() AT TIME ZONE 'UTC');
    END IF;

    -- handle application table 
    IF (TG_TABLE_NAME = 'volunteer_applications') THEN
        -- Update path timestamp if path changed
        IF (NEW.govt_id_path IS DISTINCT FROM OLD.govt_id_path) THEN
            NEW.path_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;

        -- Update terms timestamp if accepted
        IF (NEW.terms_and_conditions IS TRUE AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;

    -- handle details table 
    ELSIF (TG_TABLE_NAME = 'volunteer_details') THEN
        -- update path1 timestamp if changed
        IF (NEW.govt_id_path1 IS DISTINCT FROM OLD.govt_id_path1) THEN
            NEW.path1_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        
        -- update path2 timestamp if changed
        IF (NEW.govt_id_path2 IS DISTINCT FROM OLD.govt_id_path2) THEN
            NEW.path2_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;

        -- update terms timestamp if accepted
        IF (NEW.terms_and_conditions IS TRUE AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
*/
CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.handle_volunteer_application()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.application_status = 'ACCEPTED' AND OLD.application_status != 'ACCEPTED') THEN
        
        -- Migrate to volunteer_details
        INSERT INTO ireland_dev_saayam_rdbms.volunteer_details (
            user_id, terms_and_conditions, terms_accepted_at, 
            govt_id_path1, path1_updated_at, path2_updated_at, availability_days, availability_times, 
            created_at, last_updated_at
        ) VALUES (
            NEW.user_id, NEW.terms_and_conditions, NEW.terms_accepted_at,
            NEW.govt_id_path, NEW.path_updated_at, NULL, (NEW.availability -> 'days')::JSONB, (NEW.availability -> 'time')::JSONB,
            NEW.last_updated_at, NEW.last_updated_at
        );

        -- Migrate to user_skills (unrolling the JSON array)
        IF (NEW.skill_codes IS NOT NULL) THEN
            INSERT INTO ireland_dev_saayam_rdbms.user_skills (
                user_id, cat_id, created_at, last_updated_at
            )
            SELECT 
                NEW.user_id, 
                skill_id, 
                NEW.last_updated_at, 
                NEW.last_updated_at
            FROM json_array_elements_text(NEW.skill_codes) AS skill_id;
        END IF;

		DELETE FROM ireland_dev_saayam_rdbms.volunteer_applications WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_volunteer_app_updated_at
    BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteer_applications
    FOR EACH ROW EXECUTE FUNCTION ireland_dev_saayam_rdbms.updated_at_handler();

CREATE TRIGGER trg_handle_volunteer_application
    AFTER UPDATE ON ireland_dev_saayam_rdbms.volunteer_applications
    FOR EACH ROW EXECUTE FUNCTION ireland_dev_saayam_rdbms.handle_volunteer_application();

-- ALTER TABLE volunteer_applications ENABLE TRIGGER trg_volunteer_app_updated_at;

-- Table: meetings # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.meetings CASCADE;
-- SET TIME ZONE 'UTC';
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.meetings (
meeting_id VARCHAR(255) NOT NULL,
meeting_date DATE NOT NULL, 
start_time TIME WITHOUT TIME ZONE NOT NULL,
end_time TIME WITHOUT TIME ZONE NOT NULL,
cohost_id VARCHAR(255) NOT NULL,
last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
-- Primary key constraint 
CONSTRAINT meetings_pk 
PRIMARY KEY(meeting_id, cohost_id),

--Unique idenitifer for table 
CONSTRAINT meetings_meeting_id_unique
UNIQUE(meeting_id), 

-- Foreign key constraint
CONSTRAINT meetings_fk
FOREIGN KEY (cohost_id)
REFERENCES ireland_dev_saayam_rdbms.users(user_id),

-- Time check constraint
CONSTRAINT meetings_time_chk 
CHECK (end_time>start_time)
 );

CREATE TRIGGER trg_meetings_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.meetings
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

-- Table: meeting_participants # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.meeting_participants CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.meeting_participants(
    meeting_id VARCHAR(255) NOT NULL,
    participant_id VARCHAR(255) NOT NULL, 

    --Unique identifer for table 
    CONSTRAINT meeting_participant_pk 
    PRIMARY KEY (meeting_id, participant_id),

    -- Foreign key constraint for meeting_id
    CONSTRAINT meeting_participant_meetingid_fk
    FOREIGN KEY (meeting_id) 
    REFERENCES ireland_dev_saayam_rdbms.meetings(meeting_id),

    -- Foreign key constraint for participant_id
    CONSTRAINT meeting_participant_participant_fk
    FOREIGN KEY (participant_id)
    REFERENCES ireland_dev_saayam_rdbms.users(user_id)

);
-- Index to pull participants for a particular meeting
CREATE INDEX IF NOT EXISTS mp_meeting_id_idx
ON ireland_dev_saayam_rdbms.meeting_participants(meeting_id); 

-- Table: user_category_map # Updated as on 05/21/2026

-- DROP TABLE IF EXISTS ireland_dev_saayam_rdbms.user_category_map CASCADE;
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_category_map (
user_id VARCHAR(255) NOT NULL, 
user_category_id INT NOT NULL, 
last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
PRIMARY KEY (user_id, user_category_id), 
FOREIGN KEY (user_id) REFERENCES ireland_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE, 
FOREIGN KEY (user_category_id) REFERENCES ireland_dev_saayam_rdbms.user_category (user_category_id) ON DELETE CASCADE ); 

CREATE TRIGGER trg_user_category_map_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_category_map
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();
