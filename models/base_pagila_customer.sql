with source as (
        select * from {{ source('pagila', 'customer') }}
  ),
  renamed as (
      select
          {{ adapter.quote("customer_id") }},
        {{ adapter.quote("store_id") }},
        {{ adapter.quote("first_name") }},
        {{ adapter.quote("last_name") }},
        {{ adapter.quote("email") }},
        {{ adapter.quote("address_id") }},
        {{ adapter.quote("activebool") }},
        {{ adapter.quote("create_date") }},
        {{ adapter.quote("last_update") }},
        {{ adapter.quote("active") }}

      from source
  )
  select * from renamed
    