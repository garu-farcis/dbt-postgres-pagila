
{{
    config(
        materialized='view'
    )
    }}
select payment_id,
customer_id,
staff_id,
rental_id,
round(amount,2) amount,
payment_date
from {{source('pagila','payment')}}