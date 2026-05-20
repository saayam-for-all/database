# Search QA Validation

## Purpose

This document explains how to validate the database-side search work locally and later on QA/AWS RDS.

The local tests prove the SQL compiles and behaves correctly against a Virginia-style clone.
QA validation proves the same search logic works against the real deployed schema, permissions, data shape, and RDS settings.

## Files Under Test

Search migration files:

- `ddl/Search/codes/01_enable_fuzzy_search.sql`
- `ddl/Search/codes/02_add_request_search.sql`
- `ddl/Search/codes/03_add_user_and_volunteer_search.sql`
- `ddl/Search/codes/04_add_category_and_advanced_search.sql`

Local validation files:

- `ddl/Search/tests/runners/run_virginia_search_migrations.sql`
- `ddl/Search/tests/runners/run_ireland_search_migrations.sql`
- `ddl/Search/tests/runners/run_virginia_search_validation.sql`
- `ddl/Search/tests/runners/run_ireland_clone_validation.sql`
- `ddl/Search/tests/runners/run_ireland_search_validation.sql`
- `ddl/Search/tests/virginia_validation/01_search_smoke_test.sql`
- `ddl/Search/tests/virginia_validation/02_search_index_check.sql`
- `ddl/Search/tests/virginia_validation/03_search_function_check.sql`
- `ddl/Search/tests/virginia_validation/04_instance_clone_check.sql`
- `ddl/Search/tests/ireland_validation/05_ireland_instance_clone_check.sql`
- `ddl/Search/tests/test_clones/virginia_search_instance_clone.sql`
- `ddl/Search/tests/test_clones/ireland_search_instance_clone.sql`
- `ddl/Search/tests/ireland_validation/`

## Local Validation Runbook

Use this before QA to confirm the current branch works locally.

```bash
createdb saayam_search_clone_test

psql -d saayam_search_clone_test \
  -f ddl/Search/tests/test_clones/virginia_search_instance_clone.sql

psql -d saayam_search_clone_test \
  -f ddl/Search/tests/runners/run_virginia_search_migrations.sql

psql -d saayam_search_clone_test \
  -v ON_ERROR_STOP=1 \
  -f ddl/Search/tests/runners/run_virginia_search_validation.sql
```

Expected local result:

- all scripts complete without errors
- runner prints `Virginia search validation completed`

## Ireland Local Clone Validation

Ireland uses schema `proposed_saayam`.
The production search scripts are schema-agnostic and use the active `search_path`.

```bash
createdb saayam_ireland_search_clone_test

psql -d saayam_ireland_search_clone_test \
  -f ddl/Search/tests/test_clones/ireland_search_instance_clone.sql

psql -d saayam_ireland_search_clone_test \
  -v ON_ERROR_STOP=1 \
  -f ddl/Search/tests/runners/run_ireland_clone_validation.sql
```

Expected Ireland local result:

- clone loads without errors
- runner prints `Ireland clone validation completed`
- required Ireland search tables and columns exist under `proposed_saayam`

## Ireland Full Local Search Validation

Use this to validate the same search behavior against the Ireland schema name:

```bash
createdb saayam_ireland_full_search_test

psql -d saayam_ireland_full_search_test \
  -f ddl/Search/tests/test_clones/ireland_search_instance_clone.sql

psql -d saayam_ireland_full_search_test \
  -f ddl/Search/tests/runners/run_ireland_search_migrations.sql

psql -d saayam_ireland_full_search_test \
  -v ON_ERROR_STOP=1 \
  -f ddl/Search/tests/runners/run_ireland_search_validation.sql
```

Expected Ireland full-search result:

- scripts compile against `proposed_saayam`
- smoke test passes
- index check passes
- function check passes
- migrated clone check passes
- runner prints `Ireland full search validation completed`

## QA/RDS Validation Runbook

Use this only after QA database access is available.

Connect to QA:

```bash
psql -h <qa-rds-endpoint> \
  -U <qa-user> \
  -d <qa-database>
```

Run search scripts with the correct target schema.

For Virginia QA:

```sql
\i ddl/Search/tests/runners/run_virginia_search_migrations.sql
```

For Ireland QA:

```sql
\i ddl/Search/tests/runners/run_ireland_search_migrations.sql
```

Then run validation checks.

Recommended first QA checks:

```sql
\i ddl/Search/tests/virginia_validation/02_search_index_check.sql
\i ddl/Search/tests/virginia_validation/04_instance_clone_check.sql
```

