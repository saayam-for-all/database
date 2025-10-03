CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_for (
    request_for_id SERIAL PRIMARY KEY,
    request_for VARCHAR(25) NOT NULL,  
    request_for_desc VARCHAR(125), --15words7charlength
    last_updated_date TIMESTAMP
);
