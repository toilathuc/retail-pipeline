# 07. Data Quality Rule Catalog (Silver Zone)

Objective: define complete DQ rules for all source tables so records are split into `valid` and `invalid` datasets and summarized for MS Teams alerts.

## 1) Standard Error Codes

- `DQ_NULL_KEY`: missing primary key or required business key
- `DQ_CAST_FAIL`: failed cast from `TEXT` to target data type
- `DQ_RANGE_FAIL`: out-of-range numeric value or invalid domain value
- `DQ_DATE_FAIL`: invalid date logic (future date, start date after end date)
- `DQ_REF_FAIL`: failed logical referential check against parent table

## 2) Invalid Record Schema

Every `_invalid` table must include the following audit fields:

- `error_code`
- `error_detail`
- `failed_at`
- `run_id`
- `source_table`

## 3) Table-Level Rules

| Table              | Key/Null Rule                 | Cast Rule                                                                 | Range/Domain Rule                                              | Referential Rule                                                     |
| ------------------ | ----------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------------------------- |
| customers          | `customer_id` not null        | `customer_id, loyalty_program_id, age, created_at` cast successfully      | `age` between 0 and 120                                        | `loyalty_program_id` exists in `loyalty_programs`                    |
| stores             | `store_id` not null           | `store_id, manager_id` cast successfully                                  | `name` and `location` not empty                                | manager validation optional in phase 2                               |
| employees          | `employee_id` not null        | `employee_id, store_id` cast successfully                                 | `role` in allowed role list                                    | `store_id` exists in `stores`                                        |
| products           | `product_id` not null         | `category_id, brand_id, supplier_id, price, created_at` cast successfully | `price >= 0`                                                   | foreign keys exist in `categories`, `brands`, `suppliers`            |
| categories         | `category_id` not null        | `category_id` cast successfully                                           | `name` not empty                                               | N/A                                                                  |
| brands             | `brand_id` not null           | `brand_id` cast successfully                                              | `name` not empty                                               | N/A                                                                  |
| suppliers          | `supplier_id` not null        | `supplier_id` cast successfully                                           | `name` not empty                                               | N/A                                                                  |
| loyalty_programs   | `loyalty_program_id` not null | `points_per_dollar` cast successfully                                     | `points_per_dollar >= 0`                                       | N/A                                                                  |
| sales_transactions | `transaction_id` not null     | IDs, date, and amount cast successfully                                   | `total_amount >= 0`, `transaction_date <= current_date`        | foreign keys exist in `customers`, `stores`, `employees`, `payments` |
| sales_items        | `item_id` not null            | IDs, quantity, price, discount, tax cast successfully                     | `quantity > 0`, `unit_price >= 0`, `discount >= 0`, `tax >= 0` | foreign keys exist in `sales_transactions`, `products`               |
| payments           | `payment_id` not null         | `payment_id, paid_at` cast successfully                                   | `status` in (`paid`, `pending`, `failed`, `refunded`)          | N/A                                                                  |
| inventory          | `inventory_id` not null       | IDs, quantity, and date cast successfully                                 | `quantity >= 0`, `last_updated <= current_date`                | foreign keys exist in `stores`, `products`                           |
| stock_movements    | `movement_id` not null        | IDs, quantity, and date cast successfully                                 | `movement_type` in (`IN`, `OUT`, `ADJUSTMENT`), `quantity > 0` | foreign keys exist in `products`, `stores`                           |
| purchase_orders    | `order_id` not null           | IDs and date cast successfully                                            | `status` in allowed status list                                | `supplier_id` exists in `suppliers`                                  |
| shipments          | `shipment_id` not null        | IDs and date cast successfully                                            | `received_date >= shipped_date`                                | foreign keys exist in `purchase_orders`, `stores`                    |
| returns            | `return_id` not null          | IDs and date cast successfully                                            | `return_date <= current_date`                                  | `item_id` exists in `sales_items`                                    |
| promotions         | `promotion_id` not null       | IDs and date cast successfully                                            | `start_date <= end_date`                                       | N/A                                                                  |
| campaigns          | `campaign_id` not null        | IDs, budget, and date cast successfully                                   | `budget >= 0`, `start_date <= end_date`                        | N/A                                                                  |
| customer_feedback  | `feedback_id` not null        | IDs, rating, and date cast successfully                                   | `rating` numeric and between 1 and 5                           | foreign keys exist in `customers`, `stores`, `products`              |
| store_visits       | `visit_id` not null           | IDs and date cast successfully                                            | `visit_date <= current_date`                                   | foreign keys exist in `customers`, `stores`                          |
| pricing_history    | `history_id` not null         | IDs, price, and date cast successfully                                    | `price >= 0`, `effective_date <= current_date`                 | `product_id` exists in `products`                                    |
| discount_rules     | `rule_id` not null            | IDs, value, and date cast successfully                                    | `value >= 0`, `valid_from <= valid_to`                         | `product_id` exists in `products`                                    |
| tax_rules          | `tax_id` not null             | IDs and `tax_rate` cast successfully                                      | `tax_rate` parseable and between 0 and 100                     | `product_id` exists in `products`                                    |

## 4) Data Quality Summary for Teams Alerts

Create `dq_run_summary` for each pipeline run:

- `run_id`
- `table_name`
- `total_rows`
- `valid_rows`
- `invalid_rows`
- `invalid_ratio`
- `top_error_codes`
- `status` (`PASS` / `FAIL`)

Trigger a `DQ_FAILED` notification when:

- any table has `invalid_ratio > 0.05`, or
- `DQ_REF_FAIL` exceeds an absolute threshold (for example, > 100 rows).
