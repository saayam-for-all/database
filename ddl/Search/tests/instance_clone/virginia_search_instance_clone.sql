-- Search-scoped Virginia instance clone.
-- Use this fixture to validate ddl/Search/codes locally without editing ddl/Tables.

DROP SCHEMA IF EXISTS virginia_dev_saayam_rdbms CASCADE;
CREATE SCHEMA virginia_dev_saayam_rdbms;
SET search_path TO virginia_dev_saayam_rdbms, public;

CREATE TABLE virginia_dev_saayam_rdbms.country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    phone_code VARCHAR(5) NOT NULL,
    country_code VARCHAR(6) NOT NULL,
    last_update_date TIMESTAMP,
    is_eu_member BOOLEAN DEFAULT FALSE,
    UNIQUE (country_id)
);

CREATE TABLE virginia_dev_saayam_rdbms.state (
    state_id VARCHAR(50) PRIMARY KEY,
    country_id INT NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(6),
    last_update_date TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES virginia_dev_saayam_rdbms.country (country_id)
);

CREATE TABLE virginia_dev_saayam_rdbms.user_status (
    user_status_id SERIAL PRIMARY KEY,
    user_status VARCHAR(255) NOT NULL,
    user_status_desc VARCHAR(255),
    last_update_date TIMESTAMP,
    UNIQUE (user_status_id)
);

CREATE TABLE virginia_dev_saayam_rdbms.user_category (
    user_category_id SERIAL PRIMARY KEY,
    user_category VARCHAR(255) NOT NULL,
    user_category_desc VARCHAR(255),
    user_access_level SMALLINT,
    category_code VARCHAR(50) UNIQUE,
    is_deprecated BOOLEAN DEFAULT FALSE,
    permissions JSONB,
    last_updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE virginia_dev_saayam_rdbms.users (
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
    last_location point,
    last_update_date TIMESTAMP,
    time_zone VARCHAR(255) NULL,
    profile_picture_path VARCHAR(255) NULL,
    gender VARCHAR(255) NULL,
    language_1 VARCHAR(255) NULL,
    language_2 VARCHAR(255) NULL,
    language_3 VARCHAR(255) NULL,
    promotion_wizard_stage INT NULL,
    promotion_wizard_last_update_date TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES virginia_dev_saayam_rdbms.country (country_id) ON DELETE SET NULL,
    FOREIGN KEY (state_id) REFERENCES virginia_dev_saayam_rdbms.state (state_id) ON DELETE SET NULL,
    FOREIGN KEY (user_status_id) REFERENCES virginia_dev_saayam_rdbms.user_status (user_status_id),
    FOREIGN KEY (user_category_id) REFERENCES virginia_dev_saayam_rdbms.user_category (user_category_id) ON DELETE SET NULL
);

CREATE TABLE virginia_dev_saayam_rdbms.help_categories (
    cat_id VARCHAR(50) PRIMARY KEY,
    cat_name VARCHAR(100) NOT NULL,
    cat_desc VARCHAR(150) NOT NULL
);

CREATE TABLE virginia_dev_saayam_rdbms.request_status (
    req_status_id SERIAL PRIMARY KEY,
    req_status VARCHAR(25) NOT NULL,
    req_status_desc VARCHAR(125),
    last_updated_date TIMESTAMP
);

CREATE TABLE virginia_dev_saayam_rdbms.request_priority (
    req_priority_id SERIAL PRIMARY KEY,
    req_priority VARCHAR(25) NOT NULL,
    req_priority_desc VARCHAR(125),
    last_updated_date TIMESTAMP,
    UNIQUE (req_priority_id)
);

CREATE TABLE virginia_dev_saayam_rdbms.request_type (
    req_type_id SERIAL PRIMARY KEY,
    req_type VARCHAR(25),
    req_type_desc VARCHAR(125),
    last_updated_date TIMESTAMP
);

CREATE TABLE virginia_dev_saayam_rdbms.request_for (
    req_for_id SERIAL PRIMARY KEY,
    req_for VARCHAR(25) NOT NULL,
    req_for_desc VARCHAR(125),
    last_updated_date TIMESTAMP,
    UNIQUE (req_for_id)
);

CREATE TABLE virginia_dev_saayam_rdbms.request_isleadvol (
    req_islead_id SERIAL PRIMARY KEY,
    req_islead VARCHAR(25) NOT NULL,
    req_islead_desc VARCHAR(125),
    last_updated_date TIMESTAMP,
    UNIQUE (req_islead_id)
);

CREATE TABLE virginia_dev_saayam_rdbms.request (
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
    last_update_date TIMESTAMP,
    UNIQUE (req_id),
    FOREIGN KEY (req_user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id),
    FOREIGN KEY (req_status_id) REFERENCES virginia_dev_saayam_rdbms.request_status (req_status_id),
    FOREIGN KEY (req_priority_id) REFERENCES virginia_dev_saayam_rdbms.request_priority (req_priority_id),
    FOREIGN KEY (req_type_id) REFERENCES virginia_dev_saayam_rdbms.request_type (req_type_id),
    FOREIGN KEY (req_cat_id) REFERENCES virginia_dev_saayam_rdbms.help_categories (cat_id),
    FOREIGN KEY (req_for_id) REFERENCES virginia_dev_saayam_rdbms.request_for (req_for_id),
    FOREIGN KEY (req_islead_id) REFERENCES virginia_dev_saayam_rdbms.request_isleadvol (req_islead_id)
);

CREATE TYPE org_type_enum AS ENUM ('non_profit', 'for_profit');
CREATE TYPE source_enum AS ENUM ('irs', 'self_registered');

CREATE TABLE virginia_dev_saayam_rdbms.organizations (
    org_id VARCHAR(255) PRIMARY KEY,
    org_name VARCHAR(125) NOT NULL,
    govt_id_num VARCHAR(20) UNIQUE,
    street VARCHAR(255),
    city_name VARCHAR(100),
    state_code VARCHAR(6),
    zip_code VARCHAR(10),
    mission TEXT,
    web_url VARCHAR(255) CHECK (web_url IS NULL OR web_url LIKE 'http%'),
    phone VARCHAR(20),
    email VARCHAR(255) CHECK (email IS NULL OR email LIKE '%@%'),
    org_type org_type_enum,
    source source_enum,
    cat_id VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cat_id) REFERENCES virginia_dev_saayam_rdbms.help_categories(cat_id) ON DELETE SET NULL
);

CREATE INDEX idx_org_city_state ON virginia_dev_saayam_rdbms.organizations(city_name, state_code);
CREATE INDEX idx_org_state ON virginia_dev_saayam_rdbms.organizations(state_code);
CREATE INDEX idx_org_cat_id ON virginia_dev_saayam_rdbms.organizations(cat_id);
CREATE INDEX idx_org_name ON virginia_dev_saayam_rdbms.organizations(org_name);

CREATE TABLE virginia_dev_saayam_rdbms.user_org_map (
    user_id VARCHAR(255) NOT NULL,
    org_id VARCHAR(255) NOT NULL,
    user_role VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_org_map_pk PRIMARY KEY (user_id, org_id),
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES virginia_dev_saayam_rdbms.organizations(org_id) ON DELETE CASCADE
);
