DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_details CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.volunteer_details (
    user_id VARCHAR(255) PRIMARY KEY,

    terms_and_conditions BOOLEAN,
    terms_and_conditions_update_date TIMESTAMP WITHOUT TIME ZONE,

    govt_id_path1 TEXT,
    govt_id_path2 TEXT,
    path1_updated_at TIMESTAMP WITHOUT TIME ZONE,
    path2_updated_at TIMESTAMP WITHOUT TIME ZONE,

    availability_days JSON,
    availability_times JSON,

    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE
);
