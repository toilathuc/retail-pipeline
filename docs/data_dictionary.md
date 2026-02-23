# 02. Data Dictionary

The source database consists of 23 tables, which can be logically grouped into 4 main business areas:

## 1. Sales & Transactions

- `sales_transactions`: Header info for checkout events (customer, store, employee, total amount).
- `sales_items`: Line-item details per transaction (product, quantity, price, discount, tax).
- `payments`: Payment methods and status.
- `returns`: Items returned by customers and reasons.

## 2. Entities (Master Data)

- `customers`: Customer demographics and loyalty program references.
- `products`: Product catalogs with links to categories, brands, and suppliers.
- `stores` & `employees`: Physical locations and staff hierarchy.
- `categories`, `brands`, `suppliers`: Product metadata.

## 3. Inventory & Supply Chain

- `inventory`: Real-time stock counts per store and product.
- `stock_movements`: Log of inventory changes (In/Out).
- `purchase_orders` & `shipments`: Procurement and restocking activities.

## 4. Operations & Marketing

- `promotions`, `campaigns`: Marketing budgets and timelines.
- `pricing_history`, `discount_rules`, `tax_rules`: Historical pricing and operational rules.
- `customer_feedback`, `store_visits`: Customer engagement metrics.
- `loyalty_programs`: Point conversion configurations.
