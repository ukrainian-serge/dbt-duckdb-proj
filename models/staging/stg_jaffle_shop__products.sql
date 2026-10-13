with
    source as (select * from {{ source("jaffle_shop", "products") }}),
    final as (
        select
            sku,
            trim(replace(name, '?', '')) as product_name,
            type as product_type,
            description,
            {{ dbt_utils.safe_divide(
                    'cast(price as ' ~ dbt.type_float() ~ ')',
                    '100'
                ) }} as price
            
        from source
    )

select *
from final