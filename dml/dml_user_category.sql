/* 
-- Assuming the child table is 'users' and the foreign key is 'user_category_id'
ALTER TABLE virginia_dev_saayam_rdbms.users
    ALTER COLUMN user_category_id DROP NOT NULL;

-- Assuming the constraint was already dropped in a previous step, re-add it.
ALTER TABLE virginia_dev_saayam_rdbms.users
    ADD CONSTRAINT fk_user_category_id
        FOREIGN KEY (user_category_id)
        REFERENCES virginia_dev_saayam_rdbms.user_category (user_category_id)
        ON DELETE SET NULL;

ALTER TABLE virginia_dev_saayam_rdbms.user_category
ADD COLUMN user_access_level SMALLINT,
ADD COLUMN category_code VARCHAR(50) UNIQUE,
ADD COLUMN is_deprecated BOOLEAN DEFAULT FALSE,
ADD COLUMN permissions JSONB;

-- a. Rename the column
ALTER TABLE virginia_dev_saayam_rdbms.user_category
    RENAME COLUMN last_update_date TO last_updated_at;

-- b. Set the default value for the renamed column
ALTER TABLE virginia_dev_saayam_rdbms.user_category
    ALTER COLUMN last_updated_at SET DEFAULT NOW();
*/

--THE ABOVE CHANGES ARE DONE IN THE VIRGINIA REGION AND CHANGED IN THE DDL FILES ACCORDINGLY

-- 1. Beneficiary (Lowest Access Level: 1)
INSERT INTO virginia_dev_saayam_rdbms.user_category (
user_category, 
user_category_desc, 
user_access_level, 
category_code, 
is_deprecated, 
permissions, 
last_updated_at
) VALUES ('Beneficiary','End-users who submit and manage help requests for themselves or others',1,'BEN',FALSE,'{"submit_request": true, "track_status": true, "delete_request": true, "communicate_with_volunteer": true}',CURRENT_TIMESTAMP
);

-- 2. Volunteer (Access Level: 2)
INSERT INTO virginia_dev_saayam_rdbms.user_category (
user_category, 
user_category_desc, 
user_access_level, 
category_code, 
is_deprecated, 
permissions, 
last_updated_at
) VALUES ('Volunteer','Users who assist beneficiaries by accepting and progressing requests',2,'VOL',FALSE,'{"accept_request": true, "update_progress": true, "become_lead_volunteer": true}',CURRENT_TIMESTAMP
);

-- 3. Steward (Access Level: 3)
INSERT INTO virginia_dev_saayam_rdbms.user_category (
user_category, 
user_category_desc, 
user_access_level, 
category_code, 
is_deprecated, 
permissions, 
last_updated_at
) VALUES ('Steward','Users who facilitate operations by matching requests and reassigning tasks',3,'STW',FALSE,'{"match_requests": true, "view_reports": true, "reassign_volunteers": true, "query_matched_requests": true}',CURRENT_TIMESTAMP
);

-- 4. Admin (Access Level: 4)
INSERT INTO virginia_dev_saayam_rdbms.user_category (
user_category, 
user_category_desc, 
user_access_level, 
category_code, 
is_deprecated, 
permissions, 
last_updated_at
) VALUES ('Admin','Users who manage platform settings, user roles, integrations, and dashboards',4,'ADM',FALSE,'{"manage_roles": true, "manage_integrations": true, "manage_dashboard": true, "manage_users": true}',CURRENT_TIMESTAMP
);

-- 5. Super Admin (Highest Access Level: 5)
INSERT INTO virginia_dev_saayam_rdbms.user_category (
user_category, 
user_category_desc, 
user_access_level, 
category_code, 
is_deprecated, 
permissions, 
last_updated_at
) VALUES ('Super Admin','Users who oversee admins and handle platform-wide functions like security and backups',5,'SUP',FALSE,'{"manage_admin": true, "full_platform_backup_restore": true}',CURRENT_TIMESTAMP
);

--UPDATE virginia_dev_saayam_rdbms.users
--SET user_category_id = 1;
