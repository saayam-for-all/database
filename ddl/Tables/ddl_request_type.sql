-- Table: request_type
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_type (
    request_type_id SERIAL PRIMARY KEY,
    request_type VARCHAR(255),
    request_type_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);