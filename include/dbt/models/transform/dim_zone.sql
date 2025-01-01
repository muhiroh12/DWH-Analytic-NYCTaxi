SELECT DISTINCT
    location_id,
    borough,
    zone,
    replace(service_zone, 'Boro', 'Green') AS service_zone
FROM {{ source('nyc_taxi','zone_map') }}
WHERE service_zone IS NOT NULL