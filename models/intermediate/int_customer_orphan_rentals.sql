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
rr.rental_count as rental_count,
rr.category_rank_final as top_categories,
row_number() over(
    partition by re.customer_id order by rr.rental_count desc
) as most_popular
from {{ref('stg_pagila__films')}} as ff left join {{source('pagila','inventory')}} as inv
on ff.film_id=inv.film_id
left join ren{ source('pagila','rental') }}tal re
on inv.inventory_id=re.inventory_id
left join {{ ref('film_affinity') }} rr
on re.customer_id=rr.cust_key
where re.rental_date is null 
group by ff.film_id,re.customer_id,rr.rental_count,rr.category_rank_final
)
select pf.film_keys,
pf.cust_keys,
pf.rental_count,
pf.top_categories,
rank() over (
    partition by pf.cust_keys order by pf.most_popular
)as ranking
 from popular_films pf 

