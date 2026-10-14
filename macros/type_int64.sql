{%- macro type_int64() -%}
{#
  Platform-agnostic macro to return the correct int64/bigint type for the target adapter.
  
  Returns:
    SQL type keyword for 64-bit integer
  
  Supported adapters:
    - DuckDB: BIGINT (or INT64)
    - Snowflake: INT (or BIGINT, NUMBER)
    - BigQuery: INT64
    - Postgres: BIGINT
    - Redshift: BIGINT
#}

  {% if target.type == 'duckdb' %}
    BIGINT
  {%- elif target.type == 'snowflake' %}
    NUMBER(19, 0)
  {%- elif target.type == 'bigquery' %}
    INT64
  {%- elif target.type == 'postgres' %}
    BIGINT
  {%- elif target.type == 'redshift' %}
    BIGINT
  {%- else %}
    -- Unsupported adapter: {{ target.type }}
    -- Fallback to BIGINT
    BIGINT
  {%- endif %}

{%- endmacro %}
