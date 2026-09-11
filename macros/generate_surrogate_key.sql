--Write a macro `generate_surrogate_key` (or use dbt_utils) and apply it consistently
--     across all your dimension and fact models. Refactor existing models to use it.

{{dbt_utils.generate_surrogate_key([
    'customer_id',
    'address_id'])}} as cust_surro_key