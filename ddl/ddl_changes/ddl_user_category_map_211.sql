ALTER TABLE virginia_dev_saayam_rdbms.users
    DROP CONSTRAINT IF EXISTS users_user_category_id_fkey;

ALTER TABLE virginia_dev_saayam_rdbms.users
    DROP COLUMN IF EXISTS user_category_id;


-- Recreating users 

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.users (
    user_id                          VARCHAR(255)  PRIMARY KEY,
    state_id                         VARCHAR(30)   NULL,
    country_id                       INT           NULL,
    user_status_id                   INT           NULL,
    full_name                        VARCHAR(255)  NULL,
    first_name                       VARCHAR(255)  NULL,
    middle_name                      VARCHAR(255)  NULL,
    last_name                        VARCHAR(255)  NULL,
    primary_email_address            VARCHAR(255)  NULL,
    primary_phone_number             VARCHAR(255)  NULL,
    addr_ln1                         VARCHAR(255)  NULL,
    addr_ln2                         VARCHAR(255)  NULL,
    addr_ln3                         VARCHAR(255)  NULL,
    city_name                        VARCHAR(255)  NULL,
    zip_code                         VARCHAR(255)  NULL,
    last_location                    POINT,
    last_update_date                 TIMESTAMP,
    time_zone                        VARCHAR(255)  NULL,
    profile_picture_path             VARCHAR(255)  NULL,
    gender                           VARCHAR(255)  NULL,
    language_1                       VARCHAR(255)  NULL,
    language_2                       VARCHAR(255)  NULL,
    language_3                       VARCHAR(255)  NULL,
    promotion_wizard_stage           INT           NULL,
    promotion_wizard_last_update_date TIMESTAMP,

    FOREIGN KEY (country_id)
        REFERENCES virginia_dev_saayam_rdbms.country (country_id)
        ON DELETE SET NULL,
    FOREIGN KEY (state_id)
        REFERENCES virginia_dev_saayam_rdbms.state (state_id)
        ON DELETE SET NULL,
    FOREIGN KEY (user_status_id)
        REFERENCES virginia_dev_saayam_rdbms.user_status (user_status_id)
);

-- Creating the many-to-many mapping table

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_category_map (
    user_id          VARCHAR(255)  NOT NULL,
    user_category_id INT           NOT NULL,

    PRIMARY KEY (user_id, user_category_id),

    FOREIGN KEY (user_id)
        REFERENCES virginia_dev_saayam_rdbms.users (user_id)
        ON DELETE CASCADE,     

    FOREIGN KEY (user_category_id)
        REFERENCES virginia_dev_saayam_rdbms.user_category (user_category_id)
        ON DELETE CASCADE    
);

-- Supporting index for reverse lookups 
CREATE INDEX IF NOT EXISTS idx_ucm_user_category_id
    ON virginia_dev_saayam_rdbms.user_category_map (user_category_id);


