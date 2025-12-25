-- ENUM for application status
CREATE TYPE virginia_dev_saayam_rdbms.app_status_type AS ENUM ('STARTED', 'IN_REVIEW', 'ACCEPTED', 'REJECTED');

-- Create the volunteer_applications table
CREATE TABLE virginia_dev_saayam_rdbms.volunteer_applications (
    user_id VARCHAR(255) PRIMARY KEY,
    terms_and_conditions BOOLEAN DEFAULT FALSE,
    terms_accepted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    govt_id_path TEXT,
    path_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    skill_codes JSON,
    availability JSONB,
    current_page INT DEFAULT 1, -- Changed from TEXT to INT for numerical tracking
    application_status virginia_dev_saayam_rdbms.app_status_type DEFAULT 'STARTED',    
    is_completed BOOLEAN DEFAULT FALSE, --extra precaution    
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id)
);

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.updated_at_handler()
RETURNS TRIGGER AS $$
BEGIN
    -- check if the last_updated_at was explicitly changed in the UPDATE statement.
    -- if it WASN'T changed by the API, we force it to the current UTC.
    IF (NEW.last_updated_at IS NOT DISTINCT FROM OLD.last_updated_at) THEN
        NEW.last_updated_at = (now() AT TIME ZONE 'UTC');
    END IF;

    -- handle application table 
    IF (TG_TABLE_NAME = 'volunteer_applications') THEN
        -- Update path timestamp if path changed
        IF (NEW.govt_id_path IS DISTINCT FROM OLD.govt_id_path) THEN
            NEW.path_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;

        -- Update terms timestamp if accepted
        IF (NEW.terms_and_conditions IS TRUE AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;

    -- handle details table 
    ELSIF (TG_TABLE_NAME = 'volunteer_details') THEN
        -- update path1 timestamp if changed
        IF (NEW.govt_id_path1 IS DISTINCT FROM OLD.govt_id_path1) THEN
            NEW.path1_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        
        -- update path2 timestamp if changed
        IF (NEW.govt_id_path2 IS DISTINCT FROM OLD.govt_id_path2) THEN
            NEW.path2_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;

        -- update terms timestamp if accepted
        IF (NEW.terms_and_conditions IS TRUE AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.handle_volunteer_application()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.application_status = 'ACCEPTED' AND OLD.application_status != 'ACCEPTED') THEN
        
        -- Migrate to volunteer_details
        INSERT INTO virginia_dev_saayam_rdbms.volunteer_details (
            user_id, terms_and_conditions, terms_accepted_at, 
            govt_id_path1, path1_updated_at, path2_updated_at, availability_days, availability_times, 
            created_at, last_updated_at
        ) VALUES (
            NEW.user_id, NEW.terms_and_conditions, NEW.terms_accepted_at,
            NEW.govt_id_path, NEW.path_updated_at, NULL, (NEW.availability -> 'days')::JSONB, (NEW.availability -> 'time')::JSONB,
            NEW.last_updated_at, NEW.last_updated_at
        );

        -- Migrate to user_skills (unrolling the JSON array)
        IF (NEW.skill_codes IS NOT NULL) THEN
            INSERT INTO virginia_dev_saayam_rdbms.user_skills (
                user_id, cat_id, created_at, last_updated_at
            )
            SELECT 
                NEW.user_id, 
                skill_id, 
                NEW.last_updated_at, 
                NEW.last_updated_at
            FROM json_array_elements_text(NEW.skill_codes) AS skill_id;
        END IF;

		DELETE FROM virginia_dev_saayam_rdbms.volunteer_applications WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_volunteer_app_updated_at
    BEFORE UPDATE ON virginia_dev_saayam_rdbms.volunteer_applications
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.updated_at_handler();

CREATE TRIGGER trg_handle_volunteer_application
    AFTER UPDATE ON virginia_dev_saayam_rdbms.volunteer_applications
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.handle_volunteer_application();

ALTER TABLE virginia_dev_saayam_rdbms.volunteer_applications ENABLE TRIGGER trg_volunteer_app_updated_at;
