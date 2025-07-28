-- Table: user_status
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_status (
    user_status_id SERIAL PRIMARY KEY,
    user_status VARCHAR(255) NOT NULL,
    user_status_desc VARCHAR(255),
    last_update_date TIMESTAMP,
    UNIQUE (user_status_id)
);