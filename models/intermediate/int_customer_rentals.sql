--Build an intermediate model int_customer_rentals.sql that 
--aggregates per customer: total rentals, total payments, average rental duration, first/last rental date.
{{
    config(
        materialized = 'view'
    )
}}

with customer_rentals as (
    select
        customer_id,
        count(rental_id) as total_rentals,
        round(avg(return_date::date - rental_date::date),2) as average_rental_duration,
        min(rental_date) as first_rental_date,
        max(rental_date) as last_rental_date
    from {{ ref('stg_pagila__rental') }}
    group by customer_id
),

customer_payments as (
    select
        customer_id,
        sum(amount) as total_payments
    from {{ ref('stg_pagila__payments') }}
    group by customer_id
)

select
    cu.customer_id,
    concat(cu.first_name, ' ', cu.last_name) as full_name,
    coalesce(cr.total_rentals, 0) as total_rentals,
    coalesce(cp.total_payments, 0) as total_payments,
    cr.average_rental_duration,
    cr.first_rental_date,
    cr.last_rental_date
from {{ ref('stg_pagila__customers') }} cu
left join customer_rentals cr
    on cu.customer_id = cr.customer_id
left join customer_payments cp
    on cu.customer_id = cp.customer_id