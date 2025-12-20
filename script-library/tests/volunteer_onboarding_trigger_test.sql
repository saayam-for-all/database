BEGIN;

INSERT INTO virginia_dev_saayam_rdbms.volunteer_applications (
    user_id,
    terms_and_conditions,
    terms_and_conditions_accepted_at,
    skill_codes,
    availability,
    application_status,
    govt_id_storage_path
)
VALUES (
    'SID-TEST-TRG-01',
    TRUE,
    now(),
    '[101,102]',
    '{"days":["Monday","Wednesday"],"time":["Morning","Evening"]}'::jsonb,
    'submitted',
    's3://fake-bucket/govt-id-1.png'
);

UPDATE virginia_dev_saayam_rdbms.volunteer_applications
SET application_status = 'accepted'
WHERE user_id = 'SID-TEST-TRG-01';

SELECT * 
FROM virginia_dev_saayam_rdbms.volunteer_details
WHERE user_id = 'SID-TEST-TRG-01';

SELECT * 
FROM virginia_dev_saayam_rdbms.user_skills
WHERE user_id = 'SID-TEST-TRG-01';

SELECT *
FROM virginia_dev_saayam_rdbms.volunteer_applications
WHERE user_id = 'SID-TEST-TRG-01';

ROLLBACK;

