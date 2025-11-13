-- Table: state
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.state (
    state_id VARCHAR(50) PRIMARY KEY,
    country_id INT NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(6),
    last_update_date TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES virginia_dev_saayam_rdbms.country (country_id)
);
