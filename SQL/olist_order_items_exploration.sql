SELECT 
  *
FROM `olist.order_items`
ORDER BY order_id, order_item_id;

SELECT
  order_id,
  COUNT(*) AS num_items
FROM `olist.order_items`
GROUP BY order_id
ORDER BY num_items DESC;

SELECT
  num_items,
  COUNT(*) AS num_orders
FROM (
  SELECT
  order_id,
  COUNT(*) AS num_items
FROM `olist.order_items`
GROUP BY order_id
ORDER BY num_items DESC
)
GROUP BY num_items
ORDER BY num_orders DESC;
--most orders only ordered 1 item, should investigate which category/items are ordered in groups


SELECT product_id, price FROM `olist.order_items` LIMIT 1;

SELECT oi.product_id, oi.price, p.*
FROM `olist.order_items` oi
JOIN `olist.products` p
ON oi.product_id = p.product_id
WHERE oi.product_id = (SELECT product_id FROM `olist.order_items` LIMIT 1);
