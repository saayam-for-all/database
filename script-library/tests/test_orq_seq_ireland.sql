DO $$
DECLARE
    v_id1 TEXT;
    v_id2 TEXT;
BEGIN
    RAISE NOTICE '=== IRELAND ORG ID GENERATOR TEST ===';

    INSERT INTO ireland_dev_saayam_rdbms.organizations (org_name)
    VALUES ('Test Org Gamma')
    RETURNING org_id INTO v_id1;
    RAISE NOTICE 'Generated id #1: %', v_id1;

    INSERT INTO ireland_dev_saayam_rdbms.organizations (org_name)
    VALUES ('Test Org Delta')
    RETURNING org_id INTO v_id2;
    RAISE NOTICE 'Generated id #2: %', v_id2;

    -- Format check: must start with ORG-00-002-
    IF v_id1 LIKE 'ORG-00-002-%' THEN
        RAISE NOTICE 'PASS: Ireland prefix ORG-00-002- present';
    ELSE
        RAISE EXCEPTION 'FAIL: unexpected prefix on %', v_id1;
    END IF;

    -- Cross-region collision guard: Ireland ids must NOT carry the
    -- Virginia 001 prefix.
    IF v_id1 NOT LIKE 'ORG-00-001-%' THEN
        RAISE NOTICE 'PASS: Ireland id does not collide with Virginia range';
    ELSE
        RAISE EXCEPTION 'FAIL: Ireland produced a Virginia-range id';
    END IF;

    IF v_id1 <> v_id2 THEN
        RAISE NOTICE 'PASS: consecutive ids differ';
    ELSE
        RAISE EXCEPTION 'FAIL: duplicate ids generated';
    END IF;

    DELETE FROM ireland_dev_saayam_rdbms.organizations
    WHERE org_id IN (v_id1, v_id2);

    RAISE NOTICE '=== ALL IRELAND TESTS PASSED ===';
END $$;
