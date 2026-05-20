-- Search index check.
-- Run after instance clone and ddl/Search/codes/01..04.

DO $$
DECLARE
    missing_indexes TEXT[];
    invalid_indexes TEXT[];
BEGIN
    SELECT array_agg(expected.index_name ORDER BY expected.index_name)
    INTO missing_indexes
    FROM (
        VALUES
            ('idx_request_search_vector'),
            ('idx_request_subj_trgm'),
            ('idx_request_desc_trgm'),
            ('idx_request_loc_trgm'),
            ('idx_help_categories_name_fts'),
            ('idx_help_categories_name_trgm'),
            ('idx_users_search_vector'),
            ('idx_users_full_name_trgm'),
            ('idx_users_email_trgm'),
            ('idx_users_email_exact'),
            ('idx_organizations_name_trgm'),
            ('idx_organizations_city_trgm')
    ) AS expected(index_name)
    WHERE NOT EXISTS (
        SELECT 1
        FROM pg_indexes idx
        WHERE idx.schemaname = 'virginia_dev_saayam_rdbms'
          AND idx.indexname = expected.index_name
    );

    IF missing_indexes IS NOT NULL THEN
        RAISE EXCEPTION 'missing search indexes: %', array_to_string(missing_indexes, ', ');
    END IF;

    SELECT array_agg(expected.index_name ORDER BY expected.index_name)
    INTO invalid_indexes
    FROM (
        VALUES
            ('idx_request_search_vector', 'USING gin', 'search_vector'),
            ('idx_request_subj_trgm', 'USING gin', 'gin_trgm_ops'),
            ('idx_request_desc_trgm', 'USING gin', 'gin_trgm_ops'),
            ('idx_request_loc_trgm', 'USING gin', 'gin_trgm_ops'),
            ('idx_help_categories_name_fts', 'USING gin', 'to_tsvector'),
            ('idx_help_categories_name_trgm', 'USING gin', 'gin_trgm_ops'),
            ('idx_users_search_vector', 'USING gin', 'search_vector'),
            ('idx_users_full_name_trgm', 'USING gin', 'gin_trgm_ops'),
            ('idx_users_email_trgm', 'USING gin', 'gin_trgm_ops'),
            ('idx_users_email_exact', 'USING btree', 'primary_email_address'),
            ('idx_organizations_name_trgm', 'USING gin', 'gin_trgm_ops'),
            ('idx_organizations_city_trgm', 'USING gin', 'gin_trgm_ops')
    ) AS expected(index_name, required_method, required_expression)
    JOIN pg_indexes idx
      ON idx.schemaname = 'virginia_dev_saayam_rdbms'
     AND idx.indexname = expected.index_name
    WHERE idx.indexdef NOT ILIKE '%' || expected.required_method || '%'
       OR idx.indexdef NOT ILIKE '%' || expected.required_expression || '%';

    IF invalid_indexes IS NOT NULL THEN
        RAISE EXCEPTION 'invalid search index definitions: %', array_to_string(invalid_indexes, ', ');
    END IF;
END $$;
