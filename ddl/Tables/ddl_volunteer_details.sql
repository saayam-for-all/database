-- DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_details CASCADE;

CREATE TABLE virginia_dev_saayam_rdbms.volunteer_details (
    user_id VARCHAR(255) PRIMARY KEY,
    terms_and_conditions BOOLEAN,
    terms_accepted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    govt_id_path1 TEXT,
    govt_id_path2 TEXT,
    path1_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    path2_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    availability_days JSONB,
    availability_times JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id)
);

CREATE TRIGGER trg_volunteer_details_updated_at
    BEFORE UPDATE ON virginia_dev_saayam_rdbms.volunteer_details
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.updated_at_handler();

-- Index for searching specific days (e.g., 'Monday')
CREATE INDEX idx_volunteer_availability_days 
ON virginia_dev_saayam_rdbms.volunteer_details USING GIN (availability_days);

-- Index for searching specific time slots
CREATE INDEX idx_volunteer_availability_times 
ON virginia_dev_saayam_rdbms.volunteer_details USING GIN (availability_times);
