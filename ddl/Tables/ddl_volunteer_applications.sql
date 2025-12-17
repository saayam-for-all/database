DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_applications CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.volunteer_applications (
    user_id VARCHAR(255) NOT NULL,
    application_status VARCHAR(50) NOT NULL,
    selected_skill_codes INT[],
    govt_id_storage_path VARCHAR(255),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),

    CONSTRAINT volunteer_applications_pkey PRIMARY KEY (user_id),
    CONSTRAINT volunteer_applications_user_fk
        FOREIGN KEY (user_id)
        REFERENCES virginia_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.handle_application_acceptance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.application_status = 'accepted'
       AND OLD.application_status IS DISTINCT FROM NEW.application_status
    THEN
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
        );

        IF NEW.selected_skill_codes IS NOT NULL THEN
            INSERT INTO virginia_dev_saayam_rdbms.user_skills (user_id, cat_id)
            SELECT
                NEW.user_id,
                unnest(NEW.selected_skill_codes);
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

CREATE INDEX IF NOT EXISTS idx_volunteer_applications_status
ON virginia_dev_saayam_rdbms.volunteer_applications (application_status);
