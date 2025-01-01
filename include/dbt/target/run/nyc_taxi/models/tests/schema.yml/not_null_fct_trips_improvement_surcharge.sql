select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select improvement_surcharge
from `northern-shield-437204-m0`.`nyc_taxi`.`fct_trips`
where improvement_surcharge is null



      
    ) dbt_internal_test