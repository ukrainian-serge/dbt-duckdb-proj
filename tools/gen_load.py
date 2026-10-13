#!/usr/bin/env python3

from datetime import datetime, timedelta
from pathlib import Path
from typing import Literal

import typer

from src.config import DEFAULT_DATA_DIR, load_config, resolve_project_path
from src.generate import generate_jaffle_data, process_generated_data
from src.loader import load_data_to_duckdb
from src.process_dates import (
    calculate_years_from_range,
    get_date_range_series,
    validate_and_parse,
    validate_date_range,
)

app = typer.Typer(
    add_completion=False,
    context_settings={
        "help_option_names": ["-h", "--help"]
    },
)

@app.command()
def main(
    write_mode: Literal["replace", "append"] = typer.Option(
        "replace",
        "--write-mode", "-w",
        help="Replace existing raw tables or append rows",
        case_sensitive=False,
    ),
    warehouse_path: Path | None = typer.Option(
        None,
        "--warehouse",
        help="DuckDB warehouse file (defaults to DUCKDB_PATH or ./warehouse.duckdb)",
    ),
    generate: bool = typer.Option(
        False,
        "--generate", "-g",
        help="Run jafgen data generation before loading",
    ),
    prefix: str = typer.Option(
        "raw",
        "--prefix", "-p",
        help="Generated CSV prefix",
    ),
    data_dir: Path | None = typer.Option(
        None,
        "--data-dir", "-d",
        help="Directory with raw CSV files",
    ),
    date_from: datetime = typer.Option(
        lambda: (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d"),
        "--date-from", "-f",
        metavar="%Y-%m-%d",
        help="Date range start (YYYY-MM-DD format). Defaults to 7 days ago.",
        callback=validate_and_parse,
    ),
    date_to: datetime = typer.Option(
        lambda: datetime.now().strftime("%Y-%m-%d"),
        "--date-to", "-t",
        metavar="%Y-%m-%d",
        help="Date range end (YYYY-MM-DD format). Defaults to today.",
        callback=validate_and_parse,
    ),
) -> None:

    # Inspect a valid date range first.
    validate_date_range(date_from, date_to)

    cfg = load_config()

    cfg.write_mode = write_mode
    cfg.generate = generate
    cfg.prefix = prefix
    cfg.data_dir = resolve_project_path(str(data_dir), DEFAULT_DATA_DIR) if data_dir else cfg.data_dir
    if warehouse_path:
        cfg.warehouse_path = resolve_project_path(str(warehouse_path), cfg.warehouse_path)
    cfg.date_from = date_from
    cfg.date_to = date_to

    calculate_years_from_range(cfg)
    get_date_range_series(cfg)
    generate_jaffle_data(cfg)
    process_generated_data(cfg)
    load_data_to_duckdb(cfg)

if __name__ == "__main__":
    app()