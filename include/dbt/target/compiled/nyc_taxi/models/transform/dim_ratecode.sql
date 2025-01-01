WITH rate_code_cte AS(
    SELECT DISTINCT
        rate_code_id AS rate_id,
        CASE 
            WHEN rate_code_id = 1 THEN "Standard rate"
            WHEN rate_code_id = 2 THEN "JFK"
            WHEN rate_code_id = 3 THEN "Newark"
            WHEN rate_code_id = 4 THEN "Nassau or Westchester"
            WHEN rate_code_id = 5 THEN "Negotiated fare"
            WHEN rate_code_id = 6 THEN "Group ride"
        ELSE "Unknown"
        END AS rate_code_name
    FROM `northern-shield-437204-m0`.`nyc_taxi`.`green_tripdata`
)
SELECT
    rate_id,
    rate_code_name
FROM rate_code_cte