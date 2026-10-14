{%- macro type_float64() -%}
{#
  Platform-agnostic macro to return the correct float64/double precision type for the target adapter.
  
  Returns:
    SQL type keyword for 64-bit floating point
  
  Supported adapters:
    - DuckDB: DOUBLE
    - Snowflake: FLOAT (or FLOAT8)
    - BigQuery: FLOAT64
    - Postgres: DOUBLE PRECISION (or FLOAT8)
    - Redshift: DOUBLE PRECISION
#}

  {% if target.type == 'duckdb' %}
    DOUBLE
  {%- elif target.type == 'snowflake' %}
    FLOAT
  {%- elif target.type == 'bigquery' %}
    FLOAT64
  {%- elif target.type == 'postgres' %}
    DOUBLE PRECISION
  {%- elif target.type == 'redshift' %}
    DOUBLE PRECISION
  {%- else %}
    -- Unsupported adapter: {{ target.type }}
    -- Fallback to DOUBLE
    DOUBLE
  {%- endif %}

{%- endmacro %}
