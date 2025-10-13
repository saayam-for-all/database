-- Table: request_categories REMOVE THIS AS WE HAVE SEPERATE HELP CATEGORIES SUB SCHEMA
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_categories (
    request_category_id SERIAL PRIMARY KEY,
    request_category VARCHAR(255) NOT NULL,
    request_category_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);
