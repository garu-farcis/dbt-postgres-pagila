-- 42. Build a dynamic “film affinity” model that, for every customer, calculates the top 3 categories
--     they have rented most (by revenue and by count) and stores the result as arrays

{{
    config (
        materialized='table',
        unique_key='cust_key'
    )
}}

with ranking_cat_by_revenue as (
    select pay.customer_id as cust_key,
    count(re.rental_id) as rental_count,
    coalesce(sum(pay.amount),0) as revenue,
    fc.category_id as category_key,
    row_number() over(
        partition by pay.customer_id order by sum(pay.amount) desc ) category_rank_rev
    from {{source('pagila','film_category')}} fc left join {{ref('stg_pagila__inventory')}} inv 
    on fc.film_id =inv.film_id
    left join {{source('pagila','rental')}} re
    on inv.inventory_id=re.inventory_id
    left join {{source('pagila','payment')}} pay
    on re.rental_id=pay.rental_id
    group by pay.customer_id,fc.category_id
    ),
    ranking_by_count as (
        select rr.cust_key as cust_key,
        rr.category_rank_rev category_rank_rev,
        rr.revenue as revenue,
        rr.film_count as rental_count,
        rr.category_key as category_key,
    row_number()over (
        partition by rr.cust_key order by rr.film_count desc ) category_rank_final
    from  ranking_cat_by_revenue rr
    )
    
select  rr.cust_key,
array_agg((rr.category_key,rr.category_rank_final,rr.rental_count)) as ranking_by_count,
array_agg((rrr.category_key,rrr.category_rank_rev,rrr.revenue)) as ranking_by_revenue
from ranking_by_count rr left join ranking_cat_by_revenue rrr
on rr.cust_key=rrr.cust_key
group by rr.cust_key where rr.category_rank_final<=3 or rr.category_rank_rev<=3 
