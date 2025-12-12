-- PostgreSQL Script adapted for Ireland Region
-- User ID Generation, New columns in User Table 
-- Renaming tables with their attributes: region for better understanding
-- Changes in Table: volunteer_organizations 
-- Added WHEN clause to migrate data with existing IDs

-- Drop schema if it exists
DROP SCHEMA IF EXISTS proposed_saayam CASCADE;

-- Create schema
CREATE SCHEMA IF NOT EXISTS proposed_saayam;

-- Set schema for following operations
SET search_path TO proposed_saayam;

CREATE EXTENSION IF NOT EXISTS postgis;

-- Table: action # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS action (
    action_id SERIAL PRIMARY KEY,
    action_desc VARCHAR(30) NOT NULL,
    created_date TIMESTAMP,
    created_by VARCHAR(30),
    last_update_by VARCHAR(30),
    last_update_date TIMESTAMP,
    UNIQUE (action_id)
);

-- Table: country # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    phone_code VARCHAR(5) NOT NULL,
    country_code VARCHAR(6) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (country_id)
);
CREATE SEQUENCE IF NOT EXISTS country_seq
    INCREMENT 50
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

-- Table: identity_type # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS identity_type (
    identity_type_id SERIAL PRIMARY KEY,
    identity_value VARCHAR(255) NOT NULL,
    identity_type_dsc VARCHAR(255),
    last_updated_date TIMESTAMP,
    UNIQUE (identity_type_id)
);

-- Table: request_priority # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS request_priority (
    req_priority_id SERIAL PRIMARY KEY,
    req_priority VARCHAR(25) NOT NULL,
    req_priority_desc VARCHAR(125),
    last_updated_date TIMESTAMP,
    UNIQUE (req_priority_id)
);
CREATE SEQUENCE IF NOT EXISTS user_status_seq
    INCREMENT 50
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
-- Table: user_status # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS user_status (
    user_status_id SERIAL PRIMARY KEY,
    user_status VARCHAR(255) NOT NULL,
    user_status_desc VARCHAR(255),
    last_update_date TIMESTAMP,
    UNIQUE (user_status_id)
);

-- Table: user_category # No changes as on 12/01/2025
CREATE SEQUENCE IF NOT EXISTS user_category_seq
    INCREMENT 50
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
CREATE SEQUENCE IF NOT EXISTS user_category_user_category_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;
	
CREATE TABLE IF NOT EXISTS user_category (
    user_category_id integer NOT NULL DEFAULT nextval('user_category_user_category_id_seq'::regclass),
    user_category VARCHAR(255) NOT NULL,
    user_category_desc VARCHAR(255),
    last_update_date TIMESTAMP,
    UNIQUE (user_category_id)
);

-- Table: State # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS state (
    state_id VARCHAR(50) PRIMARY KEY,
    country_id INT NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(6),
    last_update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES country (country_id)
);
CREATE SEQUENCE IF NOT EXISTS state_seq
    INCREMENT 50
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

-- Table: city # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS city (
    city_id SERIAL PRIMARY KEY,
    state_id VARCHAR(50) NOT NULL,
    city_name VARCHAR(30) NOT NULL, 
    lattitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    last_update_date TIMESTAMP,
    UNIQUE (city_id),
    FOREIGN KEY (state_id) REFERENCES state (state_id)
);

-- Table: users # Updated as per Virginia on 12/01/2025
   CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(255) PRIMARY KEY,
    state_id VARCHAR(50) NULL,
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
    
    
    FOREIGN KEY (country_id) REFERENCES country (country_id),
    FOREIGN KEY (state_id) REFERENCES state (state_id),
    FOREIGN KEY (user_status_id) REFERENCES user_status (user_status_id),
    FOREIGN KEY (user_category_id) REFERENCES user_category (user_category_id)
);
-- Create a sequence for EU user IDs
CREATE SEQUENCE user_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

-- EU ID Function: "EU-000001", "EU-000002", etc.
CREATE FUNCTION generate_eu_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id INT;
    new_id VARCHAR(20);
