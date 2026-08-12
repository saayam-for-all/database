/*
Purpose: Validation and test cases for Wiki tables 31-40
Schema:  virginia_dev_saayam_rdbms

How it works:
- Structural tests verify columns, types, defaults, constraints, sequences, functions, and triggers.
- DML tests run only when suitable parent rows already exist.
- Every DML change is wrapped in one transaction and rolled back at the end.
- No organization insert is performed, so the org_id_seq is not advanced by this test file.

Expected result:
- The script finishes with the notice: ALL TABLE 31-40 TESTS PASSED.
- Notices beginning with SKIP mean prerequisite sample rows were unavailable; structural checks still ran.
*/

BEGIN;

SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '0';

CREATE OR REPLACE FUNCTION pg_temp.assert_true(p_condition boolean, p_message text)
RETURNS void
LANGUAGE plpgsql
AS $assert_true$
BEGIN
    IF COALESCE(p_condition, false) IS NOT TRUE THEN
        RAISE EXCEPTION 'TEST FAILED: %', p_message;
    END IF;
END
$assert_true$;

CREATE OR REPLACE FUNCTION pg_temp.column_exists(
    p_schema text,
    p_table text,
    p_column text
)
RETURNS boolean
LANGUAGE sql
AS $column_exists$
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = p_schema
          AND table_name = p_table
          AND column_name = p_column
    );
$column_exists$;

CREATE OR REPLACE FUNCTION pg_temp.column_type(
    p_table regclass,
    p_column text
)
RETURNS text
LANGUAGE sql
AS $column_type$
    SELECT format_type(a.atttypid, a.atttypmod)
    FROM pg_attribute a
    WHERE a.attrelid = p_table
      AND a.attname = p_column
      AND a.attnum > 0
      AND NOT a.attisdropped;
$column_type$;

CREATE OR REPLACE FUNCTION pg_temp.column_default(
    p_table regclass,
    p_column text
)
RETURNS text
LANGUAGE sql
AS $column_default$
    SELECT pg_get_expr(d.adbin, d.adrelid)
    FROM pg_attribute a
    LEFT JOIN pg_attrdef d
      ON d.adrelid = a.attrelid
     AND d.adnum = a.attnum
    WHERE a.attrelid = p_table
      AND a.attname = p_column
      AND a.attnum > 0
      AND NOT a.attisdropped;
$column_default$;

CREATE OR REPLACE FUNCTION pg_temp.trigger_exists(
    p_table regclass,
    p_trigger text
)
RETURNS boolean
LANGUAGE sql
AS $trigger_exists$
    SELECT EXISTS (
        SELECT 1
        FROM pg_trigger t
        WHERE t.tgrelid = p_table
          AND t.tgname = p_trigger
          AND NOT t.tgisinternal
    );
$trigger_exists$;

-- ============================================================
-- STRUCTURAL TESTS
-- ============================================================

-- 31. volunteer_rating
SELECT pg_temp.assert_true(
    to_regtype('virginia_dev_saayam_rdbms.rating_enum') IS NOT NULL,
    '31 volunteer_rating: schema-qualified rating_enum is missing.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'volunteer_rating', 'req_id'),
    '31 volunteer_rating: req_id is missing.'
);
SELECT pg_temp.assert_true(
    NOT pg_temp.column_exists('virginia_dev_saayam_rdbms', 'volunteer_rating', 'request_id'),
    '31 volunteer_rating: old request_id still exists.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'volunteer_rating', 'last_updated_at'),
    '31 volunteer_rating: last_updated_at is missing.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_attribute a
        WHERE a.attrelid = 'virginia_dev_saayam_rdbms.volunteer_rating'::regclass
          AND a.attname = 'rating'
          AND a.atttypid = 'virginia_dev_saayam_rdbms.rating_enum'::regtype
          AND a.attnum > 0
          AND NOT a.attisdropped
    ),
    '31 volunteer_rating: rating does not use the schema-qualified enum.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_type('virginia_dev_saayam_rdbms.volunteer_rating'::regclass, 'last_updated_at') =
        'timestamp without time zone',
    '31 volunteer_rating: last_updated_at has the wrong type.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.volunteer_rating'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '31 volunteer_rating: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.volunteer_rating'::regclass, 'trg_volunteer_rating_updated_at'),
    '31 volunteer_rating: update trigger is missing.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'virginia_dev_saayam_rdbms.volunteer_rating'::regclass
          AND conname = 'volunteer_rating_req_id_fkey'
          AND confrelid = 'virginia_dev_saayam_rdbms.request'::regclass
    ),
    '31 volunteer_rating: req_id foreign key is missing or points to the wrong table.'
);
SELECT pg_temp.assert_true(
    to_regclass('virginia_dev_saayam_rdbms.idx_volunteer_rating_req_id') IS NOT NULL,
    '31 volunteer_rating: req_id index is missing.'
);

