-- Table: fraud_requests 
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.fraud_requests (
    fraud_request_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    request_datetime TIMESTAMP NOT NULL,
    reason VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id)
);