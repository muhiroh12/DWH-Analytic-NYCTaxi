select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select dropoff_time_id
from `northern-shield-437204-m0`.`nyc_taxi`.`fct_trips`
where dropoff_time_id is null



      
    ) dbt_internal_test