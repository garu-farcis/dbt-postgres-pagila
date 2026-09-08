--""Build a customer dimension model dim_customers.sql (or marts/dim_customers.sql) that joins the customer 
--staging model with address → city → country so you end up with one row per customer including full location info"""

{{
    config(
        materialized = 'view'
    )
}}
select cu.first_name,cu.last_name, cu.email, ad.address,ci.city,co.country
from {{ 
    ref (
        'stg_pagila__customers'
    )
}} as cu left join {{ source('pagila', 'address') }} as ad
on ad.address_id=cu.address_id
left join {{ source('pagila', 'city') }} ci
on ci.city_id=ad.city_id
left join {{ source('pagila', 'country') }}  co
on co.country_id=ci.country_id