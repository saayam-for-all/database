-- DML: Add date_of_birth column to users table
-- Issue #191: Add DOB in Users table
ALTER TABLE virginia_dev_saayam_rdbms.users
    ADD COLUMN IF NOT EXISTS dob DATE;
