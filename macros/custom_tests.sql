
{% macro custom_tests(model,column_name) %}

select distinct {{column_name}} from {{model}}
where {{column_name}} is null or {{column_name}}<0

{% endmacro %}