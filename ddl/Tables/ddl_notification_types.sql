-- Table: notification_types
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.notification_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);