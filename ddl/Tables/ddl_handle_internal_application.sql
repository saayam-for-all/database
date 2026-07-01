-- =====================================================================
-- 2. handle_internal_application
--    Routes the row to internal_team or internal_app_rejections based
--    on terminal application_status, then deletes the source row.
--    Mirrors handle_volunteer_application but supports TWO exits.
-- =====================================================================
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.handle_internal_application()
RETURNS TRIGGER AS $$
BEGIN
    -- ---- APPROVED path -> internal_team ----
    IF (NEW.application_status = 'APPROVED'
        AND OLD.application_status != 'APPROVED') THEN

        INSERT INTO virginia_dev_saayam_rdbms.internal_team (
            user_id, email, first_name, last_name,
            phone_country_code, phone_number, phone_extension,
            linkedin_url, github_url, timezone,
            internal_role, preferred_role, hours_per_week, start_date, engagement_type,
            is_us_based, country, government_id_s3_key,
            is_active, joined_at,
            created_at, last_updated_at
        ) VALUES (
            NEW.user_id, NEW.email, NEW.first_name, NEW.last_name,
            NEW.phone_country_code, NEW.phone_number, NEW.phone_extension,
            NEW.linkedin_url, NEW.github_url, NEW.timezone,
            NEW.preferred_role,    -- default internal_role = applied-for role
            NEW.preferred_role, NEW.hours_per_week, NEW.start_date, NEW.engagement_type,
            NEW.is_us_based, NEW.country, NEW.government_id_s3_key,
            TRUE, (now() AT TIME ZONE 'UTC'),
            NEW.last_updated_at, NEW.last_updated_at
        );

        DELETE FROM virginia_dev_saayam_rdbms.internal_applications
        WHERE user_id = NEW.user_id;

    -- ---- REJECTED path -> internal_app_rejections ----
    ELSIF (NEW.application_status = 'REJECTED'
           AND OLD.application_status != 'REJECTED') THEN

        INSERT INTO virginia_dev_saayam_rdbms.internal_app_rejections (
            user_id, email, first_name, last_name,
            phone_country_code, phone_number, phone_extension,
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
            NEW.phone_country_code, NEW.phone_number, NEW.phone_extension,
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


-- =====================================================================
-- 3. Trigger definitions
-- =====================================================================

-- BEFORE UPDATE: auto-timestamps on internal_applications
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


-- =====================================================================
-- 4. Explicit ENABLE (matches existing volunteer file convention)
-- =====================================================================
ALTER TABLE virginia_dev_saayam_rdbms.internal_applications
    ENABLE TRIGGER trg_internal_app_updated_at;

ALTER TABLE virginia_dev_saayam_rdbms.internal_applications
    ENABLE TRIGGER trg_handle_internal_application;

ALTER TABLE virginia_dev_saayam_rdbms.internal_team
    ENABLE TRIGGER trg_internal_team_updated_at;
