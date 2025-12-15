DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.user_skills CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.user_skills (
    user_id VARCHAR(255) NOT NULL,
    cat_id varchar(50) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),

    CONSTRAINT user_skills_pk PRIMARY KEY (user_id, cat_id),

    CONSTRAINT user_skills_user_fk
        FOREIGN KEY (user_id)
        REFERENCES virginia_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT user_skills_cat_fk
        FOREIGN KEY (cat_id)
        REFERENCES virginia_dev_saayam_rdbms.help_categories(cat_id)
);
