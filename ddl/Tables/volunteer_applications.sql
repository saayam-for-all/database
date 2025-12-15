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
