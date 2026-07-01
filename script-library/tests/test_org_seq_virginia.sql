DO $$
DECLARE
    v_id1 TEXT;
    v_id2 TEXT;
BEGIN
    RAISE NOTICE '=== VIRGINIA ORG ID GENERATOR TEST ===';

    -- 1. Auto-generate on insert (org_id left NULL)
    INSERT INTO virginia_dev_saayam_rdbms.organizations (org_name)
    VALUES ('Test Org Alpha')
    RETURNING org_id INTO v_id1;
    RAISE NOTICE 'Generated id #1: %', v_id1;

    INSERT INTO virginia_dev_saayam_rdbms.organizations (org_name)
    VALUES ('Test Org Beta')
    RETURNING org_id INTO v_id2;
    RAISE NOTICE 'Generated id #2: %', v_id2;

    -- 2. Format check: must start with ORG-00-001-
    IF v_id1 LIKE 'ORG-00-001-%' THEN
        RAISE NOTICE 'PASS: Virginia prefix ORG-00-001- present';
    ELSE
        RAISE EXCEPTION 'FAIL: unexpected prefix on %', v_id1;
    END IF;

    -- 3. Uniqueness / monotonicity
    IF v_id1 <> v_id2 THEN
        RAISE NOTICE 'PASS: consecutive ids differ';
    ELSE
        RAISE EXCEPTION 'FAIL: duplicate ids generated';
    END IF;

    -- 4. Explicit org_id must be respected (not overwritten)
    INSERT INTO virginia_dev_saayam_rdbms.organizations (org_id, org_name)
    VALUES ('ORG-00-999-000-000-001', 'Explicit Org');
    PERFORM 1 FROM virginia_dev_saayam_rdbms.organizations
        WHERE org_id = 'ORG-00-999-000-000-001';
    IF FOUND THEN
        RAISE NOTICE 'PASS: explicit org_id preserved';
    ELSE
        RAISE EXCEPTION 'FAIL: explicit org_id was overwritten';
    END IF;

    -- cleanup
    DELETE FROM virginia_dev_saayam_rdbms.organizations
    WHERE org_id IN (v_id1, v_id2, 'ORG-00-999-000-000-001');

    RAISE NOTICE '=== ALL VIRGINIA TESTS PASSED ===';
END $$;
