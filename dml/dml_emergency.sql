LOAD DATA INFILE 'emergency_numbers_all_countries.csv'
INTO TABLE emergency_numbers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(country, police, ambulance, fire, other_emergency);
