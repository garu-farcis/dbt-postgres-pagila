{% snapshot snap_pagila__payments %}

{{
    config(
        target_schema = 'snapshots',
        unique_key = 'payment_id',
        strategy = 'timestamp',
        updated_at = 'payment_date',
        invalidate_hard_deletes = true
    )
}}

select
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
from {{ source('pagila', 'payment') }}

{% endsnapshot %}