Run behavior checks only after confirming temporary QA inserts are acceptable:

```sql
\i ddl/Search/tests/virginia_validation/01_search_smoke_test.sql
\i ddl/Search/tests/virginia_validation/03_search_function_check.sql
```

## QA Safety Notes

The behavior tests use `BEGIN` and `ROLLBACK`, so their sample data should not persist.

Still confirm before running on QA:

- the QA role can create extensions, columns, indexes, and functions
- temporary test inserts are allowed in QA
- QA constraints match the local clone assumptions
- no trigger or audit process has side effects from rolled-back inserts
- the active schema is correct for the target region

## PR Evidence To Capture

Capture the following for PR review:

- output showing `run_virginia_search_migrations.sql` completed locally
- output showing `run_virginia_search_validation.sql` passed locally for Virginia
- output showing `run_ireland_search_migrations.sql` completed locally
- output showing `run_ireland_search_validation.sql` passed locally for Ireland
- output showing QA index check passed
- output showing QA function/behavior checks passed, if run
- `EXPLAIN` or `EXPLAIN ANALYZE` for representative search queries
- confirmation that unauthorized or missing-scope calls return zero rows

Local PR evidence already captured:

- Virginia schema-agnostic validation passed: `saayam_virginia_agnostic_test_1778949545`
- Ireland schema-agnostic validation passed: `saayam_ireland_agnostic_test_1778949579`
- Both validations used the shared production scripts under `ddl/Search/codes/`
- Region selection is handled through `search_path` in the migration runners

Useful QA evidence queries:

Virginia examples are shown below. For Ireland, replace `virginia_dev_saayam_rdbms` with `proposed_saayam`.

```sql
SELECT extname
FROM pg_extension
WHERE extname = 'pg_trgm';

SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'virginia_dev_saayam_rdbms'
  AND indexname IN (
    'idx_request_search_vector',
    'idx_request_subj_trgm',
    'idx_request_desc_trgm',
    'idx_request_loc_trgm',
    'idx_help_categories_name_fts',
    'idx_help_categories_name_trgm',
    'idx_users_search_vector',
    'idx_users_full_name_trgm',
    'idx_users_email_trgm',
    'idx_users_email_exact',
    'idx_organizations_name_trgm',
    'idx_organizations_city_trgm'
  )
ORDER BY tablename, indexname;
```

Representative search checks:

```sql
SELECT *
FROM virginia_dev_saayam_rdbms.search_requests(
  'medical help',
  10,
  NULL::VARCHAR(255),
  4::SMALLINT,
  NULL::VARCHAR(255)[]
);

SELECT *
FROM virginia_dev_saayam_rdbms.search_users(
  'test@example.com',
  10,
  NULL::VARCHAR(255),
  4::SMALLINT,
  NULL::VARCHAR(255)[]
);

SELECT *
FROM virginia_dev_saayam_rdbms.search_organizations(
  'food bank',
  10,
  4::SMALLINT,
  NULL::VARCHAR(255)[]
);
```

Missing-scope checks:

```sql
SELECT count(*)
FROM virginia_dev_saayam_rdbms.search_requests(
  'medical help',
  10,
  NULL::VARCHAR(255),
  1::SMALLINT,
  NULL::VARCHAR(255)[]
);

SELECT count(*)
FROM virginia_dev_saayam_rdbms.search_users(
  'test@example.com',
  10,
  NULL::VARCHAR(255),
  1::SMALLINT,
  NULL::VARCHAR(255)[]
);

SELECT count(*)
FROM virginia_dev_saayam_rdbms.search_organizations(
  'food bank',
  10,
  1::SMALLINT,
  NULL::VARCHAR(255)[]
);
```

Expected missing-scope result:

- count is `0`

## DevSecOps Items Still Pending

These are not solved by local SQL validation:

- final backend-to-DB authorization context contract
- whether to keep function parameters or move to `SET LOCAL app.*` session variables
- whether to add Row-Level Security policies
- AWS IAM database authentication
- `rds.force_ssl = 1`
- pgAudit or RDS audit logging
- CloudWatch monitoring for suspicious search access

## Current Boundary

Current state:

- local code-level search MVP is implemented
- local clone validation passes
- local behavior/index/function tests pass
- Ireland search-shape clone validation passes
- Ireland full local search validation passes
- schema targeting is complete through `search_path` migration runners

Not yet complete:

- QA/RDS validation
- performance review with real data
- final RDS security hardening
