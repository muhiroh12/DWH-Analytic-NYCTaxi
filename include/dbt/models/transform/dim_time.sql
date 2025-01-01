WITH datetime_cte AS (
    SELECT DISTINCT
        lpep_pickup_datetime AS datetime_value
    FROM {{ source('nyc_taxi', 'green_tripdata') }}
    UNION ALL
    SELECT DISTINCT
        lpep_dropoff_datetime AS datetime_value
    FROM {{ source('nyc_taxi', 'green_tripdata') }}
),
datetime_cte_distinct AS(
    SELECT DISTINCT
        datetime_value
    FROM datetime_cte
)
SELECT
    ROW_NUMBER() OVER (ORDER BY datetime_value) AS time_id,
    DATE(datetime_value) AS date,
    datetime_value AS date_part,
    EXTRACT(YEAR FROM datetime_value) AS year,
    EXTRACT(MONTH FROM datetime_value) AS month,
    EXTRACT(DAY FROM datetime_value) AS day,
    EXTRACT(HOUR FROM datetime_value) AS hour,
    EXTRACT(MINUTE FROM datetime_value) AS minute,
    FORMAT_TIMESTAMP('%A', datetime_value) AS weekday
FROM datetime_cte_distinct
ORDER BY time_id