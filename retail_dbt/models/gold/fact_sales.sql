{{ config(materialized='table', schema='gold') }}

WITH valid_sales AS (
    SELECT CAST(transaction_id AS INT) AS transaction_id
    FROM {{ ref('silver_sales_valid') }}
),
sales_tx AS (
    SELECT
        CAST(transaction_id AS INT) AS transaction_id,
        CAST(customer_id AS INT) AS customer_id,
        CAST(store_id AS INT) AS store_id,
        CAST(transaction_date AS DATE) AS transaction_date,
        CAST(total_amount AS NUMERIC(10,2)) AS total_amount
    FROM {{ source('retail_raw', 'sales_transactions') }}
),
sales_items AS (
    SELECT
        CAST(item_id AS INT) AS item_id,
        CAST(transaction_id AS INT) AS transaction_id,
        CAST(product_id AS INT) AS product_id,
        CAST(quantity AS INT) AS quantity,
        CAST(unit_price AS NUMERIC(10,2)) AS unit_price,
        CAST(discount AS NUMERIC(10,2)) AS discount,
        CAST(tax AS NUMERIC(10,2)) AS tax
    FROM {{ source('retail_raw', 'sales_items') }}
)

SELECT 
    t.transaction_id,
    i.item_id,
    t.customer_id,
    t.store_id,
    i.product_id,
    to_char(t.transaction_date, 'YYYYMMDD')::INT AS date_id,
    i.quantity,
    i.unit_price,
    i.discount,
    i.tax,
    (i.quantity * i.unit_price - i.discount + i.tax) AS line_total,
    t.total_amount AS order_total_amount
FROM valid_sales v
JOIN sales_tx t ON t.transaction_id = v.transaction_id
JOIN sales_items i ON t.transaction_id = i.transaction_id