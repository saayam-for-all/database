-- Create ENUM type for rating values (0 to 5 stars)
CREATE TYPE rating_enum AS ENUM ('0', '1', '2', '3', '4', '5');

-- Table: volunteer_rating
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.volunteer_rating (
    volunteer_rating_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    request_id VARCHAR(255) NOT NULL,
    rating rating_enum NOT NULL,
    feedback TEXT,
    last_update_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (request_id) REFERENCES virginia_dev_saayam_rdbms.request (request_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indexes for volunteer_rating
CREATE INDEX IF NOT EXISTS idx_volunteer_rating_user_id ON virginia_dev_saayam_rdbms.volunteer_rating (user_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_rating_request_id ON virginia_dev_saayam_rdbms.volunteer_rating (request_id);