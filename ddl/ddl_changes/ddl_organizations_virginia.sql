-- =====================================================================
-- Regional Sequence Generator: ORGANIZATIONS -- VIRGINIA (us-east-1)
-- Primary / base region. Non-EU orgs.

-- ---------------------------------------------------------------------
-- 1. Sequence: Virginia starts at 1 trillion.
--    NOTE ON RANGE: The ADR reserves 1-trillion..2-trillion for Virginia
--    and 2-trillion.. for Ireland. Starting Virginia AT 1,000,000,000,000
--    means native Virginia orgs occupy the '001' sub-block. Orgs created
--    in Virginia's OWN region during normal operation carry prefix '001'.
-- ---------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS virginia_dev_saayam_rdbms.seq_org_id
    START WITH 1000000000000
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE;


-- ---------------------------------------------------------------------
-- 2. Generator function (hardcoded prefix '001' for Virginia)
--    Output example: ORG-00-001-004-010-003
--    Layout: ORG-00-<region:3>-<seg1:3>-<seg2:3>-<seg3:3>
--    Divisor math is billion-scale to support trillion ranges:
--      seg1 = (seq % 1,000,000,000) / 1,000,000
--      seg2 = (seq % 1,000,000)     / 1,000
--      seg3 =  seq % 1,000
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id TEXT;
    region_prefix TEXT := '001';   -- [D3] hardcoded: Virginia
BEGIN
    -- Only generate if caller did not supply an org_id explicitly.
    IF (NEW.org_id IS NULL) THEN
        seq_id := nextval('virginia_dev_saayam_rdbms.seq_org_id');

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
--    [D1] Assumes table virginia_dev_saayam_rdbms.organizations with
--         column org_id as PK.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_generate_org_id
    BEFORE INSERT ON virginia_dev_saayam_rdbms.organizations
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_org_id();
