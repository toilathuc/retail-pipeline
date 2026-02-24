USE retail_db;

-- =========================================================
-- NOTE:
-- 1) This script expects CSV files from the retail_data folder.
-- 2) If you run from host using mysql client, enable LOCAL INFILE:
--      mysql --local-infile=1 -u root -p < scripts/02_load_data.sql
-- 3) If you run inside Docker, make sure retail_data is mounted and
--    update the path below if needed.
-- =========================================================

SET FOREIGN_KEY_CHECKS = 0;

-- 1) Reference/master tables first
LOAD DATA LOCAL INFILE './retail_data/brands.csv'
INTO TABLE brands
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/suppliers.csv'
INTO TABLE suppliers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/loyalty_programs.csv'
INTO TABLE loyalty_programs
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/campaigns.csv'
INTO TABLE campaigns
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/promotions.csv'
INTO TABLE promotions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 2) Dependent dimensions
LOAD DATA LOCAL INFILE './retail_data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/tax_rules.csv'
INTO TABLE tax_rules
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/discount_rules.csv'
INTO TABLE discount_rules
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/pricing_history.csv'
INTO TABLE pricing_history
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 3) Facts and transactional tables
LOAD DATA LOCAL INFILE './retail_data/purchase_orders.csv'
INTO TABLE purchase_orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/shipments.csv'
INTO TABLE shipments
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/sales_transactions.csv'
INTO TABLE sales_transactions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/sales_items.csv'
INTO TABLE sales_items
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/returns.csv'
INTO TABLE returns
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/inventory.csv'
INTO TABLE inventory
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/stock_movements.csv'
INTO TABLE stock_movements
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/store_visits.csv'
INTO TABLE store_visits
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE './retail_data/customer_feedback.csv'
INTO TABLE customer_feedback
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SET FOREIGN_KEY_CHECKS = 1;

-- Optional quick sanity checks
SELECT 'brands' AS table_name, COUNT(*) AS row_count FROM brands
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'loyalty_programs', COUNT(*) FROM loyalty_programs
UNION ALL SELECT 'stores', COUNT(*) FROM stores
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL SELECT 'promotions', COUNT(*) FROM promotions
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'tax_rules', COUNT(*) FROM tax_rules
UNION ALL SELECT 'discount_rules', COUNT(*) FROM discount_rules
UNION ALL SELECT 'pricing_history', COUNT(*) FROM pricing_history
UNION ALL SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL SELECT 'sales_transactions', COUNT(*) FROM sales_transactions
UNION ALL SELECT 'sales_items', COUNT(*) FROM sales_items
UNION ALL SELECT 'returns', COUNT(*) FROM returns
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'stock_movements', COUNT(*) FROM stock_movements
UNION ALL SELECT 'store_visits', COUNT(*) FROM store_visits
UNION ALL SELECT 'customer_feedback', COUNT(*) FROM customer_feedback;
