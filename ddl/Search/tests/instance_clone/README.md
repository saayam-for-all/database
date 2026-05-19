# Instance Clone Schemas

Use this folder for local schema clones that mirror deployed AWS RDS instances.

Examples:

- Virginia schema clone
- Ireland schema clone

These files are test fixtures for search validation. They should be copied or generated from existing deployed/schema sources and kept separate from the original DDL files.

## Why This Exists

The search scripts are schema-level migrations. Testing them against a local clone of the Virginia or Ireland RDS schema helps catch:

- schema-name issues
- missing table or column assumptions
- index creation problems
- function compilation errors
- query behavior differences between minimal test tables and real schema structure

## Files

- `virginia_search_instance_clone.sql`: search-scoped Virginia clone for validating the current MVP search scripts.
- `ireland_search_instance_clone.sql`: search-scoped Ireland clone for validating Ireland schema shape without requiring local PostGIS.
- `README.md`: this guide.

The Virginia clone intentionally includes only the search-relevant tables and dependencies. It is not a replacement for the production DDL.
The Ireland search clone follows the Ireland schema name, `proposed_saayam`, and includes the search-relevant tables/columns only.

## Suggested Local Test Order

```bash
createdb saayam_search_clone_test
psql -d saayam_search_clone_test -f ddl/Search/tests/instance_clone/virginia_search_instance_clone.sql
psql -d saayam_search_clone_test -f ddl/Search/tests/run_virginia_search_migrations.sql
psql -d saayam_search_clone_test -v ON_ERROR_STOP=1 -f ddl/Search/tests/run_local_search_validation.sql
```

Add smoke-test SQL files under `ddl/Search/tests/` as the search validation suite grows.

## Ireland Search Clone Check

Use this when local PostGIS is not available or when the goal is only to confirm Ireland search shape:

```bash
createdb saayam_ireland_search_clone_test
psql -d saayam_ireland_search_clone_test -f ddl/Search/tests/instance_clone/ireland_search_instance_clone.sql
psql -d saayam_ireland_search_clone_test -f ddl/Search/tests/run_ireland_clone_validation.sql
```

This confirms the Ireland-style `proposed_saayam` clone has the tables and columns needed by the current search plan.

## Ireland Full Search Validation

Use this to validate the same search behavior against the Ireland schema name:

```bash
createdb saayam_ireland_full_search_test
psql -d saayam_ireland_full_search_test -f ddl/Search/tests/instance_clone/ireland_search_instance_clone.sql
psql -d saayam_ireland_full_search_test -f ddl/Search/tests/run_ireland_search_migrations.sql
psql -d saayam_ireland_full_search_test -v ON_ERROR_STOP=1 -f ddl/Search/tests/run_ireland_search_validation.sql
```

The same production search scripts are used for Ireland through `run_ireland_search_migrations.sql`.
