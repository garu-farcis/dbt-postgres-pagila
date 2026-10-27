{% snapshot customer_info_tracker %}
{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['email','active','address_id'],
        invalidate_hard_deletes=True
    )
}}
select customer_id,email,active,address_id from {{ref('stg_pagila__customers')}}

{% endsnapshot %}