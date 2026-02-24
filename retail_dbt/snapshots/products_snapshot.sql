{% snapshot products_snapshot %}

{{
    config(
      target_schema='silver',
      unique_key='product_id',
      strategy='check',
      check_cols=['price'],
    )
}}

select * from {{ source('retail_raw', 'products') }}

{% endsnapshot %}