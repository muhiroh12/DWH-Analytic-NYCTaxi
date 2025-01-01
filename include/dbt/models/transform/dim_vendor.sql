WITH vendor_cte AS(
    SELECT DISTINCT
        vendor_id AS id,
        CASE 
            WHEN vendor_id = 1 THEN "Creative Mobile Technologies"
            WHEN vendor_id = 2 THEN "VeriFone Inc."
        END AS vendor_name
    FROM {{ source('nyc_taxi', 'green_tripdata') }}
)
SELECT
    id,
    vendor_name
FROM vendor_cte