CREATE TYPE preference_type AS ENUM('email', 'text', 'both');

-- Table: user_notification_preferences
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_notification_preferences (
	user_notification_preferences_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    channel_id INT NOT NULL,
    preference preference_type,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id),
    FOREIGN KEY (channel_id) REFERENCES virginia_dev_saayam_rdbms.notification_channels (channel_id)
);