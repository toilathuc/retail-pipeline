from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.models import Variable
from datetime import datetime, timedelta
import pandas as pd
import requests

TABLES = [
    "brands",
    "categories",
    "suppliers",
    "loyalty_programs",
    "stores",
    "payments",
    "campaigns",
    "promotions",
    "customers",
    "employees",
    "products",
    "tax_rules",
    "discount_rules",
    "pricing_history",
    "purchase_orders",
    "shipments",
    "sales_transactions",
    "sales_items",
    "returns",
    "inventory",
    "stock_movements",
    "store_visits",
    "customer_feedback",
]
default_args = {
    "owner": "airflow",
    "start_date": datetime(2025, 6, 1),
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


def etl_table_to_raw(table_name, **kwargs):
    # Get metadata for from Airflow context
    run_id = kwargs.get("run_id", "manual_run")
    ingested_at = pd.Timestamp.utcnow()

    # Extract: Connect to MYSQL and read the entire table into a DataFrame
    mysql_hook = MySqlHook(mysql_conn_id="mysql_source_conn")
    df = mysql_hook.get_pandas_df(f"SELECT * FROM {table_name}")

    # Transform: Handle NULL and stringify
    df = df.where(pd.notnull(df), None)
    for col in df.columns:
        df[col] = df[col].apply(lambda x: str(x) if x is not None else None)

    # Add metadata columns
    df["_run_id"] = run_id
    df["_ingested_at"] = ingested_at
    df["_source_table"] = table_name

    # Load data into PostgreSQL
    pg_hook = PostgresHook(postgres_conn_id="postgres_dw_conn")
    engine = pg_hook.get_sqlalchemy_engine()
    # Create table if not exists
    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=1000,
    )

    print(f"ETL for {table_name} completed. Rows: {len(df)}. Run_ID: {run_id}")


def send_teams_report(**context):
    pg_hook = PostgresHook(postgres_conn_id="postgres_dw_conn")

    invalid_count = pg_hook.get_first(
        "SELECT COUNT(*) FROM silver.silver_sales_invalid"
    )[0]

    orders, revenue = pg_hook.get_first(
        """
        SELECT
            COUNT(DISTINCT transaction_id) AS total_orders,
            COALESCE(SUM(line_total), 0) AS total_revenue
        FROM gold.fact_sales
        """
    )

    status = (
        "✅ DQ PASS" if invalid_count == 0 else f"⚠️ DQ FAIL ({invalid_count} errors)"
    )
    color = "00FF00" if invalid_count == 0 else "FF0000"

    message = {
        "@type": "MessageCard",
        "themeColor": color,
        "title": f"Báo cáo Pipeline: {status}",
        "text": (
            f"**Run ID:** {context['run_id']}<br>"
            f"**Total Orders:** {orders}<br>"
            f"**Total Revenue:** {revenue:,.0f} VNĐ<br>"
            f"**Invalid Count:** {invalid_count}"
        ),
    }

    webhook_url = Variable.get("teams_webhook_url", default_var=None)
    if not webhook_url:
        raise ValueError("Missing Airflow Variable 'teams_webhook_url'")

    response = requests.post(webhook_url, json=message, timeout=15)
    response.raise_for_status()

    print("Teams alert sent successfully")


with DAG(
    dag_id="mysql_to_postgres_raw",
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=["retail", "raw_layer"],
) as dag:

    def create_schema():
        pg_hook = PostgresHook(postgres_conn_id="postgres_dw_conn")
        pg_hook.run("CREATE SCHEMA IF NOT EXISTS raw;")

    task_create_schema = PythonOperator(
        task_id="create_raw_schema", python_callable=create_schema
    )

    teams_alert_task = PythonOperator(
        task_id="send_teams_alert",
        python_callable=send_teams_report,
    )

    load_tasks = []

    for table in TABLES:
        task_load = PythonOperator(
            task_id=f"load_{table}_to_raw",
            python_callable=etl_table_to_raw,
            op_kwargs={"table_name": table},
        )
        task_create_schema >> task_load
        load_tasks.append(task_load)

    for task_load in load_tasks:
        task_load >> teams_alert_task
