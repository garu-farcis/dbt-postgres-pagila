
{{
    config(
        materialized='view'
    )
    }}
selectb payment_id,
customer_id,
staff_id,
rental_id,
round(amount,2) amount,
date(payment_date) payment_date,
date(last_update) last_update
from {{source('pagila','payment')}}