--Create a store performance model that shows revenue, 
--number of rentals, and unique customers per store / staff member

{{
    config(
        materialized='view'
    )
}}

    select pp.staff_id,cc.store_id,
    coalesce(sum(pp.amount),0) as total_revenue,
    count(distinct(cc.customer_id)) as unique_customers,
    count(re.rental_id) as num_rentals
    from {{ref('stg_pagila__payments')}} pp left join {{ref('stg_pagila__rental')}} re
    on pp.rental_id=re.rental_id
    left join {{ref('stg_pagila__customers')}} cc 
    on cc.customer_id=pp.customer_id
    left join store st
    on st.store_id=cc.store_id
    group by pp.staff_id,cc.store_id

