--Create fct_payments.sql that joins payments to rentals / customers and 
--calculates payment amount, payment date, and any derived flags (e.g. late payment if you can define it)

{{
    config(
        materialized= 'view'
    )
}}

select pay.amount as payment_amount,
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
group by cu.customer_id,pay.amount,pay.payment_date,re.return_date,re.rental_date,cu.first_name,cu.last_name
