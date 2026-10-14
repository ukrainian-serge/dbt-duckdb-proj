{%- macro string_split_array(string_expr, delimiter) -%}
{#
  Platform-agnostic macro to split a string into an array.
  
  Args:
    string_expr: The string to split (can be a column name or expression)
    delimiter: The delimiter character(s) to split on (include quotes, e.g., "' '")
  
  Returns:
    SQL expression that returns an array of strings
  
  Supported adapters:
    - DuckDB: STRING_SPLIT(string, delimiter)
    - Snowflake: SPLIT_TO_LIST(string, delimiter)
    - BigQuery: SPLIT(string, delimiter)
    - Postgres: STRING_TO_ARRAY(string, delimiter)
#}

  {% if target.type == 'duckdb' %}
    STRING_SPLIT({{ string_expr }}, {{ delimiter }})
  {%- elif target.type == 'snowflake' %}
    SPLIT_TO_LIST({{ string_expr }}, {{ delimiter }})
  {%- elif target.type == 'bigquery' %}
    SPLIT({{ string_expr }}, {{ delimiter }})
  {%- elif target.type == 'postgres' %}
    STRING_TO_ARRAY({{ string_expr }}, {{ delimiter }})
  {%- elif target.type in ('redshift', 'postgres') %}
    STRING_TO_ARRAY({{ string_expr }}, {{ delimiter }})
  {%- else %}
    -- Unsupported adapter: {{ target.type }}
    -- Fallback to DuckDB syntax
    STRING_SPLIT({{ string_expr }}, {{ delimiter }})
  {%- endif %}

{%- endmacro %}
