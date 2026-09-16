/*-- 34. Create dim_dates as a proper date dimension covering the full range of rental and payment dates.
--     Include columns: date_day, day_of_week, day_name, week_of_year, month_name, quarter, year,
--     is_weekend, and fiscal year helpers if useful. Materialize it as a table.*/
{{
    config(
        materialized='table'
    )
}}

with date_spine_data as (
    {{date_spine(
    start_date="(select least
    ( (select min(rental_date) from " ~ ref('stg_pagila__rental') ~ "),
     (select min(payment_date) from " ~ ref('stg_pagila__payments') ~ ") ))",
    end_date="(
    select greatest( 
    (select max(rental_date) from " ~ ref('stg_pagila__rental') ~ "), 
    (select max(payment_date) from " ~ ref('stg_pagila__payments') ~ ") ))"


    ) }}
)

select ds.date_day as date_day,
extract(dow from ds.date_day) as day_of_week,
to_char(ds.date_day, 'Day') as day_name,
extract(week from ds.date_day) as week_of_year,
to_char(ds.date_day, 'Month') as month_name,
extract(quarter from ds.date_day) as quarter_name,
extract(year from ds.date_day) as year_name,
(case
    when extract(dow from date_day) in (0, 6) then true
    else false
end) as is_weekend
from date_spine_data ds
