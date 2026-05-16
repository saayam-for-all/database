-- Ireland full local search validation runner.
-- Run after ireland_search_instance_clone.sql and run_ireland_search_migrations.sql.

\echo 'Running Ireland search smoke test'
\ir ireland_validation/01_search_smoke_test.sql

\echo 'Running Ireland search index check'
\ir ireland_validation/02_search_index_check.sql

\echo 'Running Ireland search function check'
\ir ireland_validation/03_search_function_check.sql

\echo 'Running Ireland migrated clone check'
\ir ireland_validation/04_instance_clone_check.sql

\echo 'Ireland full search validation completed'
