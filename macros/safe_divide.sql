{% macro safe_divide(numerator,denominator) %}
case when  {{denominator}}<> 0 
   then  (round(({{numerator}}::numeric/{{denominator}}),2)) 
else 0
end as average_value
{% endmacro %}


