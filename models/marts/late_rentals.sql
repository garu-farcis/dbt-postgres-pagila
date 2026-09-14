--Create a late-rental detection model that flags rentals still open after the expected
--     return window (use rental_duration from the film). Add a severity column (warning / critical).

{{
    config(
        materialized= 'table'
    )
}}

with late_rental as (
    select re.rental_id,
    re.customer_id,
    re.return_date,
    (case
        when re.return_date is null  and current_date> (re.rental_date::date + ff.rental_duration) then current_date-(re.rental_date::date + ff.rental_duration)
        else 0
        end
    ) as late_by_days
    from film ff left join inventory inv
    on inv.film_id=ff.film_id
    left join rental re
    on re.inventory_id=inv.inventory_id
)

select lr.*,
(case
when lr.late_by_days between 1 and 6 then 'warning'
when lr.late_by_days>6 then 'critical'
else 'not_late' end) as late_flag
from late_rental as lr