-- 32. user_availability
SELECT pg_temp.assert_true(
    pg_temp.column_type('virginia_dev_saayam_rdbms.user_availability'::regclass, 'start_time') =
        'timestamp without time zone',
    '32 user_availability: start_time has the wrong type.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_type('virginia_dev_saayam_rdbms.user_availability'::regclass, 'end_time') =
        'timestamp without time zone',
    '32 user_availability: end_time has the wrong type.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.user_availability'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '32 user_availability: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.user_availability'::regclass, 'trg_user_availability_updated_at'),
    '32 user_availability: update trigger is missing.'
);

-- 33. emergency_numbers
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'emergency_numbers', 'last_updated_at'),
    '33 emergency_numbers: last_updated_at is missing.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.emergency_numbers'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '33 emergency_numbers: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.emergency_numbers'::regclass, 'trg_emergency_numbers_updated_at'),
    '33 emergency_numbers: update trigger is missing.'
);

-- 34. organizations
SELECT pg_temp.assert_true(
    to_regtype('virginia_dev_saayam_rdbms.org_type_enum') IS NOT NULL,
    '34 organizations: org_type_enum is missing from the schema.'
);
SELECT pg_temp.assert_true(
    to_regtype('virginia_dev_saayam_rdbms.org_size_enum') IS NOT NULL,
    '34 organizations: org_size_enum is missing from the schema.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'organizations', 'is_contributor'),
    '34 organizations: is_contributor is missing.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_attribute a
        WHERE a.attrelid = 'virginia_dev_saayam_rdbms.organizations'::regclass
          AND a.attname = 'org_type'
          AND a.atttypid = 'virginia_dev_saayam_rdbms.org_type_enum'::regtype
          AND a.attnum > 0
          AND NOT a.attisdropped
    ),
    '34 organizations: org_type uses the wrong enum.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_attribute a
        WHERE a.attrelid = 'virginia_dev_saayam_rdbms.organizations'::regclass
          AND a.attname = 'org_size'
          AND a.atttypid = 'virginia_dev_saayam_rdbms.org_size_enum'::regtype
          AND a.attnum > 0
          AND NOT a.attisdropped
    ),
    '34 organizations: org_size uses the wrong enum.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.organizations'::regclass, 'created_at') ILIKE '%UTC%',
    '34 organizations: created_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.organizations'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '34 organizations: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.organizations'::regclass, 'trg_organizations_updated_at'),
    '34 organizations: update trigger is missing.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.organizations'::regclass, 'before_insert_organizations'),
    '34 organizations: ID-generation trigger is missing.'
);
SELECT pg_temp.assert_true(
    to_regclass('virginia_dev_saayam_rdbms.org_id_seq') IS NOT NULL,
    '34 organizations: org_id_seq is missing.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_sequences
        WHERE schemaname = 'virginia_dev_saayam_rdbms'
          AND sequencename = 'org_id_seq'
          AND min_value = 1
          AND max_value = 999999999999
          AND cycle = false
    ),
    '34 organizations: org_id_seq settings do not match the Wiki after-state.'
);
SELECT pg_temp.assert_true(
    pg_get_functiondef('virginia_dev_saayam_rdbms.generate_org_id()'::regprocedure)
        ILIKE '%lpad(seq_id::text, 13%',
    '34 organizations: generate_org_id does not use the new 13-digit format.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'virginia_dev_saayam_rdbms.organizations'::regclass
          AND conname = 'organizations_state_id_fkey'
          AND confrelid = 'virginia_dev_saayam_rdbms.state'::regclass
    ),
    '34 organizations: state_id foreign key is missing or points to the wrong table.'
);

