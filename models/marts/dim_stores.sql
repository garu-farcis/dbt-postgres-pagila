/*One row per store.
Should contain:

store_id (natural key)
Manager information (denormalized):
manager_staff_id, manager_first_name, manager_last_name

Full address (denormalized from address → city → country):
address, address2, district, postal_code, phone
city, country

Optional: any store-level attributes (opening hours, region, etc. if available)*/

{{
    config(
        materialized = 'view'
    )
}}

with manager_address as (
    select concat(ad.address,' ',ad.address2,' ',ad.district,' ',ad.postal_code,' ','Phone:',' ',ad.phone,' ',ct.city,' ',co.country) as full_address,
    st.manager_staff_id
    from {{source('pagila','store')}} st left join {{source('pagila','staff')}} sa
    on st.manager_staff_id=sa.staff_id
    left join {{source('pagila','address')}} ad
    on ad.address_id=st.address_id
    left join {{source('pagila','city')}} ct
    on ct.city_id=ad.city_id
    left join {{source('pagila','country')}} co
    on co.country_id=ct.country_id
),
manager_info as (

select st.store_id as store_key,
st.manager_staff_id as manager_key,
sf.first_name as manager_first_name,
sf.last_name as manager_last_name
from {{source('pagila','store')}} st left join {{source('pagila','staff')}} sf
on st.manager_staff_id=sf.staff_id
)

select mi.store_key,mi.manager_key,mi.manager_first_name,mi.manager_last_name,ma.full_address
from manager_info mi inner join manager_address ma
on ma.manager_staff_id=mi.manager_key

