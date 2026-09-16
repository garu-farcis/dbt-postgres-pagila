-- 32. Build a second snapshot `snap_films` that tracks changes to rental_rate, length, and rating.
--     Use the check strategy with a list of columns.
{% snapshot snap_films %}
{{
    config(
        target_schema='snapshots',
        unique_key='film_id',
        strategy='check',
        check_cols=['rental_rate','length','rating']
    )
}}

select film_id,rental_rate,length,rating from {{ref('stg_pagila__films')}}

{% endsnapshot %}

