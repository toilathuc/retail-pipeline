{{ config(materialized='table', schema='gold') }}

SELECT 
    CAST(store_id AS INT) AS store_id,
    name AS store_name,
    location,
    CAST(manager_id AS INT) AS manager_id
FROM {{ source('retail_raw', 'stores') }}