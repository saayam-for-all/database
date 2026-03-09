-- Create ENUM types
CREATE TYPE org_type_enum AS ENUM ('non_profit', 'for_profit');
CREATE TYPE org_size_enum AS ENUM ('small', 'medium', 'large');

DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.organizations CASCADE;

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.organizations (
  org_id VARCHAR(255) PRIMARY KEY,
  org_name VARCHAR(125) NOT NULL,
  street VARCHAR(255),
  city_name VARCHAR(100),
  state_id VARCHAR(50),
  zip_code VARCHAR(10),
  mission TEXT,
  web_url VARCHAR(255) CHECK (web_url IS NULL OR web_url LIKE 'http%'),
  phone VARCHAR(20),
  email VARCHAR(255) CHECK (email IS NULL OR email LIKE '%@%'),
  org_type org_type_enum,
  org_size org_size_enum,
  org_rating INTEGER CHECK (org_rating >= 1 AND org_rating <= 5),
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
  last_updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),  
  FOREIGN KEY (state_id) REFERENCES states(state_id) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX idx_org_name ON virginia_dev_saayam_rdbms.organizations(org_name);
CREATE INDEX idx_org_state_id ON virginia_dev_saayam_rdbms.organizations(state_id);
CREATE INDEX idx_org_city_state ON virginia_dev_saayam_rdbms.organizations(city_name, state_id);

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_org_id()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    seq_id INT;
    new_id VARCHAR(20);
BEGIN
    seq_id := nextval('virginia_dev_saayam_rdbms.org_id_seq');
    new_id := 'ORG-00-' || LPAD(FLOOR(seq_id / 1000000)::TEXT, 3, '0') || '-' || 
              LPAD(FLOOR((seq_id % 1000000) / 1000)::TEXT, 3, '0') || '-' || 
              LPAD((seq_id % 1000)::TEXT, 3, '0');
    NEW.org_id := new_id;
    RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER before_insert_organizations
    BEFORE INSERT
    ON virginia_dev_saayam_rdbms.organizations
    FOR EACH ROW
    EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_org_id();
