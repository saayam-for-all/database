# Search Test Workspace

This folder is for search-specific local testing only.

Do not edit the original schema files under `ddl/Tables/` for search testing. If a local clone of a deployed schema is needed, place the copied or generated schema assets under `instance_clone/`.

## Intended Flow

1. Create a local PostgreSQL database.
2. Load a Virginia or Ireland schema clone from `instance_clone/`.
3. Run the search scripts from `../codes/` in order.
4. Run local search validation.

## Search Scripts Under Test

- `../codes/01_enable_fuzzy_search.sql`
- `../codes/02_add_request_search.sql`
- `../codes/03_add_user_and_volunteer_search.sql`
- `../codes/04_add_category_and_advanced_search.sql`

## Smoke Test

## Run All Local Checks

Run this after loading the local clone and applying search migrations:

```bash
psql -d saayam_search_clone_test -f ddl/Search/tests/run_local_search_validation.sql
```

This runs the smoke test, index check, function check, and instance clone check in order.

## Virginia Full Search Check

```bash
createdb saayam_search_clone_test
psql -d saayam_search_clone_test -f ddl/Search/tests/instance_clone/virginia_search_instance_clone.sql
psql -d saayam_search_clone_test -f ddl/Search/tests/run_virginia_search_migrations.sql
psql -d saayam_search_clone_test -v ON_ERROR_STOP=1 -f ddl/Search/tests/run_local_search_validation.sql
```

## Ireland Clone Check

The production search scripts are schema-agnostic and rely on `search_path`.
Ireland uses `proposed_saayam`, so the Ireland runner sets that schema before applying the shared scripts.

```bash
createdb saayam_ireland_search_clone_test
psql -d saayam_ireland_search_clone_test -f ddl/Search/tests/instance_clone/ireland_search_instance_clone.sql
psql -d saayam_ireland_search_clone_test -f ddl/Search/tests/run_ireland_clone_validation.sql
```

This confirms the Ireland-style clone has the tables and columns needed by the search plan.

## Ireland Full Search Check

The same production scripts under `ddl/Search/codes/` are used for Ireland.
The Ireland migration runner sets `search_path` to `proposed_saayam`.

```bash
createdb saayam_ireland_full_search_test
psql -d saayam_ireland_full_search_test -f ddl/Search/tests/instance_clone/ireland_search_instance_clone.sql
psql -d saayam_ireland_full_search_test -f ddl/Search/tests/run_ireland_search_migrations.sql
psql -d saayam_ireland_full_search_test -v ON_ERROR_STOP=1 -f ddl/Search/tests/run_ireland_search_validation.sql
```

This runs the same behavior, index, function, and migrated-clone checks against the Ireland schema name, `proposed_saayam`.

## Smoke Test

Run this after loading the local clone and search scripts:

```bash
psql -d saayam_search_clone_test -f ddl/Search/tests/01_search_smoke_test.sql
```

This inserts temporary sample data, checks search behavior, and rolls the data back.

## Index Check

Run this after loading the local clone and search scripts:

```bash
psql -d saayam_search_clone_test -f ddl/Search/tests/02_search_index_check.sql
```

This fails if any expected search index is missing or uses the wrong strategy.
It checks GIN full-text indexes, GIN trigram indexes, and the exact email btree index.

## Function Check

Run this after loading the local clone and search scripts:

```bash
psql -d saayam_search_clone_test -f ddl/Search/tests/03_search_function_check.sql
```

This checks the main search functions directly:

- `search_requests(...)`
- `search_users(...)`
- `search_organizations(...)`

It verifies keyword matching, exact email matching, organization name matching, relevance scores, and empty-query behavior.

## Instance Clone Check

Run this after loading the local clone and search scripts:

```bash
psql -d saayam_search_clone_test -f ddl/Search/tests/04_instance_clone_check.sql
```

This verifies the local Virginia clone has the search-required tables, search columns, and search functions.

## QA Validation

See `QA_VALIDATION.md` for the QA/RDS validation runbook, safety notes, and PR evidence checklist.
