--     create a second model that recommends films the customer has never rented from those top categories,
--     ranked by global popularity. Use macros to keep the ranking logic reusable

{{
    config(
        materialized='table',
        unique_key='film_keys'
    )
}}
with popular_films as (
    select ff.film_id as film_keys,
    re.customer_id as cust_keys,
count(re.rental_id) as rental_count,
rr.ranking_by_count as top_categories,
row_number() over(
    partition by re.customer_id order by count(re.rental_id) desc
) as most_popular
from {{ref('stg_pagila__films')}} as ff left join {{source('pagila','inventory')}} as inv
on ff.film_id=inv.film_id
left join {{source('pagila','rental') }} re
on inv.inventory_id=re.inventory_id
left join {{ ref('int_film_affinity') }} rr
on re.customer_id=rr.cust_key
where re.rental_date is null 
group by ff.film_id,re.customer_id,re.rental_id,rr.ranking_by_count
)
select pf.film_keys,
pf.cust_keys,
pf.rental_count,
pf.top_categories,
rank() over (
    partition by pf.cust_keys order by pf.most_popular
)as ranking
 from popular_films pf 

