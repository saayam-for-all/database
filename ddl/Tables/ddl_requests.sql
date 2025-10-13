-- Table: requests
--CREATE TYPE islead_volunteer AS ENUM('YES', 'NO');
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.requests (
    req_id VARCHAR(255) PRIMARY KEY,
    req_user_id VARCHAR(255) NOT NULL,
	req_for_id INT NOT NULL,
	--lead_volunteer_user_id INT,   --there is a yes or no up there, we can have an ENUM here
	--islead_vol islead_volunteer NOT NULL DEFAULT 'NO';
    req_cat_id INT NOT NULL,
	req_islead_id INT NOT NULL,
    req_type_id INT NOT NULL,
    req_priority_id INT NOT NULL,
    req_status_id INT NOT NULL,
	req_loc VARCHAR(125),
	-- city_name VARCHAR(255) NOT NULL,
    -- zip_code VARCHAR(255) NOT NULL,
	req_subj VARCHAR(125) NOT NULL,
    req_desc VARCHAR(255) NOT NULL,
	audio_req_desc VARCHAR(255) NULL,
    submission_date TIMESTAMP,
    serviced_date TIMESTAMP,
    last_update_date TIMESTAMP,
    UNIQUE (req	_id),
    FOREIGN KEY (req_user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id),
    FOREIGN KEY (req_status_id) REFERENCES virginia_dev_saayam_rdbms.request_statuses (req_status_id),
    FOREIGN KEY (req_priority_id) REFERENCES virginia_dev_saayam_rdbms.request_priorities (req_priority_id),
    FOREIGN KEY (req_type_id) REFERENCES virginia_dev_saayam_rdbms.request_types (req_type_id),
    FOREIGN KEY (req_cat_id) REFERENCES virginia_dev_saayam_rdbms.help_categories (cat_id),
    FOREIGN KEY (req_for_id) REFERENCES virginia_dev_saayam_rdbms.request_for (req_for_id),
	FOREIGN KEY (req_islead_id) REFERENCES virginia_dev_saayam_rdbms.request_isleadvol (req_islead_id)
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
BEFORE INSERT ON virginia_dev_saayam_rdbms.requests
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_request_id();
