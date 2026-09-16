-- 24. Create a model that produces a daily date spine for the full range of rental and payment
--     dates, then left-join metrics (rentals, revenue, new customers) onto it so you have
--     a continuous time series with zero-filled days.

{{
    config(
        materialized='view'
    )
}}

with daily_date_spine as (

    {{ date_spine( 
        start_date="(select least( 
        (select min(rental_date) from " ~ ref('stg_pagila__rental') ~ "), 
        (select min(payment_date) from " ~ ref('stg_pagila__payments') ~ ") ))", 
        end_date="(
        select greatest( (select max(rental_date) from " ~ ref('stg_pagila__rental') ~ "), 
        (select max(payment_date) from " ~ ref('stg_pagila__payments') ~ ") ))" 
        ) 
        }}
)
select dds.date_day,cr.total_rentals,cr.total_payments,cr.full_name
from  daily_date_spine dds left join {{ref('int_customer_rentals')}} cr
on dds.date_day=cr.rental_date
