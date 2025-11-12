CREATE TYPE status_type AS ENUM('unread', 'read');

-- Table: notifications
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    type_id INT NOT NULL,
    channel_id INT NOT NULL,
    message TEXT NOT NULL,
    status status_type,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type_id) REFERENCES virginia_dev_saayam_rdbms.notification_types (type_id),
    FOREIGN KEY (channel_id) REFERENCES virginia_dev_saayam_rdbms.notification_channels (channel_id)
);


-- Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON virginia_dev_saayam_rdbms.notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON virginia_dev_saayam_rdbms.notifications (status);
CREATE INDEX IF NOT EXISTS idx_notifications_type_id ON virginia_dev_saayam_rdbms.notifications (type_id);
CREATE INDEX IF NOT EXISTS idx_notifications_channel_id ON virginia_dev_saayam_rdbms.notifications (channel_id);