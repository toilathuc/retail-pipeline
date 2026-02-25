{{ config(materialized='table', schema='gold') }}

SELECT 
    CAST(product_id AS INT) AS product_id,
    name AS product_name,
    CAST(category_id AS INT) AS category_id,
    CAST(brand_id AS INT) AS brand_id,
    CAST(supplier_id AS INT) AS supplier_id,
    CAST(price AS DECIMAL(10,2)) AS price,
    CAST(created_at AS DATE) AS created_at,
    season
FROM {{ source('retail_raw', 'products') }}