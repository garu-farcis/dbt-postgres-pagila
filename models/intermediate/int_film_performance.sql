--Write a model that answers: “Which films have the highest revenue 
--and how many times were they rented?” (film_performance.sql).

{{
    config(
        materialized = 'view'
    )
}}

select
    f.film_id,
    f.title,
    count(r.rental_id)          as times_rented,
    coalesce(sum(p.amount), 0)  as total_revenue
from {{ ref('stg_pagila__films') }} f
left join {{ ref('stg_pagila__inventory') }} i
    on f.film_id = i.film_id
left join {{ ref('stg_pagila__rental') }} r
    on i.inventory_id = r.inventory_id
left join {{ ref('stg_pagila__payments') }} p
    on r.rental_id = p.rental_id
group by
    f.film_id,
    f.title
order by
    total_revenue desc