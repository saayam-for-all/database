-- Table: request_types
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_types (
    req_type_id SERIAL PRIMARY KEY,
    req_type VARCHAR(25),
    req_type_desc VARCHAR(125),
    last_updated_date TIMESTAMP
);

-- CSV
-- 0  INPERSON
-- 1  HYBRID
