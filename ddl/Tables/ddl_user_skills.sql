DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.user_skills CASCADE;

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_skills (
    user_id uuid NOT NULL,
    cat_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),

    CONSTRAINT user_skills_pk
        PRIMARY KEY (user_id, cat_id),

    CONSTRAINT user_skills_user_fk
        FOREIGN KEY (user_id)
        REFERENCES virginia_dev_saayam_rdbms.users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT user_skills_category_fk
        FOREIGN KEY (cat_id)
        REFERENCES virginia_dev_saayam_rdbms.help_categories(cat_id)
);