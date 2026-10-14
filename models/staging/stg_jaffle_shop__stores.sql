with
    source as (select * from {{ source("jaffle_shop", "stores") }}),
    final as (
        select
            id as store_id,
            name as store_name,
            cast(opened_at as {{ type_datetime() }}) as opened_at,
            cast(tax_rate as {{ dbt.type_float() }}) as tax_rate
        from source
    )

select *
from final