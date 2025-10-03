-- Table: request_priority
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_priority (
    priority_id SERIAL PRIMARY KEY,
    priority_value VARCHAR(25) NOT NULL,
    priority_desc VARCHAR(125),
    last_updated_date TIMESTAMP,
    UNIQUE (priority_id)
);
