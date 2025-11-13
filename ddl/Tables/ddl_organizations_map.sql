CREATE TABLE virginia_dev_saayam_rdbms.user_org_map (
    user_id VARCHAR(255) NOT NULL,
    org_id VARCHAR(255) NOT NULL,
    user_role VARCHAR(50),        -- e.g. 'ADMIN', 'STAFF', 'VOLUNTEER'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_org_map_pk PRIMARY KEY (user_id, org_id),
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (org_id) REFERENCES virginia_dev_saayam_rdbms.organizations(org_id) ON DELETE CASCADE
);
