SELECT
  *
FROM `olist.sellers`;

SELECT
  COUNT(*)
FROM `olist.sellers`;

SELECT
  *
FROM `olist.sellers`s
JOIN `olist.order_items` o
  ON s.seller_id = o.seller_id ;

CREATE VIEW `olist.seller_statistics` AS
SELECT
  s.seller_id,
  ROUND(SUM(o.price + o.freight_value), 2) AS total_value_sold,
  COUNT(*) AS total_items_sold,
  COUNT(DISTINCT o.order_id) AS num_unique_orders
FROM `olist.sellers`s
JOIN `olist.order_items` o
  ON s.seller_id = o.seller_id
GROUP BY s.seller_id
ORDER BY 2 DESC,3 DESC,4 DESC;

SELECT * FROM `olist.seller_statistics`;

SELECT
  ROUND(AVG(total_value_sold), 2) AS avg_total_value_sold,
  ROUND(AVG(total_items_sold), 2) AS avg_total_items_sold,
  ROUND(AVG(num_unique_orders), 2) AS avg_unique_orders
FROM `olist.seller_statistics`;

SELECT
  ROUND(AVG(total_value_sold), 2) AS avg_total_value_sold,
  MAX(total_value_sold) AS max_,
  MIN(total_value_sold) AS min_,
  APPROX_QUANTILES(total_value_sold, 2)[OFFSET(1)] AS med,
  APPROX_QUANTILES(total_value_sold, 4)[OFFSET(1)] AS q1,
  APPROX_QUANTILES(total_value_sold, 4)[OFFSET(3)] AS q3,
  APPROX_QUANTILES(total_value_sold, 100)[OFFSET(90)] AS percentile_90
FROM `olist.seller_statistics`;

SELECT 
  FLOOR(total_value_sold/10000)*10000 as bin_floor,
  COUNT(*) as num_instances,
FROM `olist.seller_statistics`
GROUP BY bin_floor
ORDER BY bin_floor;
--almost all sellers have sold less than 10,000

SELECT 
  FLOOR(total_value_sold/100)*100 as bin_floor,
  COUNT(*) as num_instances,
FROM `olist.seller_statistics`
WHERE FLOOR(total_value_sold/100)*100 < 1000
GROUP BY bin_floor
ORDER BY bin_floor;
--these bins show that most sellers are in the lower ranges of total value sold

SELECT
  s.seller_state,
  ROUND(SUM(o.price + o.freight_value), 2) AS total_value_sold,
  ROUND(SUM(o.price + o.freight_value)/1000) AS total_value_sold_thousands,
  COUNT(*) AS total_items_sold,
  COUNT(DISTINCT o.order_id) AS num_unique_orders,
  COUNT(DISTINCT s.seller_id) AS num_unique_sellers
FROM `olist.sellers`s
JOIN `olist.order_items` o
  ON s.seller_id = o.seller_id
GROUP BY s.seller_state
ORDER BY total_value_sold DESC;
-- state SP (Sao Paulo) has sold almost 10x of any other state, the only state to cross 10,000,000
-- only 9 states have sold more than 100,000 of value
-- state BA has managed to sell over 300,000 with only 643 total_items_sold and only 19 sellers

SELECT
  *,
  ROUND(total_value_sold/SUM(total_value_sold) OVER () *100, 2) AS percentage_of_total_value
FROM `olist.seller_statistics`
WHERE seller_id IN (
  SELECT seller_id 
  FROM `olist.sellers` 
  WHERE seller_state = "BA"
  )
ORDER BY total_value_sold DESC;
--it appears that 77% of this states value sold is the result of one seller in particular

SELECT
  seller_id
FROM `olist.seller_statistics`
WHERE seller_id IN (
  SELECT seller_id 
  FROM `olist.sellers` 
  WHERE seller_state = "BA"
  )
ORDER BY total_value_sold DESC
LIMIT 1;
--should investigate this seller further, 53243585a1d6dc2643021fd1853d8905

SELECT
  COUNT(*) AS num_sales,
  COUNT(DISTINCT order_id) AS num_orders,
  COUNT(DISTINCT product_id) AS num_unique_products,
  AVG(price) AS avg_price,
  APPROX_QUANTILES(price, 2)[OFFSET(1)] AS med_price,
  AVG(freight_value) AS avg_freight_value
FROM `olist.order_items` i
WHERE seller_id = '53243585a1d6dc2643021fd1853d8905';
--appears to sell a few items for a high average price

SELECT
  t.product_category_name_english,
  COUNT(*) AS num_sold,
  ROUND(SUM(i.price + i.freight_value), 2) AS total_value,
  ROUND(AVG(i.price), 2) AS avg_price,
  APPROX_QUANTILES(i.price, 2)[OFFSET(1)] AS med_price,
FROM `olist.order_items` i
JOIN `olist.products` p
  ON i.product_id = p.product_id
JOIN `olist.product_category_name_translation` t
  ON t.product_category_name = p.product_category_name
WHERE seller_id = '53243585a1d6dc2643021fd1853d8905'
GROUP BY t.product_category_name_english;
--this seller sells high value items, in particular selling phones and computers.