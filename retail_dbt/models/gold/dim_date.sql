{{ config(materialized='table', schema='gold') }}

WITH date_series AS (
    SELECT generate_series(
        '2020-01-01'::DATE,
        '2030-12-31'::DATE,
        '1 day'::interval
    )::DATE AS date_actual
)
SELECT 
    to_char(date_actual, 'YYYYMMDD')::INT AS date_id,
    date_actual AS full_date,
    EXTRACT(YEAR FROM date_actual) AS year,
    EXTRACT(MONTH FROM date_actual) AS month,
    EXTRACT(DAY FROM date_actual) AS day,
    EXTRACT(QUARTER FROM date_actual) AS quarter,
    to_char(date_actual, 'Day') AS day_of_week
FROM date_series