-- 35. req_add_info
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'req_add_info', 'info_id'),
    '35 req_add_info: info_id is missing.'
);
SELECT pg_temp.assert_true(
    NOT pg_temp.column_exists('virginia_dev_saayam_rdbms', 'req_add_info', 'id'),
    '35 req_add_info: old id column still exists.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.req_add_info'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '35 req_add_info: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.req_add_info'::regclass, 'trg_req_add_info_updated_at'),
    '35 req_add_info: update trigger is missing.'
);

-- 36. request_other_details
SELECT pg_temp.assert_true(
    to_regclass('virginia_dev_saayam_rdbms.request_other_details') IS NOT NULL,
    '36 request_other_details: renamed table is missing.'
);
SELECT pg_temp.assert_true(
    to_regclass('virginia_dev_saayam_rdbms.request_guest_details') IS NULL,
    '36 request_other_details: old request_guest_details table still exists.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'request_other_details', 'user_id'),
    '36 request_other_details: user_id is missing.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.request_other_details'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '36 request_other_details: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.request_other_details'::regclass, 'trg_request_other_details_updated_at'),
    '36 request_other_details: update trigger is missing.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'virginia_dev_saayam_rdbms.request_other_details'::regclass
          AND conname = 'request_other_details_user_id_fkey'
          AND confrelid = 'virginia_dev_saayam_rdbms.users'::regclass
    ),
    '36 request_other_details: user_id foreign key is missing.'
);
SELECT pg_temp.assert_true(
    (
        SELECT count(*)
        FROM pg_constraint
        WHERE conrelid = 'virginia_dev_saayam_rdbms.request_other_details'::regclass
          AND contype = 'p'
    ) = 1,
    '36 request_other_details: the table must have exactly one primary key.'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
        FROM pg_constraint c
        WHERE c.conrelid = 'virginia_dev_saayam_rdbms.request_other_details'::regclass
          AND c.contype = 'p'
          AND pg_get_constraintdef(c.oid) = 'PRIMARY KEY (req_id)'
    ),
    '36 request_other_details: req_id must remain the sole primary-key column.'
);

-- 37. user_locations
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'user_locations', 'last_updated_at'),
    '37 user_locations: last_updated_at is missing.'
);
SELECT pg_temp.assert_true(
    NOT pg_temp.column_exists('virginia_dev_saayam_rdbms', 'user_locations', 'updated_at'),
    '37 user_locations: old updated_at column still exists.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_type('virginia_dev_saayam_rdbms.user_locations'::regclass, 'last_updated_at') =
        'timestamp without time zone',
    '37 user_locations: last_updated_at has the wrong type.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.user_locations'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '37 user_locations: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.user_locations'::regclass, 'trg_shift_prev_loc_user'),
    '37 user_locations: shift trigger is missing.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.user_locations'::regclass, 'trg_locations_insert_as_upsert_user'),
    '37 user_locations: insert-as-upsert trigger is missing.'
);
SELECT pg_temp.assert_true(
    pg_get_functiondef('virginia_dev_saayam_rdbms.fn_shift_prev_loc_user()'::regprocedure)
        ILIKE '%NEW.last_updated_at%',
    '37 user_locations: shift function still references the old timestamp column.'
);
SELECT pg_temp.assert_true(
    pg_get_functiondef('virginia_dev_saayam_rdbms.fn_locations_insert_as_upsert_user()'::regprocedure)
        ILIKE '%virginia_dev_saayam_rdbms.user_locations%',
    '37 user_locations: upsert function is not schema-qualified.'
);

-- 38. user_notification_status
SELECT pg_temp.assert_true(
    pg_temp.column_type('virginia_dev_saayam_rdbms.user_notification_status'::regclass, 'last_accessed_at') =
        'timestamp without time zone',
    '38 user_notification_status: last_accessed_at has the wrong type.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.user_notification_status'::regclass, 'last_accessed_at') ILIKE '%UTC%',
    '38 user_notification_status: last_accessed_at default is not UTC.'
);

-- 39. user_org_map
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.user_org_map'::regclass, 'created_at') ILIKE '%UTC%',
    '39 user_org_map: created_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.user_org_map'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '39 user_org_map: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.user_org_map'::regclass, 'trg_user_org_map_updated_at'),
    '39 user_org_map: update trigger is missing.'
);

