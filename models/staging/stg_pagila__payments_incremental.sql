{{
    config(
        materialized = 'incremental',
        unique_key = 'payment_id',
        incremental_strategy = 'append',   
        on_schema_change = 'fail'
    )
}}

select
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date,
    -- optional technical columns
    current_timestamp as dbt_loaded_at
from {{ source('pagila', 'payment') }}

{% if is_incremental() %}

    where payment_date > (select max(payment_date) from {{ this }})

{% endif %}