-- Table: user_category
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_category (
    user_category_id SERIAL PRIMARY KEY,
    user_category VARCHAR(255) NOT NULL,
    user_category_desc VARCHAR(255),
    last_update_date TIMESTAMP,
    UNIQUE (user_category_id)
);