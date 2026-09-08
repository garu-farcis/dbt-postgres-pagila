{{
    config(
        materialized = 'view'
    )
}}

select rental_id,
date(rental_date) rental_date,
inventory_id,
customer_id,
date(return_date) return_date,
staff_id,
date(last_update) last_update
from {{source('pagila','rental')}}