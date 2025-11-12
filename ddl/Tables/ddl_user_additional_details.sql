-- Table: user_additional_details (Additional user details)
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_additional_details (
    additional_detail_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    secondary_email_1 VARCHAR(255) NULL,
    secondary_email_2 VARCHAR(255) NULL,
    secondary_phone_1 VARCHAR(255) NULL,
    secondary_phone_2 VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE
);