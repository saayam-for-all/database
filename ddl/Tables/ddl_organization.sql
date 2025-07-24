drop table if exists organization;

CREATE TABLE organization (
  organization_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  organization_name VARCHAR(255) NOT NULL,
  ein VARCHAR(15) UNIQUE,
  mission_statement TEXT,
  website_url VARCHAR(255),
  phone VARCHAR(20),
  email VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(2) CHECK (char_length(state) = 2),
  organization_type VARCHAR(20) CHECK (organization_type IN ('Nonprofit', 'For-profit')),
  data_source VARCHAR(20) CHECK (data_source IN ('IRS', 'Self-Registered')),
  category VARCHAR(100),
  subcategory VARCHAR(100),  -- For NTEE codes 
  people JSON  -- Future volunteer contact storage
);
