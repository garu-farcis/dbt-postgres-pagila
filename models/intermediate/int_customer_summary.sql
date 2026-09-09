--Create a customer summary mart customer_summary.sql (the one you started) that combines the dimension with the aggregates 
--from the previous step and adds simple RFM-style or activity flags (e.g. “active in last 90 days”, “high value”).

{{
    config(
        materialized='view'
    )
}}
with dim_cust as (
    select dc.customer_id,dc.first_name,dc.last_name,dc.email,dc.address,dc.city,dc.country from {{ref('dim_customers')}} as dc group by dc.customer_id,dc.first_name,dc.last_name,dc.email,dc.address,dc.city,dc.country
), 
cust_rent as(
    select cr.customer_id,cr.total_rentals,cr.average_rental_duration,
    cr.first_rental_date,
    cr.last_rental_date,cr.total_payments from {{ref('int_customer_rentals')}} as cr
)

select dc.customer_id,dc.first_name,dc.last_name,dc.email,dc.address,dc.city,dc.country,
    coalesce(cr.total_rentals,0) as total_rentals,
    coalesce(cr.average_rental_duration,0) as average_rental_duration,
    cr.first_rental_date,
    cr.last_rental_date,cr.total_payments,
    (
        case 
        when cr.total_rentals>20 then 'high value'
        when cr.total_rentals between 10 and 20 then 'medium value'
        else 'low value'
        end
    ) as customer_tier,
    (
        case
        when cr.last_rental_date::date> current_date-90 then 'active in last 90 days'
        else 'NOT active in last 90 days'
        end
    ) as activity_flag
    from dim_cust dc left join cust_rent cr 
    on dc.customer_id=cr.customer_id