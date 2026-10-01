--Write a fact model fct_rentals.sql that starts from the rental
-- staging model and adds useful attributes (customer key, film key, store, rental duration in days, etc.).


{{
    config(
        materialized='view'
    )
}}
select re.customer_id as customer_key,
re.rental_id,
inv.film_id as film_key,
inv.store_id as store_key,
re.rental_date, re.return_date, 
case 
when re.return_date is not null 
then re.return_date::date - re.rental_date::date 
end as rental_duration_days
from {{ ref ('stg_pagila__rental')}} as re left join {{ ref('stg_pagila__inventory')}} as inv
on re.inventory_id=inv.inventory_id