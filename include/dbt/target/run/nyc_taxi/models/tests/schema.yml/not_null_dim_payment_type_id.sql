select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select type_id
from `northern-shield-437204-m0`.`nyc_taxi`.`dim_payment`
where type_id is null



      
    ) dbt_internal_test