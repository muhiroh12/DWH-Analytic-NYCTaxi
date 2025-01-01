
  
    

    create or replace table `northern-shield-437204-m0`.`nyc_taxi`.`dim_triptype`
      
    
    

    OPTIONS()
    as (
      WITH triptype_cte AS(
	SELECT DISTINCT 
		trip_type AS type_id,
		CASE 
			WHEN trip_type = 1 THEN 'Street-hail'
			WHEN trip_type = 2 THEN 'Dispatch'
		ELSE 'Unknown'
		END AS trip_name
	FROM `northern-shield-437204-m0`.`nyc_taxi`.`green_tripdata` 
	WHERE trip_type IS NOT NULL
)
SELECT
	type_id,
	trip_name
FROM triptype_cte
    );
  