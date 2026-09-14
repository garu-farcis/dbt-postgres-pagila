-- 21. Implement a dbt unit test (or singular test) that validates the revenue calculation
--     in film_performance matches the sum of payments joined through rentals and inventory.

select fp.total_revenue,
coalesce(sum(pay.amount),0) as total_amount
from film ff left join inventory inv
on ff.film_id=inv.film_id
left join {{ref('int_film_performance')}} fp
on fp.film_id=ff.film_id
left join rental re
on re.inventory_id=inv.inventory_id
left join payment pay
on pay.rental_id=re.rental_id
group by fp.film_id,fp.title,fp.total_revenue
having coalesce(sum(pay.amount),0) <> fp.total_revenue 