-- Run production search migrations against the Ireland schema.

SET search_path TO proposed_saayam, public;

\ir ../../../ddl/Search/01_enable_fuzzy_search.sql
\ir ../../../ddl/Search/02_add_request_search.sql
\ir ../../../ddl/Search/03_add_user_and_volunteer_search.sql
\ir ../../../ddl/Search/04_add_category_and_advanced_search.sql
