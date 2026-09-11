--Build an intermediate model `int_film_inventory_status.sql` that shows, for every film,
--     how many copies exist, how many are currently rented, and how many are available.
--     Make it reusable for both store-level and overall views.

{{
    config(
        materialized='table'
    )
}}
with currently_available as (
    select ff.film_id as current_available
    from film ff left join inventory inv
    on inv.film_id=ff.film_id
    left join rental re
    on re.inventory_id=inv.inventory_id
    left join store st
    on st.store_id=inv.store_id
    group by ff.film_id,st.store_id
    having max(re.rental_date)< curdate() and max(re.return_date) < CURDATE()

currently_rented as(
    select ff.film_id as current_rented,count(inv.inventory_id) as copies
    from film ff left join inventory inv
    on inv.film_id=ff.film_id
    left join rental re
    on re.inventory_id=inv.inventory_id
    left join store st
    on st.store_id=inv.store_id
    group by ff.film_id,st.store_id
    having max(re.rental_date) not in null and max(re.return_date) <= CURDATE()


)
select cr.copies,cr.current_rented,ca.current_available
from currently_rented cr left join currently_available  ca
on cr.film_id =ca.film_id
