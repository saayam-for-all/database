-- Table: user_availability
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_availability (
    user_availability_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    day_of_week VARCHAR(10) CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) 
);

-- Indexes for user_availability
CREATE INDEX IF NOT EXISTS idx_user_availability_user_id ON virginia_dev_saayam_rdbms.user_availability (user_id);