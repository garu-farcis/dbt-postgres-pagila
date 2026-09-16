/*-- 39. Create a generic test macro `test_positive_values` that fails if any value in the specified
--     column is ≤ 0. Apply it to payment amounts, rental rates, and inventory counts.*/

{% test test_positive_values(model,column_name) %}

select {{column_name}}
from {{model }}
where {{column_name}} <=0

{% endtest %}