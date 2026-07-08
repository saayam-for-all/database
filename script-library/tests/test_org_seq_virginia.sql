-- ============================================================================
--  test_organizations_virginia.sql   —  run in the VIRGINIA database
--  Verifies the updated generator (ORG-XXX-XXX-XXX-XXXX, 000-band).
--  Assertions print via RAISE NOTICE (psql output / pgAdmin "Messages" tab).
--  setval/TRUNCATE make it repeatable — TEST DATABASE ONLY.
-- ============================================================================

TRUNCATE virginia_dev_saayam_rdbms.organizations;
SELECT setval('virginia_dev_saayam_rdbms.org_id_seq', 1, false);   -- next = 1

-- T1  Sequential mint in the 000-band ---------------------------------------
DO $$
DECLARE a TEXT; b TEXT;
BEGIN
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name) VALUES ('VA-1') RETURNING org_id INTO a;
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name) VALUES ('VA-2') RETURNING org_id INTO b;
    IF a='ORG-000-000-000-0001' AND b='ORG-000-000-000-0002'
        THEN RAISE NOTICE 'T1 PASS  Virginia sequential 000-band (%, %)', a, b;
        ELSE RAISE NOTICE 'T1 FAIL  got %, %', a, b; END IF;
END$$;

-- T2  Trust-hook: a pre-supplied id (replica / DR copy-back) is kept, and the
--     local sequence is NOT consumed -----------------------------------------
DO $$
DECLARE kept TEXT; nxt TEXT;
BEGIN
    PERFORM setval('virginia_dev_saayam_rdbms.org_id_seq', 50, true);   -- next mint = 51
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_id, org_name)
        VALUES ('ORG-100-000-000-0000', 'copied-from-ireland') RETURNING org_id INTO kept;
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name)
        VALUES ('next-local') RETURNING org_id INTO nxt;
    IF kept='ORG-100-000-000-0000' AND nxt='ORG-000-000-000-0051'
        THEN RAISE NOTICE 'T2 PASS  pre-supplied id kept (%), sequence not consumed (next=%)', kept, nxt;
        ELSE RAISE NOTICE 'T2 FAIL  kept=% next=%', kept, nxt; END IF;
END$$;

-- T3  Segment-rollover math at 1,000 / 10,000 / 1,000,000 -------------------
DO $$
DECLARE a TEXT; b TEXT; c TEXT;
BEGIN
    PERFORM setval('virginia_dev_saayam_rdbms.org_id_seq', 999, true);
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name) VALUES ('r1k')  RETURNING org_id INTO a;
    PERFORM setval('virginia_dev_saayam_rdbms.org_id_seq', 9999, true);
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name) VALUES ('r10k') RETURNING org_id INTO b;
    PERFORM setval('virginia_dev_saayam_rdbms.org_id_seq', 999999, true);
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name) VALUES ('r1m')  RETURNING org_id INTO c;
    IF a='ORG-000-000-000-1000' AND b='ORG-000-000-001-0000' AND c='ORG-000-000-100-0000'
        THEN RAISE NOTICE 'T3 PASS  rollover correct (%, %, %)', a, b, c;
        ELSE RAISE NOTICE 'T3 FAIL  got %, %, %', a, b, c; END IF;
END$$;

-- T4  Exhaustion hard wall at MAXVALUE 999,999,999,999 ----------------------
DO $$
DECLARE last_id TEXT;
BEGIN
    PERFORM setval('virginia_dev_saayam_rdbms.org_id_seq', 999999999998, true);   -- next = MAXVALUE
    INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name) VALUES ('last') RETURNING org_id INTO last_id;
    RAISE NOTICE 'T4 ..  last mint at MAXVALUE = %', last_id;
    BEGIN
        INSERT INTO virginia_dev_saayam_rdbms.organizations(org_name) VALUES ('over');
        RAISE NOTICE 'T4 FAIL  sequence did not exhaust';
    EXCEPTION WHEN others THEN
        RAISE NOTICE 'T4 PASS  hard wall hit as designed: %', SQLERRM;
    END;
END$$;

SELECT org_id, org_name FROM virginia_dev_saayam_rdbms.organizations ORDER BY org_id;
