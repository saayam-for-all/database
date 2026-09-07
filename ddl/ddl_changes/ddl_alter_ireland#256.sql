-- ---------------------------------------------------------------------------
-- 18. req_add_info_metadata
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.req_add_info_metadata (
    field_id VARCHAR(70) PRIMARY KEY,
    field_name_key VARCHAR(100),
    field_type VARCHAR(20),
    status VARCHAR(10) DEFAULT 'active'
        CHECK (status IN ('active', 'inactive')),
    cat_id VARCHAR(50),
    FOREIGN KEY (cat_id)
        REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id)
);

-- ---------------------------------------------------------------------------
-- 19. list_item_metadata
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.list_item_metadata (
    item_id VARCHAR(100) PRIMARY KEY,
    field_id VARCHAR(70),
    item_value VARCHAR(100),
    item_type VARCHAR(20),
    FOREIGN KEY (field_id)
        REFERENCES ireland_dev_saayam_rdbms.req_add_info_metadata(field_id)
);

-- ---------------------------------------------------------------------------
-- 20. request
-- ---------------------------------------------------------------------------
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
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    to_public BOOLEAN,
    UNIQUE (req_id),
    FOREIGN KEY (req_user_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id),
    FOREIGN KEY (req_status_id)
        REFERENCES ireland_dev_saayam_rdbms.request_status(req_status_id),
    FOREIGN KEY (req_priority_id)
        REFERENCES ireland_dev_saayam_rdbms.request_priority(req_priority_id),
    FOREIGN KEY (req_type_id)
        REFERENCES ireland_dev_saayam_rdbms.request_type(req_type_id),
    FOREIGN KEY (req_cat_id)
        REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id),
    FOREIGN KEY (req_for_id)
        REFERENCES ireland_dev_saayam_rdbms.request_for(req_for_id),
    FOREIGN KEY (req_islead_id)
        REFERENCES ireland_dev_saayam_rdbms.request_isleadvol(req_islead_id)
);

-- Request ID generation follows the existing Virginia-compatible format.
CREATE SEQUENCE IF NOT EXISTS ireland_dev_saayam_rdbms.request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_request_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id TEXT;
BEGIN
    IF NEW.req_id IS NOT NULL THEN
        RETURN NEW;
    END IF;

    seq_id := nextval('ireland_dev_saayam_rdbms.request_id_seq');

    new_id := 'REQ-' ||
              LPAD(FLOOR(seq_id / 100000000)::TEXT, 2, '0') || '-' ||
              LPAD(FLOOR((seq_id % 100000000) / 100000)::TEXT, 3, '0') || '-' ||
              LPAD(FLOOR((seq_id % 100000) / 1000)::TEXT, 3, '0') || '-' ||
              LPAD((seq_id % 1000)::TEXT, 4, '0');

    NEW.req_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS before_insert_requests
    ON ireland_dev_saayam_rdbms.request;

CREATE TRIGGER before_insert_requests
BEFORE INSERT ON ireland_dev_saayam_rdbms.request
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_request_id();

-- ---------------------------------------------------------------------------
-- 21. sentiment_codes
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.sentiment_codes (
    code INT PRIMARY KEY,
    label VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL
);

INSERT INTO ireland_dev_saayam_rdbms.sentiment_codes
    (code, label, description)
VALUES
    (0, 'Good Request',
        'Request is clean, no harmful or negative content detected.'),
    (1, 'Foul Language',
        'Request contains offensive or foul language.'),
    (2, 'Depressive or Suicidal',
        'Request contains depressive or suicidal language.'),
    (3, 'Threatening',
        'Request contains threatening language or references to weapons.')
ON CONFLICT (code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 22. fraud_requests
-- ---------------------------------------------------------------------------
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
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    to_public BOOLEAN,
    ref_code INT NOT NULL,
    FOREIGN KEY (ref_code)
        REFERENCES ireland_dev_saayam_rdbms.sentiment_codes(code)
);

