-- ----------------------------------------------------------------------------
--  WHAT CHANGED vs PR #243:
--    - Format: ORG-00-001-XXX-XXX-XXX  ->  ORG-XXX-XXX-XXX-XXXX (13 digits, 3-3-3-4)
--        * dropped the constant "00" marker (differentiated nothing)
--        * dropped the explicit "001" region sub-block (region now lives in the range)
--    - Formatting: FLOOR/MOD math  ->  LPAD + SUBSTRING (string slicing)
--    - Sequence range: START 1,000,000,000,000  ->  START 1, MAXVALUE 999,999,999,999
--        (Virginia now owns the 000-band; Ireland-DR owns the 100-band)
--  KEPT / ADDED (not in the raw feedback snippet):
--    - Trust-hook: a pre-supplied org_id (replication / DR copy-back) is not re-minted
--    - Width guard: loud error if a value ever exceeds 13 digits (SUBSTRING contract)
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS virginia_dev_saayam_rdbms.org_id_seq
    START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 999999999999 NO CYCLE;

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    padded TEXT;
BEGIN
    IF NEW.org_id IS NOT NULL THEN            -- replication / DR copy-back -> keep id
        RETURN NEW;
    END IF;

    seq_id := nextval('virginia_dev_saayam_rdbms.org_id_seq');
    padded := LPAD(seq_id::TEXT, 13, '0');

    IF length(padded) > 13 THEN               -- SUBSTRING width contract
        RAISE EXCEPTION 'org_id_seq value % exceeds 13 digits; format would corrupt', seq_id;
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
    BEFORE INSERT ON virginia_dev_saayam_rdbms.organizations
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_org_id();
