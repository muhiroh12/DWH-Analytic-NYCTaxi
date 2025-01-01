
    
    

with dbt_test__target as (

  select location_id as unique_field
  from `northern-shield-437204-m0`.`nyc_taxi`.`dim_zone`
  where location_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


