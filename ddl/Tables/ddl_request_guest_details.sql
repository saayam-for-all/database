-- This table is only populated when req_for is 1/OTHER  in the 'request' table.
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request_guest_details (
    -- The primary key is the foreign key to the request table (one-to-one relationship)
    req_id VARCHAR(255) PRIMARY KEY,
    req_fname VARCHAR(100) NOT NULL,
    req_lname VARCHAR(100) NOT NULL,
    req_email VARCHAR(100),
    req_phone VARCHAR(20) NOT NULL,
    req_age INT,
    req_gender VARCHAR(50),
    req_pref_lang VARCHAR(50),
    FOREIGN KEY (req_id) REFERENCES virginia_dev_saayam_rdbms.request (req_id) ON DELETE CASCADE
);

