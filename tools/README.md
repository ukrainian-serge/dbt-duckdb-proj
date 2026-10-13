# Data Generation and Loading

Generates synthetic Jaffle Shop data and loads it into the project's persistent
DuckDB warehouse. By default, the database file is `warehouse.duckdb` in the
project root. The loader creates the `raw` and `dev` schemas; CSV tables are
loaded into `raw`, and dbt uses `dev` for transformed models.

## Quick Start

```bash
# Generate and load data for a date range
python tools/gen_load.py --generate --date-from 2026-05-15 --date-to 2026-08-12

# Load existing CSVs without generating
python tools/gen_load.py --data-dir ./jaffle_raw_data

# Append instead of replacing each raw table
python tools/gen_load.py --write-mode append

```

## gen_load.py

Entry point that orchestrates data generation and loading:
- Uses `jafgen` to generate synthetic Jaffle Shop CSVs
- Maps dates and filters data to specified date range
- Loads CSVs as string-valued tables in DuckDB's `raw` schema

No cloud credentials or environment variables are required. By default, the
warehouse is `./warehouse.duckdb` and generated/input CSVs are in
`./jaffle_raw_data`. Optional `.env` values:

```bash
DUCKDB_PATH=warehouse.duckdb
JAFGEN_DATA_DIR=jaffle_raw_data
```

CLI paths can also be set directly. Relative paths resolve from the project root:

```bash
python tools/gen_load.py --warehouse ./warehouse.duckdb --data-dir ./jaffle_raw_data
```

`--write-mode replace` (the default) replaces each loaded table;
`--write-mode append` adds rows to existing tables. `--generate` runs jafgen
before loading. The date range is inclusive.

Configure dbt to use the same database file in `~/.dbt/profiles.yml`:

```yaml
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: /absolute/path/to/dbt-duckdb-proj/warehouse.duckdb
      schema: dev
      threads: 4
```

## dbt Cloud trigger helper

The repository also includes [dbt-trigger](dbt-trigger), a shell utility for starting a dbt Cloud job from the local terminal. It is outside the local DuckDB generation/loading workflow.

It looks for the dbt Cloud identifiers and API token in the credentials environment file and then calls the dbt Cloud v2 job run endpoint:

```bash
./tools/dbt-trigger -c /path/to/credentials
./tools/dbt-trigger -m "manual run from local dev" -c /path/to/credentials
```

The script expects values such as:

```bash
DBT_CLOUD_ACCOUNT_ID=12345
DBT_CLOUD_JOB_ID=67890
DBT_CLOUD_HOST=cloud.getdbt.com
DBT_CLOUD_API_TOKEN=your_token_here
```

This makes it easy to quickly kick off a dbt Cloud production job after local validation, while keeping the trigger logic simple and repeatable.

## Related documentation

- **[SETUP_GUIDE](../SETUP_GUIDE.md)**
- [../README.md](../README.md)
- [src/](src/) module details.
