
select
    re.rental_id,
    sum(pay.amount) as total_payment

from {{ ref('stg_pagila__rental') }} as re

left join {{ ref('stg_pagila__payments') }} as pay
    on re.rental_id = pay.rental_id

group by
    re.rental_id

having sum(pay.amount) > 20

