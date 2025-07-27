 drop table if exists organization;

create table if not exists organization (
  org_id VARCHAR(255) PRIMARY KEY,
  org_name VARCHAR(255) NOT NULL,
  emp_id_num VARCHAR(15) UNIQUE,
  mission_statement TEXT,
  website_url VARCHAR(255),
  phone VARCHAR(20),
  email VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(2) CHECK (char_length(state) = 2),
  org_type VARCHAR(20) CHECK (org_type IN ('Nonprofit', 'For-profit')),
  data_source VARCHAR(20) CHECK (data_source IN ('IRS', 'Self-Registered')),
  people JSON  -- Future volunteer contact storage
  cat_id VARCHAR(50),
  FOREIGN KEY (cat_id) REFERENCES help_category(cat_id) --Linking up help_category with organization
);
 
/* insertion is done by organization_map.csv file */
