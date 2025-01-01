select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        payment_name as value_field,
        count(*) as n_records

    from `northern-shield-437204-m0`.`nyc_taxi`.`dim_payment`
    group by payment_name

)

select *
from all_values
where value_field not in (
    'Credit card','Cash','No charge','Dispute','Unknown','Voided trip'
)



      
    ) dbt_internal_test