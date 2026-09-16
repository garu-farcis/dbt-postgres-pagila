/*--     a) No orphan rentals (every rental must have a matching customer and film*/

select re.rental_id 
from {{ref('stg_pagila__rental')}} re left join {{ref('stg_pagila__customers')}} cu
on cu.customer_id=re.customer_id
left join {{ref('stg_pagila__inventory')}} as inv
on inv.inventory_id=re.inventory_id
left join {{ref('stg_pagila__films')}} ff
on ff.film_id=inv.film_id
where cu.customer_id is null and  ff.film_id is null
