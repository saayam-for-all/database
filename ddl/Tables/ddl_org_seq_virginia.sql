
-- 1. Sequence (create if missing; leave existing untouched)
CREATE SEQUENCE IF NOT EXISTS virginia_dev_saayam_rdbms.seq_org_id
    START WITH 1000000000000
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE;

-- 2. (Re)create the generator function
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id TEXT;
    region_prefix TEXT := '001';
BEGIN
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

-- 3. Recreate the trigger (drop first so re-runs don't error)
DROP TRIGGER IF EXISTS trg_generate_org_id
    ON virginia_dev_saayam_rdbms.organizations;

CREATE TRIGGER trg_generate_org_id
    BEFORE INSERT ON virginia_dev_saayam_rdbms.organizations
    FOR EACH ROW EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_org_id();
