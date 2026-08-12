DO $user_availability_rename$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'user_availability'
          AND column_name = 'last_update_date'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'user_availability'
          AND column_name = 'last_updated_at'
    ) THEN
        ALTER TABLE virginia_dev_saayam_rdbms.user_availability
            RENAME COLUMN last_update_date TO last_updated_at;
    END IF;
END
$user_availability_rename$;

ALTER TABLE virginia_dev_saayam_rdbms.user_availability
    ALTER COLUMN start_time TYPE TIMESTAMP WITHOUT TIME ZONE
        USING start_time::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN end_time TYPE TIMESTAMP WITHOUT TIME ZONE
        USING end_time::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DROP TRIGGER IF EXISTS trg_user_availability_updated_at
    ON virginia_dev_saayam_rdbms.user_availability;
CREATE TRIGGER trg_user_availability_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.user_availability
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();
