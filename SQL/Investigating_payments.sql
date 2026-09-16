SELECT 
  *
FROM `olist.orders`
WHERE order_status = "delivered";

SELECT 
  *
FROM `olist.orders` o
JOIN `olist.total_payments` t
  ON o.order_id = t.order_id;

SELECT
  FORMAT_TIMESTAMP("%Y-%m", o.order_purchase_timestamp) AS yearmonth,
  ROUND(SUM(t.total_paid),2) AS total,
  ROUND(SUM(t.total_paid)/1000) AS total_thousands,
  COUNT(*) AS num_orders,
  ROUND(SUM(t.total_paid)/COUNT(*), 2) AS avg_cost_per_order
FROM `olist.orders` o
JOIN `olist.total_payments` t
  ON o.order_id = t.order_id
GROUP BY yearmonth
ORDER BY yearmonth;

SELECT
  FORMAT_TIMESTAMP("%m", o.order_purchase_timestamp) AS month,
  ROUND(SUM(t.total_paid),2) AS total,
  ROUND(SUM(t.total_paid)/1000) AS total_thousands,
  COUNT(*) AS num_orders,
  ROUND(SUM(t.total_paid)/COUNT(*), 2) AS avg_cost_per_order
FROM `olist.orders` o
JOIN `olist.total_payments` t
  ON o.order_id = t.order_id
GROUP BY month
ORDER BY month;

CREATE VIEW `olist.order_cost_vs_paid` AS
  SELECT c.order_id, c.order_cost, t.total_paid
  FROM (
    SELECT
      i.order_id,
      ROUND(SUM(price + freight_value), 2) AS order_cost
    FROM `olist.order_items` i
    JOIN `olist.products` p
      ON i.product_id = p.product_id
    JOIN `olist.product_category_name_translation` tr
      ON p.product_category_name = tr.product_category_name
    GROUP BY i.order_id
    ORDER BY order_cost DESC
  ) c
  JOIN `olist.total_payments` t
    ON c.order_id = t.order_id
  ORDER BY order_cost DESC;

--order cost is what we expect to be paid. so far investigation has looked at actual payments but not at expected payments.

SELECT
  FORMAT_TIMESTAMP("%Y-%m", o.order_purchase_timestamp) AS yearmonth,
  ROUND(SUM(t.total_paid),2) AS total,
  ROUND(SUM(t.total_paid)/1000) AS total_thousands,
  ROUND(SUM(c.order_cost),2) AS expected_total,
  ROUND(ROUND(SUM(t.total_paid),2) - ROUND(SUM(c.order_cost),2),2) AS outstanding,
  COUNT(*) AS num_orders,
  ROUND(SUM(t.total_paid)/COUNT(*), 2) AS avg_cost_per_order
FROM `olist.orders` o
JOIN `olist.total_payments` t
  ON o.order_id = t.order_id
JOIN `olist.order_cost_vs_paid` c
  ON o.order_id = c.order_id
GROUP BY yearmonth
ORDER BY yearmonth;

SELECT
  FORMAT_TIMESTAMP("%m", o.order_purchase_timestamp) AS month,
  ROUND(SUM(t.total_paid),2) AS total,
  ROUND(SUM(t.total_paid)/1000) AS total_thousands,
  ROUND(SUM(c.order_cost),2) AS expected_total,
  ROUND(ROUND(SUM(t.total_paid),2) - ROUND(SUM(c.order_cost),2),2) AS outstanding,
  COUNT(*) AS num_orders,
  ROUND(AVG(c.order_cost), 2) AS avg_cost_per_order
FROM `olist.orders` o
JOIN `olist.total_payments` t
  ON o.order_id = t.order_id
JOIN `olist.order_cost_vs_paid` c
  ON o.order_id = c.order_id
GROUP BY month
ORDER BY month;

SELECT
    tr.product_category_name_english,
    ROUND(SUM(price + freight_value), 2) AS total_cost,
    COUNT(*) AS num_items,
    ROUND(AVG(price + freight_value), 2) AS avg_cost_per_item
FROM `olist.order_items` i
JOIN `olist.products` p
  ON i.product_id = p.product_id
JOIN `olist.product_category_name_translation` tr
  ON p.product_category_name = tr.product_category_name
GROUP BY tr.product_category_name_english
ORDER BY total_cost DESC
--total cost of products sold by category
