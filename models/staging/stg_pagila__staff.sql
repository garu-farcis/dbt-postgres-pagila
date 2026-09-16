{{
    config(
        materialized='view'
    )
}}

with source as (
    select staff_id,
    first_name,
    last_name,
    address_id,
    picture,
    store_id,
    active,
    username,
    password,
    last_update
    from {{source('pagila','staff')}}

),
renamed as (
    select staff_id,
    {{full_name('first_name','last_name')}},
    address_id,
    picture,
    store_id,
    active,
    username,
    password,
    last_update
    from source
)

select * from renamed