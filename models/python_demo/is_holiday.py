def model(dbt, session):
    dbt.config(
        materialized="table",
        packages=["holidays", "pandas"]
    )

    import subprocess
    import sys
    
    # Ensure holidays package is installed (for DuckDB environments)
    try:
        import holidays
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "holidays"])
        import holidays
    
    import pandas as pd

    us_holidays = holidays.US()
    # Convert DuckDB Relation to pandas DataFrame using .df()
    df = dbt.ref("dates_spine").df()
    df["is_holiday"] = df["date_day"].apply(lambda x: x in us_holidays)
    return df