--drop table if exists emergency_numbers;

create table if exists emergency_numbers (
    emergency_num_id SERIAL PRIMARY KEY,
    country VARCHAR(100),
    police VARCHAR(20),
    ambulance VARCHAR(20),
    fire VARCHAR(20),
    other_emergency VARCHAR(100)
);


