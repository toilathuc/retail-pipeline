# 05. Table Mapping: Source -> Raw -> Silver -> Gold

Objective: ensure all 23 source tables have a clear, traceable path across all Medallion layers for implementation and demo.

## Naming Convention

- Raw: `raw_<source_table>` (all columns stored as `TEXT`)
- Silver valid: `silver_<source_table>`
- Silver invalid: `silver_<source_table>_invalid`
- Gold: `fact_*`, `dim_*`, `bridge_*` (only when needed for analytics and BI)

## Mapping Matrix (23 Source Tables)

| #   | Source Table       | Raw Table              | Silver Valid              | Silver Invalid                    | Gold Target                      | Load Type   | SCD  |
| --- | ------------------ | ---------------------- | ------------------------- | --------------------------------- | -------------------------------- | ----------- | ---- |
| 1   | customers          | raw_customers          | silver_customers          | silver_customers_invalid          | dim_customer                     | incremental | SCD2 |
| 2   | stores             | raw_stores             | silver_stores             | silver_stores_invalid             | dim_store                        | incremental | SCD1 |
| 3   | employees          | raw_employees          | silver_employees          | silver_employees_invalid          | dim_employee                     | incremental | SCD1 |
| 4   | products           | raw_products           | silver_products           | silver_products_invalid           | dim_product                      | incremental | SCD2 |
| 5   | categories         | raw_categories         | silver_categories         | silver_categories_invalid         | dim_category                     | full        | SCD1 |
| 6   | brands             | raw_brands             | silver_brands             | silver_brands_invalid             | dim_brand                        | full        | SCD1 |
| 7   | suppliers          | raw_suppliers          | silver_suppliers          | silver_suppliers_invalid          | dim_supplier                     | incremental | SCD1 |
| 8   | loyalty_programs   | raw_loyalty_programs   | silver_loyalty_programs   | silver_loyalty_programs_invalid   | dim_loyalty_program              | full        | SCD1 |
| 9   | sales_transactions | raw_sales_transactions | silver_sales_transactions | silver_sales_transactions_invalid | fact_sales (header contribution) | incremental | N/A  |
| 10  | sales_items        | raw_sales_items        | silver_sales_items        | silver_sales_items_invalid        | fact_sales (line-level grain)    | incremental | N/A  |
| 11  | payments           | raw_payments           | silver_payments           | silver_payments_invalid           | dim_payment_method               | incremental | SCD1 |
| 12  | inventory          | raw_inventory          | silver_inventory          | silver_inventory_invalid          | fact_inventory_snapshot          | incremental | N/A  |
| 13  | stock_movements    | raw_stock_movements    | silver_stock_movements    | silver_stock_movements_invalid    | fact_stock_movement              | incremental | N/A  |
| 14  | purchase_orders    | raw_purchase_orders    | silver_purchase_orders    | silver_purchase_orders_invalid    | fact_purchase_order              | incremental | N/A  |
| 15  | shipments          | raw_shipments          | silver_shipments          | silver_shipments_invalid          | fact_shipment                    | incremental | N/A  |
| 16  | returns            | raw_returns            | silver_returns            | silver_returns_invalid            | fact_returns                     | incremental | N/A  |
| 17  | promotions         | raw_promotions         | silver_promotions         | silver_promotions_invalid         | dim_promotion                    | incremental | SCD2 |
| 18  | campaigns          | raw_campaigns          | silver_campaigns          | silver_campaigns_invalid          | dim_campaign                     | incremental | SCD2 |
| 19  | customer_feedback  | raw_customer_feedback  | silver_customer_feedback  | silver_customer_feedback_invalid  | fact_feedback                    | incremental | N/A  |
| 20  | store_visits       | raw_store_visits       | silver_store_visits       | silver_store_visits_invalid       | fact_store_visit                 | incremental | N/A  |
| 21  | pricing_history    | raw_pricing_history    | silver_pricing_history    | silver_pricing_history_invalid    | bridge_product_price_history     | incremental | N/A  |
| 22  | discount_rules     | raw_discount_rules     | silver_discount_rules     | silver_discount_rules_invalid     | bridge_discount_rule             | incremental | SCD2 |
| 23  | tax_rules          | raw_tax_rules          | silver_tax_rules          | silver_tax_rules_invalid          | dim_tax_rule                     | incremental | SCD2 |

## Implementation Notes

1. Raw layer performs no type casting and no data normalization; it only appends technical metadata such as `ingested_at`, `run_id`, and `source_table`.
2. Silver layer performs casting and data quality validation; invalid records always include `error_code`, `error_detail`, `failed_at`, and `run_id`.
3. Gold layer should prioritize revenue analytics first: `fact_sales`, `dim_customer`, `dim_product`, `dim_store`, and `dim_date`.
4. Additional gold marts can be delivered in phase 2 after the end-to-end MVP demo passes.
