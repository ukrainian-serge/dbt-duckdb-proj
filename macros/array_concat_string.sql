{%- macro array_concat_string(array_expr, delimiter) -%}
{#
  Platform-agnostic macro to concatenate array elements into a string.
  
  Args:
    array_expr: The array expression to concatenate (e.g., array_slice(...) or ARRAY[...])
    delimiter: The delimiter to use between elements (include quotes, e.g., "' '")
  
  Returns:
    SQL expression that returns a string of concatenated array elements
  
  Supported adapters:
    - DuckDB: ARRAY_TO_STRING(array, delimiter)
    - Snowflake: ARRAY_JOIN(array, delimiter)
    - BigQuery: STRING_AGG() with UNNEST (complex subquery)
    - Postgres: ARRAY_TO_STRING(array, delimiter)
#}

  {% if target.type == 'duckdb' %}
    ARRAY_TO_STRING({{ array_expr }}, {{ delimiter }})
  {%- elif target.type == 'snowflake' %}
    ARRAY_JOIN({{ array_expr }}, {{ delimiter }})
  {%- elif target.type == 'bigquery' %}
    (
      SELECT STRING_AGG(elem, {{ delimiter }} ORDER BY pos)
      FROM UNNEST({{ array_expr }}) AS elem WITH OFFSET pos
    )
  {%- elif target.type == 'postgres' %}
    ARRAY_TO_STRING({{ array_expr }}, {{ delimiter }})
  {%- elif target.type in ('redshift', 'postgres') %}
    ARRAY_TO_STRING({{ array_expr }}, {{ delimiter }})
  {%- else %}
    -- Unsupported adapter: {{ target.type }}
    -- Fallback to DuckDB syntax
    ARRAY_TO_STRING({{ array_expr }}, {{ delimiter }})
  {%- endif %}

{%- endmacro %}