-- 40. user_signoff
SELECT pg_temp.assert_true(
    pg_temp.column_exists('virginia_dev_saayam_rdbms', 'user_signoff', 'is_external_auth'),
    '40 user_signoff: is_external_auth is missing.'
);
SELECT pg_temp.assert_true(
    pg_temp.column_default('virginia_dev_saayam_rdbms.user_signoff'::regclass, 'last_updated_at') ILIKE '%UTC%',
    '40 user_signoff: last_updated_at default is not UTC.'
);
SELECT pg_temp.assert_true(
    pg_temp.trigger_exists('virginia_dev_saayam_rdbms.user_signoff'::regclass, 'trg_user_signoff_updated_at'),
    '40 user_signoff: update trigger is missing.'
);

-- ============================================================
-- DML/TRIGGER TESTS
-- ============================================================

-- 31. volunteer_rating
DO $test_volunteer_rating$
DECLARE
    v_user_id varchar(255);
    v_req_id varchar(255);
    v_id integer;
    v_timestamp timestamp without time zone;
BEGIN
    SELECT u.user_id, r.req_id
      INTO v_user_id, v_req_id
      FROM virginia_dev_saayam_rdbms.users u
      CROSS JOIN virginia_dev_saayam_rdbms.request r
      LIMIT 1;

    IF v_user_id IS NULL OR v_req_id IS NULL THEN
        RAISE NOTICE 'SKIP 31 volunteer_rating DML: users/request prerequisite row not found.';
        RETURN;
    END IF;

    INSERT INTO virginia_dev_saayam_rdbms.volunteer_rating
        (user_id, req_id, rating, feedback, last_updated_at)
    VALUES
        (v_user_id, v_req_id, '5'::virginia_dev_saayam_rdbms.rating_enum,
         '__migration_test__', TIMESTAMP '2099-01-01 00:00:00')
    RETURNING volunteer_rating_id INTO v_id;

    UPDATE virginia_dev_saayam_rdbms.volunteer_rating
       SET feedback = '__migration_test_updated__'
     WHERE volunteer_rating_id = v_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.volunteer_rating
     WHERE volunteer_rating_id = v_id;

    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '31 volunteer_rating: trigger did not replace the future test timestamp.'
    );
END
$test_volunteer_rating$;

-- 32. user_availability
DO $test_user_availability$
DECLARE
    v_user_id varchar(255);
    v_id integer;
    v_timestamp timestamp without time zone;
BEGIN
    SELECT user_id INTO v_user_id
      FROM virginia_dev_saayam_rdbms.users
      LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE NOTICE 'SKIP 32 user_availability DML: users prerequisite row not found.';
        RETURN;
    END IF;

    INSERT INTO virginia_dev_saayam_rdbms.user_availability
        (user_id, day_of_week, start_time, end_time, last_updated_at)
    VALUES
        (v_user_id, 'Monday', TIMESTAMP '2026-01-05 09:00:00',
         TIMESTAMP '2026-01-05 17:00:00', TIMESTAMP '2099-01-01 00:00:00')
    RETURNING user_availability_id INTO v_id;

    UPDATE virginia_dev_saayam_rdbms.user_availability
       SET end_time = TIMESTAMP '2026-01-05 18:00:00'
     WHERE user_availability_id = v_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.user_availability
     WHERE user_availability_id = v_id;

    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '32 user_availability: trigger did not update last_updated_at.'
    );
END
$test_user_availability$;

-- 33. emergency_numbers
DO $test_emergency_numbers$
DECLARE
    v_id integer;
    v_timestamp timestamp without time zone;
    v_name text := '__migration_test_emergency_' || txid_current()::text;
BEGIN
    INSERT INTO virginia_dev_saayam_rdbms.emergency_numbers
        (en_name, is_country, police, last_updated_at)
    VALUES
        (v_name, true, '100', TIMESTAMP '2099-01-01 00:00:00')
    RETURNING en_id INTO v_id;

    UPDATE virginia_dev_saayam_rdbms.emergency_numbers
       SET police = '101'
     WHERE en_id = v_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.emergency_numbers
     WHERE en_id = v_id;

    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '33 emergency_numbers: trigger did not update last_updated_at.'
    );
END
$test_emergency_numbers$;

-- 34. organizations (update only; avoids advancing org_id_seq)
DO $test_organizations$
DECLARE
    v_org_id varchar(255);
    v_timestamp timestamp without time zone;
