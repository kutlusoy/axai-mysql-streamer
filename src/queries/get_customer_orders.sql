-- ------------------------------------------------------------
-- Name: get_customer_orders
-- Description: Returns all orders for a given customer within a date range.
-- Parameters:
--   1️⃣  customer_id   (INT)  – The primary‑key of the customer.
--   2️⃣  start_date    (DATE) – Beginning of the period (inclusive).
--   3️⃣  end_date      (DATE) – End of the period (inclusive).
-- ------------------------------------------------------------

SELECT
    o.id               AS order_id,
    o.order_date,
    o.total_amount,
    p.id               AS product_id,
    p.name             AS product_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
JOIN order_items AS oi   ON oi.order_id = o.id
JOIN products AS p       ON p.id = oi.product_id
WHERE o.customer_id = {{customer_id}}
  AND o.order_date BETWEEN {{start_date}} AND {{end_date}}
ORDER BY o.order_date DESC;
