CREATE TABLE virginia_dev_saayam_rdbms.internal_app_rejections (
    rejection_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 VARCHAR(255) NOT NULL,

    -- applicant snapshot
    email                   VARCHAR(255) NOT NULL,
    first_name              VARCHAR(100),
    last_name               VARCHAR(100),
    phone_country_code      VARCHAR(10),
    phone_number            VARCHAR(20),
    linkedin_url            VARCHAR(500),
    github_url              VARCHAR(500),
    college                 VARCHAR(255),
    degree_program          VARCHAR(255),
    relevant_experience     TEXT,
    preferred_role          VARCHAR(100),
    hours_per_week          INT,
    start_date              DATE,
    engagement_type         VARCHAR(50),
    is_us_based             BOOLEAN,
    country                 VARCHAR(100),
    resume_s3_key           VARCHAR(500),
    ead_card_s3_key         VARCHAR(500),
    i20_s3_key              VARCHAR(500),
    government_id_s3_key    VARCHAR(500),
    acknowledgments         JSONB,

    -- rejection metadata
    rejection_reason        TEXT NOT NULL,
    reviewer_cognito_id     VARCHAR(255),
    reviewer_notes          TEXT,

    -- timestamps
    application_created_at  TIMESTAMP WITHOUT TIME ZONE,
    rejected_at             TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),

    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id)
);

CREATE INDEX idx_internal_rejections_user
    ON virginia_dev_saayam_rdbms.internal_app_rejections(user_id);
CREATE INDEX idx_internal_rejections_rejected_at
    ON virginia_dev_saayam_rdbms.internal_app_rejections(rejected_at DESC);
