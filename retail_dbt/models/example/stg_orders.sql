{{ config(materialized='table') }}

WITH raw_data AS (
    SELECT * FROM {{ source('retail_raw', 'sales_transactions') }}
)

SELECT 
    transaction_id AS order_id,
    customer_id,
    CAST(transaction_date AS TIMESTAMP) AS order_date,
    CAST(total_amount AS NUMERIC(10,2)) AS total_amount,
    payment_id
FROM raw_data
WHERE transaction_id IS NOT NULL