BEGIN
    seq_id := nextval('user_id_seq');
    new_id := 'EU-00-' || LPAD(FLOOR(seq_id / 1000000)::TEXT, 3, '0') || '-' || 
              LPAD(FLOOR((seq_id % 1000000) / 1000)::TEXT, 3, '0') || '-' || 
              LPAD((seq_id % 1000)::TEXT, 3, '0');
    NEW.user_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_users
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION generate_eu_id();

-- Table: user_additional_details  # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS user_additional_details (
    additional_detail_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    secondary_email_1 VARCHAR(255) NULL,
    secondary_email_2 VARCHAR(255) NULL,
    secondary_phone_1 VARCHAR(255) NULL,
    secondary_phone_2 VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- Table: volunteer_details # Updated as per Virginia on 12/01/2025
CREATE SEQUENCE IF NOT EXISTS volunteer_details_seq
    INCREMENT 50
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
DROP TABLE IF EXISTS volunteer_details CASCADE;
CREATE TABLE IF NOT EXISTS volunteer_details (
    user_id VARCHAR(255) PRIMARY KEY,
    terms_and_conditions BOOL NULL,
    terms_and_conditions_update_date TIMESTAMP NULL,
    govt_id_path VARCHAR(255) NULL, -- stored in S3, this attribute stores the S3 link
    govt_id_update_date TIMESTAMP NULL,
    skills JSONB NULL,  -- to store unstructured data
    notification BOOL NULL,
    iscomplete BOOL NULL,
    completed_date TIMESTAMP NULL,
    location geography(Point,4326),
    CONSTRAINT volunteer_details_user_fk 
        FOREIGN KEY (user_id) 
        REFERENCES users (user_id) 
        ON DELETE CASCADE
);
-- --IF you have already table exists and trying to change the column name and type from Pii varchar(255) to skills jsonb 
-- -- Change the column type from varchar to json
-- ALTER TABLE IF EXISTS volunteer_details ALTER COLUMN pii TYPE jsonb USING pii::jsonb;

-- -- Rename the column from pii to skills
-- ALTER TABLE IF EXISTS volunteer_details RENAME COLUMN pii TO skills;

-- used to store unstructured data

-- To ensure each volunteer is unique by user_id as we don’t plan to allow multiple volunteer rows per use

DO $$ 
BEGIN
   IF NOT EXISTS (
       SELECT 1 FROM pg_constraint
       WHERE conname = 'volunteer_details_user_uk'
       AND conrelid = 'volunteer_details'::regclass
) THEN
  ALTER TABLE volunteer_details
  ADD CONSTRAINT volunteer_details_user_uk UNIQUE (user_id);
END IF;
END;
$$;
-- Table: user_volunteer_skills
/* CREATE TABLE IF NOT EXISTS user_volunteer_skills (
    skills JSONB
); */

-- Table: request_status # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS request_status (
    req_status_id SERIAL PRIMARY KEY,
    req_status VARCHAR(25) NOT NULL,
    req_status_desc VARCHAR(125),
    last_updated_date TIMESTAMP
);

-- Table: request_type # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS request_type (
    req_type_id SERIAL PRIMARY KEY,
    req_type VARCHAR(25),
    req_type_desc VARCHAR(125),
    last_updated_date TIMESTAMP
);

-- Table: request_category # No longer exists in Virginia region
/* CREATE TABLE IF NOT EXISTS request_category (
    request_category_id SERIAL PRIMARY KEY,
    request_category VARCHAR(255) NOT NULL,
    request_category_desc VARCHAR(255),
    last_updated_date TIMESTAMP
); */

-- Table: request_for # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS request_for (
    req_for_id SERIAL PRIMARY KEY,
    req_for VARCHAR(25) NOT NULL,
    req_for_desc VARCHAR(125), --15words7charlength
    last_updated_date TIMESTAMP
);

-- Request_isleadvol # Added as per Virginia on 12/01/2025

CREATE TABLE IF NOT EXISTS request_isleadvol (
    req_islead_id SERIAL PRIMARY KEY,
    req_islead VARCHAR(15) NOT NULL,  
    req_islead_desc VARCHAR(100), 
    last_updated_date TIMESTAMP
);

