-- =====================================================================
-- DDL CHANGE SCRIPT: Ireland org sequence generator
-- Idempotent migration. Differs from Virginia only in start range
-- (2 trillion) and region prefix ('002').
-- =====================================================================

CREATE SEQUENCE IF NOT EXISTS ireland_dev_saayam_rdbms.seq_org_id
    START WITH 2000000000000
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE;

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id TEXT;
    region_prefix TEXT := '002';
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

DROP TRIGGER IF EXISTS trg_generate_org_id
    ON ireland_dev_saayam_rdbms.organizations;

CREATE TRIGGER trg_generate_org_id
    BEFORE INSERT ON ireland_dev_saayam_rdbms.organizations
    FOR EACH ROW EXECUTE FUNCTION ireland_dev_saayam_rdbms.generate_org_id();
