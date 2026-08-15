ALTER TABLE virginia_dev_saayam_rdbms.user_org_map
    ALTER COLUMN created_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING created_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN created_at SET DEFAULT (now() AT TIME ZONE 'UTC'),
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DROP TRIGGER IF EXISTS trg_user_org_map_updated_at
    ON virginia_dev_saayam_rdbms.user_org_map;
CREATE TRIGGER trg_user_org_map_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.user_org_map
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();
