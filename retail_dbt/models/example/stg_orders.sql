{{ config(materialized='table') }}

WITH raw_data AS (
    SELECT * FROM {{ source('retail_raw', 'sales_transactions') }}
)

SELECT 
    CAST(transaction_id AS INT) AS transaction_id,
    CAST(customer_id AS INT) AS customer_id,
    CAST(store_id AS INT) AS store_id,
    CAST(employee_id AS INT) AS employee_id,
    CAST(transaction_date AS TIMESTAMP) AS transaction_date,
    CAST(total_amount AS NUMERIC(10,2)) AS total_amount,
    CAST(payment_id AS INT) AS payment_id
FROM raw_data
WHERE transaction_id IS NOT NULL