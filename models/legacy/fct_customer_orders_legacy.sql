{{
  config(
    materialized = 'table',
    full_refresh=true
    )
}}

-- Legacy monolithic query: does all transformations in one place
-- Splits customer names, calculates order aggregates, and joins in single query

WITH customer_cleaned as (
    -- Clean and split customer names from raw source
    select
        id as customer_id,
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(name, '[^a-zA-Z\s]', ''),
                '\s+',
                ' '
            )
        ) as clean_name
    from {{ source('jaffle_shop', 'customers') }}
),

customer_names as (
    -- Extract first and last names from cleaned names
    select
        customer_id,
        CASE 
            WHEN split_part(clean_name, ' ', 1) IS NOT NULL 
            THEN split_part(clean_name, ' ', 1)
            ELSE NULL
        END as first_name,
        CASE 
            WHEN split_part(clean_name, ' ', 2) IS NOT NULL 
            THEN split_part(clean_name, ' ', 2)
            WHEN split_part(clean_name, ' ', 1) IS NOT NULL
            THEN split_part(clean_name, ' ', 1)
            ELSE NULL
        END as last_name
    from customer_cleaned
),

paid_orders as (
    -- Aggregate orders with payment info
    select
        orders.id as order_id,
        orders.customer as customer_id,
        orders.ordered_at as order_placed_at,
        max(orders.ordered_at) over (partition by orders.id) as payment_finalized_date,
        sum(cast(orders.order_total as {{ dbt.type_float() }})) over (partition by orders.id) as total_amount_paid,
        cn.first_name as customer_first_name,
        cn.last_name as customer_last_name
    from {{ source('jaffle_shop', 'orders') }} as orders
    left join customer_names cn on orders.customer = cn.customer_id
    where cast(orders.order_total as {{ dbt.type_float() }}) > 0
),

customer_orders as (
    -- Customer-level order metrics
    select
        orders.customer as customer_id,
        min(orders.ordered_at) as first_order_date,
        max(orders.ordered_at) as most_recent_order_date,
        count(orders.id) as number_of_orders
    from {{ source('jaffle_shop', 'orders') }} as orders
    group by orders.customer
)

select
    p.order_id,
    p.customer_id,
    p.order_placed_at,
    p.total_amount_paid,
    p.payment_finalized_date,
    p.customer_first_name,
    p.customer_last_name,
    ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
    ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.order_id) as customer_sales_seq,
    CASE WHEN c.first_order_date = p.order_placed_at
        THEN 'new'
        ELSE 'return' 
    END as nvsr,
    SUM(p.total_amount_paid) OVER (
        PARTITION BY p.customer_id 
        ORDER BY p.order_placed_at 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS customer_lifetime_value,
    c.first_order_date as fdos
from paid_orders p
left join customer_orders c on p.customer_id = c.customer_id
order by p.order_id