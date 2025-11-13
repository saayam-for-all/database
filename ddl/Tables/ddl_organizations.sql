-- Create ENUM types
CREATE TYPE org_type_enum AS ENUM ('non_profit', 'for_profit');
CREATE TYPE source_enum AS ENUM ('irs', 'self_registered');

DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.organizations CASCADE;
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.organizations (
  org_id VARCHAR(255) PRIMARY KEY,
  org_name VARCHAR(125) NOT NULL,
  govt_id_num VARCHAR(20) UNIQUE,  -- EIN for lookups
  street VARCHAR(255),
  city_name VARCHAR(100),
  state_code VARCHAR(6),
  zip_code VARCHAR(10),
  mission TEXT,
  web_url VARCHAR(255) CHECK (web_url IS NULL OR web_url LIKE 'http%'),
  phone VARCHAR(20),
  email VARCHAR(255) CHECK (email IS NULL OR email LIKE '%@%'),
  org_type org_type_enum,
  source source_enum,
  cat_id VARCHAR(50),   --help_categories
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cat_id) REFERENCES help_categories(cat_id) ON DELETE SET NULL,
  FOREIGN KEY (state_code) REFERENCES states(state_code) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX idx_org_city_state ON virginia_dev_saayam_rdbms.organizations(city_name, state_code);
CREATE INDEX idx_org_state ON virginia_dev_saayam_rdbms.organizations(state_code);
CREATE INDEX idx_org_cat_id ON virginia_dev_saayam_rdbms.organizations(cat_id);
CREATE INDEX idx_org_name ON virginia_dev_saayam_rdbms.organizations(org_name);
 
/* insertion is done by organization_map.csv file \
ALTER TYPE org_type_enum ADD VALUE 'Government';
ALTER TYPE org_type_enum ADD VALUE 'Hybrid' AFTER 'Nonprofit';
Deleting an enum type is a complex process; it requires a temp table in between. Stop using the type.*/

-- Create sequence for organization IDs
CREATE SEQUENCE virginia_dev_saayam_rdbms.org_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;

-- Create a function to generate ORG IDs in the format: ORG-00-XXX-XXX-XXX
CREATE FUNCTION virginia_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate org_id before insert
CREATE TRIGGER before_insert_organizations
BEFORE INSERT ON virginia_dev_saayam_rdbms.organizations
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_org_id();

