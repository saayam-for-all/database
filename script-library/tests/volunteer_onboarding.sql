-- WRITE YOUR OWN TEST CASES AS WE HAVE THE FOREIGN KEY IMPLEMENTED

-- Test Audit Timestamps
-- This test verifies that the updated_at_handler trigger correctly updates timestamps when you make changes, prioritizing the database's UTC time if the API provides none.

-- Step 1: Insert a test application
INSERT INTO virginia_dev_saayam_rdbms.volunteer_applications (user_id, application_status)
VALUES ('test_user_001', 'STARTED');

-- Step 2: Update a field (like current_page) and check if updated_at changes
UPDATE virginia_dev_saayam_rdbms.volunteer_applications 
SET current_page = 2 
WHERE user_id = 'test_user_001';

-- Step 3: Update the govt_id_path specifically
-- Check if path_updated_at refreshes while others remain distinct
UPDATE virginia_dev_saayam_rdbms.volunteer_applications 
SET govt_id_path = 'https://storage.com/id1.jpg' 
WHERE user_id = 'test_user_001';

SELECT user_id, updated_at, path_updated_at FROM virginia_dev_saayam_rdbms.volunteer_applications;

-- Test Volunteer Acceptance (Migration Trigger)
-- Step 1: Prepare the application with skills and availability
UPDATE virginia_dev_saayam_rdbms.volunteer_applications 
SET application_status = 'IN_REVIEW',
    skill_codes = '["SKILL_01", "SKILL_02"]',
    availability = '{"days": ["Monday", "Wednesday"], "time": ["Morning"]}'::JSONB,
    terms_and_conditions = TRUE
WHERE user_id = 'test_user_001';

-- Step 2: Trigger the migration by accepting the volunteer
UPDATE virginia_dev_saayam_rdbms.volunteer_applications 
SET application_status = 'ACCEPTED' 
WHERE user_id = 'test_user_001';

-- Step 3: Verify migration to volunteer_details
SELECT * FROM virginia_dev_saayam_rdbms.volunteer_details WHERE user_id = 'test_user_001';

-- Step 4: Verify migration to user_skills (should have 2 rows for the 2 skill_codes)
SELECT * FROM virginia_dev_saayam_rdbms.user_skills WHERE user_id = 'test_user_001';

-- Test Skill Search Performance
-- Search for all volunteers who have "SKILL_01"
-- Use EXPLAIN to confirm the index idx_user_skills_cat_id is being used
EXPLAIN ANALYZE
SELECT user_id 
FROM virginia_dev_saayam_rdbms.user_skills 
WHERE cat_id = 'SKILL_01';

-- Test Availability Search
-- Search for volunteers available on Monday
SELECT user_id 
FROM virginia_dev_saayam_rdbms.volunteer_details 
WHERE availability_days ? 'Monday';

-- Search for volunteers available in the Morning
SELECT user_id 
FROM virginia_dev_saayam_rdbms.volunteer_details 
WHERE availability_times ? 'Morning';