BEGIN
    SELECT org_id INTO v_org_id
      FROM virginia_dev_saayam_rdbms.organizations
      LIMIT 1;

    IF v_org_id IS NULL THEN
        RAISE NOTICE 'SKIP 34 organizations DML: no existing organization; sequence was intentionally not advanced.';
        RETURN;
    END IF;

    UPDATE virginia_dev_saayam_rdbms.organizations
       SET mission = mission
     WHERE org_id = v_org_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.organizations
     WHERE org_id = v_org_id;

    PERFORM pg_temp.assert_true(
        v_timestamp BETWEEN
            (now() AT TIME ZONE 'UTC') - INTERVAL '1 minute'
            AND (now() AT TIME ZONE 'UTC') + INTERVAL '1 minute',
        '34 organizations: trigger did not set a current UTC timestamp.'
    );
END
$test_organizations$;

-- 35. req_add_info
DO $test_req_add_info$
DECLARE
    v_req_id varchar(255);
    v_field_id varchar(70);
    v_info_id integer;
    v_timestamp timestamp without time zone;
BEGIN
    SELECT r.req_id, m.field_id
      INTO v_req_id, v_field_id
      FROM virginia_dev_saayam_rdbms.request r
      CROSS JOIN virginia_dev_saayam_rdbms.req_add_info_metadata m
      LIMIT 1;

    IF v_req_id IS NULL OR v_field_id IS NULL THEN
        RAISE NOTICE 'SKIP 35 req_add_info DML: request/metadata prerequisite row not found.';
        RETURN;
    END IF;

    INSERT INTO virginia_dev_saayam_rdbms.req_add_info
        (req_id, field_id, item_id, field_value, last_updated_at)
    VALUES
        (v_req_id, v_field_id, NULL, '__migration_test__', TIMESTAMP '2099-01-01 00:00:00')
    RETURNING info_id INTO v_info_id;

    UPDATE virginia_dev_saayam_rdbms.req_add_info
       SET field_value = '__migration_test_updated__'
     WHERE info_id = v_info_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.req_add_info
     WHERE info_id = v_info_id;

    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '35 req_add_info: trigger did not update last_updated_at.'
    );
END
$test_req_add_info$;

-- 36. request_other_details
DO $test_request_other_details$
DECLARE
    v_req_id varchar(255);
    v_user_id varchar(255);
    v_timestamp timestamp without time zone;
BEGIN
    SELECT r.req_id, u.user_id
      INTO v_req_id, v_user_id
      FROM virginia_dev_saayam_rdbms.request r
      CROSS JOIN virginia_dev_saayam_rdbms.users u
      WHERE NOT EXISTS (
          SELECT 1
          FROM virginia_dev_saayam_rdbms.request_other_details d
          WHERE d.req_id = r.req_id
      )
      LIMIT 1;

    IF v_req_id IS NULL OR v_user_id IS NULL THEN
        RAISE NOTICE 'SKIP 36 request_other_details DML: unused request/user prerequisite row not found.';
        RETURN;
    END IF;

    INSERT INTO virginia_dev_saayam_rdbms.request_other_details
        (req_id, user_id, req_fname, last_updated_at)
    VALUES
        (v_req_id, v_user_id, '__migration_test__', TIMESTAMP '2099-01-01 00:00:00');

    UPDATE virginia_dev_saayam_rdbms.request_other_details
       SET req_fname = '__migration_test_updated__'
     WHERE req_id = v_req_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.request_other_details
     WHERE req_id = v_req_id;

    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '36 request_other_details: trigger did not update last_updated_at.'
    );
END
$test_request_other_details$;

-- 37. user_locations
DO $test_user_locations$
DECLARE
    v_user_id varchar(255);
    v_prev_exists boolean;
    v_curr_exists boolean;
    v_timestamp timestamp without time zone;
BEGIN
    SELECT user_id INTO v_user_id
      FROM virginia_dev_saayam_rdbms.users
      LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE NOTICE 'SKIP 37 user_locations DML: users prerequisite row not found.';
        RETURN;
    END IF;

    INSERT INTO virginia_dev_saayam_rdbms.user_locations
        (user_id, curr_loc, last_updated_at)
    VALUES
        (v_user_id,
         ST_SetSRID(ST_MakePoint(-77.0365, 38.8977), 4326)::geography,
         TIMESTAMP '2099-01-01 00:00:00');

    UPDATE virginia_dev_saayam_rdbms.user_locations
       SET curr_loc = ST_SetSRID(ST_MakePoint(-77.0091, 38.8895), 4326)::geography
     WHERE user_id = v_user_id;

    SELECT prev_loc IS NOT NULL, curr_loc IS NOT NULL, last_updated_at
      INTO v_prev_exists, v_curr_exists, v_timestamp
      FROM virginia_dev_saayam_rdbms.user_locations
     WHERE user_id = v_user_id;

    PERFORM pg_temp.assert_true(v_prev_exists,
        '37 user_locations: previous location was not shifted.');
    PERFORM pg_temp.assert_true(v_curr_exists,
        '37 user_locations: current location is null.');
    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '37 user_locations: specialized trigger did not update last_updated_at.'
    );
