with
    source as (select * from {{ source("jaffle_shop", "orders") }}),
    renamed as (

        select
            -- Primary & foreign keys
            id as order_id,
            customer as customer_id,
            store_id,
            -- Timestamps
            cast(ordered_at as {{ type_datetime() }}) as ordered_at,
            {{ date_diff_days(
                'cast(ordered_at as ' ~ type_datetime() ~ ')',
                'cast(' ~ dbt.current_timestamp() ~ ' as ' ~ type_datetime() ~ ')'
                ) }} as days_since_order,
            -- Monetary amounts (cast to int, then convert cents -> dollars)
            {{ dbt_utils.safe_divide(
                    'cast(subtotal as ' ~ dbt.type_int() ~ ')',
                    '100'
                ) }} as subtotal,
            {{ dbt_utils.safe_divide(
                    'cast(tax_paid as ' ~ dbt.type_int() ~ ')',
                    '100'
                ) }} as tax_paid,
            {{ dbt_utils.safe_divide(
                    'cast(order_total as ' ~ dbt.type_int() ~ ')',
                    '100'
                ) }} as order_total

        from source

    )

select *
from renamed