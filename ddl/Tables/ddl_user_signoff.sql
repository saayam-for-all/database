ALTER TABLE virginia_dev_saayam_rdbms.user_signoff
    ADD COLUMN IF NOT EXISTS is_external_auth BOOLEAN,
    ADD COLUMN IF NOT EXISTS last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC');

ALTER TABLE virginia_dev_saayam_rdbms.user_signoff
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DROP TRIGGER IF EXISTS trg_user_signoff_updated_at
    ON virginia_dev_saayam_rdbms.user_signoff;
CREATE TRIGGER trg_user_signoff_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.user_signoff
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

COMMIT;
