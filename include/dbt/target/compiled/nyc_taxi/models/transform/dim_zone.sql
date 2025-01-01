SELECT DISTINCT
    location_id,
    borough,
    zone,
    replace(service_zone, 'Boro', 'Green') AS service_zone
FROM `northern-shield-437204-m0`.`nyc_taxi`.`zone_map`
WHERE service_zone IS NOT NULL