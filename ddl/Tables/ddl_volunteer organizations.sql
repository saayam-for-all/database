-- Table : volunteer organizations 
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.volunteer_organizations (
	volunteer_organization_id SERIAL PRIMARY KEY,
    contact_id VARCHAR(255) NOT NULL,
    city_name VARCHAR(255) NOT NULL,
    addr_ln1 VARCHAR(255) NULL,
    addr_ln2 VARCHAR(255) NULL,
    addr_ln3 VARCHAR(255) NULL,
    zip_code VARCHAR(255) NOT NULL,
    last_update_date TIMESTAMP,
    time_zone VARCHAR(255) NULL,
    FOREIGN KEY (contact_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);