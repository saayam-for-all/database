CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_for (
    req_for_id SERIAL PRIMARY KEY,
    req_for VARCHAR(25) NOT NULL,  
    req_for_desc VARCHAR(125), --15words7charlength
    last_updated_date TIMESTAMP
);


-- CSV
-- 0   SELF    Personal benefits of the individual
-- 1   OTHER   User is filing a request for others. This other person does NOT have an account within our system. 
