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
    -- Global: if API didn't explicitly set last_updated_at, force UTC now.
    IF (NEW.last_updated_at IS NOT DISTINCT FROM OLD.last_updated_at) THEN
        NEW.last_updated_at = (now() AT TIME ZONE 'UTC');
    END IF;
 
    -- EXISTING: volunteer_applications
    IF (TG_TABLE_NAME = 'volunteer_applications') THEN
        IF (NEW.govt_id_path IS DISTINCT FROM OLD.govt_id_path) THEN
            NEW.path_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.terms_and_conditions IS TRUE
            AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;
 
    -- EXISTING: volunteer_details
    ELSIF (TG_TABLE_NAME = 'volunteer_details') THEN
        IF (NEW.govt_id_path1 IS DISTINCT FROM OLD.govt_id_path1) THEN
            NEW.path1_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.govt_id_path2 IS DISTINCT FROM OLD.govt_id_path2) THEN
            NEW.path2_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.terms_and_conditions IS TRUE
            AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;
 
    -- NEW: internal_applications
    ELSIF (TG_TABLE_NAME = 'internal_applications') THEN
        -- Stamp govt_id_path_updated_at when the S3 key changes
        IF (NEW.government_id_s3_key IS DISTINCT FROM OLD.government_id_s3_key) THEN
            NEW.govt_id_path_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
 
        -- Stamp acknowledgments_accepted_at when consent JSON changes
        IF (NEW.acknowledgments IS DISTINCT FROM OLD.acknowledgments) THEN
            NEW.acknowledgments_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;
 
        -- Stamp reviewed_at when status hits a terminal state
        IF (NEW.application_status IS DISTINCT FROM OLD.application_status
            AND NEW.application_status IN ('APPROVED', 'REJECTED')) THEN
            NEW.reviewed_at = (now() AT TIME ZONE 'UTC');
        END IF;
 
    -- NEW: internal_team
    ELSIF (TG_TABLE_NAME = 'internal_team') THEN
        -- Stamp deactivated_at when is_active flips from TRUE/NULL to FALSE
        IF (NEW.is_active IS FALSE
            AND (OLD.is_active IS TRUE OR OLD.is_active IS NULL)) THEN
            NEW.deactivated_at = (now() AT TIME ZONE 'UTC');
        END IF;
    END IF;
 
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.handle_internal_application()
RETURNS TRIGGER AS $$
BEGIN
    -- ---- APPROVED path ----
    IF (NEW.application_status = 'APPROVED'
        AND OLD.application_status != 'APPROVED') THEN

        INSERT INTO virginia_dev_saayam_rdbms.internal_team (
            user_id, email, first_name, last_name,
            phone_country_code, phone_number,
            linkedin_url, github_url, timezone,
            internal_role, preferred_role, hours_per_week, start_date, engagement_type,
            is_us_based, country, government_id_s3_key,
            is_active, joined_at,
            created_at, last_updated_at
        ) VALUES (
            NEW.user_id, NEW.email, NEW.first_name, NEW.last_name,
            NEW.phone_country_code, NEW.phone_number,
            NEW.linkedin_url, NEW.github_url, NEW.timezone,
            NEW.preferred_role,    -- default internal_role = what they applied for
            NEW.preferred_role, NEW.hours_per_week, NEW.start_date, NEW.engagement_type,
            NEW.is_us_based, NEW.country, NEW.government_id_s3_key,
            TRUE, (now() AT TIME ZONE 'UTC'),
            NEW.last_updated_at, NEW.last_updated_at
        );

        DELETE FROM virginia_dev_saayam_rdbms.internal_applications
        WHERE user_id = NEW.user_id;

    -- ---- REJECTED path ----
    ELSIF (NEW.application_status = 'REJECTED'
           AND OLD.application_status != 'REJECTED') THEN

        INSERT INTO virginia_dev_saayam_rdbms.internal_app_rejections (
            user_id, email, first_name, last_name,
            phone_country_code, phone_number,
            linkedin_url, github_url,
            college, degree_program, relevant_experience,
            preferred_role, hours_per_week, start_date, engagement_type,
            is_us_based, country,
            resume_s3_key, ead_card_s3_key, i20_s3_key, government_id_s3_key,
            acknowledgments,
            rejection_reason, reviewer_cognito_id, reviewer_notes,
            application_created_at, rejected_at
        ) VALUES (
            NEW.user_id, NEW.email, NEW.first_name, NEW.last_name,
            NEW.phone_country_code, NEW.phone_number,
            NEW.linkedin_url, NEW.github_url,
            NEW.college, NEW.degree_program, NEW.relevant_experience,
            NEW.preferred_role, NEW.hours_per_week, NEW.start_date, NEW.engagement_type,
            NEW.is_us_based, NEW.country,
            NEW.resume_s3_key, NEW.ead_card_s3_key, NEW.i20_s3_key, NEW.government_id_s3_key,
            NEW.acknowledgments,
            COALESCE(NEW.rejection_reason, 'No reason supplied'),
            NEW.reviewer_cognito_id, NEW.reviewer_notes,
            NEW.created_at, (now() AT TIME ZONE 'UTC')
        );

        DELETE FROM virginia_dev_saayam_rdbms.internal_applications
        WHERE user_id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_internal_app_updated_at
    BEFORE UPDATE ON virginia_dev_saayam_rdbms.internal_applications
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.updated_at_handler();

-- BEFORE UPDATE: auto-timestamps on internal_team
CREATE TRIGGER trg_internal_team_updated_at
    BEFORE UPDATE ON virginia_dev_saayam_rdbms.internal_team
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.updated_at_handler();

-- AFTER UPDATE: route on terminal application_status
CREATE TRIGGER trg_handle_internal_application
    AFTER UPDATE ON virginia_dev_saayam_rdbms.internal_applications
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.handle_internal_application();

-- 4. Explicit ENABLE (matches existing volunteer file convention)
ALTER TABLE virginia_dev_saayam_rdbms.internal_applications
    ENABLE TRIGGER trg_internal_app_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.internal_applications
    ENABLE TRIGGER trg_handle_internal_application;

ALTER TABLE virginia_dev_saayam_rdbms.internal_team
    ENABLE TRIGGER trg_internal_team_updated_at;
