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

-- Table: action
CREATE TABLE IF NOT EXISTS action (
    action_id SERIAL PRIMARY KEY,
    action_desc VARCHAR(30) NOT NULL,
    created_date TIMESTAMP,
    created_by VARCHAR(30),
    last_update_by VARCHAR(30),
    last_update_date TIMESTAMP,
    UNIQUE (action_id)
);

-- Table: country
CREATE TABLE IF NOT EXISTS country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL,
    phone_country_code INT NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (country_id)
);

-- Table: identity_type
CREATE TABLE IF NOT EXISTS identity_type (
    identity_type_id SERIAL PRIMARY KEY,
    identity_value VARCHAR(255) NOT NULL,
    identity_type_dsc VARCHAR(255),
    last_updated_date TIMESTAMP,
    UNIQUE (identity_type_id)
);

-- Table: request_priority
CREATE TABLE IF NOT EXISTS request_priority (
    priority_id SERIAL PRIMARY KEY,
    priority_value VARCHAR(255) NOT NULL,
    priority_description VARCHAR(255),
    last_updated_date TIMESTAMP,
    UNIQUE (priority_id)
);

-- Table: user_status
CREATE TABLE IF NOT EXISTS user_status (
    user_status_id SERIAL PRIMARY KEY,
    user_status VARCHAR(255) NOT NULL,
    user_status_desc VARCHAR(255),
    last_update_date TIMESTAMP,
    UNIQUE (user_status_id)
);

-- Table: user_category
CREATE TABLE IF NOT EXISTS user_category (
    user_category_id SERIAL PRIMARY KEY,
    user_category VARCHAR(255) NOT NULL,
    user_category_desc VARCHAR(255),
    last_update_date TIMESTAMP,
    UNIQUE (user_category_id)
);

-- Table: region 
CREATE TABLE IF NOT EXISTS region (
    region_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    region_name VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (country_id, region_id),
    FOREIGN KEY (country_id) REFERENCES country (country_id)
);

-- Table: city
CREATE TABLE IF NOT EXISTS city (
    city_id SERIAL PRIMARY KEY,
    region_id INT NOT NULL,
    city_name VARCHAR(255) NOT NULL,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    last_update_date TIMESTAMP,
    UNIQUE (city_id),
    FOREIGN KEY (region_id) REFERENCES region (region_id)
);

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(255) PRIMARY KEY,  -- EU-based ID (e.g., "EU-000001")
    country_id INT NULL,
    region_id INT NULL,               -- referencing 'region'
    city_id INT NULL,                 -- referencing 'city'
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
    
    zip_code VARCHAR(255) NULL,       -- or rename to postal_code for local understanding
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
    
    -- EU specific attributes
    region_code VARCHAR(5) DEFAULT 'EU', --identifying the region where the user’s data primarily resides, distinguish EU users from others, if needed
    gdpr_consent TIMESTAMP NULL, --Tracks when the user provided consent for data processing
    
    FOREIGN KEY (country_id) REFERENCES country (country_id),
    FOREIGN KEY (region_id) REFERENCES region (region_id),
    FOREIGN KEY (city_id) REFERENCES city (city_id),
    FOREIGN KEY (user_status_id) REFERENCES user_status (user_status_id),
    FOREIGN KEY (user_category_id) REFERENCES user_category (user_category_id)
);

