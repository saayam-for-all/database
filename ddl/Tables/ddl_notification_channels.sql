--Table: notification_channels
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.notification_channels (
    channel_id SERIAL PRIMARY KEY,
    channel_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);