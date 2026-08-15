DO $request_other_details_rename$
BEGIN
    IF to_regclass('virginia_dev_saayam_rdbms.request_guest_details') IS NOT NULL
       AND to_regclass('virginia_dev_saayam_rdbms.request_other_details') IS NULL THEN
        ALTER TABLE virginia_dev_saayam_rdbms.request_guest_details
            RENAME TO request_other_details;
    ELSIF to_regclass('virginia_dev_saayam_rdbms.request_guest_details') IS NOT NULL
       AND to_regclass('virginia_dev_saayam_rdbms.request_other_details') IS NOT NULL THEN
        RAISE EXCEPTION 'Both request_guest_details and request_other_details exist. Resolve the duplicate tables manually.';
    END IF;
END
$request_other_details_rename$;

ALTER TABLE virginia_dev_saayam_rdbms.request_other_details
    ADD COLUMN IF NOT EXISTS user_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS last_updated_at TIMESTAMP WITHOUT TIME ZONE
        DEFAULT (now() AT TIME ZONE 'UTC');

-- The Wiki after-state makes these fields nullable.
ALTER TABLE virginia_dev_saayam_rdbms.request_other_details
    ALTER COLUMN req_fname DROP NOT NULL,
    ALTER COLUMN req_lname DROP NOT NULL,
    ALTER COLUMN req_phone DROP NOT NULL,
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DO $request_other_details_user_fk$
DECLARE
    v_constraint text;
BEGIN
    FOR v_constraint IN
        SELECT c.conname
        FROM pg_constraint c
        WHERE c.conrelid = 'virginia_dev_saayam_rdbms.request_other_details'::regclass
          AND c.contype = 'f'
          AND EXISTS (
              SELECT 1
              FROM unnest(c.conkey) AS key(attnum)
              JOIN pg_attribute a
                ON a.attrelid = c.conrelid
               AND a.attnum = key.attnum
              WHERE a.attname = 'user_id'
          )
    LOOP
        EXECUTE format(
            'ALTER TABLE virginia_dev_saayam_rdbms.request_other_details DROP CONSTRAINT %I',
            v_constraint
        );
    END LOOP;

    ALTER TABLE virginia_dev_saayam_rdbms.request_other_details
        ADD CONSTRAINT request_other_details_user_id_fkey
        FOREIGN KEY (user_id)
        REFERENCES virginia_dev_saayam_rdbms.users(user_id)
        ON DELETE SET NULL;
END
$request_other_details_user_fk$;

DROP TRIGGER IF EXISTS trg_request_other_details_updated_at
    ON virginia_dev_saayam_rdbms.request_other_details;
CREATE TRIGGER trg_request_other_details_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.request_other_details
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();