-- Table: user_additional_details
CREATE TABLE IF NOT EXISTS user_additional_details (
    additional_detail_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    secondary_email_1 VARCHAR(255) NULL,
    secondary_email_2 VARCHAR(255) NULL,
    secondary_phone_1 VARCHAR(255) NULL,
    secondary_phone_2 VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- Table: volunteer_details
CREATE TABLE IF NOT EXISTS volunteer_details (
    volunteer_detail_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    terms_and_conditions BOOL NULL,
    terms_and_conditions_update_date TIMESTAMP NULL,
    govt_id VARCHAR(255) NULL,
    govt_id_update_date TIMESTAMP NULL,
    skills JSONB NULL,
    notification BOOL NULL,
    iscomplete BOOL NULL,
    completed_date TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- Table: user_volunteer_skills
CREATE TABLE IF NOT EXISTS user_volunteer_skills (
    skills JSONB
);

-- Table: request_status
CREATE TABLE IF NOT EXISTS request_status (
    request_status_id SERIAL PRIMARY KEY,
    request_status VARCHAR(255) NOT NULL,
    request_status_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);

-- Table: request_type
CREATE TABLE IF NOT EXISTS request_type (
    request_type_id SERIAL PRIMARY KEY,
    request_type VARCHAR(255),
    request_type_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);

-- Table: request_category
CREATE TABLE IF NOT EXISTS request_category (
    request_category_id SERIAL PRIMARY KEY,
    request_category VARCHAR(255) NOT NULL,
    request_category_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);

-- Table: request_for
CREATE TABLE IF NOT EXISTS request_for (
    request_for_id SERIAL PRIMARY KEY,
    request_for VARCHAR(255) NOT NULL,
    request_for_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);

-- Table: request
CREATE TABLE IF NOT EXISTS request (
    request_id VARCHAR(255) PRIMARY KEY,
    request_user_id VARCHAR(255) NOT NULL,
    request_status_id INT NOT NULL,
    request_priority_id INT NOT NULL,
    request_type_id INT NOT NULL,
    request_category_id INT NOT NULL,
    request_for_id INT NOT NULL,
    
    -- referencing city_id if you want to track the request's city
    city_id INT NULL,
    zip_code VARCHAR(255) NULL,
    
    request_desc VARCHAR(255) NOT NULL,
    audio_req_desc VARCHAR(255) NULL,
    request_for VARCHAR(255) NOT NULL,
    submission_date TIMESTAMP,
    lead_volunteer_user_id INT,
    serviced_date TIMESTAMP,
    last_update_date TIMESTAMP,
    UNIQUE (request_id),
    
    FOREIGN KEY (request_user_id) REFERENCES users (user_id),
    FOREIGN KEY (request_status_id) REFERENCES request_status (request_status_id),
    FOREIGN KEY (request_priority_id) REFERENCES request_priority (priority_id),
    FOREIGN KEY (request_type_id) REFERENCES request_type (request_type_id),
    FOREIGN KEY (request_category_id) REFERENCES request_category (request_category_id),
    FOREIGN KEY (request_for_id) REFERENCES request_for (request_for_id),
    FOREIGN KEY (city_id) REFERENCES city (city_id)
);

-- Table: fraud_requests
CREATE TABLE IF NOT EXISTS fraud_requests (
    fraud_request_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    request_datetime TIMESTAMP NOT NULL,
    reason VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

-- Table: volunteers_assigned
CREATE TABLE IF NOT EXISTS volunteers_assigned (
    volunteers_assigned_id SERIAL PRIMARY KEY,
    request_id VARCHAR(255) NOT NULL,
    volunteer_id VARCHAR(255) NOT NULL,
    volunteer_type VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP NOT NULL,
    FOREIGN KEY (request_id) REFERENCES request (request_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: comments
CREATE TABLE IF NOT EXISTS comments (
    comment_id SERIAL PRIMARY KEY,
    request_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    comment_desc TEXT NOT NULL,
    comment_date TIMESTAMP NOT NULL,
    FOREIGN KEY (request_id) REFERENCES request (request_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS fk_comments_request_id_idx ON comments (request_id);
CREATE INDEX IF NOT EXISTS fk_comments_user_id_idx ON comments (user_id);

-- Table: volunteer_organizations
CREATE TABLE IF NOT EXISTS volunteer_organizations (
    volunteer_organization_id SERIAL PRIMARY KEY,
    contact_id VARCHAR(255) NOT NULL,
    -- Reference city/region
	region_id INT NULL,
    city_id INT NULL,
    -- city_name VARCHAR(255) NOT NULL,
    addr_ln1 VARCHAR(255) NULL,
    addr_ln2 VARCHAR(255) NULL,
    addr_ln3 VARCHAR(255) NULL,
    zip_code VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP,
    time_zone VARCHAR(255) NULL,
    FOREIGN KEY (contact_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (region_id) REFERENCES region (region_id),
    FOREIGN KEY (city_id) REFERENCES city (city_id)
);

-- Table: notification_channels
CREATE TABLE IF NOT EXISTS notification_channels (
    channel_id SERIAL PRIMARY KEY,
    channel_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- Table: notification_types
CREATE TABLE IF NOT EXISTS notification_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

CREATE TYPE status_type AS ENUM('unread', 'read');

-- Table: notifications
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

-- Table: user_notification_preferences
CREATE TABLE IF NOT EXISTS user_notification_preferences (
    user_notification_preferences_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    channel_id INT NOT NULL,
    preference preference_type,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (channel_id) REFERENCES notification_channels (channel_id)
);

-- Table: skill_list
CREATE TABLE IF NOT EXISTS skill_list (
    skill_list_id SERIAL PRIMARY KEY,
    request_category_id INT NOT NULL,
    skill_desc VARCHAR(100) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (skill_list_id),
    FOREIGN KEY (request_category_id) REFERENCES request_category (request_category_id)
);

-- Table: sla
CREATE TABLE IF NOT EXISTS sla (
    sla_id SERIAL PRIMARY KEY,
    sla_hours INT NOT NULL,
    sla_description VARCHAR(255) NOT NULL,
    no_of_cust_impct INT,
    last_updated_date TIMESTAMP,
    UNIQUE (sla_id)
);

CREATE TYPE skill_levels AS ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT');

-- Table: user_skills
CREATE TABLE IF NOT EXISTS user_skills (
    user_skills_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    skill_id INT NOT NULL,
    skill_level skill_levels,
    last_used_date TIMESTAMP,
    created_date TIMESTAMP,
    last_update_date TIMESTAMP,
    FOREIGN KEY (skill_id) REFERENCES skill_list (skill_list_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE TYPE rating_enum AS ENUM ('0', '1', '2', '3', '4', '5');

-- Table: volunteer_rating
CREATE TABLE IF NOT EXISTS volunteer_rating (
    volunteer_rating_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    request_id VARCHAR(255) NOT NULL,
    rating rating_enum NOT NULL,
    feedback TEXT,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (request_id) REFERENCES request (request_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_volunteer_rating_user_id ON volunteer_rating (user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_rating_request_id ON volunteer_rating (request_id);

-- Table: user_availability
CREATE TABLE IF NOT EXISTS user_availability (
    user_availability_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    day_of_week VARCHAR(10) CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_availability_user_id ON user_availability (user_id);

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
    new_id := 'EU-' || LPAD(seq_id::TEXT, 6, '0');
    NEW.user_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_users
BEFORE INSERT ON users
FOR EACH ROW
WHEN (NEW.user_id IS NULL OR NEW.user_id = '')
EXECUTE FUNCTION generate_eu_id();

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
    new_id VARCHAR(30);
BEGIN
    seq_id := nextval('request_id_seq');
    new_id := 'REQ-' || LPAD(FLOOR(seq_id / 100000000)::TEXT, 2, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000000) / 100000)::TEXT, 3, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000) / 1000)::TEXT, 3, '0') || '-' || 
              LPAD((seq_id % 1000)::TEXT, 4, '0');
    NEW.request_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER before_insert_requests
BEFORE INSERT ON request
FOR EACH ROW
WHEN (NEW.request_id IS NULL OR NEW.request_id = '')
EXECUTE FUNCTION generate_request_id();

-- Emergency Numbers
CREATE TABLE IF NOT EXISTS emergency_numbers(    
    emergency_number_id SERIAL PRIMARY KEY,
    country VARCHAR(100),
    police VARCHAR(20),
    ambulance VARCHAR(20),
    fire VARCHAR(20),
    other_emergency VARCHAR(100)
);

