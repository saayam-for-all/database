DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_applications CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.volunteer_applications (
    user_id VARCHAR(255) PRIMARY KEY,

    terms_and_conditions BOOLEAN,
    terms_and_conditions_accepted_at TIMESTAMP WITHOUT TIME ZONE,

    skill_codes JSON,
    availability JSONB,

    application_status TEXT,
    is_completed BOOLEAN,
    current_page TEXT,

    govt_id_storage_path TEXT,
    path_updated_at TIMESTAMP WITHOUT TIME ZONE,

    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.set_application_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_application_updated_at
ON virginia_dev_saayam_rdbms.volunteer_applications;

CREATE TRIGGER trg_set_application_updated_at
BEFORE UPDATE
ON virginia_dev_saayam_rdbms.volunteer_applications
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_application_updated_at();

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.handle_application_acceptance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
 IF OLD.application_status = 'submitted'
       AND NEW.application_status = 'accepted'
    THEN
        INSERT INTO virginia_dev_saayam_rdbms.volunteer_details (
            user_id,
            terms_and_conditions,
            terms_and_conditions_update_date,
            govt_id_path1, 
            availability_days,
            availability_times,
            created_at,
            updated_at
        )
        VALUES (
            NEW.user_id,
            NEW.terms_and_conditions,
            NEW.terms_and_conditions_accepted_at,
            NEW.govt_id_storage_path,
            NEW.availability -> 'days',
            NEW.availability -> 'time',
            NEW.updated_at,
            NEW.updated_at
        );

        IF NEW.skill_codes IS NOT NULL THEN
            INSERT INTO virginia_dev_saayam_rdbms.user_skills (
                user_id,
                cat_id,
                created_at,
                updated_at
            )
            SELECT
 NEW.user_id,
                value::INT,
                NEW.updated_at,
                NEW.updated_at 
            FROM json_array_elements_text(NEW.skill_codes);
        END IF;
         
        DELETE FROM virginia_dev_saayam_rdbms.volunteer_applications
        WHERE user_id = NEW.user_id;
    END IF;
            
    RETURN NULL;
END;
$$;
            
DROP TRIGGER IF EXISTS trg_handle_application_acceptance
ON virginia_dev_saayam_rdbms.volunteer_applications;

CREATE TRIGGER trg_handle_application_acceptance
AFTER UPDATE OF application_status
ON virginia_dev_saayam_rdbms.volunteer_applications
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.handle_application_acceptance();
