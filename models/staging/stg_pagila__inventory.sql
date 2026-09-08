
{{
    config(
        materialized= 'view'
    )
}}
select inventory_id,
film_id,
store_id,
date(last_update) last_update
from {{ source ('pagila','inventory')}} 