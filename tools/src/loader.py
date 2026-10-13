import duckdb
import pandas as pd
import typer

from src.config import Config


def string_col_dtype_inspection(df: pd.DataFrame, table_name: str) -> None:
    non_string_cols = [
        col
        for col in df.columns
        if not pd.api.types.is_object_dtype(df[col]) and not pd.api.types.is_string_dtype(df[col])
    ]

    if non_string_cols:
        invalid_details = {col: str(df[col].dtype) for col in non_string_cols}
        raise TypeError(
            f"Table '{table_name}' contains non-string columns: {invalid_details}. "
            f"All columns must be strings/objects before loading."
        )


def quote_identifier(identifier: str) -> str:
    return '"' + identifier.replace('"', '""') + '"'


def load_data_to_duckdb(cfg: Config) -> None:
    csv_files = sorted(cfg.data_dir.glob("*.csv"))

    if not csv_files:
        typer.echo(f"No CSV files found in {cfg.data_dir}")
        raise typer.Exit(code=1)

    if cfg.write_mode not in {"replace", "append"}:
        raise ValueError(f"Unsupported write mode: {cfg.write_mode}")

    cfg.warehouse_path.parent.mkdir(parents=True, exist_ok=True)
    connection = duckdb.connect(str(cfg.warehouse_path))
    try:
        connection.execute('CREATE SCHEMA IF NOT EXISTS "raw"')
        connection.execute('CREATE SCHEMA IF NOT EXISTS "dev"')

        for csv_path in csv_files:
            table_name = csv_path.stem.split("_")[-1]
            df = pd.read_csv(csv_path, dtype=str)
            string_col_dtype_inspection(df, table_name)

            connection.register("raw_data_frame", df)
            quoted_table = quote_identifier(table_name)
            try:
                if cfg.write_mode == "replace":
                    connection.execute(
                        f"CREATE OR REPLACE TABLE raw.{quoted_table} "
                        "AS SELECT * FROM raw_data_frame"
                    )
                elif cfg.write_mode == "append":
                    connection.execute(
                        f"CREATE TABLE IF NOT EXISTS raw.{quoted_table} "
                        "AS SELECT * FROM raw_data_frame WHERE FALSE"
                    )
                    connection.execute(
                        f"INSERT INTO raw.{quoted_table} SELECT * FROM raw_data_frame"
                    )
            finally:
                connection.unregister("raw_data_frame")

            print(
                f"   Success: Loaded {len(df)} rows into "
                f"`raw.{table_name}` ({cfg.warehouse_path})"
            )
    finally:
        connection.close()
