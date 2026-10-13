# Module Overview

Core modules for `gen_load.py`:

## config.py
Loads optional local path configuration from `.env`. Defaults to
`warehouse.duckdb` and `jaffle_raw_data/` in the project root.

## generate.py
Runs `jafgen.Simulation`, maps dates, and filters generated data to the requested
inclusive date range.

## process_dates.py
Parses dates, validates the range, calculates the number of years to generate,
and creates the date series used to filter source CSVs.

## loader.py
Creates/reuses the persistent DuckDB warehouse, ensures `raw` and `dev` schemas
exist, validates raw columns, and replaces or appends string-valued tables in
`raw`.
