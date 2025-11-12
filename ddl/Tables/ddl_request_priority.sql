-- Table: request_priority
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_priority (
    req_priority_id SERIAL PRIMARY KEY,
    req_priority VARCHAR(25) NOT NULL,
    req_priority_desc VARCHAR(125),
    last_updated_date TIMESTAMP,
    UNIQUE (req_priority_id)
);


-- CSV
-- 0  LOW
-- 1  MEDIUM
-- 2  HIGH
-- 3 CRITICAL
