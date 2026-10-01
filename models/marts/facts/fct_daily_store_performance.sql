-- 44. Implement an incremental “daily store performance” fact that is partitioned by date
--     and only processes new/changed rentals and payments since the last run.
--     Challenges to solve:
--     - Handle late-arriving payments that belong to older rental dates
--     - Recalculate metrics for any affected historical day when late data arrives
--     - Maintain a watermark table (or use dbt’s incremental strategy cleverly)
--     - Guarantee that re-running the same day produces identical results (idempotency)
--     Document the chosen strategy and its trade-offs.

{{
    config(
        materialized='incremental',
        unique_key='store_key',

    )
}}

with store_performance as (
    /* - no of rentals per store
    - payment_revenue per store
    - distinct cust per store
    - distinct fims rented per store */
    select ss.store_id as store_key,
    count(re.rental_id) as total_rentals,
    sum(pay.amount) as total_revenue,
    count(distinct re.customer_id) as cust_key,
    count(distinct inv.film_id) as film_key,
    pay.last_update as payment_last_update,
    re.last_update as rental_last_update,
    rank() over (partition by rental_last_update::date) as most_updated_ranking

    from {{source('pagila','store')}} as ss left join {source('pagila','inventory')}} inv 
    on ss.store_id=inv.store_id
    left join {{ref('stg_pagila__rental')}} re
    on inv.inventory_id=re.rental_id
    left join {{ref('stg_pagila__payments')}} pay
    on re.rental_id=pay.rental_id
    group by ss.store_id,re.rental_id,pay.amount,re.customer_id,inv.film_id
),
ranking_by_freshness as (
    select st.store_key,st.total_rentals,st.total_revenue,st.cust_key,st.film_key,st.film_key,st.payment_last_update,st.rental_last_update
    from store_performance st left join {{ref('stg_pagila__payments')}} pay
    on st.cust_key=pay.customer_id
    left join {{ref('stg_pagila__rental')}} re
    on st.cust_key=re.customer_id
    where (max(re.rental_date) >st.rental_last_update::date) and (max(pay.payment_date)>st.payment_last_update::date)
),
late_payments as (

)
