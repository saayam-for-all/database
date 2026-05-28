
ALTER TABLE virginia_dev_saayam_rdbms.organizations
    RENAME COLUMN is_collaborator TO is_collaborative;

-- 2. Add new column. Nullable; meaningful only for for_profit orgs.
ALTER TABLE virginia_dev_saayam_rdbms.organizations
    ADD COLUMN is_contributing BOOLEAN;

-- 3. Optional backfill (uncomment if business requires a default for existing rows).
-- UPDATE virginia_dev_saayam_rdbms.organizations
--    SET is_contributing = FALSE
--  WHERE org_type = 'for_profit'
--    AND is_contributing IS NULL;

-- 4. Enforce that is_contributing is NULL whenever org is not for_profit.
ALTER TABLE virginia_dev_saayam_rdbms.organizations
    ADD CONSTRAINT chk_contributing_only_for_profit
    CHECK (org_type = 'for_profit' OR is_contributing IS NULL);