-- Help Categories # Added as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS help_categories (
    cat_id VARCHAR(50) PRIMARY KEY,           -- e.g., '1', '1.1', '1.1.1'
    cat_name VARCHAR(100) NOT NULL,                    -- string_key, e.g., 'DONATE_CLOTHES'
    cat_desc VARCHAR(150) NOT NULL                     -- purpose or goal of the category
);

-- Table: request # Updated as per Virginia on 12/01/2025

--CREATE TYPE islead_volunteer AS ENUM('YES', 'NO');
CREATE TABLE IF NOT EXISTS request (
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
    serviced_date TIMESTAMP, 						--completed or cancelled date
    last_update_date TIMESTAMP,
    UNIQUE (req_id),
    FOREIGN KEY (req_user_id) REFERENCES users (user_id),
    FOREIGN KEY (req_status_id) REFERENCES request_status (req_status_id),
    FOREIGN KEY (req_priority_id) REFERENCES request_priority (req_priority_id),
    FOREIGN KEY (req_type_id) REFERENCES request_type (req_type_id),
    FOREIGN KEY (req_cat_id) REFERENCES help_categories (cat_id),
    FOREIGN KEY (req_for_id) REFERENCES request_for (req_for_id),
	FOREIGN KEY (req_islead_id) REFERENCES request_isleadvol (req_islead_id)
);

-- Create the sequence for request IDs
CREATE SEQUENCE request_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

-- Create the function to generate the formatted request ID
CREATE FUNCTION generate_request_id()
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

-- Table: fraud_requests # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS fraud_requests (
    fraud_request_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    request_datetime TIMESTAMP NOT NULL,
    reason VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

-- Table: volunteers_assigned # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS volunteers_assigned (
    volunteers_assigned_id SERIAL PRIMARY KEY,
    req_id VARCHAR(255) NOT NULL,
    volunteer_id VARCHAR(255) NOT NULL,
    volunteer_type VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP NOT NULL,
    FOREIGN KEY (req_id) REFERENCES request (req_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: comments # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS comments (
    comment_id SERIAL PRIMARY KEY,
    req_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    comment_desc TEXT NOT NULL,
    comment_date TIMESTAMP NOT NULL,
    FOREIGN KEY (req_id) REFERENCES request (req_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS fk_comments_request_id_idx ON comments (req_id);
CREATE INDEX IF NOT EXISTS fk_comments_user_id_idx ON comments (user_id);

-- Table: volunteer_organizations  # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS volunteer_organizations (
    volunteer_organization_id SERIAL PRIMARY KEY,
    contact_id VARCHAR(255) NOT NULL,
    city_name VARCHAR(255) NOT NULL,
    addr_ln1 VARCHAR(255) NULL,
    addr_ln2 VARCHAR(255) NULL,
    addr_ln3 VARCHAR(255) NULL,
    zip_code VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP,
    time_zone VARCHAR(255) NULL,
    FOREIGN KEY (contact_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
 
-- Table: notification_channels  # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS notification_channels (
    channel_id SERIAL PRIMARY KEY,
    channel_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- Table: notification_types  # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS notification_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

CREATE TYPE status_type AS ENUM('unread', 'read');

-- Table: notifications   # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    type_id INT NOT NULL,
    channel_id INT NOT NULL,
    message TEXT NOT NULL,
    status status_type,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type_id) REFERENCES notification_types (type_id),
    FOREIGN KEY (channel_id) REFERENCES notification_channels (channel_id)
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications (status);
CREATE INDEX IF NOT EXISTS idx_notifications_type_id ON notifications (type_id);
CREATE INDEX IF NOT EXISTS idx_notifications_channel_id ON notifications (channel_id);

CREATE TYPE preference_type AS ENUM('email', 'text', 'both');

-- Table: user_notification_preferences # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS user_notification_preferences (
    user_notification_preferences_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    channel_id INT NOT NULL,
    preference preference_type,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (channel_id) REFERENCES notification_channels (channel_id)
);

-- Table: skill_list  # No changes as on 12/01/2025
/* CREATE TABLE IF NOT EXISTS skill_list (
    skill_list_id SERIAL PRIMARY KEY,
    request_category_id INT NOT NULL,
    skill_desc VARCHAR(100) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (skill_list_id),
    FOREIGN KEY (request_category_id) REFERENCES request_category (request_category_id)
); */

-- Table: sla # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS sla (
    sla_id SERIAL PRIMARY KEY,
    sla_hours INT NOT NULL,
    sla_description VARCHAR(255) NOT NULL,
    no_of_cust_impct INT,
    last_updated_date TIMESTAMP,
    UNIQUE (sla_id)
);

