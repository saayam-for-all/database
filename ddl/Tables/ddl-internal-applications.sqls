CREATE TYPE virginia_dev_saayam_rdbms.internal_app_status_type
    AS ENUM ('PENDING', 'IN_VERIFICATION', 'APPROVED', 'REJECTED');

CREATE TABLE virginia_dev_saayam_rdbms.internal_applications (
    user_id                 VARCHAR(255) PRIMARY KEY,

    -- contact / identity
    email                   VARCHAR(255) NOT NULL,
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    phone_country_code      VARCHAR(10),
    phone_number            VARCHAR(20),
    phone_extension         VARCHAR(10),
    linkedin_url            VARCHAR(500),
    github_url              VARCHAR(500),
    timezone                VARCHAR(100),

    -- academic / professional background
    college                 VARCHAR(255),
    degree_program          VARCHAR(255),
    dean_contact            VARCHAR(255),
    relevant_experience     TEXT,

    -- role / engagement
    preferred_role          VARCHAR(100),
    hours_per_week          INT,
    start_date              DATE,
    engagement_type         VARCHAR(50),

    -- location & document type
    is_us_based             BOOLEAN,
    need_offer_letter       BOOLEAN,
    document_type           VARCHAR(50),
    country                 VARCHAR(100),

    -- S3 document references
    resume_s3_key           VARCHAR(500),
    ead_card_s3_key         VARCHAR(500),
    i20_s3_key              VARCHAR(500),
    government_id_s3_key    VARCHAR(500),
    govt_id_path_updated_at TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),

    -- acknowledgments
    acknowledgments         JSONB,
    acknowledgments_accepted_at TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),

    -- review workflow
    application_status      virginia_dev_saayam_rdbms.internal_app_status_type
                            DEFAULT 'PENDING',
    reviewer_cognito_id     VARCHAR(255),
    reviewer_notes          TEXT,
    rejection_reason        TEXT,

    -- timestamps
    created_at              TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at         TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),
    reviewed_at             TIMESTAMP WITHOUT TIME ZONE,

    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id)
);

CREATE INDEX idx_internal_apps_status
    ON virginia_dev_saayam_rdbms.internal_applications(application_status);
CREATE INDEX idx_internal_apps_reviewer
    ON virginia_dev_saayam_rdbms.internal_applications(reviewer_cognito_id);
CREATE INDEX idx_internal_apps_created
    ON virginia_dev_saayam_rdbms.internal_applications(created_at DESC);
