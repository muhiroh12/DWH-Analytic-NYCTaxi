select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select service_zone
from `northern-shield-437204-m0`.`nyc_taxi`.`dim_zone`
where service_zone is null



      
    ) dbt_internal_test