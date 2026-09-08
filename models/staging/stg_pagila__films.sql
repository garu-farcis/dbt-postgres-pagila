
{{
    config(
        materialized = 'view'
    )
}}
select film_id,
trim(lower(title)) title,
year(release_year) release_year,
language_id,
original_language_id,
rental_duration,
round(rental_rate,2) rental_rate,
length,
round(replacement_cost,2) replacement_cost,
rating,
special_features,
date(last_update) last_update
from {{source('pagila','film')}}