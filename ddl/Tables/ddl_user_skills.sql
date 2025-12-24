DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.user_skills CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.user_skills (
    user_id VARCHAR(255),
    cat_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    PRIMARY KEY (user_id, cat_id),
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id),
    FOREIGN KEY (cat_id) REFERENCES virginia_dev_saayam_rdbms.help_categories(cat_id)
);

CREATE TRIGGER trg_user_skills_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.user_skills
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_user_skills_cat_id  ON virginia_dev_saayam_rdbms.user_skills (cat_id);
