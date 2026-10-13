# dbt Project

This project builds a local Jaffle Shop analytics stack with dbt and a persistent DuckDB warehouse. The model layer covers staging, intermediate logic, and marts, with jafgen source data loaded locally and dbt Cloud triggering retained as an optional separate workflow.

See **[SETUP_GUIDE](./SETUP_GUIDE.md)**

## Project overview

The repository includes:
- Python utilities for raw-data generation and local DuckDB ingestion
- dbt models for staging, intermediate, and analytics marts
- a persistent project-local DuckDB warehouse
- an optional dbt Cloud workflow for production job triggers

## Local warehouse

The default warehouse file is `warehouse.duckdb` in the project root. The
loader creates a `raw` schema for jafgen CSV tables and a `dev` schema for dbt
models. Configure the same database path in `~/.dbt/profiles.yml`; see
[SETUP_GUIDE](./SETUP_GUIDE.md).

## Raw data generation and loading

The generator/loading utility at [tools/gen_load.py](tools/gen_load.py) can
generate synthetic CSV files and load them into the local DuckDB `raw` schema.
It requires no cloud credentials.

For more detail on the script, its environment variables, and example commands, see [tools/README.md](tools/README.md).


## Project structure

### dbt models
Located in [models/](models/) and organized by layer:

**Staging** (`staging/`)
- Raw data layer that sources from the Jaffle Shop source tables and creates clean, normalized views:
  - `stg_jaffle_shop__customers` — Customers staging view with unique/not_null tests on customer_id
  - `stg_jaffle_shop__orders` — Orders staging view with referential integrity to customers
  - `stg_jaffle_shop__items` — Order items staging view
  - `stg_jaffle_shop__products` — Products staging view
  - `stg_jaffle_shop__stores` — Stores staging view
  - `stg_jaffle_shop__supplies` — Supplies staging view
  - `stg_jaffle_shop__tweets` — Tweets staging view

**Intermediate** (`marts/intermediate/`)
- Business logic and joins combining staging data with aggregations:
  - `int_customer_orders` — Enriched orders with customer-level aggregations (contract enforced), includes transaction sequencing and lifetime value calculations
  - `int_store_products` — Store-product relationships

**Marts** (`marts/fact/`)
- Fact tables for analytics:
  - `fct_customer_orders` — Primary fact table with **two versions** (v1 and v2) using incremental microbatch materialization, partitioned by order date, with contract enforcement and public access. v2 refines datetime columns (fdos, payment_finalized_date) to date types.
  - `fct_test` — Testing endpoint (assigned to product group)

**Legacy** (`legacy/`)
- Backward-compatible models maintained for historical reference:
  - `fct_customer_orders_legacy` — Previous fact table implementation with comprehensive data tests (unique/not_null constraints, accepted values for nvsr)

**Python Models** (`python_demo/`)
- Experimental Python-based models (**disabled by default** in dbt_project.yml; they require 20+ minutes startup time):
  - `dates_spine` — Date spine helper table (SQL-based)
  - `is_holiday` — Python model for holiday detection using pandas and holidays packages

### Additional dbt directories
- [seeds/](seeds/) — seed files and reference datasets (disabled by default)
- [snapshots/](snapshots/) — snapshot definitions
- [analyses/](analyses/) — ad hoc SQL checks and validation queries (disabled by default)
- [macros/](macros/) — reusable dbt macros (e.g., `clean_zero_row_models`)
- [functions/](functions/) — SQL and UDF helper objects
- [tests/](tests/) — SQL-based dbt tests with dbt_utils for cardinality and equality validations

### Development and tooling
- [tools/](tools/):
   - (local DEV) `gen_load.py`: raw data generation and DuckDB loading

## Quick start

1. Create a Python environment.
2. Install dependencies:
   `python -m pip install -r requirements.txt`
3. Install dbt dependencies:
   `dbt deps`
4. Generate and load data following [tools/README.md](tools/README.md).
5. Configure `~/.dbt/profiles.yml` using [SETUP_GUIDE](./SETUP_GUIDE.md).
6. Build dbt models:
   `dbt debug`
   `dbt build`

## Related documentation

- **[SETUP_GUIDE](./SETUP_GUIDE.md)**
- [tools/README.md](tools/README.md)
- [tools/gen_load.py](tools/gen_load.py)
- [tools/dbt-trigger](tools/dbt-trigger)
- [dbt_project.yml](dbt_project.yml)

## Resources

- Jaffle Shop generator: https://github.com/dbt-labs/jaffle-shop-generator