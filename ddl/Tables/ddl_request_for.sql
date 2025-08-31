CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_for (
    request_for_id SERIAL PRIMARY KEY,
    request_for VARCHAR(255) NOT NULL,
    request_for_desc VARCHAR(255),
    last_updated_date TIMESTAMP
);