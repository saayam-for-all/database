-- =====================================================================
-- Regional Sequence Generator: ORGANIZATIONS -- IRELAND (eu-west-1)
-- EU region.
--
-- Per ADR: organizations are GLOBAL operational tables, so there is
-- NO is_eu split and NO dual generator here. Ireland differs from
-- Virginia ONLY in its sequence start range (2 trillion) and its
-- hardcoded region prefix ('002'), which together guarantee that any
-- org created in Ireland can never collide with a Virginia-native org
-- during disaster recovery / sync-back.
--
-- DECISION POINTS: identical to the Virginia file. See [D1]-[D4] there.
-- The ONLY differences from Virginia are:
--   - START WITH 2000000000000  (2 trillion)
--   - region_prefix := '002'
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Sequence: Ireland starts at 2 trillion.
-- ---------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS ireland_dev_saayam_rdbms.seq_org_id
    START WITH 2000000000000
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE;


-- ---------------------------------------------------------------------
-- 2. Generator function (hardcoded prefix '002' for Ireland)
--    Output example: ORG-00-002-004-010-003
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id TEXT;
    region_prefix TEXT := '002';   -- [D3] hardcoded: Ireland
BEGIN
    IF (NEW.org_id IS NULL) THEN
        seq_id := nextval('ireland_dev_saayam_rdbms.seq_org_id');

        new_id := 'ORG-00-' || region_prefix || '-' ||
                  LPAD(FLOOR((seq_id % 1000000000) / 1000000)::TEXT, 3, '0') || '-' ||
                  LPAD(FLOOR((seq_id % 1000000) / 1000)::TEXT, 3, '0') || '-' ||
                  LPAD((seq_id % 1000)::TEXT, 3, '0');

        NEW.org_id := new_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ---------------------------------------------------------------------
-- 3. Trigger: fire before INSERT on organizations.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_generate_org_id
    BEFORE INSERT ON ireland_dev_saayam_rdbms.organizations
    FOR EACH ROW EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_org_id();
