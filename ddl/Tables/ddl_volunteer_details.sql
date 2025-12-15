DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_details CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.volunteer_details (
    user_id VARCHAR(255) PRIMARY KEY,

    terms_and_conditions boolean,
    terms_and_conditions_update_date timestamp without time zone,

    govt_id_path text,
    govt_id_update_date timestamp without time zone,
    gov_id_content_type text,

    notification boolean,
    iscomplete boolean,
    completed_date timestamp without time zone,

    availability_days text[],
    availability_time text,

    location text,

    created_at timestamp without time zone DEFAULT now(),

    CONSTRAINT volunteer_details_user_fk
        FOREIGN KEY (user_id)
        REFERENCES virginia_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE
);
