-- 42. Build a dynamic “film affinity” model that, for every customer, calculates the top 3 categories
--     they have rented most (by revenue and by count) and stores the result as arrays or JSON.
--     Then create a second model that recommends films the customer has never rented from those top categories,
--     ranked by global popularity. Use macros to keep the ranking logic reusable.
--     Add a singular test that no recommended film has already been rented by that customer

{{
    config(
        materialized='table'
    )
}}

with cust_categ_ranking as (
    select cc.customer_id as cust_key,
    concat(cc.first_name,' ',cc.last_name) as full_name,
    rank() over( order by fc.category_id desc) as ranking
    from {{ref('stg_pagila__customers')}} cc left join {{ref('stg_pagila__rental')}} re
    on cc.customer_id =re.customer_id
    left join {{ref('stg_pagila__inventory')}} inv
    on inv.inventory_id=re.inventory_id
    left join {{source('pagila','film_category')}} fc
    on fc.film_id=inv.film_id
),
by_revenue as (
    select pp.amount as revenue,
    cc.cust_key,
    cc.full_name,
    cc.ranking,
    count(*) as counts,
    rank() over (order by pp.amount desc) as by_rev
    from cust_categ_ranking cc left join {{ref('stg_pagila__payments')}} pp
    on cc.cust_key=pp.customer_id

),
by_count as (
    select cc.cust_key,
    cc.full_name,
    rank() over (order by cc.counts desc) as by_cnt
    from by_revenue cc
)
select * from by_count