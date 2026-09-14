--Build an intermediate model `int_film_inventory_status.sql` that shows, for every film,
--     how many copies exist, how many are currently rented, and how many are available.
--     Make it reusable for both store-level and overall views.

{{
    config(
        materialized='table'
    )
}}
with latest_rental as (
    select inventory_id,
    return_date,
    row_number() over (
        partition by inventory_id
        order by rental_date desc
    )as rn
    from rental

)
SELECT
    f.title,
    COUNT(CASE
        WHEN lr.return_date IS NULL THEN 1
    END) AS copies_rented,

    COUNT(CASE
        WHEN lr.return_date IS NOT NULL OR lr.inventory_id IS NULL THEN 1
    END) AS copies_available
FROM film f
JOIN inventory i
    ON f.film_id = i.film_id
LEFT JOIN latest_rental lr
    ON i.inventory_id = lr.inventory_id
    and lr.rn=1
GROUP BY f.film_id, f.title