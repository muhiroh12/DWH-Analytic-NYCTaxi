select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        trip_name as value_field,
        count(*) as n_records

    from `northern-shield-437204-m0`.`nyc_taxi`.`dim_triptype`
    group by trip_name

)

select *
from all_values
where value_field not in (
    'Street-hail','Dispatch','Unknown'
)



      
    ) dbt_internal_test