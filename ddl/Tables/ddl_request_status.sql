-- Table: request_status
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_status (
    request_status_id SERIAL PRIMARY KEY,
    request_status VARCHAR(255) NOT NULL,
    request_status_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);