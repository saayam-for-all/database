DROP TABLE IF EXISTS virginia_dev_saayam_rdbms.org_skills CASCADE;

CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.org_skills (
  org_id VARCHAR(255),
  cat_id VARCHAR(50),
  assigned_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (now() AT TIME ZONE 'UTC'),
  PRIMARY KEY (org_id, cat_id),
  FOREIGN KEY (org_id) REFERENCES virginia_dev_saayam_rdbms.organizations(org_id) ON DELETE CASCADE,
  FOREIGN KEY (cat_id) REFERENCES help_categories(cat_id) ON DELETE CASCADE
);

-- Indexes for optimized Lookups/Joins
-- Note: (org_id, cat_id) is already indexed by the Primary Key.
-- We add an index on cat_id specifically for queries looking up all orgs for a specific skill.
CREATE INDEX idx_org_skills_cat_id ON virginia_dev_saayam_rdbms.org_skills(cat_id);