
-- 30. Build an ephemeral intermediate model that enriches rentals with film rating, category, 
-- and language, then use it in three different final marts without materializing it. 
-- Prove in the docs that the lineage is correct and no extra tables were created.
{{
    config(
        materialized='ephemeral'
    )
}}

with cat_name as (
    select ff.rating as film_rating,
    cat.name as category_name,
    ff.film_id as film_id
    from {{ref('stg_pagila__films')}} ff left join {{ source('pagila','film_category')}} fc
    on ff.film_id=fc.film_id
    left join {{source('pagila','category')}} cat
    on cat.category_id=fc.category_id
),
lang_name as (
    select lang.name as language_name,
    ff.film_id as film_id
    from {{ref('stg_pagila__films')}} ff left join {{source('pagila','language')}} lang
    on ff.language_id=lang.language_id
)
select cn.film_rating,cn.category_name,lnn.language_name
from lang_name lnn left join cat_name cn
on cn.film_id=lnn.film_id