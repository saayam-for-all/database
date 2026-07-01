-- Search MVP smoke test.
-- Run after instance clone and ddl/Search/01..04.

BEGIN;

SET search_path TO virginia_dev_saayam_rdbms, public;

INSERT INTO country (country_id, country_name, phone_code, country_code)
VALUES (1, 'United States', '+1', 'US')
ON CONFLICT (country_id) DO NOTHING;

INSERT INTO state (state_id, country_id, state_name, state_code)
VALUES ('CA', 1, 'California', 'CA')
ON CONFLICT (state_id) DO NOTHING;

INSERT INTO user_status (user_status_id, user_status, user_status_desc)
VALUES (1, 'active', 'Active user')
ON CONFLICT (user_status_id) DO NOTHING;

INSERT INTO user_category (
    user_category_id,
    user_category,
    user_category_desc,
    user_access_level,
    category_code
)
VALUES
    (1, 'requester', 'Requester', 1, 'REQUESTER'),
    (4, 'admin', 'Admin', 4, 'ADMIN')
ON CONFLICT (user_category_id) DO NOTHING;

INSERT INTO users (
    user_id,
    state_id,
    country_id,
    user_status_id,
    user_category_id,
    full_name,
    first_name,
    last_name,
    primary_email_address,
    city_name
)
VALUES
    ('user-admin', 'CA', 1, 1, 4, 'Admin Search', 'Admin', 'Search', 'admin@example.test', 'San Jose'),
    ('user-alice', 'CA', 1, 1, 1, 'Alice Emergency', 'Alice', 'Emergency', 'alice@example.test', 'San Jose'),
    ('user-bob', 'CA', 1, 1, 1, 'Bob Foodhelp', 'Bob', 'Foodhelp', 'bob@example.test', 'Oakland')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO help_categories (cat_id, cat_name, cat_desc)
VALUES
    ('medical', 'Medical Help', 'Medical and emergency support'),
    ('food', 'Food Support', 'Groceries and food help')
ON CONFLICT (cat_id) DO NOTHING;

INSERT INTO request_status (req_status_id, req_status, req_status_desc)
VALUES (1, 'open', 'Open request')
ON CONFLICT (req_status_id) DO NOTHING;

INSERT INTO request_priority (req_priority_id, req_priority, req_priority_desc)
VALUES (1, 'high', 'High priority')
ON CONFLICT (req_priority_id) DO NOTHING;

INSERT INTO request_type (req_type_id, req_type, req_type_desc)
VALUES (1, 'standard', 'Standard request')
ON CONFLICT (req_type_id) DO NOTHING;

INSERT INTO request_for (req_for_id, req_for, req_for_desc)
VALUES (1, 'self', 'For self')
ON CONFLICT (req_for_id) DO NOTHING;

INSERT INTO request_isleadvol (req_islead_id, req_islead, req_islead_desc)
VALUES (1, 'no', 'Not lead volunteer')
ON CONFLICT (req_islead_id) DO NOTHING;

INSERT INTO request (
    req_id,
    req_user_id,
    req_for_id,
    req_islead_id,
    req_cat_id,
    req_type_id,
    req_priority_id,
    req_status_id,
    req_loc,
    iscalamity,
    req_subj,
    req_desc,
    submission_date
)
VALUES
    (
        'req-medical-1',
        'user-alice',
        1,
        1,
        'medical',
        1,
        1,
        1,
        'San Jose',
        false,
        'Emergency medical help',
        'Need urgent medical support and transport',
        now()
    ),
    (
        'req-food-1',
        'user-bob',
        1,
        1,
        'food',
        1,
        1,
        1,
        'Oakland',
        false,
        'Food pantry support',
        'Need groceries and food assistance',
        now()
    )
ON CONFLICT (req_id) DO NOTHING;

INSERT INTO organizations (
    org_id,
    org_name,
    city_name,
    state_code,
    org_type,
    source,
    cat_id
)
VALUES
    ('org-saayam-1', 'Saayam Foundation', 'San Jose', 'CA', 'non_profit', 'self_registered', 'medical'),
    ('org-food-1', 'Community Food Bank', 'Oakland', 'CA', 'non_profit', 'self_registered', 'food')
ON CONFLICT (org_id) DO NOTHING;

DO $$
DECLARE
    result_count INT;
BEGIN
    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_requests(
        'emergancy medical',
        20,
        NULL::VARCHAR(255),
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    )
    WHERE req_id = 'req-medical-1';

    IF result_count <> 1 THEN
        RAISE EXCEPTION 'request fuzzy search failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_requests(
        'food',
        20,
        'user-alice'::VARCHAR(255),
        1::SMALLINT,
        NULL::VARCHAR(255)[]
    )
    WHERE req_id = 'req-food-1';

    IF result_count <> 0 THEN
        RAISE EXCEPTION 'request self-scope filter failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_requests(
        'food',
        20,
        NULL::VARCHAR(255),
        1::SMALLINT,
        ARRAY['user-bob']::VARCHAR(255)[]
    )
    WHERE req_id = 'req-food-1';

    IF result_count <> 1 THEN
        RAISE EXCEPTION 'request allowed-owner filter failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_users(
        'Alic',
        20,
        NULL::VARCHAR(255),
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    )
    WHERE user_id = 'user-alice';

    IF result_count <> 1 THEN
        RAISE EXCEPTION 'user fuzzy search failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_users(
        'bob@example.test',
        20,
        'user-alice'::VARCHAR(255),
        1::SMALLINT,
        NULL::VARCHAR(255)[]
    )
    WHERE user_id = 'user-bob';

    IF result_count <> 0 THEN
        RAISE EXCEPTION 'user self-scope filter failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_users(
        'bob@example.test',
        20,
        NULL::VARCHAR(255),
        1::SMALLINT,
        ARRAY['user-bob']::VARCHAR(255)[]
    )
    WHERE user_id = 'user-bob';

    IF result_count <> 1 THEN
        RAISE EXCEPTION 'user allowed-list filter failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_organizations(
        'Saaym Foundation',
        20,
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    )
    WHERE org_id = 'org-saayam-1';

    IF result_count <> 1 THEN
        RAISE EXCEPTION 'organization fuzzy search failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_organizations(
        'Food Bank',
        20,
        1::SMALLINT,
        NULL::VARCHAR(255)[]
    )
    WHERE org_id = 'org-food-1';

    IF result_count <> 0 THEN
        RAISE EXCEPTION 'organization scope filter failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM virginia_dev_saayam_rdbms.search_organizations(
        'Food Bank',
        20,
        1::SMALLINT,
        ARRAY['org-food-1']::VARCHAR(255)[]
    )
    WHERE org_id = 'org-food-1';

    IF result_count <> 1 THEN
        RAISE EXCEPTION 'organization allowed-list filter failed';
    END IF;
END $$;

ROLLBACK;
