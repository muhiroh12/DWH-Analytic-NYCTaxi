WITH tripdata_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['t.vendor_id', 't.lpep_pickup_datetime', 't.lpep_dropoff_datetime', 't.__index_level_0__']) }} AS trip_id,
        t.vendor_id,
        pt.time_id AS pickup_time_id,
        dt.time_id AS dropoff_time_id,
        t.rate_code_id,
        t.pu_location_id,
        t.do_location_id,
        t.passenger_count,
        t.trip_distance,
        t.fare_amount,
        t.extra,
        t.mta_tax,
        t.tip_amount,
        t.tolls_amount,
        t.improvement_surcharge,
        t.total_amount,
        t.payment_type,
        t.trip_type,
        t.congestion_surcharge
    FROM {{ source('nyc_taxi', 'green_tripdata') }} AS t
    INNER JOIN (
        SELECT DISTINCT date_part, time_id 
        FROM {{ ref('dim_time') }}
    ) pt ON t.lpep_pickup_datetime = pt.date_part
    INNER JOIN (
        SELECT DISTINCT date_part, time_id 
        FROM {{ ref('dim_time') }}
    ) dt ON t.lpep_dropoff_datetime = dt.date_part
)
SELECT 
    trip_id,
    vendor_id,
    pickup_time_id,
    dropoff_time_id,
    rate_code_id,
    pu_location_id,
    do_location_id,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    payment_type,
    trip_type,
    congestion_surcharge
FROM tripdata_cte