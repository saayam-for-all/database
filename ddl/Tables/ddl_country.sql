-- Table: country
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL,
    phone_country_code INT NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (country_id)
);