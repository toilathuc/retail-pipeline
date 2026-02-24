# retail_dbt

dbt project for Silver and Gold transformations in the retail analytics pipeline.

## Profile

- profile name: retail_dbt
- default target: dev
- expected warehouse database: data_warehouse

## Current Source Mapping

- source name: retail_raw
- schema: raw
- tables used now:
  - products
  - customers
  - sales_transactions

## Current Model

- model: stg_orders
- source table: raw.sales_transactions
- output table: silver.stg_orders

## Run Commands

- Run selected model:
  E:\FSOFT\.venv310\Scripts\python.exe -m dbt.cli.main run --project-dir E:\FSOFT\retail_dbt --profiles-dir C:\Users\ADMIN\.dbt --select stg_orders

- Test selected model:
  E:\FSOFT\.venv310\Scripts\python.exe -m dbt.cli.main test --project-dir E:\FSOFT\retail_dbt --profiles-dir C:\Users\ADMIN\.dbt --select stg_orders

- Run snapshots:
  E:\FSOFT\.venv310\Scripts\python.exe -m dbt.cli.main snapshot --project-dir E:\FSOFT\retail_dbt --profiles-dir C:\Users\ADMIN\.dbt

## Notes

- Keep runtime artifacts out of git:
  - target/
  - dbt_packages/
  - logs/
- If dbt cannot find profiles, pass --profiles-dir explicitly.
