-- Table: volunteer_details (Volunteer-specific details)
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.volunteer_details (
    volunteer_detail_id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
	terms_and_conditions BOOL NULL,
	terms_and_conditions_update_date TIMESTAMP NULL,
	govt_id VARCHAR(255) NULL,   --stored in S3, this attribute stored the S3 link of it
	govt_id_update_date TIMESTAMP NULL,
	skills JSONB NULL,  --to store unctructured data
	notification BOOL NULL,
	iscomplete BOOL NULL,
	completed_date TIMESTAMP NULL,
	location geography(Point,4326),
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE
);

-- --IF you have already table exists and trying to change the column name and type from Pii varchar(255) to skills jsonb 
-- -- Change the column type from varchar to json
-- ALTER TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_details ALTER COLUMN pii TYPE jsonb USING pii::jsonb;

-- -- Rename the column from pii to skills
-- ALTER TABLE IF EXISTS virginia_dev_saayam_rdbms.volunteer_details RENAME COLUMN pii TO skills;

-- used to store unstructured data

-- To ensure each volunteer is unique by user_id as we don’t plan to allow multiple volunteer rows per use

DO $$ 
BEGIN
   IF NOT EXISTS (
       SELECT 1 FROM pg_constraint
       WHERE conname = 'volunteer_details_user_uk'
       AND conrelid = 'virginia_dev_saayam_rdbms.volunteer_details'::regclass
) THEN
  ALTER TABLE virginia_dev_saayam_rdbms.volunteer_details
  ADD CONSTRAINT volunteer_details_user_uk UNIQUE (user_id);
END IF;
END;
$$;

