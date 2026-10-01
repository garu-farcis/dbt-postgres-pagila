{% macro ranking_val(column_name,value) %}
select rank() over (partition by {{column_name}} order by {{value}} desc )
{% endmacro %}