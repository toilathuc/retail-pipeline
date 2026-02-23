# 08. Demo Runbook: End-to-End Pipeline

Objective: prove that the full pipeline works from Source -> Raw -> Silver -> Gold and sends the expected MS Teams notifications.

## 1) Preconditions

- Docker services are running: MySQL, PostgreSQL (DWH/RDS local simulation), Airflow, and dbt runtime.
- Airflow connections are configured:
  - `mysql_source`
  - `postgres_dwh`
  - `teams_webhook`
- Initial seed data has been loaded for all 23 source tables.

## 2) Demo Scenario

Insert one new sales transaction in the source system and verify downstream KPI updates.

### Step A: Insert source records (MySQL)

1. Insert one record into `sales_transactions`.
2. Insert matching line item records into `sales_items`.
3. Optional: insert one `customer_feedback` record to show a non-sales data stream.

Record the new `transaction_id` for traceability.

### Step B: Trigger pipeline

- Open Airflow UI and trigger DAG `retail_end_to_end_pipeline`.
- Wait for completion of the key tasks:
  - `ingest_mysql_to_raw`
  - `run_silver_transforms`
  - `run_dq_checks`
  - `run_gold_models`
  - `notify_teams`

### Step C: Validate each zone

#### C1. Raw validation

- Verify the new records exist in `raw_sales_transactions` and `raw_sales_items`.
- Confirm all data columns remain `TEXT` in raw tables.

#### C2. Silver validation

- Verify records are present in `silver_sales_transactions` and `silver_sales_items`.
- Verify records do not appear in `_invalid` unless intentionally testing DQ failure.

#### C3. Gold validation

- Verify records appear in `fact_sales` (line-item grain).
- Compare KPIs before and after insertion:
  - total net revenue
  - transaction count
  - average basket value

## 3) MS Teams Notification Checklist

Capture evidence for three alert scenarios:

1. `SUCCESS`: DAG run completed successfully.
2. `FAILED`: intentionally fail one task (for example, temporary bad connection) to test failure notification.
3. `DQ_FAILED`: insert an invalid record (for example, `quantity = -1`) to trigger DQ summary notification.

## 4) Suggested SQL Verification Snippets

- Trace the inserted transaction:
  - `select * from raw_sales_transactions where transaction_id = <id>;`
  - `select * from silver_sales_transactions where transaction_id = <id>;`
  - `select * from fact_sales where transaction_id = <id>;`

- Validate DQ routing:
  - `select * from silver_sales_items_invalid where transaction_id = <id>;`
  - `select * from dq_run_summary order by run_id desc, table_name;`

## 5) Demo Evidence Pack (for trainer)

Prepare one evidence folder containing:

- screenshot of Airflow DAG graph with task statuses
- screenshot of SQL checks for Raw/Silver/Gold
- screenshot of MS Teams messages (`SUCCESS`, `FAILED`, `DQ_FAILED`)
- dashboard screenshots before and after inserting the new record

## 6) Pass Criteria

The demo is considered successful when:

- new source data flows correctly across all three zones
- DQ rules correctly separate valid and invalid records
- MS Teams receives correct alert type for each test case
- dashboard KPIs reflect the inserted record as expected
