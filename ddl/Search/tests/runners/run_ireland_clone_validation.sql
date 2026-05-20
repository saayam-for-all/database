-- Ireland local clone validation runner.
-- Run after ddl/Search/tests/test_clones/ireland_search_instance_clone.sql.

\echo 'Running Ireland instance clone check'
\ir ../ireland_validation/05_ireland_instance_clone_check.sql

\echo 'Ireland clone validation completed'
