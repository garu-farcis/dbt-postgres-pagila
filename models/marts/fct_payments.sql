--Create fct_payments.sql that joins payments to rentals / customers and 
--calculates payment amount, payment date, and any derived flags (e.g. late payment if you can define it)
--Convert fct_payments into an incremental model.
--     Use unique_key = 'payment_id' and a watermark on payment_date.
--     Add on_schema_change = 'sync_all_columns'. Explain why you chose the strategy.

{{
    config(
        materialized= 'incremental',
        unique_key='payment_id',
        incremental_strategy='merge',
        updated_at='payment_date',
        on_schema_change='sync_all_columns'
    )
}}

select pay.payment_id,pay.amount as payment_amount,
concat(cu.first_name,' ',cu.last_name) as full_name,
pay.payment_date,
(case 
when pay.payment_date >re.rental_date then 'late payment'
else 'payment on time'
end) as payment_punctuality,
(
    case
    when re.return_date > (re.rental_date + 5) then 'late_return'
    else 'return on-time'
    end
) as rental_punctuality
from {{ref('stg_pagila__payments')}} as pay left join {{ref('stg_pagila__customers')}} as cu
on pay.customer_id=cu.customer_id
left join {{ref('stg_pagila__rental')}} as re
on re.rental_id=pay.rental_id


{% if is_incremental() %}
    where pay.payment_date > (
        select max(payment_date)
        from {{ this }}
    )
{% endif %}

