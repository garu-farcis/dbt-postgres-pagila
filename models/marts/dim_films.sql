--Create a film dimension dim_films.sql that brings in language name, category names (as an array or concatenated string), and actor names.


{{
    config(
        materialized = 'view'
    )
}}

select
    f.film_id,
    f.title,
    l.name as language,

    string_agg(distinct c.name, ', ') as categories,

    string_agg(
        distinct concat(a.first_name, ' ', a.last_name),
        ', '
    ) as actors

from {{ ref('stg_pagila__films') }} as f

left join {{ source('pagila', 'language') }} as l
    on f.language_id = l.language_id

left join {{ source('pagila', 'film_category') }} as fc
    on f.film_id = fc.film_id

left join {{ source('pagila', 'category') }} as c
    on fc.category_id = c.category_id

left join {{ source('pagila', 'film_actor') }} as fa
    on f.film_id = fa.film_id

left join {{ source('pagila', 'actor') }} as a
    on fa.actor_id = a.actor_id

group by
    f.film_id,
    f.title,
    l.name

