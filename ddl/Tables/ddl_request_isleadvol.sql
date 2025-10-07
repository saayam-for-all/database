CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_isleadvol (
    req_islead_id SERIAL PRIMARY KEY,
    req_islead VARCHAR(15) NOT NULL,  
    req_islead_desc VARCHAR(100), 
    last_updated_date TIMESTAMP
);

-- CSV
-- 0   NO    Contributes to the request under the direction of the lead
-- 1   YES   The main point of contact with full authority over the request process
