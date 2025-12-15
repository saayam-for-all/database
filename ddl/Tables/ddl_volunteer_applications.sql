CREATE TABLE IF NOT EXISTS volunteer_applications (
    user_id VARCHAR(255) NOT NULL,
    application_status VARCHAR(50) NOT NULL,
    availability JSONB,
    selected_skill_codes JSONB,
    current_step INT,
    submitted_at TIMESTAMP,
    updated_at TIMESTAMP,
    terms_and_conditions_accepted_at TIMESTAMP,
    govt_id_storage_path VARCHAR(255),
    govt_id_uploaded_at TIMESTAMP,
    approved_by_user_id VARCHAR(255),
    approved_at TIMESTAMP,
    CONSTRAINT volunteer_applications_pkey PRIMARY KEY (user_id)
);
-- Trigger function: handle application acceptance
CREATE OR REPLACE FUNCTION handle_application_acceptance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    skill_code TEXT;
BEGIN
    IF NEW.application_status = 'accepted'
       AND OLD.application_status IS DISTINCT FROM 'accepted'
    THEN
        -- Insert / update volunteer_details
        INSERT INTO volunteer_details (
            user_id,
            govt_id_path,
            availability_days,
            availability_time,
            iscomplete,
            completed_date
        )
        VALUES (
            NEW.user_id,
            NEW.govt_id_storage_path,
            ARRAY(
                SELECT jsonb_array_elements_text(NEW.availability->'days')
            ),
            NEW.availability->>'time',
            TRUE,
            NOW()
        )
        ON CONFLICT (user_id) DO UPDATE
        SET
            govt_id_path = EXCLUDED.govt_id_path,
            availability_days = EXCLUDED.availability_days,
            availability_time = EXCLUDED.availability_time,
            iscomplete = EXCLUDED.iscomplete,
            completed_date = EXCLUDED.completed_date;

        -- Normalize skills into user_skills
        DELETE FROM user_skills
        WHERE user_id = NEW.user_id;

        IF NEW.selected_skill_codes IS NOT NULL THEN
            FOR skill_code IN
                SELECT jsonb_array_elements_text(NEW.selected_skill_codes)
            LOOP
                INSERT INTO user_skills (user_id, cat_id)
                VALUES (NEW.user_id, skill_code)
                ON CONFLICT (user_id, cat_id) DO NOTHING;
            END LOOP;
        END IF;

        -- Remove application after acceptance
        DELETE FROM volunteer_applications
        WHERE user_id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$;

-- Trigger: fires when application is accepted
CREATE TRIGGER trg_handle_application_acceptance
AFTER UPDATE OF application_status ON volunteer_applications
FOR EACH ROW
WHEN (
    NEW.application_status = 'accepted'
    AND OLD.application_status IS DISTINCT FROM 'accepted'
)
EXECUTE FUNCTION handle_application_acceptance();
