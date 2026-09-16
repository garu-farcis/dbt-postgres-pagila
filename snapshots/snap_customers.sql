-- 31. Create a snapshot `snap_customers` on the source customer table (or stg_pagila__customers).
--     Track changes on email, active status, and address_id using strategy = 'timestamp' or 'check'.
--     Enable invalidate_hard_deletes and add a unique key. Document the chosen strategy.

{% snapshot snap_customers %}
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