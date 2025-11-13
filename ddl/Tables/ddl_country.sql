-- Table: country
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    phone_code VARCHAR(5) NOT NULL,
    country_code VARCHAR(6) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (country_id)
);
