# 06. SCD Specification (Raw/Silver/Gold)

Objective: define one consistent historical tracking mechanism so SCD logic is clear during implementation and demo defense.

## 1) SCD Scope

Apply SCD Type 2 to dimensions where attribute changes must be historically tracked:

- `dim_customer` (source: `customers`)
- `dim_product` (source: `products`)
- `dim_promotion` (source: `promotions`)
- `dim_campaign` (source: `campaigns`)
- `dim_tax_rule` (source: `tax_rules`)
- `bridge_discount_rule` (source: `discount_rules`)

All remaining dimensions can use SCD Type 1 (overwrite), because historical attribute versions are not critical for the main revenue KPIs.

## 2) Standard SCD2 Columns

Each SCD2 table must include:

- Surrogate key: `<table>_sk` (BIGINT, generated)
- Business key: e.g., `customer_id`, `product_id`
- `effective_from` (TIMESTAMP, NOT NULL)
- `effective_to` (TIMESTAMP, nullable; open record = NULL)
- `is_current` (BOOLEAN, NOT NULL)
- `row_hash` (TEXT, NOT NULL), hash of tracked attributes
- `updated_at` (TIMESTAMP, NOT NULL)
- `run_id` (TEXT, NOT NULL)

## 3) Change Detection Rules

1. Read the latest valid records from Silver.
2. Generate `row_hash` from tracked columns.
3. Compare by business key against the current active version (`is_current = true`).
4. If no current record exists, insert a new row (`effective_from = load_time`, `effective_to = NULL`, `is_current = true`).
5. If current record exists and hash is unchanged, do not create a new version.
6. If current record exists and hash changes:
   - Update previous row: `effective_to = load_time - interval '1 second'`, `is_current = false`
   - Insert new current row: `effective_from = load_time`, `effective_to = NULL`, `is_current = true`

## 4) Business Keys and Tracked Columns

### `dim_customer`

- Business key: `customer_id`
- Tracked columns: `name`, `email`, `phone`, `loyalty_program_id`, `gender`, `age`

### `dim_product`

- Business key: `product_id`
- Tracked columns: `name`, `category_id`, `brand_id`, `supplier_id`, `price`, `season`

### `dim_promotion`

- Business key: `promotion_id`
- Tracked columns: `name`, `start_date`, `end_date`

### `dim_campaign`

- Business key: `campaign_id`
- Tracked columns: `name`, `budget`, `start_date`, `end_date`

### `dim_tax_rule`

- Business key: `tax_id`
- Tracked columns: `product_id`, `tax_rate`, `region`

### `bridge_discount_rule`

- Business key: `rule_id`
- Tracked columns: `product_id`, `discount_type`, `value`, `valid_from`, `valid_to`

## 5) dbt Snapshot Recommendation

- Use `strategy='check'` with tracked attributes in `check_cols`.
- Set `unique_key` to the business key.
- Use `updated_at` only when the source has a trusted update timestamp; otherwise, use pipeline load timestamp.

## 6) Audit Queries (Demo Checklist)

- Current active row count:
  - `select count(*) from dim_product where is_current = true;`
- Historical versions of one business key:
  - `select * from dim_product where product_id = <id> order by effective_from;`
- Timeline overlap validation:
  - self-join by business key to ensure no overlapping effective periods.
