-- Table: slas
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.slas (
    sla_id SERIAL PRIMARY KEY,
    sla_hours INT NOT NULL,
    sla_description VARCHAR(255) NOT NULL,
    no_of_cust_impct INT,
    last_updated_date TIMESTAMP,
    UNIQUE (sla_id)
);
