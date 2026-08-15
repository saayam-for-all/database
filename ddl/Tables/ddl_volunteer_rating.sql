DO $rating_type$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'virginia_dev_saayam_rdbms'
          AND t.typname = 'rating_enum'
    ) THEN
        CREATE TYPE virginia_dev_saayam_rdbms.rating_enum
            AS ENUM ('0', '1', '2', '3', '4', '5');
    END IF;
END
$rating_type$;

DO $volunteer_rating_renames$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'volunteer_rating'
          AND column_name = 'request_id'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'volunteer_rating'
          AND column_name = 'req_id'
    ) THEN
        ALTER TABLE virginia_dev_saayam_rdbms.volunteer_rating
            RENAME COLUMN request_id TO req_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'volunteer_rating'
          AND column_name = 'last_update_date'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'volunteer_rating'
          AND column_name = 'last_updated_at'
    ) THEN
        ALTER TABLE virginia_dev_saayam_rdbms.volunteer_rating
            RENAME COLUMN last_update_date TO last_updated_at;
    END IF;
END
$volunteer_rating_renames$;

ALTER TABLE virginia_dev_saayam_rdbms.volunteer_rating
    ALTER COLUMN rating TYPE virginia_dev_saayam_rdbms.rating_enum
        USING rating::text::virginia_dev_saayam_rdbms.rating_enum,
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DO $volunteer_rating_fk$
DECLARE
    v_constraint text;
BEGIN
    FOR v_constraint IN
        SELECT c.conname
        FROM pg_constraint c
        WHERE c.conrelid = 'virginia_dev_saayam_rdbms.volunteer_rating'::regclass
          AND c.contype = 'f'
          AND EXISTS (
              SELECT 1
              FROM unnest(c.conkey) AS key(attnum)
              JOIN pg_attribute a
                ON a.attrelid = c.conrelid
               AND a.attnum = key.attnum
              WHERE a.attname = 'req_id'
          )
    LOOP
        EXECUTE format(
            'ALTER TABLE virginia_dev_saayam_rdbms.volunteer_rating DROP CONSTRAINT %I',
            v_constraint
        );
    END LOOP;

    ALTER TABLE virginia_dev_saayam_rdbms.volunteer_rating
        ADD CONSTRAINT volunteer_rating_req_id_fkey
        FOREIGN KEY (req_id)
        REFERENCES virginia_dev_saayam_rdbms.request(req_id)
        ON DELETE CASCADE ON UPDATE CASCADE;
END
$volunteer_rating_fk$;

DO $volunteer_rating_index$
BEGIN
    IF to_regclass('virginia_dev_saayam_rdbms.idx_volunteer_rating_request_id') IS NOT NULL
       AND to_regclass('virginia_dev_saayam_rdbms.idx_volunteer_rating_req_id') IS NULL THEN
        ALTER INDEX virginia_dev_saayam_rdbms.idx_volunteer_rating_request_id
            RENAME TO idx_volunteer_rating_req_id;
    ELSIF to_regclass('virginia_dev_saayam_rdbms.idx_volunteer_rating_request_id') IS NOT NULL
       AND to_regclass('virginia_dev_saayam_rdbms.idx_volunteer_rating_req_id') IS NOT NULL THEN
        DROP INDEX virginia_dev_saayam_rdbms.idx_volunteer_rating_request_id;
    END IF;
END
$volunteer_rating_index$;

CREATE INDEX IF NOT EXISTS idx_volunteer_rating_user_id
    ON virginia_dev_saayam_rdbms.volunteer_rating(user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_rating_req_id
    ON virginia_dev_saayam_rdbms.volunteer_rating(req_id);

DROP TRIGGER IF EXISTS trg_volunteer_rating_updated_at
    ON virginia_dev_saayam_rdbms.volunteer_rating;
CREATE TRIGGER trg_volunteer_rating_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.volunteer_rating
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();
