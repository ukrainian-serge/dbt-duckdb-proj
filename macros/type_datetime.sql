{%- macro type_datetime() -%}
{#
  Platform-agnostic macro to return the correct datetime/timestamp type for the target adapter.
  
  Returns:
    SQL type keyword for datetime/timestamp
  
  Supported adapters:
    - DuckDB: TIMESTAMP
    - Snowflake: TIMESTAMP_NTZ (or TIMESTAMP)
    - BigQuery: DATETIME
    - Postgres: TIMESTAMP
    - Redshift: TIMESTAMP
#}

  {% if target.type == 'duckdb' %}
    TIMESTAMP
  {%- elif target.type == 'snowflake' %}
    TIMESTAMP_NTZ
  {%- elif target.type == 'bigquery' %}
    DATETIME
  {%- elif target.type == 'postgres' %}
    TIMESTAMP
  {%- elif target.type == 'redshift' %}
    TIMESTAMP
  {%- else %}
    -- Unsupported adapter: {{ target.type }}
    -- Fallback to TIMESTAMP
    TIMESTAMP
  {%- endif %}

{%- endmacro %}
