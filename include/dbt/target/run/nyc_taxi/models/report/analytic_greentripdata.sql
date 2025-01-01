
  
    

    create or replace table `northern-shield-437204-m0`.`nyc_taxi`.`analytic_greentripdata`
      
    
    

    OPTIONS()
    as (
      WITH 
pickup_times AS (
    SELECT 
        fct.trip_id,
        pu_t.date_part AS pickup_datetime,
        pu_t.date AS pickup_date,
        pu_t.hour AS pickup_hour,
        FORMAT_DATE('%b', pu_t.date) AS month_name,
        UPPER(LEFT(pu_t.weekday, 3)) AS day_of_week
    FROM 
        `northern-shield-437204-m0`.`nyc_taxi`.`fct_trips` fct
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_time` pu_t ON fct.pickup_time_id = pu_t.time_id
),
dropoff_times AS (
    SELECT 
        fct.trip_id,
        do_t.date_part AS dropoff_datetime,
        TIMESTAMP_DIFF(do_t.date_part, pu_t.date_part, MINUTE) AS trip_duration_minutes
    FROM 
        `northern-shield-437204-m0`.`nyc_taxi`.`fct_trips` fct
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_time` pu_t ON fct.pickup_time_id = pu_t.time_id
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_time` do_t ON fct.dropoff_time_id = do_t.time_id
),
trip_details AS (
    SELECT 
        fct.trip_id,
        v.vendor_name,
        p.payment_name AS payment_type,
        z_pickup.zone AS pu_zone,
        z_dropoff.zone AS do_zone,
        r.rate_code_name,
        tt.trip_name,
        fct.passenger_count,
        CASE 
            WHEN fct.passenger_count > 3 THEN '>3'
            ELSE CAST(fct.passenger_count AS STRING)
        END AS passenger_count_group,
        fct.fare_amount,
        fct.tip_amount,
        fct.total_amount,
        (fct.total_amount - fct.fare_amount - fct.tip_amount) AS other_amount,
        fct.trip_distance,
        CASE 
            WHEN fct.trip_distance < 5 THEN '<5 miles'
            WHEN fct.trip_distance >= 5 AND fct.trip_distance < 10 THEN '5-10 miles'
            WHEN fct.trip_distance >= 10 AND fct.trip_distance < 20 THEN '11-20 miles'
            WHEN fct.trip_distance >= 20 AND fct.trip_distance < 30 THEN '21-30 miles'
            WHEN fct.trip_distance >= 30 AND fct.trip_distance < 40 THEN '31-40 miles'
            ELSE '>40 miles'
        END AS trip_distance_group
    FROM 
        `northern-shield-437204-m0`.`nyc_taxi`.`fct_trips` fct
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_vendor` v ON fct.vendor_id = v.id
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_payment` p ON fct.payment_type = p.type_id
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_zone` z_pickup ON fct.pu_location_id = z_pickup.location_id
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_zone` z_dropoff ON fct.do_location_id = z_dropoff.location_id
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_ratecode` r ON fct.rate_code_id = r.rate_id
    JOIN `northern-shield-437204-m0`.`nyc_taxi`.`dim_triptype` tt ON fct.trip_type = tt.type_id
    WHERE 
        fct.trip_type IS NOT NULL
        AND fct.rate_code_id IS NOT NULL
        AND fct.trip_type != 99
        AND fct.rate_code_id != 99
)
SELECT 
	td.trip_id,
    pt.pickup_datetime,
    pt.pickup_date,
    pt.pickup_hour,
    pt.month_name,
    pt.day_of_week,
    dt.trip_duration_minutes,
    td.vendor_name,
    td.payment_type,
    td.pu_zone,
    td.do_zone,
    td.rate_code_name,
    td.trip_name,
    td.passenger_count,
    td.passenger_count_group,
    td.fare_amount,
    td.tip_amount,
    td.total_amount,
    td.other_amount,
    td.trip_distance,
    td.trip_distance_group
FROM 
    pickup_times pt
JOIN dropoff_times dt ON pt.trip_id = dt.trip_id
JOIN trip_details td ON pt.trip_id = td.trip_id
ORDER BY 
    td.trip_id
    );
  