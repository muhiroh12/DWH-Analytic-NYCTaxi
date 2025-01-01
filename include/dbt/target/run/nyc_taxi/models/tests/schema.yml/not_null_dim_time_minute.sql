select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select minute
from `northern-shield-437204-m0`.`nyc_taxi`.`dim_time`
where minute is null



      
    ) dbt_internal_test