
    
    

with all_values as (

    select
        rate_code_name as value_field,
        count(*) as n_records

    from `northern-shield-437204-m0`.`nyc_taxi`.`dim_ratecode`
    group by rate_code_name

)

select *
from all_values
where value_field not in (
    'Standard rate','JFK','Newark','Nassau or Westchester','Negotiated fare','Group ride'
)


