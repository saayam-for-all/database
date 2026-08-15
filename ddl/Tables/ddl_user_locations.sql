DO $user_locations_rename$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'user_locations'
          AND column_name = 'updated_at'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'virginia_dev_saayam_rdbms'
          AND table_name = 'user_locations'
          AND column_name = 'last_updated_at'
    ) THEN
        ALTER TABLE virginia_dev_saayam_rdbms.user_locations
            RENAME COLUMN updated_at TO last_updated_at;
    END IF;
END
$user_locations_rename$;

DO $user_locations_timestamp_type$
DECLARE
    v_type text;
BEGIN
    SELECT a.atttypid::regtype::text
      INTO v_type
      FROM pg_attribute a
     WHERE a.attrelid = 'virginia_dev_saayam_rdbms.user_locations'::regclass
       AND a.attname = 'last_updated_at'
       AND a.attnum > 0
       AND NOT a.attisdropped;

    IF v_type = 'timestamp with time zone' THEN
        ALTER TABLE virginia_dev_saayam_rdbms.user_locations
            ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
            USING last_updated_at AT TIME ZONE 'UTC';
    ELSIF v_type <> 'timestamp without time zone' THEN
        ALTER TABLE virginia_dev_saayam_rdbms.user_locations
            ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
            USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE;
    END IF;
END
$user_locations_timestamp_type$;

ALTER TABLE virginia_dev_saayam_rdbms.user_locations
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC'),
    ALTER COLUMN last_updated_at DROP NOT NULL;

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.fn_shift_prev_loc_user()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $shift_prev_location$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.curr_loc IS DISTINCT FROM OLD.curr_loc THEN
        NEW.prev_loc := OLD.curr_loc;
        NEW.last_updated_at := (now() AT TIME ZONE 'UTC');
    END IF;
    RETURN NEW;
END
$shift_prev_location$;

DROP TRIGGER IF EXISTS trg_shift_prev_loc_user
    ON virginia_dev_saayam_rdbms.user_locations;
CREATE TRIGGER trg_shift_prev_loc_user
BEFORE UPDATE ON virginia_dev_saayam_rdbms.user_locations
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.fn_shift_prev_loc_user();

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.fn_locations_insert_as_upsert_user()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $locations_upsert$
DECLARE
    k BIGINT;
BEGIN
    k := hashtextextended(NEW.user_id, 0);
    PERFORM pg_advisory_xact_lock(k);

    UPDATE virginia_dev_saayam_rdbms.user_locations AS l
       SET curr_loc = NEW.curr_loc
     WHERE l.user_id = NEW.user_id;

    IF FOUND THEN
        RETURN NULL;
    END IF;

    RETURN NEW;
END
$locations_upsert$;

DROP TRIGGER IF EXISTS trg_locations_insert_as_upsert_user
    ON virginia_dev_saayam_rdbms.user_locations;
CREATE TRIGGER trg_locations_insert_as_upsert_user
BEFORE INSERT ON virginia_dev_saayam_rdbms.user_locations
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.fn_locations_insert_as_upsert_user();
