-- Table: city
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.city (
    city_id SERIAL PRIMARY KEY,
    state_id INT NOT NULL,
    city_name VARCHAR(30) NOT NULL,
    lattitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    last_update_date TIMESTAMP,
    UNIQUE (city_id),
    FOREIGN KEY (state_id) REFERENCES virginia_dev_saayam_rdbms.state (state_id)
);