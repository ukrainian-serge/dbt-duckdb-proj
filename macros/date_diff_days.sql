{%- macro date_diff_days(start_date, end_date) -%}
{#
  Platform-agnostic macro to calculate the difference in days between two dates.
  
  Args:
    start_date: The start date/timestamp (can be a column name or expression)
    end_date: The end date/timestamp (can be a column name or expression)
  
  Returns:
    SQL expression that returns the number of days between the two dates
  
  Supported adapters:
    - DuckDB: date_diff('day', start_date, end_date)
    - Snowflake: datediff(day, start_date, end_date)
    - BigQuery: date_diff(end_date, start_date, day)
    - Postgres: (end_date::date - start_date::date)
#}

  {% if target.type == 'duckdb' %}
    date_diff('day', {{ start_date }}, {{ end_date }})
  {%- elif target.type == 'snowflake' %}
    datediff(day, {{ start_date }}, {{ end_date }})
  {%- elif target.type == 'bigquery' %}
    date_diff({{ end_date }}, {{ start_date }}, day)
  {%- elif target.type == 'postgres' %}
    ({{ end_date }}::date - {{ start_date }}::date)
  {%- elif target.type == 'redshift' %}
    ({{ end_date }}::date - {{ start_date }}::date)
  {%- else %}
    -- Unsupported adapter: {{ target.type }}
    -- Fallback to DuckDB syntax
    date_diff('day', {{ start_date }}, {{ end_date }})
  {%- endif %}

{%- endmacro %}
