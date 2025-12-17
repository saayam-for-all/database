DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_applications CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.volunteer_applications (
    user_id VARCHAR(255) NOT NULL,
    application_status VARCHAR(50) NOT NULL,
    availability JSONB,
    selected_skill_codes INT[],
    govt_id_storage_path VARCHAR(255),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),

    CONSTRAINT volunteer_applications_pkey PRIMARY KEY (user_id)
);

-- Trigger function: handle application acceptance
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.handle_application_acceptance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only act when status changes to 'accepted'
    IF NEW.application_status = 'accepted'
       AND OLD.application_status IS DISTINCT FROM NEW.application_status
    THEN
        -- Upsert into volunteer_details
        INSERT INTO virginia_dev_saayam_rdbms.volunteer_details (
            user_id,
            govt_id_path,
            govt_id_path2,
            iscomplete,
            completed_date
        )
        VALUES (
            NEW.user_id,
            NEW.govt_id_storage_path,
            NULL,
            TRUE,
            now()
        )
        ON CONFLICT (user_id)
        DO UPDATE SET
            govt_id_path   = EXCLUDED.govt_id_path,
            iscomplete     = TRUE,
            completed_date = now();

        -- Insert user skills
        IF NEW.selected_skill_codes IS NOT NULL THEN
            INSERT INTO virginia_dev_saayam_rdbms.user_skills (user_id, cat_id)
            SELECT
                NEW.user_id,
                unnest(NEW.selected_skill_codes)
            ON CONFLICT DO NOTHING;
        END IF;

        -- Remove the application after acceptance
        DELETE FROM virginia_dev_saayam_rdbms.volunteer_applications
        WHERE user_id = NEW.user_id;
    END IF;

    RETURN NULL;
END;
$$;

-- Trigger
DROP TRIGGER IF EXISTS trg_handle_application_acceptance
ON virginia_dev_saayam_rdbms.volunteer_applications;

CREATE TRIGGER trg_handle_application_acceptance
AFTER UPDATE OF application_status
ON virginia_dev_saayam_rdbms.volunteer_applications
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.handle_application_acceptance();

