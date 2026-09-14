
-- 22. Add a custom generic test (macros/tests) called `expect_column_values_to_be_between`
--     and apply it to payment amounts and rental durations.
{% test expect_column_values_to_be_between(model, column_name, min_value, max_value) %}

    select *
    from {{ model }}
    where {{ column_name }} < {{ min_value }}
       or {{ column_name }} > {{ max_value }}

{% endtest %}
