-- Analysis: Audit fct_customer_orders model
-- Purpose: Compare model structure and row counts for data quality checks
-- Note: This analysis is a template for auditing transformations

{% set dbt_relation = ref('fct_customer_orders') %}

{% if execute %}
  {% set columns = dbt_relation.columns %}
  {{ log("=" ~ " AUDIT: fct_customer_orders ", info=True) }}
  {{ log("Column count: " ~ columns | length, info=True) }}
  {% for col in columns %}
    {{ log("  - " ~ col.name ~ " (" ~ col.dtype ~ ")", info=True) }}
  {% endfor %}
{% endif %}

-- Display row count and sample data
select
  count(*) as total_rows,
  count(distinct order_id) as distinct_orders
from {{ ref('fct_customer_orders') }}
