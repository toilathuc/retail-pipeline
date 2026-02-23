# 03. Data Quality and SCD Strategy

This document defines the baseline strategy for historical tracking (SCD) and data quality checks in the Silver layer.

## 1. SCD Type 2 Strategy

SCD Type 2 is applied to entities where attribute changes should be historically tracked for analytics:

- `products`: track changes to `price`, `category_id`, `brand_id`, and `supplier_id`
- `customers`: track changes to `loyalty_program_id` and profile attributes

Implementation options:

- dbt snapshots (recommended for maintainability)
- SQL merge/upsert logic orchestrated by Airflow

Detailed implementation specifications are documented in `scd_specification.md`.

## 2. Silver-Layer Data Quality Rules

During Raw -> Silver transformation, each table is validated and records are split into valid and invalid outputs.

### A. Format and Type Casting

- All Raw fields (`TEXT`) must successfully cast to target types (`INT`, `DECIMAL`, `DATE`, etc.).
- Any cast failure is routed to the corresponding `_invalid` table.

### B. Business Validation Rules

1. Date cutoff validation:
   - Date fields such as `created_at`, `transaction_date`, and `visit_date` must not be in the future (`<= current_date`).
2. Numeric constraints:
   - `sales_items.quantity > 0`
   - `products.price >= 0`
   - `sales_transactions.total_amount >= 0`
3. Referential integrity checks:
   - Example: `sales_transactions.customer_id` must exist in `customers`.

### C. Routing Rules

- Valid output: `silver_<table_name>`
- Invalid output: `silver_<table_name>_invalid`

Each invalid record should include at least:

- `error_code`
- `error_detail`
- `failed_at`
- `run_id`

The complete rule catalog by table is documented in `dq_rule_catalog.md`.