END
$test_user_locations$;

-- 38. user_notification_status
DO $test_user_notification_status$
DECLARE
    v_user_id varchar(255);
    v_timestamp timestamp without time zone;
BEGIN
    SELECT u.user_id
      INTO v_user_id
      FROM virginia_dev_saayam_rdbms.users u
      WHERE NOT EXISTS (
          SELECT 1
          FROM virginia_dev_saayam_rdbms.user_notification_status s
          WHERE s.user_id = u.user_id
      )
      LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE NOTICE 'SKIP 38 user_notification_status DML: no unused user_id found.';
        RETURN;
    END IF;

    INSERT INTO virginia_dev_saayam_rdbms.user_notification_status(user_id)
    VALUES (v_user_id)
    RETURNING last_accessed_at INTO v_timestamp;

    PERFORM pg_temp.assert_true(
        v_timestamp BETWEEN
            (now() AT TIME ZONE 'UTC') - INTERVAL '1 minute'
            AND (now() AT TIME ZONE 'UTC') + INTERVAL '1 minute',
        '38 user_notification_status: default timestamp is not current UTC.'
    );
END
$test_user_notification_status$;

-- 39. user_org_map
DO $test_user_org_map$
DECLARE
    v_user_id varchar(255);
    v_org_id varchar(255);
    v_timestamp timestamp without time zone;
BEGIN
    SELECT u.user_id, o.org_id
      INTO v_user_id, v_org_id
      FROM virginia_dev_saayam_rdbms.users u
      CROSS JOIN virginia_dev_saayam_rdbms.organizations o
      LIMIT 1;

    IF v_user_id IS NULL OR v_org_id IS NULL THEN
        RAISE NOTICE 'SKIP 39 user_org_map DML: users/organizations prerequisite row not found.';
        RETURN;
    END IF;

    INSERT INTO virginia_dev_saayam_rdbms.user_org_map
        (user_id, org_id, user_role, created_at, last_updated_at)
    VALUES
        (v_user_id, v_org_id, '__migration_test__',
         TIMESTAMP '2099-01-01 00:00:00', TIMESTAMP '2099-01-01 00:00:00')
    ON CONFLICT (user_id, org_id) DO NOTHING;

    UPDATE virginia_dev_saayam_rdbms.user_org_map
       SET user_role = '__migration_test_updated__'
     WHERE user_id = v_user_id
       AND org_id = v_org_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.user_org_map
     WHERE user_id = v_user_id
       AND org_id = v_org_id;

    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '39 user_org_map: trigger did not update last_updated_at.'
    );
END
$test_user_org_map$;

-- 40. user_signoff
DO $test_user_signoff$
DECLARE
    v_id integer;
    v_timestamp timestamp without time zone;
BEGIN
    INSERT INTO virginia_dev_saayam_rdbms.user_signoff
        (reason, is_external_auth, last_updated_at)
    VALUES
        ('__migration_test__', true, TIMESTAMP '2099-01-01 00:00:00')
    RETURNING signoff_id INTO v_id;

    UPDATE virginia_dev_saayam_rdbms.user_signoff
       SET reason = '__migration_test_updated__'
     WHERE signoff_id = v_id;

    SELECT last_updated_at INTO v_timestamp
      FROM virginia_dev_saayam_rdbms.user_signoff
     WHERE signoff_id = v_id;

    PERFORM pg_temp.assert_true(
        v_timestamp < TIMESTAMP '2099-01-01 00:00:00',
        '40 user_signoff: trigger did not update last_updated_at.'
    );
END
$test_user_signoff$;

DO $success$
BEGIN
    RAISE NOTICE 'ALL TABLE 31-40 TESTS PASSED.';
    RAISE NOTICE 'All test data will now be rolled back.';
END
$success$;

ROLLBACK;
