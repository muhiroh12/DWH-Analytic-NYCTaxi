
    
    

with all_values as (

    select
        weekday as value_field,
        count(*) as n_records

    from `northern-shield-437204-m0`.`nyc_taxi`.`dim_time`
    group by weekday

)

select *
from all_values
where value_field not in (
    'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
)

