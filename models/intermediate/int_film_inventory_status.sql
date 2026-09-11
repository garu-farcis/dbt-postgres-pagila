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
    where max(re.rental_date)< curdate() and max(re.return_date) < CURDATE()
    group by ff.film_id
currently_rented as(
    select ff.film_id as current_rented
    from film ff left join inventory inv
    on inv.film_id=ff.film_id
    left join rental re
    on re.inventory_id=inv.inventory_id
    where max(re.rental_date) not in null and re.return_date > CURDATE()
    group by ff.film_id

)
select count(inv.inventory_id) as copies,