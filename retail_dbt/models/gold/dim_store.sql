{{ config(materialized='table', schema='gold') }}

WITH ranked AS (
    SELECT
        CAST(store_id AS INT) AS store_id,
        name AS store_name,
        location,
        CAST(manager_id AS INT) AS manager_id,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(store_id AS INT)
            ORDER BY _ingested_at DESC, _run_id DESC
        ) AS rn
    FROM {{ source('retail_raw', 'stores') }}
)

SELECT
    store_id,
    store_name,
    location,
    manager_id
FROM ranked
WHERE rn = 1