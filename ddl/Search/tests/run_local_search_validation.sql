-- Local search validation runner.
-- Run after instance clone and ddl/Search/codes/01..04.

\echo 'Running search smoke test'
\ir 01_search_smoke_test.sql

\echo 'Running search index check'
\ir 02_search_index_check.sql

\echo 'Running search function check'
\ir 03_search_function_check.sql

\echo 'Running instance clone check'
\ir 04_instance_clone_check.sql

\echo 'Local search validation completed'
