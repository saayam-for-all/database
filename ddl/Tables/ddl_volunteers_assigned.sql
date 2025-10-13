-- Table: volunteers_assigned
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.volunteers_assigned (
    volunteers_assigned_id SERIAL PRIMARY KEY,
    request_id VARCHAR(255) NOT NULL,
    volunteer_id VARCHAR(255) NOT NULL,
    volunteer_type VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP NOT NULL,
    FOREIGN KEY (request_id) REFERENCES virginia_dev_saayam_rdbms.requests (request_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
