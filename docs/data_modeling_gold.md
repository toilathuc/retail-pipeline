# 04. Gold Zone Dimensional Modeling (Star Schema)

To fulfill the requirement of "uncovering insights to improve company revenue", the Gold zone is modeled using the Kimball Star Schema approach. This optimizes query performance for BI tools (PowerBI/Superset).

## Core Business Process: Sales Revenue

**Granularity:** One row per item sold in a transaction.

### 1. Fact Table: `fact_sales`

Combines valid data from `sales_transactions` and `sales_items`.

- **Primary Keys:** `transaction_id`, `item_id`
- **Foreign Keys:** `customer_key`, `store_key`, `product_key`, `employee_key`, `date_key`
- **Measures:** `quantity`, `unit_price`, `discount_amount`, `tax_amount`, `net_revenue` (calculated as `quantity * unit_price - discount_amount`).

### 2. Dimension Tables

- **`dim_customer`:** Derived from `customers` and `loyalty_programs`. Includes demographic segments.
- **`dim_product`:** Derived from `products`, `categories`, `brands`. Contains historical price attributes (from SCD).
- **`dim_store`:** Derived from `stores`. Used for location-based revenue analysis.
- **`dim_date`:** Auto-generated calendar table to analyze revenue trends over time (Year, Quarter, Month, Week, Seasonality).

## Key Analytical Questions Supported

1. Which products/categories generate the highest net revenue?
2. How do loyalty programs impact total customer spend?
3. Which stores underperform during specific seasons?
