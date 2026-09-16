{% macro full_name(first_name,last_name) %}
(concat({{first_name}},' ',{{last_name}})) as full_name
{% endmacro %}