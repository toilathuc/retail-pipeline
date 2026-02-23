# 01. Business Requirements and Project Scope

## 1. Project Objective

The company provides retail sales data across 23 source tables (sales, customers, inventory, marketing, and operations). The project objective is to build an end-to-end data pipeline that ingests, transforms, validates, and analyzes this data to generate actionable recommendations for revenue growth.

## 2. Inputs

- Retail source datasets (`.csv` files)
- DDL scripts for source table creation

## 3. Required Platform and Tools

- Source system: MySQL running in Docker
- Data warehouse: PostgreSQL running in Docker as a local simulation of AWS RDS PostgreSQL
- Orchestration and transformation: Apache Airflow + dbt (Dockerized)
- Notifications: MS Teams incoming webhook
- Visualization: Power BI Desktop, Apache Superset, Metabase, or another Docker-compatible BI tool

## 4. Functional Requirements

### 4.1 Source Database Setup

1. Create and run a MySQL container locally.
2. Create all source tables from provided DDL scripts.
3. Load all source data into MySQL.

### 4.2 Data Warehouse Setup

1. Create and run a PostgreSQL container locally.
2. Use PostgreSQL as the analytics warehouse (RDS-equivalent local environment).

### 4.3 Data Pipeline Setup

Pipeline is orchestrated by Airflow and implemented with dbt using Medallion architecture:

- Raw zone:
  - Extract from MySQL and load into PostgreSQL raw schema.
  - Preserve source values exactly as-is.
  - Store all business fields as `TEXT`.
  - Apply SCD where required for historical tracking.

- Silver zone:
  - Clean and type-cast data.
  - Apply data quality rules (including date cutoff checks).
  - Split records into valid and invalid outputs.

- Gold zone:
  - Build dimensional models and analytical marts for BI consumption.

### 4.4 Monitoring and Alerts

Send MS Teams notifications for:

1. Successful job run
2. Failed job run
3. Data quality check failure, including summary metrics

### 4.5 Data Analysis

1. Assess overall data quality of source and transformed datasets.
2. Identify and explain insights that can improve company revenue.
3. Extend transformation from Silver to Gold for reporting and decision support.

### 4.6 Visualization

Build at least one dashboard using one approved tool:

- Power BI Desktop, or
- Open-source alternatives (Superset, Metabase, etc.)

### 4.7 Presentation and Demo

1. Present architecture, pipeline flow, data quality, and insights to trainer panel.
2. Demonstrate end-to-end operation by inserting a new source record and re-running the pipeline to show updates in downstream layers and dashboard outputs.

## 5. Success Criteria

- All 23 source tables are ingested and traceable from Raw to Silver.
- Gold models support revenue analysis use cases.
- Data quality process is auditable and produces valid/invalid outputs.
- Teams alerts are sent for success, failure, and DQ failure scenarios.
- End-to-end demo is reproducible via runbook.
