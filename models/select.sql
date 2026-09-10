select
    customer_id,
    payment_date,
    dbt_valid_from,
    dbt_valid_to,dbt_scd_id from snapshots.snap_pagila_payments
