-- Minimal user_category rows 
INSERT INTO virginia_dev_saayam_rdbms.user_category
    (user_category_id, user_category, user_category_desc, category_code)
VALUES
    (1, 'Beneficiary',  'Default category for all users',     'BEN'),
    (2, 'Volunteer',    'Users who offer services',           'VOL'),
    (3, 'Coordinator',  'Users who manage requests',          'CRD'),
    (4, 'Donor',        'Users who contribute resources',     'DNR'),
    (5, 'Admin',        'Platform administrators',            'ADM')
ON CONFLICT (user_category_id) DO NOTHING;

WITH ins AS (
    INSERT INTO virginia_dev_saayam_rdbms.users
        (state_id, country_id, full_name, primary_email_address)
    VALUES
        ('VA', 1, 'Alice Test',   'alice@test.example'),
        ('VA', 1, 'Bob Test',     'bob@test.example')
    RETURNING user_id, primary_email_address
)
SELECT * FROM ins;   
DO $$
DECLARE
    alice_id VARCHAR(255);
    bob_id   VARCHAR(255);
BEGIN
    SELECT user_id INTO alice_id
      FROM virginia_dev_saayam_rdbms.users
     WHERE primary_email_address = 'alice@test.example';

    SELECT user_id INTO bob_id
      FROM virginia_dev_saayam_rdbms.users
     WHERE primary_email_address = 'bob@test.example';

    -- TEST 1: Default Beneficiary assignment
    
    INSERT INTO virginia_dev_saayam_rdbms.user_category_map
        (user_id, user_category_id)
    VALUES
        (alice_id, 1),   
        (bob_id,   1);   

    ASSERT (
        SELECT COUNT(*) FROM virginia_dev_saayam_rdbms.user_category_map
         WHERE user_category_id = 1
    ) = 2,
    'TEST 1 FAILED: Both users should have Beneficiary mapping';
    RAISE NOTICE 'TEST 1 PASSED: Default Beneficiary assignment';

    -- TEST 2: Multi-category assignment (up to 5 categories)

    INSERT INTO virginia_dev_saayam_rdbms.user_category_map
        (user_id, user_category_id)
    VALUES
        (alice_id, 2),   -- Volunteer
        (alice_id, 3),   -- Coordinator
        (alice_id, 4),   -- Donor
        (alice_id, 5);   -- Admin

    ASSERT (
        SELECT COUNT(*) FROM virginia_dev_saayam_rdbms.user_category_map
         WHERE user_id = alice_id
    ) = 5,
    'TEST 2 FAILED: Alice should have exactly 5 category mappings';
    RAISE NOTICE 'TEST 2 PASSED: Multi-category assignment (5 roles)';

    -- TEST 3: Duplicate mapping rejected (PK constraint)

    BEGIN
        INSERT INTO virginia_dev_saayam_rdbms.user_category_map
            (user_id, user_category_id)
        VALUES (alice_id, 1);  

        RAISE EXCEPTION 'TEST 3 FAILED: Duplicate insert should have been rejected';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'TEST 3 PASSED: Duplicate (user, category) correctly rejected';
    END;

    -- TEST 4: FK on user_id – invalid user rejected

    BEGIN
        INSERT INTO virginia_dev_saayam_rdbms.user_category_map
            (user_id, user_category_id)
        VALUES ('SID-00-999-999-999', 1);   

        RAISE EXCEPTION 'TEST 4 FAILED: Invalid user_id should have been rejected';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'TEST 4 PASSED: FK on user_id correctly enforced';
    END;

    -- TEST 5: FK on user_category_id – invalid category rejected

    BEGIN
        INSERT INTO virginia_dev_saayam_rdbms.user_category_map
            (user_id, user_category_id)
        VALUES (bob_id, 999);   

        RAISE EXCEPTION 'TEST 5 FAILED: Invalid user_category_id should have been rejected';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'TEST 5 PASSED: FK on user_category_id correctly enforced';
    END;

    -- TEST 6: Cascade delete on user removal

    DELETE FROM virginia_dev_saayam_rdbms.users
     WHERE user_id = bob_id;

    ASSERT (
        SELECT COUNT(*) FROM virginia_dev_saayam_rdbms.user_category_map
         WHERE user_id = bob_id
    ) = 0,
    'TEST 6 FAILED: Mappings should be cascade-deleted with the user';
    RAISE NOTICE 'TEST 6 PASSED: Cascade delete on user correctly removes mappings';

    -- TEST 7: users table no longer has user_category_id column

    ASSERT (
        SELECT COUNT(*) FROM information_schema.columns
         WHERE table_schema = 'virginia_dev_saayam_rdbms'
           AND table_name   = 'users'
           AND column_name  = 'user_category_id'
    ) = 0,
    'TEST 7 FAILED: user_category_id column should not exist on users table';
    RAISE NOTICE 'TEST 7 PASSED: user_category_id column removed from users';

    -- TEST 8: Reverse lookup – all users in a given category

    ASSERT (
        SELECT COUNT(*) FROM virginia_dev_saayam_rdbms.user_category_map
         WHERE user_category_id = 2   
    ) = 1,
    'TEST 8 FAILED: Only Alice should be a Volunteer';
    RAISE NOTICE 'TEST 8 PASSED: Reverse lookup (category → users) works correctly';


    DELETE FROM virginia_dev_saayam_rdbms.users
     WHERE primary_email_address IN ('alice@test.example', 'bob@test.example');

    DELETE FROM virginia_dev_saayam_rdbms.user_category
     WHERE user_category_id IN (1, 2, 3, 4, 5);

    RAISE NOTICE '--- All tests completed. Seed data cleaned up. ---';
END;
$$;


