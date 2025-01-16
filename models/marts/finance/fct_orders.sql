select
  order_id,
  customer_id,
  status,
  amount
from {{ ref('stg_stripe__payments') }}