CREATE TYPE skill_levels AS ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT');

-- Table: user_skills # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS user_skills (
    user_skills_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    skill_id INT NOT NULL,
    skill_level skill_levels,
    last_used_date TIMESTAMP,
    created_date TIMESTAMP,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE TYPE rating_enum AS ENUM ('0', '1', '2', '3', '4', '5');

-- Table: volunteer_rating # No changes as on 12/01/2025
CREATE TABLE IF NOT EXISTS volunteer_rating (
    volunteer_rating_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    req_id VARCHAR(255) NOT NULL,
    rating rating_enum NOT NULL,
    feedback TEXT,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (req_id) REFERENCES request (req_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_volunteer_rating_user_id ON volunteer_rating (user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_rating_request_id ON volunteer_rating (req_id);

-- Table: user_availability # No changes as on 12/01/2025
CREATE SEQUENCE IF NOT EXISTS user_availability_user_availability_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;
CREATE SEQUENCE IF NOT EXISTS user_availability_seq
    INCREMENT 50
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
	
CREATE TABLE IF NOT EXISTS user_availability (
    user_availability_id integer NOT NULL DEFAULT nextval('user_availability_user_availability_id_seq'::regclass),
    user_id VARCHAR(255) NOT NULL,
    day_of_week VARCHAR(10) CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_availability_user_id ON user_availability (user_id);
CREATE TRIGGER before_insert_requests
BEFORE INSERT ON request
FOR EACH ROW
WHEN (NEW.req_id IS NULL OR NEW.req_id = '')
EXECUTE FUNCTION generate_request_id();

-- Emergency Numbers # Updated as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS emergency_numbers(    
    emergency_number_id SERIAL PRIMARY KEY,
    country VARCHAR(100),
    police VARCHAR(20),
    ambulance VARCHAR(20),
    fire VARCHAR(20),
    other_emergency VARCHAR(100)
);
-- Help Category Map # Added as per Virginia on 12/01/2025
CREATE TABLE IF NOT EXISTS help_category_map (
    parent_id VARCHAR(50),
    child_id VARCHAR(50) PRIMARY KEY, --one parent multiple child
    FOREIGN KEY (parent_id) REFERENCES help_categories(cat_id),
    FOREIGN KEY (child_id) REFERENCES help_categories(cat_id)
);

-- Req_Add_Info_MetaData # Added as per Virginia on 12/01/2025

CREATE TABLE IF NOT EXISTS req_add_info_metadata(
    field_id VARCHAR(70) PRIMARY KEY,                         --  primary key
    field_name_key VARCHAR(100),
    field_type VARCHAR(20),                                   -- examples: 'string', 'int', 'float', 'list'
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),  -- Fixed syntax
    cat_id VARCHAR(50),                                       
    FOREIGN KEY (cat_id) REFERENCES help_categories(cat_id)
);

-- List Item Meta_Data  # Added as per Virginia on 12/01/2025
CREATE TABLE list_item_metadata (
    item_id VARCHAR(100) PRIMARY KEY,
    field_id VARCHAR(70),
    item_value VARCHAR(100),
    item_type VARCHAR(20),  --examples: 'string', 'int', 'range', 'currency'
    FOREIGN KEY (field_id) REFERENCES req_add_info_metadata(field_id)
);

-- Organizations # Added as per Virginia on 12/01/2025

-- Create ENUM types
CREATE TYPE org_type_enum AS ENUM ('non_profit', 'for_profit');
CREATE TYPE source_enum AS ENUM ('irs', 'self_registered');

DROP TABLE IF EXISTS organizations CASCADE;
CREATE TABLE IF NOT EXISTS organizations (
  org_id VARCHAR(255) PRIMARY KEY,
  org_name VARCHAR(125) NOT NULL,
  govt_id_num VARCHAR(20) UNIQUE,  -- EIN for lookups
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
  cat_id VARCHAR(50),   --help_categories
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  last_updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cat_id) REFERENCES help_categories(cat_id) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX idx_org_city_state ON organizations(city_name, state_code);
CREATE INDEX idx_org_state ON organizations(state_code);
CREATE INDEX idx_org_cat_id ON organizations(cat_id);
CREATE INDEX idx_org_name ON organizations(org_name);
 
ALTER TYPE org_type_enum ADD VALUE 'Government';
ALTER TYPE org_type_enum ADD VALUE 'Hybrid' AFTER 'non_profit';
/*Deleting an enum type is a complex process; it requires a temp table in between. Stop using the type.*/

-- Create sequence for organization IDs
CREATE SEQUENCE org_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

-- Create a function to generate ORG IDs in the format: ORG-00-XXX-XXX-XXX
CREATE FUNCTION generate_org_id()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate org_id before insert
CREATE TRIGGER before_insert_organizations
BEFORE INSERT ON organizations
FOR EACH ROW
EXECUTE FUNCTION generate_org_id();

-- Req_Add_Info # Added as per Virginia on 12/01/2025

CREATE TABLE IF NOT EXISTS req_add_info(
    req_id VARCHAR(255) NOT NULL,                        -- FK to Request
    field_id VARCHAR(70) NOT NULL,                       -- FK to req_add_info_metadata called questions
    item_ids TEXT,                                       -- stores the chosen answers
    PRIMARY KEY (req_id, field_id),
    FOREIGN KEY (req_id) REFERENCES request(req_id),
    FOREIGN KEY (field_id) REFERENCES req_add_info_metadata(field_id)
);

-- Request_Guest_Details # Added as per Virginia on 12/01/2025

CREATE TABLE IF NOT EXISTS request_guest_details (
    -- The primary key is the foreign key to the request table (one-to-one relationship)
    req_id VARCHAR(255) PRIMARY KEY,
    req_fname VARCHAR(100) NOT NULL,
    req_lname VARCHAR(100) NOT NULL,
    req_email VARCHAR(100),
    req_phone VARCHAR(20) NOT NULL,
    req_age INT,
    req_gender VARCHAR(50),
    req_pref_lang VARCHAR(50),
    FOREIGN KEY (req_id) REFERENCES request (req_id) ON DELETE CASCADE
);
-- User Locations # Added as per Virginia on 12/01/2025

-- User locations table

DROP TABLE IF EXISTS user_locations CASCADE;
CREATE TABLE IF NOT EXISTS user_locations (
    user_id VARCHAR(255) NOT NULL PRIMARY KEY,
    prev_loc geography(Point, 4326),
    curr_loc geography(Point, 4326),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT user_locations_user_fk
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_locations_curr_gist
    ON user_locations USING GIST (curr_loc); 
CREATE INDEX IF NOT EXISTS idx_user_locations_prev_gist
    ON user_locations USING GIST (prev_loc);

CREATE OR REPLACE FUNCTION fn_shift_prev_loc_user() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.curr_loc IS DISTINCT FROM OLD.curr_loc THEN
        NEW.prev_loc := OLD.curr_loc; 
        NEW.updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_shift_prev_loc_user ON user_locations; 
CREATE TRIGGER trg_shift_prev_loc_user
BEFORE UPDATE ON user_locations 
FOR EACH ROW
EXECUTE FUNCTION fn_shift_prev_loc_user();

CREATE OR REPLACE FUNCTION fn_locations_insert_as_upsert_user() 
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

DROP TRIGGER IF EXISTS trg_locations_insert_as_upsert_user ON user_locations; 
CREATE TRIGGER trg_locations_insert_as_upsert_user
BEFORE INSERT ON user_locations 
FOR EACH ROW
EXECUTE FUNCTION fn_locations_insert_as_upsert_user(); 

-- User_Notification_Status # Added as per Virginia on 12/01/2025

CREATE TABLE user_notification_status (
    user_id VARCHAR(255) PRIMARY KEY,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- User_org_map  # Added as per Virginia on 12/01/2025

CREATE TABLE user_org_map (
    user_id VARCHAR(255) NOT NULL,
    org_id VARCHAR(255) NOT NULL,
    user_role VARCHAR(50),        -- e.g. 'ADMIN', 'STAFF', 'VOLUNTEER'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_org_map_pk PRIMARY KEY (user_id, org_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES organizations(org_id) ON DELETE CASCADE
);

-- User Sign_Off # Added as per Virginia on 12/01/2025

CREATE TABLE IF NOT EXISTS user_signoff (
	signoff_id SERIAL PRIMARY KEY,
    reason VARCHAR(250)
);

-- Volunteer locations table # Added as per Virginia on 12/01/2025
DROP TABLE IF EXISTS volunteer_locations CASCADE;
CREATE TABLE IF NOT EXISTS volunteer_locations (
    user_id VARCHAR(255) NOT NULL PRIMARY KEY, 
    prev_loc geography(Point, 4326),
    curr_loc geography(Point, 4326),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT volunteer_locations_user_fk
        FOREIGN KEY (user_id)
        REFERENCES volunteer_details (user_id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_volunteer_locations_curr_gist
    ON volunteer_locations USING GIST (curr_loc); 
CREATE INDEX IF NOT EXISTS idx_volunteer_locations_prev_gist
    ON volunteer_locations USING GIST (prev_loc);

-- Trigger function to shift old curr_loc -> prev_loc on update
CREATE OR REPLACE FUNCTION fn_shift_prev_loc_volunteer() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.curr_loc IS DISTINCT FROM OLD.curr_loc THEN
        NEW.prev_loc := OLD.curr_loc; 
        NEW.updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_shift_prev_loc_volunteer ON volunteer_locations; 
CREATE TRIGGER trg_shift_prev_loc_volunteer
BEFORE UPDATE ON volunteer_locations 
FOR EACH ROW
EXECUTE FUNCTION fn_shift_prev_loc_volunteer();

-- Trigger function for INSERT upsert behavior
CREATE OR REPLACE FUNCTION fn_locations_insert_as_upsert_volunteer() 
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

DROP TRIGGER IF EXISTS trg_locations_insert_as_upsert_volunteer ON volunteer_locations; 
CREATE TRIGGER trg_locations_insert_as_upsert_volunteer
BEFORE INSERT ON volunteer_locations 
FOR EACH ROW
EXECUTE FUNCTION fn_locations_insert_as_upsert_volunteer();

CREATE TABLE IF NOT EXISTS req_comments (
    -- comment_id is the primary key, using a BIGINT and auto-generated identity (like SERIAL)
    comment_id BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    req_id VARCHAR(255) NOT NULL,
    commenter_id VARCHAR(255) NOT NULL,
    comment_desc TEXT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    isdeleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_req_comment_request
        FOREIGN KEY (req_id) 
        REFERENCES request (req_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,    
    CONSTRAINT fk_req_comment_user
        FOREIGN KEY (commenter_id) 
        REFERENCES users (user_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

-- Index for efficient lookup by request ID
CREATE INDEX IF NOT EXISTS idx_req_comment_req_id
    ON req_comments (req_id);

-- Index for efficient lookup by commenter ID
CREATE INDEX IF NOT EXISTS idx_req_comment_commenter_id
    ON req_comments (commenter_id);

-- Index for filtering out soft-deleted comments
CREATE INDEX IF NOT EXISTS idx_req_comment_isdeleted
    ON req_comments (isdeleted);

CREATE SEQUENCE IF NOT EXISTS skill_list_skill_list_id_seq
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
    last_update_date timestamp without time zone,
    CONSTRAINT skill_list_pkey PRIMARY KEY (skill_list_id)
);
