-- WRITE YOUR OWN TEST CASES AS WE HAVE THE FOREIGN KEY IMPLEMENTED
INSERT INTO public.help_categories (cat_id, cat_name) VALUES 
('1', 'Education & Tutoring'),
('2', 'Medical Assistance'),
('3', 'Logistics & Transport'),
('2.1', 'Child Care'),
('5', 'Administrative Support');

INSERT INTO public.users (full_name) VALUES 
('Alice Johnson'),
('Bob Smith');

-- Insert a test application
INSERT INTO public.volunteer_applications (user_id, application_status)
VALUES ('SID-00-000-000-001', 'STARTED');

-- Update a field (like current_page) and check if updated_at changes
UPDATE public.volunteer_applications 
SET current_page = 2 
WHERE user_id = 'SID-00-000-000-001';

-- Update the govt_id_path specifically
-- Check if path_updated_at refreshes while others remain distinct
UPDATE public.volunteer_applications 
SET govt_id_path = 'https://storage.com/alice_id.jpg' 
WHERE user_id = 'SID-00-000-000-001';

SELECT user_id, updated_at, path_updated_at FROM virginia_dev_saayam_rdbms.volunteer_applications;

-- Test Volunteer Acceptance (Migration Trigger)
UPDATE public.volunteer_applications 
SET application_status = 'IN_REVIEW',
    skill_codes = '["2", "5"]',
    availability = '{"days": ["Monday", "Wednesday"], "time": ["2025-12-24 23:17:20.929643"]}'::JSONB,
    terms_and_conditions = TRUE
WHERE user_id = 'SID-00-000-000-001';

-- This executes your 'handle_volunteer_application' function
UPDATE public.volunteer_applications 
SET application_status = 'ACCEPTED' 
WHERE user_id = 'SID-00-000-000-001';

SELECT * FROM public.volunteer_details WHERE user_id = 'SID-00-000-000-001';
SELECT * FROM public.user_skills WHERE user_id = 'SID-00-000-000-001';
SELECT * FROM public.volunteer_applications WHERE user_id = 'SID-00-000-000-001';

-- Use EXPLAIN to confirm the index idx_user_skills_cat_id is being used
EXPLAIN ANALYZE
SELECT user_id 
FROM public.user_skills 
WHERE cat_id = '5';

-- Search for volunteers available on Monday
SELECT user_id 
FROM virginia_dev_saayam_rdbms.volunteer_details 
WHERE availability_days ? 'Monday';

SELECT user_id 
FROM public.volunteer_details 
WHERE availability_times ? '2025-12-24 23:17:20.929643';



