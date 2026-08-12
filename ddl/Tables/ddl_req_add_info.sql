DO $req_add_info_rename$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'req_add_info'
          AND column_name = 'id'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'req_add_info'
          AND column_name = 'info_id'
    ) THEN
        ALTER TABLE virginia_dev_saayam_rdbms.req_add_info
            RENAME COLUMN id TO info_id;
    END IF;
END
$req_add_info_rename$;

ALTER TABLE virginia_dev_saayam_rdbms.req_add_info
    ADD COLUMN IF NOT EXISTS last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC');

ALTER TABLE virginia_dev_saayam_rdbms.req_add_info
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DROP TRIGGER IF EXISTS trg_req_add_info_updated_at
    ON virginia_dev_saayam_rdbms.req_add_info;
CREATE TRIGGER trg_req_add_info_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.req_add_info
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();
