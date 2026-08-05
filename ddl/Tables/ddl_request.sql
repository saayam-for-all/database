-- Table: request
--CREATE TYPE islead_volunteer AS ENUM('YES', 'NO');
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.request (
    req_id VARCHAR(255) PRIMARY KEY,
    req_user_id VARCHAR(255) NOT NULL,
	req_for_id INT NOT NULL,
	req_islead_id INT NOT NULL,
    req_cat_id VARCHAR(50) NOT NULL,
    req_type_id INT NOT NULL,
    req_priority_id INT NOT NULL,
    req_status_id INT NOT NULL,
	req_loc VARCHAR(125),
	iscalamity BOOLEAN,
	req_subj VARCHAR(125) NOT NULL,
    req_desc VARCHAR(255) NOT NULL,
	req_doc_link TEXT,
	audio_req_desc VARCHAR(255),
    submission_date TIMESTAMP,
    serviced_date TIMESTAMP, 						--completed or cancelled date
    last_update_date TIMESTAMP,
    UNIQUE (req_id),
    FOREIGN KEY (req_user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id),
    FOREIGN KEY (req_status_id) REFERENCES virginia_dev_saayam_rdbms.request_status (req_status_id),
    FOREIGN KEY (req_priority_id) REFERENCES virginia_dev_saayam_rdbms.request_priority (req_priority_id),
    FOREIGN KEY (req_type_id) REFERENCES virginia_dev_saayam_rdbms.request_type (req_type_id),
    FOREIGN KEY (req_cat_id) REFERENCES virginia_dev_saayam_rdbms.help_categories (cat_id),
    FOREIGN KEY (req_for_id) REFERENCES virginia_dev_saayam_rdbms.request_for (req_for_id),
	FOREIGN KEY (req_islead_id) REFERENCES virginia_dev_saayam_rdbms.request_isleadvol (req_islead_id)
);

-- Request ID sequence — Virginia: 1 → 999,999,999,999
CREATE SEQUENCE virginia_dev_saayam_rdbms.request_id_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 999999999999
NO CYCLE
CACHE 1;

-- Request ID: REQ-XXX-XXX-XXX-XXXX (13 digits, grouped 3-3-3-4 via LPAD + SUBSTRING)
CREATE FUNCTION virginia_dev_saayam_rdbms.generate_req_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    padded TEXT;
BEGIN
    seq_id := nextval('virginia_dev_saayam_rdbms.request_id_seq');
    padded := LPAD(seq_id::TEXT, 13, '0');
    NEW.req_id := 'REQ-' ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 4);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_requests
BEFORE INSERT ON virginia_dev_saayam_rdbms.request
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_req_id();
