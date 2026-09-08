{{
    config(
        materialized='view'
    )
}}
select customer_id,
store_id,
first_name,
last_name,
email,
address_id,
active,
date(create_date) as create_date,
date(last_update) as last_date
from {{source('pagila','customer')}}