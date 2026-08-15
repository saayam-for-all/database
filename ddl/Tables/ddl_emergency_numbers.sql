ALTER TABLE virginia_dev_saayam_rdbms.emergency_numbers
    ADD COLUMN IF NOT EXISTS last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC');

ALTER TABLE virginia_dev_saayam_rdbms.emergency_numbers
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DROP TRIGGER IF EXISTS trg_emergency_numbers_updated_at
    ON virginia_dev_saayam_rdbms.emergency_numbers;
CREATE TRIGGER trg_emergency_numbers_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.emergency_numbers
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();
