-- Local instance clone check.
-- Run after instance clone and ddl/Search/codes/01..04.

DO $$
DECLARE
    missing_tables TEXT[];
    missing_columns TEXT[];
    missing_functions TEXT[];
BEGIN
    SELECT array_agg(expected.table_name ORDER BY expected.table_name)
    INTO missing_tables
    FROM (
        VALUES
            ('country'),
            ('state'),
            ('user_status'),
            ('user_category'),
            ('users'),
            ('help_categories'),
            ('request_status'),
            ('request_priority'),
            ('request_type'),
            ('request_for'),
            ('request_isleadvol'),
            ('request'),
            ('organizations'),
            ('user_org_map')
    ) AS expected(table_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.tables tbl
        WHERE tbl.table_schema = 'proposed_saayam'
          AND tbl.table_name = expected.table_name
    );

    IF missing_tables IS NOT NULL THEN
        RAISE EXCEPTION 'missing clone tables: %', array_to_string(missing_tables, ', ');
    END IF;

    SELECT array_agg(expected.table_name || '.' || expected.column_name ORDER BY expected.table_name, expected.column_name)
    INTO missing_columns
    FROM (
        VALUES
            ('request', 'search_vector'),
            ('users', 'search_vector'),
            ('request', 'req_subj'),
            ('request', 'req_desc'),
            ('request', 'req_loc'),
            ('help_categories', 'cat_name'),
            ('users', 'full_name'),
            ('users', 'primary_email_address'),
            ('organizations', 'org_name'),
            ('organizations', 'city_name')
    ) AS expected(table_name, column_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.columns col
        WHERE col.table_schema = 'proposed_saayam'
          AND col.table_name = expected.table_name
          AND col.column_name = expected.column_name
    );

    IF missing_columns IS NOT NULL THEN
        RAISE EXCEPTION 'missing clone/search columns: %', array_to_string(missing_columns, ', ');
    END IF;

    SELECT array_agg(expected.function_name ORDER BY expected.function_name)
    INTO missing_functions
    FROM (
        VALUES
            ('search_requests'),
            ('search_users'),
            ('search_organizations')
    ) AS expected(function_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.routines routine
        WHERE routine.specific_schema = 'proposed_saayam'
          AND routine.routine_name = expected.function_name
          AND routine.routine_type = 'FUNCTION'
    );

    IF missing_functions IS NOT NULL THEN
        RAISE EXCEPTION 'missing search functions: %', array_to_string(missing_functions, ', ');
    END IF;
END $$;
