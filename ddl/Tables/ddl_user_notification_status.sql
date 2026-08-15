ALTER TABLE virginia_dev_saayam_rdbms.user_notification_status
    ALTER COLUMN last_accessed_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_accessed_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_accessed_at SET DEFAULT (now() AT TIME ZONE 'UTC');
