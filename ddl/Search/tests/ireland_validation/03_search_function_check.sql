-- Search function check.
-- Run after instance clone and ddl/Search/codes/01..04.

BEGIN;

SET search_path TO proposed_saayam, public;

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
    user_category_desc
)
VALUES
    (1, 'requester', 'Requester'),
    (4, 'admin', 'Admin')
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
    ('fn-admin', 'CA', 1, 1, 4, 'Function Admin', 'Function', 'Admin', 'fn-admin@example.test', 'San Jose'),
    ('fn-requester', 'CA', 1, 1, 1, 'Maya Medical', 'Maya', 'Medical', 'maya.medical@example.test', 'San Jose'),
    ('fn-other', 'CA', 1, 1, 1, 'Noah Grocery', 'Noah', 'Grocery', 'noah.grocery@example.test', 'Oakland')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO help_categories (cat_id, cat_name, cat_desc)
VALUES
    ('fn-medical', 'Medical Care', 'Medical help category'),
    ('fn-food', 'Food Delivery', 'Food help category')
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
        'fn-req-medical',
        'fn-requester',
        1,
        1,
        'fn-medical',
        1,
        1,
        1,
        'San Jose',
        false,
        'Need medical transportation',
        'Need a ride to medical appointment',
        now()
    ),
    (
        'fn-req-food',
        'fn-other',
        1,
        1,
        'fn-food',
        1,
        1,
        1,
        'Oakland',
        false,
        'Need grocery delivery',
        'Need food delivery this week',
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
    ('fn-org-medical', 'Medical Transport Network', 'San Jose', 'CA', 'non_profit', 'self_registered', 'fn-medical'),
    ('fn-org-food', 'Grocery Relief Group', 'Oakland', 'CA', 'non_profit', 'self_registered', 'fn-food')
ON CONFLICT (org_id) DO NOTHING;

DO $$
DECLARE
    result_count INT;
    top_id TEXT;
    score REAL;
BEGIN
    SELECT count(*), max(req_id), max(relevance_score)
    INTO result_count, top_id, score
    FROM proposed_saayam.search_requests(
        'medical transportation',
        5,
        NULL::VARCHAR(255),
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    );

    IF result_count = 0 OR top_id <> 'fn-req-medical' OR score <= 0 THEN
        RAISE EXCEPTION 'search_requests keyword ranking failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM proposed_saayam.search_requests(
        '',
        5,
        NULL::VARCHAR(255),
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    );

    IF result_count <> 0 THEN
        RAISE EXCEPTION 'search_requests empty query failed';
    END IF;

    SELECT count(*), max(user_id), max(relevance_score)
    INTO result_count, top_id, score
    FROM proposed_saayam.search_users(
        'maya.medical@example.test',
        5,
        NULL::VARCHAR(255),
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    );

    IF result_count = 0 OR top_id <> 'fn-requester' OR score <= 0 THEN
        RAISE EXCEPTION 'search_users exact email failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM proposed_saayam.search_users(
        '',
        5,
        NULL::VARCHAR(255),
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    );

    IF result_count <> 0 THEN
        RAISE EXCEPTION 'search_users empty query failed';
    END IF;

    SELECT count(*), max(org_id), max(relevance_score)
    INTO result_count, top_id, score
    FROM proposed_saayam.search_organizations(
        'Medical Transport',
        5,
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    );

    IF result_count = 0 OR top_id <> 'fn-org-medical' OR score <= 0 THEN
        RAISE EXCEPTION 'search_organizations name search failed';
    END IF;

    SELECT count(*)
    INTO result_count
    FROM proposed_saayam.search_organizations(
        '',
        5,
        4::SMALLINT,
        NULL::VARCHAR(255)[]
    );

    IF result_count <> 0 THEN
        RAISE EXCEPTION 'search_organizations empty query failed';
    END IF;
END $$;

ROLLBACK;
