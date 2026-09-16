SELECT 
  *
FROM `olist.order_payments`;

SELECT
  payment_type,
  COUNT(*) AS num_payments
FROM `olist.order_payments`
GROUP BY payment_type
ORDER BY num_payments DESC;

SELECT
  payment_installments,
  COUNT(*) AS num_payments
FROM `olist.order_payments`
GROUP BY payment_installments
ORDER BY 1;
--most people use few instalments,  while a few use 8 or 10 instalments

SELECT 
  *
FROM `olist.order_payments`
WHERE order_id = (SELECT order_id FROM `olist.order_payments` WHERE payment_installments = 2 LIMIT 1 OFFSET 1);
--looking at orders with more than one payment to understand columns

SELECT
  order_id,
  SUM(payment_value) AS total_paid,
  SUM(payment_installments) AS total_installments,
  COUNT(*) AS payments
FROM `olist.order_payments`
GROUP BY order_id
ORDER BY total_paid DESC;

CREATE VIEW `olist.total_payments` AS 
  SELECT
  order_id,
  SUM(payment_value) AS total_paid,
  SUM(payment_installments) AS total_installments,
  COUNT(*) AS payments
FROM `olist.order_payments`
GROUP BY order_id
ORDER BY total_paid DESC;

SELECT 
  AVG(total_paid) AS avg_total,
  MAX(total_paid) AS max_,
  MIN(total_paid) AS min_,
  APPROX_QUANTILES(total_paid, 2)[OFFSET(1)] AS med,
  APPROX_QUANTILES(total_paid, 4)[OFFSET(1)] AS q1,
  APPROX_QUANTILES(total_paid, 4)[OFFSET(3)] AS q3,
  APPROX_QUANTILES(total_paid, 100)[OFFSET(90)] AS percentile_90
FROM `olist.total_payments`;
--distribution of payments, can look more into it in R
