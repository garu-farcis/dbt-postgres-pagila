
select
    rental_id,
    rental_date,
    return_date

from {{ ref('fct_rentals') }}

where return_date < rental_date
