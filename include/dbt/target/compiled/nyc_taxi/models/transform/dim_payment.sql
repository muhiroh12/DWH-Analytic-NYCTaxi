WITH payment_cte AS(
    SELECT DISTINCT
        payment_type AS type_id,
        CASE 
            WHEN payment_type = 1 THEN "Credit card"
            WHEN payment_type = 2 THEN "Cash"
            WHEN payment_type = 3 THEN "No charge"
            WHEN payment_type = 4 THEN "Dispute"
            WHEN payment_type = 5 THEN "Unknown"
            WHEN payment_type = 6 THEN "Voided trip"
        END AS payment_name
    FROM `northern-shield-437204-m0`.`nyc_taxi`.`green_tripdata`
)
SELECT
    type_id,
    payment_name
FROM payment_cte