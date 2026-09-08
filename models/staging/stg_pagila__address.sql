

{{
    config(
        materialized= 'view'
    )
}}
select address_id,
lower(address) address1,
lower(address2) address2,
district,
city_id,
postal_code,
phone,
date(last_update) last_update
from {{source('pagila','address')}}
