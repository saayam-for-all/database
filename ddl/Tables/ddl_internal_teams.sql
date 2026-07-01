CREATE TABLE virginia_dev_saayam_rdbms.internal_team (
    user_id                 VARCHAR(255) PRIMARY KEY,

    -- identity
    email                   VARCHAR(255) NOT NULL,
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    phone_country_code      VARCHAR(10),
    phone_number            VARCHAR(20),
    linkedin_url            VARCHAR(500),
    github_url              VARCHAR(500),
    timezone                VARCHAR(100),

    -- role / engagement
    internal_role           VARCHAR(100),
    preferred_role          VARCHAR(100),
    hours_per_week          INT,
    start_date              DATE,
    engagement_type         VARCHAR(50),

    -- location / docs
    is_us_based             BOOLEAN,
    country                 VARCHAR(100),
    government_id_s3_key    VARCHAR(500),

    -- membership lifecycle
    is_active               BOOLEAN DEFAULT TRUE,
    joined_at               TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),
    deactivated_at          TIMESTAMP WITHOUT TIME ZONE,

    -- standard timestamps
    created_at              TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at         TIMESTAMP WITHOUT TIME ZONE
                            DEFAULT (now() AT TIME ZONE 'UTC'),

    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id)
);

CREATE INDEX idx_internal_team_role
    ON virginia_dev_saayam_rdbms.internal_team(internal_role);
CREATE INDEX idx_internal_team_active
    ON virginia_dev_saayam_rdbms.internal_team(is_active);
