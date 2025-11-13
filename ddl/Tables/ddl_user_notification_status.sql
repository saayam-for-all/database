CREATE TABLE virginia_dev_saayam_rdbms.user_notification_status (
    user_id VARCHAR(255) PRIMARY KEY,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id) ON DELETE CASCADE
);
