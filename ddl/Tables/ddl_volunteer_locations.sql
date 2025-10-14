CREATE EXTENSION IF NOT EXISTS postgis;
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.volunteer_locations (
  volunteer_detail_id VARCHAR(255) NOT NULL PRIMARY KEY,
  prev_loc geography(Point, 4326),
  curr_loc geography(Point, 4326),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (volunteer_detail_id)
  REFERENCES virginia_dev_saayam_rdbms.volunteer_details (volunteer_detail_id)
  ON DELETE CASCADE
);


CREATE INDEX IF NOT EXISTS idx_volunteer_locations_curr_gist
    ON virginia_dev_saayam_rdbms.volunteer_locations USING GIST (curr_loc); 
CREATE INDEX IF NOT EXISTS idx_volunteer_locations_prev_gist
    ON virginia_dev_saayam_rdbms.volunteer_locations USING GIST (prev_loc);
	
-- Trigger function to shift old curr_loc -> prev_loc on update
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

/*Trigger function for INSERT ... (user_id, curr_loc); if the row exists, we update instead (and also do the prev→curr 
shift). We can also add a per-user advisory lock to prevent rare race conditions with concurrent inserts.*/

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.fn_locations_insert_as_upsert_volunteer() 
RETURNS trigger
LANGUAGE plpgsql 
AS $$ 
DECLARE k BIGINT;
BEGIN
    -- Serialize concurrent inserts for the same user
    k := hashtextextended(NEW.user_id, 0);
    PERFORM pg_advisory_xact_lock(k);
	-- If row exists, UPDATE only curr_loc (shift handled by BEFORE UPDATE trigger)
    UPDATE virginia_dev_saayam_rdbms.volunteer_locations l
       SET curr_loc = NEW.curr_loc 
	   WHERE l.user_id = NEW.user_id;

IF FOUND THEN
RETURN NULL;  -- suppress the original INSERT
END IF;
-- No row yet → proceed with INSERT
RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_locations_insert_as_upsert_volunteer ON virginia_dev_saayam_rdbms.volunteer_locations; 
CREATE TRIGGER trg_locations_insert_as_upsert_volunteer
BEFORE INSERT ON virginia_dev_saayam_rdbms.volunteer_locations
 
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.fn_locations_insert_as_upsert_volunteer();

/*-- How it flows
-- First insert → row created (curr_loc set, prev_loc NULL).
-- Later insert for same user → trigger converts to UPDATE curr_loc → fn_shift_prev_loc() runs and moves old curr to 
prev, updates timestamp.
-- Direct updates (if any) → handled by fn_shift_prev_loc() the same way. */

