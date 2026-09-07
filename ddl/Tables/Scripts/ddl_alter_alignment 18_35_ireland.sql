-- Issue #256: Ireland Tables 18-35
-- Attribute alignment with the current Virginia DDL in saayam-for-all/database.
-- Scope: Ireland schema only, Tables 18-35.
-- Regional sequence generators are intentionally excluded from this file.
--
-- IMPORTANT:
-- 1. Run against a disposable/local copy first.
-- 2. This script does NOT drop/recreate tables.
-- 3. fraud_requests is NOT automatically migrated because the Ireland and
--    Virginia structures are semantically different; see the commented
--    review block at the end.
-- 4. Rename operations preserve existing data.
-- 5. Before production use, verify row counts and application dependencies.

BEGIN;

-- ============================================================
-- Table 20: request
-- Virginia: last_update_date; no to_public column.
-- Ireland: last_updated_at + to_public.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='request'
          AND column_name='last_updated_at'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='request'
          AND column_name='last_update_date'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.request
            RENAME COLUMN last_updated_at TO last_update_date;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.request
    ALTER COLUMN last_update_date DROP DEFAULT;

ALTER TABLE ireland_dev_saayam_rdbms.request
    DROP COLUMN IF EXISTS to_public;

-- The Ireland trigger function writes last_updated_at, so remove the
-- Ireland-only updated-at trigger after the column is aligned to Virginia.
DROP TRIGGER IF EXISTS trg_request_updated_at
    ON ireland_dev_saayam_rdbms.request;


-- ============================================================
-- Table 23: volunteers_assigned
-- Virginia: volunteers_assigned_id, request_id, last_update_date.
-- Ireland: vol_assigned_id, req_id, last_updated_at.
--
-- IMPORTANT: The current Virginia DDL itself references request(request_id),
-- while the current Virginia request table uses req_id. Renaming Ireland's
-- req_id to request_id would therefore reproduce an invalid FK relationship.
-- Keep the Ireland req_id name until the Virginia DDL is corrected upstream.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='volunteers_assigned'
          AND column_name='last_updated_at'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='volunteers_assigned'
          AND column_name='last_update_date'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.volunteers_assigned
            RENAME COLUMN last_updated_at TO last_update_date;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.volunteers_assigned
    ALTER COLUMN last_update_date DROP DEFAULT;

DROP TRIGGER IF EXISTS trg_volunteers_assigned_updated_at
    ON ireland_dev_saayam_rdbms.volunteers_assigned;


-- ============================================================
-- Table 24: volunteer_organizations
-- Virginia: last_update_date.
-- Ireland: last_updated_at.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='volunteer_organizations'
          AND column_name='last_updated_at'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='volunteer_organizations'
          AND column_name='last_update_date'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.volunteer_organizations
            RENAME COLUMN last_updated_at TO last_update_date;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.volunteer_organizations
    ALTER COLUMN last_update_date DROP DEFAULT;


-- ============================================================
-- Table 27: notifications
-- Virginia: last_update_date.
-- Ireland: last_updated_at.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='notifications'
          AND column_name='last_updated_at'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='notifications'
          AND column_name='last_update_date'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.notifications
            RENAME COLUMN last_updated_at TO last_update_date;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.notifications
    ALTER COLUMN last_update_date DROP DEFAULT;

DROP TRIGGER IF EXISTS trg_notifications_updated_at
    ON ireland_dev_saayam_rdbms.notifications;


-- ============================================================
-- Table 28: user_notification_preferences
-- Virginia has no last_updated_at column.
-- Ireland has last_updated_at.
-- ============================================================

ALTER TABLE ireland_dev_saayam_rdbms.user_notification_preferences
    DROP COLUMN IF EXISTS last_updated_at;

DROP TRIGGER IF EXISTS trg_user_notification_preferences_updated_at
    ON ireland_dev_saayam_rdbms.user_notification_preferences;


-- ============================================================
-- Table 29: sla
-- Virginia: last_updated_date.
-- Ireland: last_updated_at.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='sla'
          AND column_name='last_updated_at'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='sla'
          AND column_name='last_updated_date'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.sla
            RENAME COLUMN last_updated_at TO last_updated_date;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.sla
    ALTER COLUMN last_updated_date DROP DEFAULT;

DROP TRIGGER IF EXISTS trg_sla_updated_at
    ON ireland_dev_saayam_rdbms.sla;


-- ============================================================
-- Table 30: user_skills
-- Virginia does not contain skill_level.
-- ============================================================

ALTER TABLE ireland_dev_saayam_rdbms.user_skills
    DROP COLUMN IF EXISTS skill_level;

DROP TRIGGER IF EXISTS trg_user_skills_updated_at
    ON ireland_dev_saayam_rdbms.user_skills;

