-- Table: state
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.state (
    state_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    state_name VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP,
    UNIQUE (country_id, state_id),
    FOREIGN KEY (country_id) REFERENCES virginia_dev_saayam_rdbms.country (country_id)
);