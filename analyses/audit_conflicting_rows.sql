-- Analysis: Audit conflicting rows
-- Purpose: Identify rows with potential data quality issues or differences
-- This is a template for comparing versions of a model

{% set dbt_relation = ref("fct_customer_orders") %}

{% if execute %}
  -- Template query to find potential issues in model data
  with data_quality_checks as (
    select
      order_id,
      customer_id,
      order_placed_at,
      count(*) as row_count
    from {{ dbt_relation }}
    group by order_id, customer_id, order_placed_at
    having count(*) > 1  -- find duplicate order_ids
  )
  select
    order_id,
    customer_id,
    order_placed_at,
    row_count,
    'duplicate_key' as issue_type
  from data_quality_checks
  order by row_count desc

{% else %}
  -- parse-time placeholder
  select
    cast(null as string) as order_id,
    cast(null as string) as customer_id,
    cast(null as timestamp) as order_placed_at,
    cast(null as integer) as row_count,
    cast(null as string) as issue_type
{% endif %}