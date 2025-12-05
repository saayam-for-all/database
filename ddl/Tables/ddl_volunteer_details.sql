CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.volunteer_details (
    user_id uuid PRIMARY KEY,
    terms_and_conditions boolean,
    terms_and_conditions_update_date timestamp without time zone,
    govt_id_path text,
    govt_id_update_date timestamp without time zone,
    skills jsonb,
    notification boolean,
    iscomplete boolean,
    completed_date timestamp without time zone,
    location text,
    full_name text,
    email text,
    phone text,
    availability_days text[],
    availability_time text,
    gov_id_content_type text
);