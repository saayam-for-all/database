-- Table: request_status
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_status (
    req_status_id SERIAL PRIMARY KEY,
    req_status VARCHAR(25) NOT NULL,
    req_status_desc VARCHAR(125),
    last_updated_date TIMESTAMP
);

-- CSV
-- 0  CREATED
-- 1  MATCHING VOLUNTEER
-- 2  MANAGED
-- 3  CLOSED
-- 4  CANCELLED
-- 5  DELETED
