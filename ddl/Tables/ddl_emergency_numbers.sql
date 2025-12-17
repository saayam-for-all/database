--DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.emergency_numbers;

CREATE TABLE virginia_dev_saayam_rdbms.emergency_numbers (

  en_id                      SERIAL PRIMARY KEY,       
  country_id                         INT NULL,              
  state_id                             VARCHAR(50) NULL,             

  en_name                                 VARCHAR(100) NOT NULL UNIQUE,
  is_country                          BOOLEAN NOT NULL,

  police                                 VARCHAR(75) NULL,
  ambulance                         VARCHAR(75) NULL,
  fire                                      VARCHAR(75) NULL,
  non_emergency_police      VARCHAR(75) NULL,
  cyber_police                       VARCHAR(75) NULL,

  medicare_support              VARCHAR(75) NULL,
  gas_leak                             VARCHAR(75) NULL,
  electricity_outage               VARCHAR(75) NULL,
  water_department              VARCHAR(75) NULL,
  
  disaster_recovery                VARCHAR(75) NULL,             
  flood_help                           VARCHAR(75) NULL,
  earthquake_info                  VARCHAR(75) NULL,
  hurricane_info                     VARCHAR(75) NULL,
  emergency_mgmt               VARCHAR(75) NULL,
  environmental_hazards       VARCHAR(75) NULL,

  transportation_assistance    VARCHAR(75) NULL,
  roadside_assistance             VARCHAR(75) NULL,
  highway_patrol                    VARCHAR(75) NULL,

  suicide                                 VARCHAR(75) NULL,                      
  help_women                        VARCHAR(75) NULL,
  child_abuse                          VARCHAR(75) NULL,
  domestic_abuse                   VARCHAR(75) NULL,
  mental_health                      VARCHAR(75) NULL,
  elderly_abuse                       VARCHAR(75) NULL,           
  poison_control                     VARCHAR(75) NULL,      
  animal_control                     VARCHAR(75) NULL,
  wildlife_rescue                     VARCHAR(75) NULL,
  homeless_services               VARCHAR(75) NULL,
  food_assistance                   VARCHAR(75) NULL,
  FOREIGN KEY (country_id) REFERENCES virginia_dev_saayam_rdbms.country (country_id),
  FOREIGN KEY (state_id) REFERENCES virginia_dev_saayam_rdbms.state (state_id)
 );

