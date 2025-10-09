CREATE EXTENSION IF NOT EXISTS postgis;
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.volunteer_locations (
  user_id VARCHAR(255) NOT NULL PRIMARY KEY,
  prev_loc geography(Point, 4326),
  curr_loc geography(Point, 4326),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (user_id)
  REFERENCES virginia_dev_saayam_rdbms.users (user_id)
  ON DELETE CASCADE
);


CREATE INDEX IF NOT EXISTS idx_volunteer_locations_curr_gist
    ON virginia_dev_saayam_rdbms.volunteer_locations USING GIST (curr_loc); 
CREATE INDEX IF NOT EXISTS idx_volunteer_locations_prev_gist
    ON virginia_dev_saayam_rdbms.volunteer_locations USING GIST (prev_loc);
	

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.fn_shift_prev_loc_volunteer() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.curr_loc IS DISTINCT FROM OLD.curr_loc THEN
        NEW.prev_loc := OLD.curr_loc; 
        NEW.updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_shift_prev_loc_volunteer ON virginia_dev_saayam_rdbms.volunteer_locations; 
CREATE TRIGGER trg_shift_prev_loc_volunteer
BEFORE UPDATE ON virginia_dev_saayam_rdbms.volunteer_locations 
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.fn_shift_prev_loc_volunteer();


CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.fn_locations_insert_as_upsert_volunteer() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$ 
DECLARE k BIGINT;
BEGIN
    k := hashtextextended(NEW.user_id, 0);
    PERFORM pg_advisory_xact_lock(k);
    UPDATE virginia_dev_saayam_rdbms.volunteer_locations l
       SET curr_loc = NEW.curr_loc 
	   WHERE l.user_id = NEW.user_id;

IF FOUND THEN
RETURN NULL;
END IF;

RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_locations_insert_as_upsert_volunteer ON virginia_dev_saayam_rdbms.volunteer_locations; 
CREATE TRIGGER trg_locations_insert_as_upsert_volunteer
BEFORE INSERT ON virginia_dev_saayam_rdbms.volunteer_locations
 
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.fn_locations_insert_as_upsert_volunteer();
