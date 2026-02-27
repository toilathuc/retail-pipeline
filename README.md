# End-to-End Retail Data Pipeline

This project implements an end-to-end retail analytics pipeline with MySQL (source), PostgreSQL (warehouse), Airflow (orchestration), dbt (transformations), and Power BI (visualization).

## Scope

- Ingest 23 source retail tables from MySQL
- Build Raw, Silver, and Gold layers in PostgreSQL
- Apply data quality logic (valid/invalid split)
- Build Kimball-style Gold models for BI (`fact_sales`, `dim_*`)
- Send Microsoft Teams notifications for pipeline outcomes

## Architecture

- Source: MySQL in Docker (`retail_db`)
- Warehouse: PostgreSQL in Docker (local simulation of AWS RDS PostgreSQL)
- Orchestration: Apache Airflow in Docker
- Transformation: dbt (executed inside Airflow and optionally local CLI)
- Visualization: Power BI

## Main DAGs

- `retail_end_to_end_pipeline` (recommended)
  - Raw ingest -> Silver dbt -> Gold dbt -> DQ evaluation -> Teams notification
- `mysql_to_postgres_raw`
  - Raw ingest only (legacy/fallback)

## Repository Structure

- `dags/`: Airflow DAGs
- `scripts/`: MySQL DDL and CSV loading scripts
- `retail_dbt/`: dbt project
- `retail_data/`: input CSV files
- `docs/`: requirements, mapping, SCD, DQ, runbook, submission guide

## Prerequisites

- Docker Desktop
- Python 3.10 (recommended for local CLI consistency)
- (Optional but recommended) Python 3.10 virtual environment for local dbt CLI
- DBeaver/psql for SQL validation

## Python 3.10 Virtual Environment (Recommended)

Use this when you run dbt locally outside Airflow.

1. Create virtual environment (Windows)

- `py -3.10 -m venv .venv310`

2. Activate virtual environment

- PowerShell: `\.venv310\Scripts\Activate.ps1`
- Git Bash: `source .venv310/Scripts/activate`

3. Upgrade pip and install dependencies

- `python -m pip install --upgrade pip`
- `pip install -r requirements.txt`

4. Optional quick check

- `python -m dbt.cli.main --version`

## Quick Start

1. Start services

- `docker compose up -d --build`

2. Load source data to MySQL

- Windows:
  - `cmd /c "mysql --local-infile=1 -h 127.0.0.1 -P 13306 -u root -proot_pass retail_db < scripts\02_load_data.sql"`

3. Open Airflow

- URL: `http://localhost:8080`

4. Configure Airflow

- Connections:
  - `mysql_source_conn`
  - `postgres_dw_conn`
- Variables:
  - `teams_webhook_url`
  - `dq_fail_threshold` (default recommendation: `0.05`)

5. Trigger pipeline

- DAG: `retail_end_to_end_pipeline`

6. Validate KPI in PostgreSQL

- `SELECT COUNT(DISTINCT transaction_id) AS total_orders, ROUND(SUM(line_total),2) AS total_revenue, ROUND(SUM(line_total)/NULLIF(COUNT(DISTINCT transaction_id),0),2) AS aov FROM silver_gold.fact_sales;`

7. Refresh Power BI

- Confirm dashboard KPIs match SQL results.

## Local dbt CLI (Optional)

If you want to run dbt manually from local machine (instead of only Airflow):

- `Set-Location retail_dbt`
- `E:\FSOFT\.venv310\Scripts\python.exe -m dbt.cli.main run --select stg_orders silver_sales_valid silver_sales_invalid dim_customer dim_date dim_product dim_store fact_sales`
- `E:\FSOFT\.venv310\Scripts\python.exe -m dbt.cli.main test`

## Important Notes

- Raw business fields are preserved as text for traceability.
- Current setup is local PostgreSQL as AWS RDS-compatible simulation.
- `retail_end_to_end_pipeline` sends:
  - `SUCCESS` when invalid ratio <= threshold
  - `DQ_FAILED` when invalid ratio > threshold
  - `FAILED` on runtime errors

## Common Troubleshooting

- Airflow cannot send Teams message:
  - Check `teams_webhook_url` Airflow Variable.
- dbt path/profile issue in DAG:
  - Check Variables `dbt_project_dir` and `dbt_profiles_dir`.
- Data volume unexpectedly increases:
  - Ensure latest DAG code is used (raw load mode uses snapshot `replace`, not `append`).
- DBeaver timezone connection error:
  - Remove invalid timezone properties from driver settings.

## Documentation

- Full docs index: [docs/00_docs_index.md](docs/00_docs_index.md)
