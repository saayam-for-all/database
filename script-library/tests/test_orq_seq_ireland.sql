-- ============================================================================
--  test_organizations_ireland.sql   —  run in the IRELAND database
--  Verifies the updated DR generator (ORG-XXX-XXX-XXX-XXXX, 100-band).
--  Ireland = DR for Virginia; its sequence lives in the 1,000,000,000,000 band.
--  Assertions print via RAISE NOTICE. setval/TRUNCATE => TEST DATABASE ONLY.
-- ============================================================================

TRUNCATE ireland_dev_saayam_rdbms.organizations;
SELECT setval('ireland_dev_saayam_rdbms.org_id_dr_seq', 1000000000000, false);   -- next = 1e12

-- T1  Sequential mint in the 100-band ---------------------------------------
DO $$
DECLARE a TEXT; b TEXT;
BEGIN
    INSERT INTO ireland_dev_saayam_rdbms.organizations(org_name) VALUES ('IE-1') RETURNING org_id INTO a;
    INSERT INTO ireland_dev_saayam_rdbms.organizations(org_name) VALUES ('IE-2') RETURNING org_id INTO b;
    IF a='ORG-100-000-000-0000' AND b='ORG-100-000-000-0001'
        THEN RAISE NOTICE 'T1 PASS  Ireland-DR sequential 100-band (%, %)', a, b;
        ELSE RAISE NOTICE 'T1 FAIL  got %, %', a, b; END IF;
END$$;

-- T2  Trust-hook: a pre-supplied id (e.g. a Virginia 000-band id being
--     replicated in) is kept, and the DR sequence is NOT consumed -----------
DO $$
DECLARE kept TEXT; nxt TEXT;
BEGIN
    PERFORM setval('ireland_dev_saayam_rdbms.org_id_dr_seq', 1000000000050, true);  -- next = ...051
    INSERT INTO ireland_dev_saayam_rdbms.organizations(org_id, org_name)
        VALUES ('ORG-000-000-000-0007', 'replicated-from-virginia') RETURNING org_id INTO kept;
    INSERT INTO ireland_dev_saayam_rdbms.organizations(org_name)
        VALUES ('next-dr') RETURNING org_id INTO nxt;
    IF kept='ORG-000-000-000-0007' AND nxt='ORG-100-000-000-0051'
        THEN RAISE NOTICE 'T2 PASS  pre-supplied id kept (%), DR seq not consumed (next=%)', kept, nxt;
        ELSE RAISE NOTICE 'T2 FAIL  kept=% next=%', kept, nxt; END IF;
END$$;

-- T3  Segment-rollover math inside the 100-band -----------------------------
DO $$
DECLARE a TEXT; b TEXT;
BEGIN
    PERFORM setval('ireland_dev_saayam_rdbms.org_id_dr_seq', 1000000000999, true);  -- next ...1000
    INSERT INTO ireland_dev_saayam_rdbms.organizations(org_name) VALUES ('r1k')  RETURNING org_id INTO a;
    PERFORM setval('ireland_dev_saayam_rdbms.org_id_dr_seq', 1000000009999, true);  -- next ...10000
    INSERT INTO ireland_dev_saayam_rdbms.organizations(org_name) VALUES ('r10k') RETURNING org_id INTO b;
    IF a='ORG-100-000-000-1000' AND b='ORG-100-000-001-0000'
        THEN RAISE NOTICE 'T3 PASS  rollover correct (%, %)', a, b;
        ELSE RAISE NOTICE 'T3 FAIL  got %, %', a, b; END IF;
END$$;

-- T4  Exhaustion hard wall at MAXVALUE 1,999,999,999,999 --------------------
DO $$
DECLARE last_id TEXT;
BEGIN
    PERFORM setval('ireland_dev_saayam_rdbms.org_id_dr_seq', 1999999999998, true); -- next = MAXVALUE
    INSERT INTO ireland_dev_saayam_rdbms.organizations(org_name) VALUES ('last') RETURNING org_id INTO last_id;
    RAISE NOTICE 'T4 ..  last mint at MAXVALUE = %', last_id;
    BEGIN
        INSERT INTO ireland_dev_saayam_rdbms.organizations(org_name) VALUES ('over');
        RAISE NOTICE 'T4 FAIL  sequence did not exhaust';
    EXCEPTION WHEN others THEN
        RAISE NOTICE 'T4 PASS  hard wall hit as designed: %', SQLERRM;
    END;
END$$;

SELECT org_id, org_name FROM ireland_dev_saayam_rdbms.organizations ORDER BY org_id;
