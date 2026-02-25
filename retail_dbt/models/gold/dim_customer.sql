{{ config(materialized='table', schema='gold') }}

SELECT 
    CAST(customer_id AS INT) AS customer_id,
    name,
    email,
    phone,
    CAST(loyalty_program_id AS INT) AS loyalty_program_id,
    gender,
    CAST(age AS INT) AS age,
    CAST(created_at AS DATE) AS created_at
FROM {{ source('retail_raw', 'customers') }}