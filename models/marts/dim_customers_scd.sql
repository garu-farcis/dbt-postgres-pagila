--     - Downstream dim_customers_scd2 exposes valid_from / valid_to / is_current
{{
    config(
        materialized='table'
    )
}}

select cu.customer_id as customer_key,
cu.active as status,
cu.address_id as address_key,
dbt_valid_from as valid_from,
dbt_valid_to as valid_to,
case
when dbt_valid_to is null then true
else false
end as is_current
from {{ref('snap_customers')}} cu