drop table if exists organization;

create table if not exists organization (
  org_id VARCHAR(255) PRIMARY KEY,
  org_name VARCHAR(255) NOT NULL,
  emp_ident_no VARCHAR(15) UNIQUE,
  mission_statement TEXT,
  website_url VARCHAR(255),
  phone VARCHAR(20),
  email VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(2) CHECK (char_length(state) = 2),
  org_type VARCHAR(20) CHECK (org_type IN ('Nonprofit', 'For-profit')),
  data_source VARCHAR(20) CHECK (data_source IN ('IRS', 'Self-Registered')),
  --need to have a mapping from help_category
  --category VARCHAR(100),
  --subcategory VARCHAR(100),  -- For NTEE codes 
  people JSON  -- Future volunteer contact storage
);
 
/*
CREATE SEQUENCE org_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;
 
CREATE FUNCTION generate_org_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id INT;
    new_id VARCHAR(30);
BEGIN
    seq_id := nextval('org_id_seq');
    new_id := 'ORG-' || LPAD(FLOOR(seq_id / 100000000)::TEXT, 2, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000000) / 100000)::TEXT, 3, '0') || '-' || 
              LPAD(FLOOR((seq_id % 100000) / 1000)::TEXT, 3, '0') || '-' || 
              LPAD((seq_id % 1000)::TEXT, 4, '0');
    NEW.org_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_organization
BEFORE INSERT ON organization
FOR EACH ROW
EXECUTE FUNCTION generate_org_id();
*/
