{% macro cents_to_dollars(col_name,scale=2) %}
({{col_name}}/100)::numeric(10,{{scale}})
{% endmacro %}