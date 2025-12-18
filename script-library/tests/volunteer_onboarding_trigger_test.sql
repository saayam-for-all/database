-- Test Case: Volunteer onboarding trigger
-- Validates trigger behavior on volunteer_applications acceptance

SET search_path TO virginia_dev_saayam_rdbms;

-- Cleanup existing test data
DELETE FROM user_skills WHERE user_id = 'SID-TEST-PR-01';
DELETE FROM volunteer_details WHERE user_id = 'SID-TEST-PR-01';
DELETE FROM volunteer_applications WHERE user_id = 'SID-TEST-PR-01';

-- Step 1: Insert volunteer application
INSERT INTO volunteer_applications (
    user_id,
    application_status,
    availability,
    selected_skill_codes,
    govt_id_storage_path
) VALUES (
    'SID-TEST-PR-01',
    'submitted',
    '{"days":["Monday","Wednesday"],"time":["Morning","Evening"]}'::jsonb,
    ARRAY[101,102],
    's3://fake-bucket/govt-id-1.png'
);

-- Verify application insert
SELECT user_id, application_status
FROM volunteer_applications
WHERE user_id = 'SID-TEST-PR-01';

-- Step 2: Accept the application (trigger fires)
UPDATE volunteer_applications
SET application_status = 'accepted'
WHERE user_id = 'SID-TEST-PR-01';

-- Step 3: Application should be removed
SELECT *
FROM volunteer_applications
WHERE user_id = 'SID-TEST-PR-01';

-- Step 4: Volunteer details auto-created
SELECT
    user_id,
    govt_id_path,
    govt_id_path2,
    iscomplete,
    completed_date
FROM volunteer_details
WHERE user_id = 'SID-TEST-PR-01';

-- Step 5: Skills expanded into user_skills
SELECT
    user_id,
    cat_id,
    created_at
FROM user_skills
WHERE user_id = 'SID-TEST-PR-01'
ORDER BY cat_id;

-- Step 6: Count validation
SELECT count(*) FROM volunteer_details WHERE user_id = 'SID-TEST-PR-01';
SELECT count(*) FROM user_skills WHERE user_id = 'SID-TEST-PR-01';

