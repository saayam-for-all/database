-- 1. Remove old indexes and constraints first
DROP INDEX IF EXISTS virginia_dev_saayam_rdbms.idx_org_cat_id;  
DROP INDEX IF EXISTS virginia_dev_saayam_rdbms.idx_org_state;
DROP INDEX IF EXISTS virginia_dev_saayam_rdbms.idx_org_city_state;

ALTER TABLE virginia_dev_saayam_rdbms.organizations 
    DROP CONSTRAINT IF EXISTS organizations_cat_id_fkey,
    DROP CONSTRAINT IF EXISTS organizations_govt_id_num_key;

-- 2. Remove columns
ALTER TABLE virginia_dev_saayam_rdbms.organizations 
    DROP COLUMN IF EXISTS govt_id_num,
    DROP COLUMN IF EXISTS source,
    DROP COLUMN IF EXISTS cat_id;

-- 3. Drop unused ENUMs
DROP TYPE IF EXISTS source_enum;

-- 4. Create a new ENUM and add new columns
CREATE TYPE org_size_enum AS ENUM ('small', 'medium', 'large');

ALTER TABLE virginia_dev_saayam_rdbms.organizations 
    ADD COLUMN org_size org_size_enum,
    ADD COLUMN org_rating INTEGER CHECK (org_rating >= 1 AND org_rating <= 5),
    ADD COLUMN is_collaborator BOOLEAN;

ALTER TABLE virginia_dev_saayam_rdbms.organizations 
    RENAME COLUMN state_code TO state_id;

ALTER TABLE virginia_dev_saayam_rdbms.organizations 
    ALTER COLUMN state_id TYPE VARCHAR(50);

ALTER TABLE virginia_dev_saayam_rdbms.organizations 
    ADD CONSTRAINT organizations_state_id_fkey 
    FOREIGN KEY (state_id) 
    REFERENCES virginia_dev_saayam_rdbms.state(state_id) 
    ON DELETE SET NULL;

-- 4. Re-create the updated Indexes
CREATE INDEX idx_org_state_id 
    ON virginia_dev_saayam_rdbms.organizations(state_id);

CREATE INDEX idx_org_city_state 
    ON virginia_dev_saayam_rdbms.organizations(city_name, state_id);

ALTER TABLE virginia_dev_saayam_rdbms.organizations 
    ALTER COLUMN created_at TYPE TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN created_at SET DEFAULT (now() AT TIME ZONE 'UTC'),
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');
