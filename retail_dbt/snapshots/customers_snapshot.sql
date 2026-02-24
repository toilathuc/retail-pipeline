{% snapshot customers_snapshot %}

{{
    config(
      target_schema='silver',
      unique_key='customer_id',
      strategy='check',
      check_cols=['loyalty_program_id'],
    )
}}

select * from {{ source('retail_raw', 'customers') }}

{% endsnapshot %}