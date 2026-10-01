with versions as (

    select
        customer_id,
        customer_key,
        valid_from,
        valid_to

    from {{ ref('dim_customers_scd2') }}

),

overlaps as (

    select
        a.customer_id,
        a.customer_key as customer_key_a,
        b.customer_key as customer_key_b

    from versions a

    join versions b
        on a.customer_id = b.customer_id
        and a.customer_key <> b.customer_key

    where a.valid_from < coalesce(b.valid_to, '9999-12-31'::timestamp)
      and b.valid_from < coalesce(a.valid_to, '9999-12-31'::timestamp)

)

select *
from overlaps