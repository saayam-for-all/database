-- Run production search migrations against the Ireland schema.

SET search_path TO proposed_saayam, public;

\ir ../../codes/01_enable_fuzzy_search.sql
\ir ../../codes/02_add_request_search.sql
\ir ../../codes/03_add_user_and_volunteer_search.sql
\ir ../../codes/04_add_category_and_advanced_search.sql
