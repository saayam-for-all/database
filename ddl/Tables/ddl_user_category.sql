-- DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.user_category CASCADE;

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_category (
-- Existing Columns
user_category_id SERIAL PRIMARY KEY,
user_category VARCHAR(255) NOT NULL,
user_category_desc VARCHAR(255),

-- New Columns
user_access_level SMALLINT, -- Permission hierarchy
category_code VARCHAR(50) UNIQUE, -- Short code, made UNIQUE for data integrity
is_deprecated BOOLEAN DEFAULT FALSE, -- Enable/disable flag
permissions JSONB, -- Stores granular permissions in JSON format

-- Updated Column Name and Default Value
last_updated_at TIMESTAMP DEFAULT NOW()
);
