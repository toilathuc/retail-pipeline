{{ config(materialized='table', schema='gold') }}

WITH ranked AS (
    SELECT
        CAST(product_id AS INT) AS product_id,
        name AS product_name,
        CAST(category_id AS INT) AS category_id,
        CAST(brand_id AS INT) AS brand_id,
        CAST(supplier_id AS INT) AS supplier_id,
        CAST(price AS DECIMAL(10,2)) AS price,
        CAST(created_at AS DATE) AS created_at,
        season,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(product_id AS INT)
            ORDER BY _ingested_at DESC, _run_id DESC
        ) AS rn
    FROM {{ source('retail_raw', 'products') }}
)

SELECT
    product_id,
    product_name,
    category_id,
    brand_id,
    supplier_id,
    price,
    created_at,
    season
FROM ranked
WHERE rn = 1