-- Virginia DDL creates the table index without IF NOT EXISTS.
-- Keep the existing index because it is structurally equivalent.


-- ============================================================
-- Table 31: volunteer_rating
-- Virginia: request_id, last_update_date.
-- Ireland: req_id, last_updated_at.
--
-- IMPORTANT: The current Virginia DDL references request(request_id),
-- although the current Virginia request table uses req_id. Do not rename
-- Ireland req_id until that upstream inconsistency is resolved.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='volunteer_rating'
          AND column_name='last_updated_at'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='volunteer_rating'
          AND column_name='last_update_date'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.volunteer_rating
            RENAME COLUMN last_updated_at TO last_update_date;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.volunteer_rating
    ALTER COLUMN last_update_date DROP DEFAULT;

DROP TRIGGER IF EXISTS trg_volunteer_rating_updated_at
    ON ireland_dev_saayam_rdbms.volunteer_rating;


-- ============================================================
-- Table 32: user_availability
-- Virginia: last_update_date.
-- Ireland: last_updated_at.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='user_availability'
          AND column_name='last_updated_at'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='user_availability'
          AND column_name='last_update_date'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.user_availability
            RENAME COLUMN last_updated_at TO last_update_date;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.user_availability
    ALTER COLUMN last_update_date DROP DEFAULT;

DROP TRIGGER IF EXISTS trg_user_availability_updated_at
    ON ireland_dev_saayam_rdbms.user_availability;


-- ============================================================
-- Table 33: emergency_numbers
-- Virginia has no last_updated_at column.
-- Ireland has last_updated_at.
-- ============================================================

ALTER TABLE ireland_dev_saayam_rdbms.emergency_numbers
    DROP COLUMN IF EXISTS last_updated_at;

DROP TRIGGER IF EXISTS trg_emergency_numbers_updated_at
    ON ireland_dev_saayam_rdbms.emergency_numbers;


-- ============================================================
-- Table 34: organizations
-- Virginia has is_collaborator but not is_contributor.
-- Ireland has is_contributor.
--
-- org_id sequence/generator is intentionally NOT changed here.
-- ============================================================

ALTER TABLE ireland_dev_saayam_rdbms.organizations
    DROP COLUMN IF EXISTS is_contributor;


-- ============================================================
-- Table 35: req_add_info
-- Virginia: id as PK and no timestamp column.
-- Ireland: info_id as PK + last_updated_at.
-- ============================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='req_add_info'
          AND column_name='info_id'
    )
    AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='ireland_dev_saayam_rdbms'
          AND table_name='req_add_info'
          AND column_name='id'
    ) THEN
        ALTER TABLE ireland_dev_saayam_rdbms.req_add_info
            RENAME COLUMN info_id TO id;
    END IF;
END $$;

ALTER TABLE ireland_dev_saayam_rdbms.req_add_info
    DROP COLUMN IF EXISTS last_updated_at;

DROP TRIGGER IF EXISTS trg_req_add_info_updated_at
    ON ireland_dev_saayam_rdbms.req_add_info;


-- ============================================================
-- Table 22: fraud_requests
-- NOT auto-migrated.
--
-- Current Virginia DDL is:
--   fraud_request_id SERIAL PRIMARY KEY
--   user_id VARCHAR(255) NOT NULL
--   request_datetime TIMESTAMP NOT NULL
--   reason VARCHAR(255) NOT NULL
--
-- Current Ireland DDL instead stores request-level fields and a
-- sentiment ref_code. Converting it requires a business mapping for
-- request_datetime and reason and can be destructive. See review
-- block below.
-- ============================================================

COMMIT;


-- ============================================================
-- POST-MIGRATION VALIDATION
-- ============================================================

SELECT table_name, column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema='ireland_dev_saayam_rdbms'
  AND table_name IN (
      'request',
      'volunteers_assigned',
      'volunteer_organizations',
      'notifications',
      'user_notification_preferences',
      'sla',
      'user_skills',
      'volunteer_rating',
      'user_availability',
      'emergency_numbers',
      'organizations',
      'req_add_info'
  )
ORDER BY table_name, ordinal_position;


-- ============================================================
-- FRAUD_REQUESTS REVIEW BLOCK
-- ============================================================
-- Do NOT execute until the team confirms the data mapping.
--
-- A safe migration would first add the Virginia columns:
--
-- ALTER TABLE ireland_dev_saayam_rdbms.fraud_requests
--     ADD COLUMN fraud_request_id SERIAL,
--     ADD COLUMN user_id VARCHAR(255),
--     ADD COLUMN request_datetime TIMESTAMP,
--     ADD COLUMN reason VARCHAR(255);
--
-- Then populate them from the existing Ireland data according to an
-- agreed business rule. Only after validation should the Ireland-only
-- columns be removed and the new PK/FK constraints created.
--
-- Do not use req_desc blindly as reason without team approval.
