from datetime import datetime, timedelta
import subprocess

import pandas as pd
import requests
from airflow import DAG
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.utils.trigger_rule import TriggerRule

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

DEFAULT_ARGS = {
    "owner": "airflow",
    "start_date": datetime(2025, 6, 1),
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


def _teams_webhook():
    return Variable.get("teams_webhook_url", default_var=None)


def _post_to_teams(message):
    webhook_url = _teams_webhook()
    if not webhook_url:
        raise ValueError("Missing Airflow Variable 'teams_webhook_url'")
    response = requests.post(webhook_url, json=message, timeout=15)
    response.raise_for_status()


def notify_failure(context):
    webhook_url = _teams_webhook()
    if not webhook_url:
        return

    task_instance = context.get("task_instance")
    exception = context.get("exception")

    message = {
        "@type": "MessageCard",
        "themeColor": "FF0000",
        "title": "Pipeline Status: FAILED",
        "text": (
            f"**DAG:** {context.get('dag').dag_id}<br>"
            f"**Run ID:** {context.get('run_id')}<br>"
            f"**Task:** {task_instance.task_id if task_instance else 'unknown'}<br>"
            f"**Error:** {str(exception) if exception else 'Unknown error'}"
        ),
    }
    response = requests.post(webhook_url, json=message, timeout=15)
    response.raise_for_status()


def create_raw_schema():
    pg_hook = PostgresHook(postgres_conn_id="postgres_dw_conn")
    pg_hook.run("CREATE SCHEMA IF NOT EXISTS raw;")


def etl_table_to_raw(table_name, **kwargs):
    run_id = kwargs.get("run_id", "manual_run")
    ingested_at = pd.Timestamp.utcnow()

    mysql_hook = MySqlHook(mysql_conn_id="mysql_source_conn")
    df = mysql_hook.get_pandas_df(f"SELECT * FROM {table_name}")

    df = df.where(pd.notnull(df), None)
    for col in df.columns:
        df[col] = df[col].apply(lambda value: str(value) if value is not None else None)

    df["_run_id"] = run_id
    df["_ingested_at"] = ingested_at
    df["_source_table"] = table_name

    pg_hook = PostgresHook(postgres_conn_id="postgres_dw_conn")
    engine = pg_hook.get_sqlalchemy_engine()
    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=1000,
    )


def run_dbt(select_models):
    dbt_python_bin = Variable.get("dbt_python_bin", default_var="python")
    dbt_project_dir = Variable.get("dbt_project_dir", default_var="/opt/airflow/retail_dbt")
    dbt_profiles_dir = Variable.get(
        "dbt_profiles_dir", default_var="/opt/airflow/retail_dbt/profiles"
    )

    command = [
        dbt_python_bin,
        "-m",
        "dbt.cli.main",
        "run",
        "--project-dir",
        dbt_project_dir,
        "--profiles-dir",
        dbt_profiles_dir,
        "--select",
    ] + select_models

    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(
            "dbt run failed\n"
            f"Command: {' '.join(command)}\n"
            f"STDOUT:\n{result.stdout}\n"
            f"STDERR:\n{result.stderr}"
        )


def run_dbt_silver():
    run_dbt(["stg_orders", "silver_sales_valid", "silver_sales_invalid"])


def run_dbt_gold():
    run_dbt(["dim_customer", "dim_date", "dim_product", "dim_store", "fact_sales"])


def _get_invalid_count(pg_hook):
    candidates = ["silver.silver_sales_invalid", "silver_silver.silver_sales_invalid"]
    for table in candidates:
        try:
            result = pg_hook.get_first(f"SELECT COUNT(*) FROM {table}")
            if result is not None:
                return int(result[0])
        except Exception:
            continue
    raise RuntimeError("Could not find silver_sales_invalid table in expected schemas")


def _get_kpi(pg_hook):
    candidates = ["gold.fact_sales", "silver_gold.fact_sales"]
    for table in candidates:
        try:
            result = pg_hook.get_first(
                f"SELECT COUNT(DISTINCT transaction_id), COALESCE(SUM(line_total),0) FROM {table}"
            )
            if result is not None:
                return int(result[0]), float(result[1])
        except Exception:
            continue
    raise RuntimeError("Could not find fact_sales table in expected schemas")


def _get_valid_count(pg_hook):
    candidates = ["silver.silver_sales_valid", "silver_silver.silver_sales_valid"]
    for table in candidates:
        try:
            result = pg_hook.get_first(f"SELECT COUNT(*) FROM {table}")
            if result is not None:
                return int(result[0])
        except Exception:
            continue
    raise RuntimeError("Could not find silver_sales_valid table in expected schemas")


def send_pipeline_report(**context):
    pg_hook = PostgresHook(postgres_conn_id="postgres_dw_conn")
    valid_count = _get_valid_count(pg_hook)
    invalid_count = _get_invalid_count(pg_hook)
    orders, revenue = _get_kpi(pg_hook)

    total_checked = valid_count + invalid_count
    invalid_ratio = (invalid_count / total_checked) if total_checked > 0 else 0
    dq_fail_threshold = float(Variable.get("dq_fail_threshold", default_var="0.05"))

    if invalid_ratio > dq_fail_threshold:
        status = "DQ_FAILED"
        color = "FFA500"
    else:
        status = "SUCCESS"
        color = "00AA00"

    message = {
        "@type": "MessageCard",
        "themeColor": color,
        "title": f"Pipeline Status: {status}",
        "text": (
            f"**Run ID:** {context['run_id']}<br>"
            f"**Total Orders:** {orders}<br>"
            f"**Total Revenue:** {revenue:,.0f} VNĐ<br>"
            f"**Valid Count:** {valid_count}<br>"
            f"**Invalid Count:** {invalid_count}<br>"
            f"**Invalid Ratio:** {invalid_ratio:.2%}<br>"
            f"**DQ Threshold:** {dq_fail_threshold:.0%}"
        ),
    }
    _post_to_teams(message)


with DAG(
    dag_id="retail_end_to_end_pipeline",
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    catchup=False,
    tags=["retail", "end_to_end"],
    on_failure_callback=notify_failure,
) as dag:
    create_schema = PythonOperator(
        task_id="create_raw_schema",
        python_callable=create_raw_schema,
    )

    load_tasks = []
    for table in TABLES:
        task = PythonOperator(
            task_id=f"load_{table}_to_raw",
            python_callable=etl_table_to_raw,
            op_kwargs={"table_name": table},
        )
        create_schema >> task
        load_tasks.append(task)

    run_silver = PythonOperator(
        task_id="run_silver_transforms",
        python_callable=run_dbt_silver,
    )

    run_gold = PythonOperator(
        task_id="run_gold_models",
        python_callable=run_dbt_gold,
    )

    notify_pipeline_status = PythonOperator(
        task_id="notify_pipeline_status",
        python_callable=send_pipeline_report,
    )

    finish = EmptyOperator(
        task_id="pipeline_finished",
        trigger_rule=TriggerRule.ALL_SUCCESS,
    )

    for task in load_tasks:
        task >> run_silver

    run_silver >> run_gold >> notify_pipeline_status >> finish
