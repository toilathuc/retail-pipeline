# End-to-End Retail Data Pipeline

This repository contains a local end-to-end data pipeline for retail analytics using MySQL, PostgreSQL, Airflow, and dbt.

## Project Goal

- Ingest 23 retail source tables from MySQL
- Build Raw, Silver, and Gold layers in PostgreSQL
- Apply data quality checks and SCD logic
- Prepare analytics-ready models for dashboarding and demo

## Architecture

- Source database: MySQL in Docker
- Warehouse: PostgreSQL in Docker (local simulation of AWS RDS PostgreSQL)
- Orchestration: Apache Airflow
- Transformations and testing: dbt
- Visualization: Power BI, Superset, or Metabase

## Repository Structure

- docs: requirements, mapping, SCD, DQ, and demo runbook
- scripts: DDL and source data loading SQL scripts
- dags: Airflow DAGs for ingestion and orchestration
- retail_dbt: dbt project for Silver and Gold transformations
- retail_data: source CSV files

## Prerequisites

- Docker Desktop
- Python 3.10 virtual environment (optional for local dbt CLI)
- DBeaver or psql (optional for validation)

## Local Setup

1. Start infrastructure

- Command: docker compose up -d

2. Service endpoints

- Airflow UI: http://localhost:8080
- MySQL source (host): localhost:13306
- PostgreSQL warehouse (host): localhost:5432

3. Load source data to MySQL

- Command (Windows):
  cmd /c "mysql --local-infile=1 -h 127.0.0.1 -P 13306 -u root -proot_pass retail_db < scripts\02_load_data.sql"

4. Run Raw ingestion DAG

- DAG name: mysql_to_postgres_raw
- Expected output: raw schema tables populated in PostgreSQL

5. Run dbt model and tests

- Command:
  E:\FSOFT\.venv310\Scripts\python.exe -m dbt.cli.main run --project-dir E:\FSOFT\retail_dbt --profiles-dir C:\Users\ADMIN\.dbt --select stg_orders
- Command:
  E:\FSOFT\.venv310\Scripts\python.exe -m dbt.cli.main test --project-dir E:\FSOFT\retail_dbt --profiles-dir C:\Users\ADMIN\.dbt --select stg_orders

## Key Notes

- Raw layer stores source business fields as text for traceability.
- In Docker network, Airflow connections should use service names:
  - MySQL host: retail_mysql_source
  - PostgreSQL host: retail_postgres_dw
- Host ports are used only by local tools (DBeaver, local CLI):
  - MySQL 13306, PostgreSQL 5432

## Common Troubleshooting

- dbt profile issue:
  ensure dbt uses the correct profile directory with --profiles-dir
- DBeaver PostgreSQL connection fails with timezone error:
  remove invalid timezone options such as Asia/Saigon from driver/connection properties
- Airflow task shows success but Rows: 0:
  source MySQL table is empty or source data load step has not run yet

## Documentation

- See [docs/00_docs_index.md](docs/00_docs_index.md) for the complete documentation map.
