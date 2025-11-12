-- Table: skill_lst
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.skill_list (
    skill_list_id SERIAL PRIMARY KEY,
    request_category_id INT NOT NULL,
    skill_desc VARCHAR(100) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (skill_list_id),
    FOREIGN KEY (request_category_id) REFERENCES virginia_dev_saayam_rdbms.request_category (request_category_id)
);