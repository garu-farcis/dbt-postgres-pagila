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
        unique_key=['store_key', 'performance_date'],
        incremental_strategy='delete+insert'

    )
}}

with store_performance as (
    /* - no of rentals per store
    - payment_revenue per store
    - distinct cust per store
    - distinct fims rented per store */
    select ss.store_id as store_key,
    count(re.rental_id) as total_rentals,
    coalesce(sum(pay.amount), 0) as total_revenue,
    count(distinct re.customer_id) as cust_key,
    count(distinct inv.film_id) as film_key,
    max(pay.payment_date) as payment_last_update,
    max(re.rental_date) as rental_last_update
    
    from {{source('pagila','store')}} as ss left join {{source('pagila','inventory')}} inv 
    on ss.store_id=inv.store_id
    left join {{ref('stg_pagila__rental')}} re
    on inv.inventory_id=re.inventory_id
    left join {{ref('stg_pagila__payments')}} pay
    on re.rental_id=pay.rental_id
    group by ss.store_id,re.rental_date::date
),
ranking_by_freshness as (
    select st.store_key,st.total_rentals,st.total_revenue,st.cust_key,st.film_key,st.payment_last_update,st.rental_last_update
    from store_performance st left join {{ref('stg_pagila__payments')}} pay
    on st.cust_key=pay.customer_id
    left join {{ref('stg_pagila__rental')}} re
    on st.cust_key=re.customer_id
    where (max(re.rental_date) >st.rental_last_update::date) and (max(pay.payment_date)>st.payment_last_update::date)
),
changed_rentals as (
select distinct re.rental_id,
        re.inventory_id,
        re.rental_date::date as performance_date,
        re.last_update
        from {{ ref('stg_pagila__rental') }} as re

    {% if is_incremental() %}

    where re.last_update > (
        select max(rental_last_update)
        from {{ this }}
    )

    {% endif %}
),
changed_payments as (
select distinct pay.payment_id,
        pay.rental_id,
        pay.last_update
    from {{ ref('stg_pagila__payments') }} as pay

    {% if is_incremental() %}

    where pay.last_update > (
        select max(payment_last_update)
        from {{ this }}
    )
    {% endif %}
), 
late_payments as (
        select distinct re.inventory_id,re.rental_date::date as performance_date
    from changed_payments as pay inner join {{ ref('stg_pagila__rental') }} as re
    on pay.rental_id = re.rental_id
),
affected_store_days as (
 select distinct inv.store_id as store_key, cr.performance_date
from changed_rentals as cr inner join {{ source('pagila', 'inventory') }} as inv
on cr.inventory_id = inv.inventory_id
union
select distinct inv.store_id as store_key, lp.performance_date
from late_payments as lp inner join {{ source('pagila', 'inventory') }} as inv
on lp.inventory_id = inv.inventory_id
),
recalc_on_late_arrivals as (
    select st.store_key,
        st.performance_date,
        st.total_rentals,
        st.total_revenue,
        st.cust_key,
        st.film_key,
        st.payment_last_update::date,
        st.rental_last_update,
        current_timestamp as latest_watermark

    from store_performance as st inner join affected_store_days as ad
        on st.store_key = ad.store_key
        and st.performance_date = ad.performance_date

)
select * from recalc_on_late_arrivals