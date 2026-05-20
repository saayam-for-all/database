-- Ireland local instance clone check.
-- Run after ddl/Search/tests/test_clones/ireland_search_instance_clone.sql.

DO $$
DECLARE
    missing_tables TEXT[];
    missing_columns TEXT[];
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
        RAISE EXCEPTION 'missing Ireland clone tables: %', array_to_string(missing_tables, ', ');
    END IF;

    SELECT array_agg(expected.table_name || '.' || expected.column_name ORDER BY expected.table_name, expected.column_name)
    INTO missing_columns
    FROM (
        VALUES
            ('request', 'req_subj'),
            ('request', 'req_desc'),
            ('request', 'req_loc'),
            ('request', 'req_cat_id'),
            ('request', 'req_user_id'),
            ('help_categories', 'cat_name'),
            ('users', 'full_name'),
            ('users', 'first_name'),
            ('users', 'last_name'),
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
        RAISE EXCEPTION 'missing Ireland search columns: %', array_to_string(missing_columns, ', ');
    END IF;
END $$;
