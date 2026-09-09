-- models/customer_summary.sql

{{ config(
    materialized='table'
) }}

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) as total_rentals,
    SUM(p.amount) as total_spent,
    MAX(r.rental_date) as last_rental_date
FROM {{ source('pagila', 'customer') }} as c
LEFT JOIN {{ source('pagila', 'rental') }} as r 
    ON c.customer_id = r.customer_id
LEFT JOIN {{ source('pagila', 'payment') }} as p 
    ON r.rental_id = p.rental_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_spent DESC