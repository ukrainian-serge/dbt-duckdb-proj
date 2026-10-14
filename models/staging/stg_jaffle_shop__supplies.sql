with
    source as (select * from {{ source("jaffle_shop", "supplies") }}),
    final as (
        select
            id as supply_id,
            name as supplies_name,
            cast(perishable as boolean) as perishable,
            sku,
            {{ dbt_utils.safe_divide(
                    'cast(cost as ' ~ dbt.type_float() ~ ')',
                    '100'
                ) }} as cost
        from source
    )

select *
from final