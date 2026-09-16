{{
    config(
        materialized='view'
    )
}}

with source as (
    select actor_id,
    first_name,
    last_name,
    last_update
    from {{source('pagila','actor')}}
),
renamed as (
    select actor_id,
    concat(first_name,' ',last_name) as full_name,
    last_update
    from source
)
select *
from renamed