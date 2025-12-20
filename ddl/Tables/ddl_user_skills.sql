DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.user_skills CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.user_skills (
    user_id VARCHAR(255) NOT NULL,
    cat_id INT NOT NULL,

    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE,

    CONSTRAINT user_skills_pkey PRIMARY KEY (user_id, cat_id)
);
