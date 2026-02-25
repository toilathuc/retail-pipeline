{{ config(materialized='table', schema='silver') }}

-- Capture records that fail business rules (non-positive quantity or future date)
WITH tx AS (
    SELECT
        CAST(transaction_id AS INT) AS transaction_id,
        CAST(customer_id AS INT) AS customer_id,
        CAST(store_id AS INT) AS store_id,
        CAST(transaction_date AS DATE) AS transaction_date,
        CAST(total_amount AS DECIMAL(10,2)) AS total_amount
    FROM {{ source('retail_raw', 'sales_transactions') }}
),
item_qty AS (
    SELECT
        CAST(transaction_id AS INT) AS transaction_id,
        SUM(CAST(quantity AS INT)) AS total_quantity
    FROM {{ source('retail_raw', 'sales_items') }}
    GROUP BY CAST(transaction_id AS INT)
),
joined AS (
    SELECT
        tx.transaction_id,
        tx.customer_id,
        tx.store_id,
        tx.transaction_date,
        COALESCE(item_qty.total_quantity, 0) AS quantity,
        tx.total_amount
    FROM tx
    LEFT JOIN item_qty ON item_qty.transaction_id = tx.transaction_id
)

SELECT *
FROM joined
WHERE quantity <= 0
   OR transaction_date > CURRENT_DATE
