{{ config(materialized='table', schema='gold') }}

WITH ranked AS (
    SELECT
        CAST(customer_id AS INT) AS customer_id,
        name,
        email,
        phone,
        CAST(loyalty_program_id AS INT) AS loyalty_program_id,
        gender,
        CAST(age AS INT) AS age,
        CAST(created_at AS DATE) AS created_at,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(customer_id AS INT)
            ORDER BY _ingested_at DESC, _run_id DESC
        ) AS rn
    FROM {{ source('retail_raw', 'customers') }}
)

SELECT
    customer_id,
    name,
    email,
    phone,
    loyalty_program_id,
    gender,
    age,
    created_at
FROM ranked
WHERE rn = 1