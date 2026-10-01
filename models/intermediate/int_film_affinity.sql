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
    fc.film_id as film_key,
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
        rr.film_key as film_key,
        rr.category_rank_rev category_rank_rev,
        rr.revenue as revenue,
        rr.rental_count as rental_count,
        rr.category_key as category_key,
    row_number()over (
        partition by rr.cust_key order by rr.rental_count desc ) category_rank_final
    from  ranking_cat_by_revenue rr
    ),
    top_count as (
    select *
    from ranking_by_count
    where category_rank_final <= 3

),

top_revenue as (

    select *
    from ranking_by_count
    where category_rank_rev <= 3

),
count_array as (

    select
        cust_key,
        array_agg(
            (category_key, category_rank_final, rental_count)
            order by category_rank_final
        ) as ranking_by_count
    from top_count
    group by cust_key

),

revenue_array as (
select cust_key,array_agg((category_key, category_rank_rev, revenue)
order by category_rank_rev) as ranking_by_revenue
from top_revenue
group by cust_key

),
count_array as (
select cust_key,
array_agg((category_key, category_rank_final, rental_count)
order by category_rank_final) as ranking_by_count
from top_count
group by cust_key

)
    
select ca.cust_key,
     ca.ranking_by_count,
    ra.ranking_by_revenue
from count_array ca left join revenue_array ra
on ca.cust_key = ra.cust_key
