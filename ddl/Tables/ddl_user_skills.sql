CREATE TYPE skill_levels AS ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT');

-- Table: user_skills
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_skills (
	user_skills_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    skill_id INT NOT NULL,
    skill_level skill_levels,
    last_used_date TIMESTAMP,
    created_date TIMESTAMP,
    last_update_date TIMESTAMP,
    FOREIGN KEY (skill_id) REFERENCES virginia_dev_saayam_rdbms.skills_list (skill_list_id),
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id)
);
