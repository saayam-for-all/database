COPY emergency_numbers(country, police, ambulance, fire, other_emergency)
FROM 'database/dml/emergency_numbers_all_countries.csv'
DELIMITER ','
CSV HEADER;
