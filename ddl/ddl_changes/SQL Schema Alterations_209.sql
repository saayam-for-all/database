BEGIN;
ALTER TABLE virginia_dev_saayam_rdbms.organizations
    RENAME COLUMN is_collaborator TO is_collaborative;
ALTER TABLE virginia_dev_saayam_rdbms.organizations
    ADD COLUMN IF NOT EXISTS is_contributing BOOLEAN;

UPDATE virginia_dev_saayam_rdbms.organizations
SET is_contributing = NULL
WHERE org_type IS DISTINCT FROM 'for_profit'
  AND is_contributing IS NOT NULL;

ALTER TABLE virginia_dev_saayam_rdbms.organizations
    ADD CONSTRAINT chk_contributing_only_for_profit
    CHECK (
        (org_type = 'for_profit')
        OR (org_type IS DISTINCT FROM 'for_profit' AND is_contributing IS NULL)
    ) NOT VALID;

ALTER TABLE virginia_dev_saayam_rdbms.organizations
    VALIDATE CONSTRAINT chk_contributing_only_for_profit;

CREATE INDEX IF NOT EXISTS idx_org_contributing_for_profit
    ON virginia_dev_saayam_rdbms.organizations(org_type)
    WHERE is_contributing = TRUE;

COMMIT;
