SELECT 
  *
FROM `olist.orders`
WHERE order_status = "delivered";

SELECT 
  *
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
WHERE order_status = "delivered"
;

--as discovered previously, only a small percentage of customers have ordered twice, and the customer id is not relevant but customer_unique_id is
CREATE VIEW `olist.orders_id_fix` AS 
  SELECT
    o.* REPLACE(c.customer_unique_id AS customer_id)
  FROM `olist.orders` o 
  JOIN `olist.customers` c
    ON o.customer_id = c.customer_id;

WITH repeat_customers AS(
  SELECT customer_id 
  FROM `olist.orders_id_fix`
  GROUP BY customer_id
  HAVING COUNT(*) > 1
)
SELECT
  AVG(CASE 
      WHEN o.customer_id NOT IN (SELECT * FROM repeat_customers) 
      THEN r.review_score END) AS avg_one_time_review_score,
  AVG(CASE 
      WHEN o.customer_id IN (SELECT * FROM repeat_customers) 
      THEN r.review_score END) AS avg_returning_review_score,
FROM `olist.orders_id_fix` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id;
--There does not appear to be a significant difference between review scores from one-time and repeat customers.

SELECT 
  p.product_category_name,
  ROUND(AVG(r.review_score) ,2) AS avg_review_score,
  COUNT(r.review_score) AS num_reviews
FROM `olist.order_items` oi
JOIN `olist.orders` o
  ON oi.order_id = o.order_id
JOiN `olist.products` p
  ON oi.product_id = p.product_id
JOIN `olist.order_reviews` r
  ON r.order_id = o.order_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;

--We can begin to differentiate between review scores using category names

SELECT 
  t.product_category_name_english,
  ROUND(AVG(r.review_score) ,2) AS avg_review_score,
  COUNT(r.review_score) AS num_reviews
FROM `olist.order_items` oi
JOIN `olist.orders` o
  ON oi.order_id = o.order_id
JOiN `olist.products` p
  ON oi.product_id = p.product_id
JOIN `olist.order_reviews` r
  ON r.order_id = o.order_id
JOIN `olist.product_category_name_translation` t
  ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
HAVING num_reviews >= 100
ORDER BY avg_review_score DESC;

--appears to be a clear difference in reviews across categories, although the average review still remains between 3.5-5

SELECT 
  p.product_photos_qty,
  ROUND(AVG(r.review_score) ,2) AS avg_review_score,
  COUNT(r.review_score) AS num_instances
FROM `olist.order_items` oi
JOIN `olist.orders` o
  ON oi.order_id = o.order_id
JOiN `olist.products` p
  ON oi.product_id = p.product_id
JOIN `olist.order_reviews` r
  ON r.order_id = o.order_id
GROUP BY p.product_photos_qty
HAVING num_instances >= 100
ORDER BY avg_review_score DESC;

--there does not appear to be a significant impact of number of photos on the review score. The hypothesis was that less photos meant items would be less likely to meet expectations, but this doesnt necessarily suggest that.


SELECT 
  FLOOR(total_paid/100.00)*100 as bin_floor,
  COUNT(*) as num_instances,
  AVG(r.review_score) AS avg_review_score
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
JOIN `olist.total_payments` t
  ON o.order_id = t.order_id
GROUP BY bin_floor
ORDER BY bin_floor;
--its possible that higher price results in a lower average review score, but more testing would be necessary; smaller sample sizes have higher variance.


SELECT 
  FLOOR(total_paid/10.00)*10 as bin_floor,
  COUNT(*) as num_instances,
  AVG(r.review_score) AS avg_review_score
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
JOIN `olist.total_payments` t
  ON o.order_id = t.order_id
WHERE total_paid <= 500
GROUP BY bin_floor
ORDER BY bin_floor;
-- looking more closely into the diffence in review scores across bins between 0 - 500, we find that review scores appear to descrease at higher costs.


SELECT
  FORMAT_TIMESTAMP("%Y", o.order_purchase_timestamp) AS year,
  AVG(r.review_score) AS avg_review_score,
  COUNT(*) AS num_orders
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
GROUP BY year
ORDER BY year;   

--there does not appear to be a significant difference between 2017 and 2018, they are very similar. 2016 had poorer reviews on average however this is a smaller sample size.

SELECT
  FORMAT_TIMESTAMP("%Y-%m", o.order_purchase_timestamp) AS yearmonth,
  AVG(r.review_score) AS avg_review_score,
  COUNT(*) AS num_orders
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
GROUP BY yearmonth
ORDER BY yearmonth;  

SELECT
  FORMAT_TIMESTAMP("%m", o.order_purchase_timestamp) AS month,
  AVG(r.review_score) AS avg_review_score,
  COUNT(*) AS num_orders
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
GROUP BY month
ORDER BY month;  
--by observing the review score and number of orders across months, a trend appears of the average review score being slightly higher during the months 4-10 whereas the remaining months appear to lag behind.

SELECT
  CASE 
    WHEN (TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) > 0) THEN "Late" 
    ELSE "Early/On-time" 
  END AS deliv_vs_expected_diff,
  AVG(r.review_score) AS avg_review_score,
  COUNT(*) AS num_orders
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
GROUP BY deliv_vs_expected_diff;
--delivery speed has a surprisingly significant effect on review_scores

SELECT
  CASE 
    WHEN (TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) > 3) THEN ">3 days late" 
    WHEN (TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) BETWEEN 1 AND 3) THEN "<3 days late" 
    WHEN (TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) >= -1) THEN "on time" 
    WHEN (TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) >= -3) THEN "early" 
    ELSE ">3 days early" 
  END AS deliv_vs_expected_diff,
  AVG(r.review_score) AS avg_review_score,
  COUNT(*) AS num_orders
FROM `olist.orders` o
JOIN `olist.order_reviews` r
  ON o.order_id = r.order_id
GROUP BY deliv_vs_expected_diff;
--this table provides a closer look, the review scores seem to get much lower the more overdue the delivery is. this has the most clear impact on review score out of any factor seen.


