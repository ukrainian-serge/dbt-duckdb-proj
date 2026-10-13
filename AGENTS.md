# Project Instructions

## Project context

- This is a dbt Jaffle Shop project using a persistent local DuckDB warehouse
- `tools/gen_load.py` loads source CSVs into the warehouse's `raw` schema; dbt builds models in `dev`. Configure dbt to use the same warehouse path as the loader.
- dbt Cloud triggering through `tools/dbt-trigger` is optional and separate from local development.
- See [SETUP_GUIDE.md](SETUP_GUIDE.md) for local setup and [tools/README.md](tools/README.md) for data generation and loading.

## Project conventions

- Follow the existing dbt model layering, naming, YAML configuration, and test patterns in `models/`, `macros/`, and `tests/`.
- Keep SQL compatible with DuckDB and use the project's configured dbt profile and schema conventions.

## Validation and data safety

- Run the narrowest relevant dbt validation for a change; use `dbt debug` to check the local connection and select only affected models when building or testing.
- dbt builds and data loads can change the persistent warehouse. `tools/gen_load.py` defaults to `--write-mode replace`, which replaces loaded raw tables; do not run data-mutating commands against shared or production data without explicit authorization.
- Do not commit the local warehouse, generated artifacts, logs, or credentials.
