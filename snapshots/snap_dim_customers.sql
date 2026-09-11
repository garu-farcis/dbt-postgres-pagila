--Create a snapshot of the customer table (or dim_customers) to track SCD Type 2 changes
--     on email, address, and active status. Configure invalidate_hard_deletes.

{% snapshot snap_dim_customers %}
{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['email','address','active'],
        invalidate_hard_deletes=True
    )
}}

select customer_id,first_name,last_name,email, address,active 
from {{ref('dim_customers')}}

{% endsnapshot %}
