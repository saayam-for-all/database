-- Table: request
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request (
    req_id VARCHAR(255) PRIMARY KEY,
    req_user_id VARCHAR(255) NOT NULL,
    req_status_id INT NOT NULL,
    req_priority_id INT NOT NULL,
    req_type_id INT NOT NULL,
    req_cat_id INT NOT NULL,
    req_for_id INT NOT NULL,
	city_name VARCHAR(255) NOT NULL,
    zip_code VARCHAR(255) NOT NULL,
    req_desc VARCHAR(255) NOT NULL,
	audio_req_desc VARCHAR(255) NULL,
    req_for VARCHAR(255) NOT NULL,
    submission_date TIMESTAMP,
    lead_volunteer_user_id INT,
    serviced_date TIMESTAMP,
    last_update_date TIMESTAMP,
    UNIQUE (request_id),
    FOREIGN KEY (req_user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id),
    FOREIGN KEY (req_status_id) REFERENCES virginia_dev_saayam_rdbms.request_status (req_status_id),
    FOREIGN KEY (req_priority_id) REFERENCES virginia_dev_saayam_rdbms.request_priority (req_priority_id),
    FOREIGN KEY (req_type_id) REFERENCES virginia_dev_saayam_rdbms.request_type (req_type_id),
    FOREIGN KEY (req_cat_id) REFERENCES virginia_dev_saayam_rdbms.help_categories (cat_id),
    FOREIGN KEY (req_for_id) REFERENCES virginia_dev_saayam_rdbms.request_for (req_for_id)
);

-- Create the sequence for request IDs
CREATE SEQUENCE virginia_dev_saayam_rdbms.request_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

-- Create the function to generate the formatted request ID
CREATE FUNCTION virginia_dev_saayam_rdbms.generate_request_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id INT;
    new_id VARCHAR(30);
BEGIN
    seq_id := nextval('request_id_seq');
    new_id := 'REQ-' || LPAD(FLOOR(seq_id / 100000000)::TEXT, 2, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000000) / 100000)::TEXT, 3, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000) / 1000)::TEXT, 3, '0') || '-' || 
              LPAD((seq_id % 1000)::TEXT, 4, '0');
    NEW.req_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER before_insert_requests
BEFORE INSERT ON virginia_dev_saayam_rdbms.request
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_request_id();
