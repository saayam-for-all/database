-- Virginia search validation runner.
-- Run after Virginia test clone and search migrations.

\echo 'Running search smoke test'
\ir ../virginia_validation/01_search_smoke_test.sql

\echo 'Running search index check'
\ir ../virginia_validation/02_search_index_check.sql

\echo 'Running search function check'
\ir ../virginia_validation/03_search_function_check.sql

\echo 'Running instance clone check'
\ir ../virginia_validation/04_instance_clone_check.sql

\echo 'Virginia search validation completed'