-- ---------------------------------------------------------------------------
-- 23. volunteers_assigned
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteers_assigned (
    vol_assigned_id SERIAL PRIMARY KEY,
    req_id VARCHAR(255) NOT NULL,
    volunteer_id VARCHAR(255) NOT NULL,
    volunteer_type VARCHAR(255) NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (req_id)
        REFERENCES ireland_dev_saayam_rdbms.request(req_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (volunteer_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------------
-- 24. volunteer_organizations
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteer_organizations (
    volunteer_organization_id SERIAL PRIMARY KEY,
    contact_id VARCHAR(255) NOT NULL,
    city_name VARCHAR(255) NOT NULL,
    addr_ln1 VARCHAR(255),
    addr_ln2 VARCHAR(255),
    addr_ln3 VARCHAR(255),
    zip_code VARCHAR(255) NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    time_zone VARCHAR(255),
    FOREIGN KEY (contact_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------------
-- 25. notification_channels
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.notification_channels (
    channel_id SERIAL PRIMARY KEY,
    channel_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- ---------------------------------------------------------------------------
-- 26. notification_types
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.notification_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- ---------------------------------------------------------------------------
-- 27. notifications
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'ireland_dev_saayam_rdbms'
          AND t.typname = 'status_type'
    ) THEN
        CREATE TYPE ireland_dev_saayam_rdbms.status_type AS ENUM ('unread', 'read');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    type_id INT NOT NULL,
    channel_id INT NOT NULL,
    message TEXT NOT NULL,
    status ireland_dev_saayam_rdbms.status_type,
    created_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type_id)
        REFERENCES ireland_dev_saayam_rdbms.notification_types(type_id),
    FOREIGN KEY (channel_id)
        REFERENCES ireland_dev_saayam_rdbms.notification_channels(channel_id)
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id
    ON ireland_dev_saayam_rdbms.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status
    ON ireland_dev_saayam_rdbms.notifications(status);
CREATE INDEX IF NOT EXISTS idx_notifications_type_id
    ON ireland_dev_saayam_rdbms.notifications(type_id);
CREATE INDEX IF NOT EXISTS idx_notifications_channel_id
    ON ireland_dev_saayam_rdbms.notifications(channel_id);

-- ---------------------------------------------------------------------------
-- 28. user_notification_preferences
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'ireland_dev_saayam_rdbms'
          AND t.typname = 'preference_type'
    ) THEN
        CREATE TYPE ireland_dev_saayam_rdbms.preference_type
            AS ENUM ('email', 'text', 'both');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_notification_preferences (
    user_notification_preferences_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    channel_id INT NOT NULL,
    preference ireland_dev_saayam_rdbms.preference_type,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id),
    FOREIGN KEY (channel_id)
        REFERENCES ireland_dev_saayam_rdbms.notification_channels(channel_id)
);

-- ---------------------------------------------------------------------------
-- 29. sla
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.sla (
    sla_id SERIAL PRIMARY KEY,
    sla_hours INT NOT NULL,
    sla_description VARCHAR(255) NOT NULL,
    no_of_cust_impct INT,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (sla_id)
);

-- ---------------------------------------------------------------------------
-- 30. user_skills
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'ireland_dev_saayam_rdbms'
          AND t.typname = 'skill_levels'
    ) THEN
        CREATE TYPE ireland_dev_saayam_rdbms.skill_levels
            AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_skills (
    user_id VARCHAR(255),
    cat_id VARCHAR(50) NOT NULL,
    skill_level ireland_dev_saayam_rdbms.skill_levels,
    created_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    PRIMARY KEY (user_id, cat_id),
    FOREIGN KEY (user_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id),
    FOREIGN KEY (cat_id)
        REFERENCES ireland_dev_saayam_rdbms.help_categories(cat_id)
);

CREATE INDEX IF NOT EXISTS idx_user_skills_cat_id
    ON ireland_dev_saayam_rdbms.user_skills(cat_id);

-- ---------------------------------------------------------------------------
-- 31. volunteer_rating
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'ireland_dev_saayam_rdbms'
          AND t.typname = 'rating_enum'
    ) THEN
        CREATE TYPE ireland_dev_saayam_rdbms.rating_enum
            AS ENUM ('0', '1', '2', '3', '4', '5');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.volunteer_rating (
    volunteer_rating_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    req_id VARCHAR(255) NOT NULL,
    rating ireland_dev_saayam_rdbms.rating_enum NOT NULL,
    feedback TEXT,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (req_id)
        REFERENCES ireland_dev_saayam_rdbms.request(req_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_volunteer_rating_user_id
    ON ireland_dev_saayam_rdbms.volunteer_rating(user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_rating_req_id
    ON ireland_dev_saayam_rdbms.volunteer_rating(req_id);

-- ---------------------------------------------------------------------------
-- 32. user_availability
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.user_availability (
    user_availability_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    day_of_week VARCHAR(10)
        CHECK (day_of_week IN
            ('Monday', 'Tuesday', 'Wednesday', 'Thursday',
             'Friday', 'Saturday', 'Sunday')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id)
        REFERENCES ireland_dev_saayam_rdbms.users(user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_availability_user_id
    ON ireland_dev_saayam_rdbms.user_availability(user_id);

-- ---------------------------------------------------------------------------
-- 33. emergency_numbers
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.emergency_numbers (
    en_id SERIAL PRIMARY KEY,
    country_id INT,
    state_id VARCHAR(50),
    en_name VARCHAR(100) NOT NULL UNIQUE,
    is_country BOOLEAN NOT NULL,
    police VARCHAR(75),
    ambulance VARCHAR(75),
    fire VARCHAR(75),
    non_emergency_police VARCHAR(75),
    cyber_police VARCHAR(75),
    medicare_support VARCHAR(75),
    gas_leak VARCHAR(75),
    electricity_outage VARCHAR(75),
    water_department VARCHAR(75),
    disaster_recovery VARCHAR(75),
    flood_help VARCHAR(75),
    earthquake_info VARCHAR(75),
    hurricane_info VARCHAR(75),
    emergency_mgmt VARCHAR(75),
    environmental_hazards VARCHAR(75),
    transportation_assistance VARCHAR(75),
    roadside_assistance VARCHAR(75),
    highway_patrol VARCHAR(75),
    suicide VARCHAR(75),
    help_women VARCHAR(75),
    child_abuse VARCHAR(75),
    domestic_abuse VARCHAR(75),
    mental_health VARCHAR(75),
    elderly_abuse VARCHAR(75),
    poison_control VARCHAR(75),
    animal_control VARCHAR(75),
    wildlife_rescue VARCHAR(75),
    homeless_services VARCHAR(75),
    food_assistance VARCHAR(75),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (country_id)
        REFERENCES ireland_dev_saayam_rdbms.country(country_id),
    FOREIGN KEY (state_id)
        REFERENCES ireland_dev_saayam_rdbms.state(state_id)
);

-- ---------------------------------------------------------------------------
-- 34. organizations
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'ireland_dev_saayam_rdbms'
          AND t.typname = 'org_type_enum'
    ) THEN
        CREATE TYPE ireland_dev_saayam_rdbms.org_type_enum
            AS ENUM ('non_profit', 'for_profit');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'ireland_dev_saayam_rdbms'
          AND t.typname = 'org_size_enum'
    ) THEN
        CREATE TYPE ireland_dev_saayam_rdbms.org_size_enum
            AS ENUM ('small', 'medium', 'large');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.organizations (
    org_id VARCHAR(255) PRIMARY KEY,
    org_name VARCHAR(125) NOT NULL,
    street VARCHAR(255),
    city_name VARCHAR(100),
    state_id VARCHAR(50),
    zip_code VARCHAR(10),
    mission TEXT,
    web_url VARCHAR(255)
        CHECK (web_url IS NULL OR web_url LIKE 'http%'),
    phone VARCHAR(20),
    email VARCHAR(255)
        CHECK (email IS NULL OR email LIKE '%@%'),
    org_type ireland_dev_saayam_rdbms.org_type_enum,
    org_size ireland_dev_saayam_rdbms.org_size_enum,
    org_rating INTEGER CHECK (org_rating >= 1 AND org_rating <= 5),
    is_collaborator BOOLEAN,
    is_contributor BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (state_id)
        REFERENCES ireland_dev_saayam_rdbms.state(state_id)
        ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_org_name
    ON ireland_dev_saayam_rdbms.organizations(org_name);
CREATE INDEX IF NOT EXISTS idx_org_state_id
    ON ireland_dev_saayam_rdbms.organizations(state_id);
CREATE INDEX IF NOT EXISTS idx_org_city_state
    ON ireland_dev_saayam_rdbms.organizations(city_name, state_id);

-- ---------------------------------------------------------------------------
-- 35. req_add_info
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ireland_dev_saayam_rdbms.req_add_info (
    info_id SERIAL PRIMARY KEY,
    req_id VARCHAR(255) NOT NULL,
    field_id VARCHAR(70) NOT NULL,
    item_id VARCHAR(100),
    field_value VARCHAR(255),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC'),
    UNIQUE (req_id, field_id, item_id),
    FOREIGN KEY (req_id)
        REFERENCES ireland_dev_saayam_rdbms.request(req_id),
    FOREIGN KEY (field_id)
        REFERENCES ireland_dev_saayam_rdbms.req_add_info_metadata(field_id),
    FOREIGN KEY (item_id)
        REFERENCES ireland_dev_saayam_rdbms.list_item_metadata(item_id)
);


-- ---------------------------------------------------------------------------
-- Updated-at triggers
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_request_updated_at
    ON ireland_dev_saayam_rdbms.request;
CREATE TRIGGER trg_request_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.request
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_fraud_requests_updated_at
    ON ireland_dev_saayam_rdbms.fraud_requests;
CREATE TRIGGER trg_fraud_requests_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.fraud_requests
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_volunteers_assigned_updated_at
    ON ireland_dev_saayam_rdbms.volunteers_assigned;
CREATE TRIGGER trg_volunteers_assigned_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteers_assigned
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_notifications_updated_at
    ON ireland_dev_saayam_rdbms.notifications;
CREATE TRIGGER trg_notifications_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.notifications
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_user_notification_preferences_updated_at
    ON ireland_dev_saayam_rdbms.user_notification_preferences;
CREATE TRIGGER trg_user_notification_preferences_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_notification_preferences
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_sla_updated_at
    ON ireland_dev_saayam_rdbms.sla;
CREATE TRIGGER trg_sla_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.sla
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_user_skills_updated_at
    ON ireland_dev_saayam_rdbms.user_skills;
CREATE TRIGGER trg_user_skills_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_skills
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_volunteer_rating_updated_at
    ON ireland_dev_saayam_rdbms.volunteer_rating;
CREATE TRIGGER trg_volunteer_rating_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.volunteer_rating
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_user_availability_updated_at
    ON ireland_dev_saayam_rdbms.user_availability;
CREATE TRIGGER trg_user_availability_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.user_availability
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_emergency_numbers_updated_at
    ON ireland_dev_saayam_rdbms.emergency_numbers;
CREATE TRIGGER trg_emergency_numbers_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.emergency_numbers
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_organizations_updated_at
    ON ireland_dev_saayam_rdbms.organizations;
CREATE TRIGGER trg_organizations_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.organizations
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();

DROP TRIGGER IF EXISTS trg_req_add_info_updated_at
    ON ireland_dev_saayam_rdbms.req_add_info;
CREATE TRIGGER trg_req_add_info_updated_at
BEFORE UPDATE ON ireland_dev_saayam_rdbms.req_add_info
FOR EACH ROW
EXECUTE FUNCTION ireland_dev_saayam_rdbms.set_updated_at();


-- ---------------------------------------------------------------------------
-- Validation
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    expected_tables TEXT[] := ARRAY[
        'req_add_info_metadata',
        'list_item_metadata',
        'request',
        'sentiment_codes',
        'fraud_requests',
        'volunteers_assigned',
        'volunteer_organizations',
        'notification_channels',
        'notification_types',
        'notifications',
        'user_notification_preferences',
        'sla',
        'user_skills',
        'volunteer_rating',
        'user_availability',
        'emergency_numbers',
        'organizations',
        'req_add_info'
    ];
    t TEXT;
BEGIN
    FOREACH t IN ARRAY expected_tables LOOP
        IF to_regclass('ireland_dev_saayam_rdbms.' || t) IS NULL THEN
            RAISE EXCEPTION 'Issue #256 validation failed: missing table %', t;
        END IF;
    END LOOP;

    RAISE NOTICE 'Issue #256 validation PASS: Ireland tables 18-35 are present.';
END $$;
