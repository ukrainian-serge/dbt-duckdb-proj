-- Analysis: Test patterns and exploration queries
-- Purpose: Ad-hoc queries for testing and data exploration
-- This file can be used for temporary analysis work during development

{# -- Example: Orders summary by store
select
  store_id,
  count(*) as order_count,
  count(distinct customer_id) as unique_customers,
  sum(order_total) as total_sales,
  avg(order_total) as avg_order_value
from {{ ref("stg_jaffle_shop__orders") }}
group by store_id
order by total_sales desc #}


-- analyses/scratch_contract.sql
{# {{ get_empty_schema_sql(graph.nodes['model.jaffle_shop.stg_jaffle_shop__customers'].columns) }} #}


{# 

dbt run-operation run_query --args '{
  "sql": "
    select * from (
      {{ get_empty_schema_sql(graph.nodes[\"model.jaffle_shop.stg_jaffle_shop__customers\"].columns) }}
    ) where false limit 0
  "
}' 

#}
