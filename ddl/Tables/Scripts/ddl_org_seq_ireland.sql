-- ============================================================================
--  alter_org_seq_ireland.sql   (MIGRATION: old PR format -> new format)
-- ----------------------------------------------------------------------------
--  Moves an existing deployment from  ORG-00-001-XXX-XXX-XXX  (PR #243, Ireland = DR for Virginia)
--  to the reviewed format             ORG-XXX-XXX-XXX-XXXX.
--
--  IMPORTANT — this changes BOTH the format AND the sequence range, so a plain
--  "create if missing" cannot update the already-deployed sequence. This script
--  therefore DROPS and RECREATES the sequence, which RESETS the counter.
--    * SAFE  pre-launch / in dev, when NO org_id values have been issued yet.
--    * NOT SAFE if ORG ids already exist: resetting would re-issue them, AND the
--      already-stored old-format ids (ORG-00-001-...) would need a separate
--      data back-fill. In that case, migrate data first, then run this.
--
--  Run as the OWNER of the organizations table.
-- ============================================================================

-- 1) Remove old objects (order: trigger -> function -> sequence) --------------
DROP TRIGGER  IF EXISTS before_insert_organizations ON ireland_dev_saayam_rdbms.organizations;
DROP FUNCTION IF EXISTS ireland_dev_saayam_rdbms.generate_org_id();
DROP SEQUENCE IF EXISTS ireland_dev_saayam_rdbms.org_id_dr_seq;   -- resets counter (see note)

-- 2) Recreate with the new range + format ------------------------------------
CREATE SEQUENCE ireland_dev_saayam_rdbms.org_id_dr_seq
    START WITH 1000000000000 INCREMENT BY 1 MINVALUE 1000000000000 MAXVALUE 1999999999999 NO CYCLE;

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    padded TEXT;
BEGIN
    IF NEW.org_id IS NOT NULL THEN
        RETURN NEW;
    END IF;
    seq_id := nextval('ireland_dev_saayam_rdbms.org_id_dr_seq');
    padded := LPAD(seq_id::TEXT, 13, '0');
    IF length(padded) > 13 THEN
        RAISE EXCEPTION 'org_id_dr_seq value % exceeds 13 digits; format would corrupt', seq_id;
    END IF;
    NEW.org_id := 'ORG-' ||
        SUBSTRING(padded FROM 1  FOR 3) || '-' ||
        SUBSTRING(padded FROM 4  FOR 3) || '-' ||
        SUBSTRING(padded FROM 7  FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 4);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER before_insert_organizations
    BEFORE INSERT ON ireland_dev_saayam_rdbms.organizations
    FOR EACH ROW EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_org_id();
