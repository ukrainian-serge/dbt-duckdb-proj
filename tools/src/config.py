from dataclasses import dataclass
from datetime import datetime
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv


CONFIG_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = CONFIG_DIR.parents[1]
ENV_PATH = PROJECT_ROOT / ".env"
DEFAULT_DATA_DIR = PROJECT_ROOT / "jaffle_raw_data"
DEFAULT_WAREHOUSE_PATH = PROJECT_ROOT / "warehouse.duckdb"


@dataclass(frozen=False)
class Config:
    warehouse_path: Path
    data_dir: Path
    write_mode: str = "replace"
    generate: bool = False
    prefix: str = "raw"
    date_from: datetime = datetime.now()
    date_to: datetime = datetime.now()
    calculated_years: int | None = None
    s_dst: pd.Series | None = None
    order_unique_id: pd.arrays.ArrowStringArray | None = None
    order_unique_cust: pd.arrays.ArrowStringArray | None = None


def load_config() -> Config:
    """Load optional local paths from .env, defaulting to project-local paths."""
    if ENV_PATH.exists():
        load_dotenv(dotenv_path=ENV_PATH, override=True)

    return Config(
        warehouse_path=resolve_project_path(
            os.getenv("DUCKDB_PATH"), DEFAULT_WAREHOUSE_PATH
        ),
        data_dir=resolve_project_path(os.getenv("JAFGEN_DATA_DIR"), DEFAULT_DATA_DIR),
    )


def resolve_project_path(value: str | None, default: Path) -> Path:
    """Resolve configured relative paths from the project root."""
    if value is None:
        return default

    path = Path(value).expanduser()
    if not path.is_absolute():
        path = PROJECT_ROOT / path
    return path.resolve()