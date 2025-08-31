-- Table: action
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.action (
    action_id SERIAL PRIMARY KEY,
    action_desc VARCHAR(30) NOT NULL,
    created_date TIMESTAMP,
    created_by VARCHAR(30),
    last_update_by VARCHAR(30),
    last_update_date TIMESTAMP,
    UNIQUE (action_id)
);