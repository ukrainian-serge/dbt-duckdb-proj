# Project Setup Guide

This guide covers local development with the persistent DuckDB warehouse.

## 1. Install dependencies

Create and activate a Python environment, then install the project dependencies:

```bash
python -m pip install -r requirements.txt
dbt deps
```

## 2. Configure dbt

Create `~/.dbt/profiles.yml` and point it at this project's warehouse file. Use
an absolute path for `path`:

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

The data loader creates `warehouse.duckdb` in the project root by default, with
`raw` for generated source tables and `dev` for dbt models. The warehouse is
git-ignored and persists across runs.

## 3. Generate and load source data

Run from the project root:

```bash
python tools/gen_load.py --generate --date-from 2018-01-01 --date-to 2026-08-01
```

To load CSVs already present in `jaffle_raw_data/`, omit `--generate`. Use
`--write-mode append` to append instead of replacing the existing raw tables.

Optional `.env` settings in the project root:

```bash
DUCKDB_PATH=warehouse.duckdb
JAFGEN_DATA_DIR=jaffle_raw_data
```

The CLI options `--warehouse` and `--data-dir` override these settings.
Relative paths resolve from the project root.

## 4. Run dbt locally

After loading the CSVs, validate the connection and build:

```bash
dbt debug
dbt build
```

## 5. VS Code Debug Configuration (Optional)

**File location:** `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Generate and load local data",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/tools/gen_load.py",
      "args": [
        "--generate",
        "--date-from", "2018-01-01",
        "--date-to", "2026-08-01",
        "--write-mode", "replace"
      ],
      "console": "integratedTerminal",
      "justMyCode": true
    }
  ]
}
```

## 6. PROD Mother Duck (Further Work)

The [tools/dbt-trigger](tools/dbt-trigger)
