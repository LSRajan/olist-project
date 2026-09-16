SELECT
  *
FROM `olist.orders`;

SELECT
  *
FROM `olist.orders`
WHERE order_status = "approved";

SELECT
  ROUND(
      SUM(CASE WHEN order_status = "canceled" THEN 1 ELSE 0 END) / COUNT(*) * 100,
       2) AS percent_cancelled
FROM `olist.orders`;
--both approved and canceled dont seem to appear much

SELECT
  order_status, COUNT(*) AS num_orders
FROM `olist.orders`
GROUP BY order_status
ORDER BY 2 DESC;
--most orders are delivered, only a few of the other instances

SELECT
  customer_id, COUNT(*) AS num_orders
FROM `olist.orders`
GROUP BY customer_id
HAVING num_orders >=2;
--no customers have made more than one order. which is strange but is likely due to the id column

SELECT
  c.customer_unique_id, COUNT(*) AS num_orders
FROM `olist.orders` o
JOIN `olist.customers` c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING num_orders >=2
ORDER BY 2 DESC;
--the corrected column, other tables appear to use customer_unique_id not customer_id.

SELECT
  FORMAT_TIMESTAMP("%Y", order_purchase_timestamp) AS year,
  COUNT(*) AS num_orders
FROM `olist.orders`
GROUP BY year
ORDER BY num_orders DESC;

SELECT
  FORMAT_TIMESTAMP("%Y-%m", order_purchase_timestamp) AS yearmonth,
  COUNT(*) AS num_orders
FROM `olist.orders`
GROUP BY yearmonth
ORDER BY num_orders DESC;
--possible spread of number of orders between time periods or due to data collection process


SELECT
  TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY) AS acceptance_time
FROM `olist.orders`
WHERE order_approved_at IS NOT NULL
ORDER BY acceptance_time DESC;

SELECT
  AVG(TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY)) AS avg_acceptance_time,
  MAX(TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY)) AS max_acceptance_time,
  MIN(TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY)) AS min_acceptance_time,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY), 2)[OFFSET(1)] AS med_acceptance_time,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY), 4)[OFFSET(1)] AS q1_acceptance_time,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY), 4)[OFFSET(3)] AS q3_acceptance_time,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, DAY), 100)[OFFSET(90)] AS percentile_90_acceptance_time
FROM `olist.orders`
WHERE order_approved_at IS NOT NULL;
--most orders appear to be accepted within 1 day

SELECT
  FORMAT_TIMESTAMP("%Y-%m-%d", order_delivered_customer_date) AS delivery_date,
  FORMAT_TIMESTAMP("%Y-%m-%d", order_estimated_delivery_date) AS estimated_delivery_date,
  TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS actual_vs_estimated_delivery_date
FROM `olist.orders`
ORDER BY 3 DESC;
--some interesting data here, can try to understand how quickly orders are being delivered / how accuracte the estimates are

SELECT
  AVG(TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY)) AS avg_actual_vs_estimated,
  MAX(TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY)) AS max_actual_vs_estimated,
  MIN(TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY)) AS min_actual_vs_estimated,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY), 2)[OFFSET(1)] AS med_actual_vs_estimated,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY), 4)[OFFSET(1)] AS q1_actual_vs_estimated,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY), 4)[OFFSET(3)] AS q3_actual_vs_estimated,
  APPROX_QUANTILES(TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY), 100)[OFFSET(90)] AS percentile_90_actual_vs_estimated
FROM `olist.orders`

--appears that most orders arrive before their estimated delivery date, not after.


