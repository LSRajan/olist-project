SELECT 
  *
FROM `olist.customers`
LIMIT 1000;

SELECT 
  COUNT(*)
FROM `olist.customers`;

SELECT 
  COUNT(DISTINCT customer_id)
FROM `olist.customers`;
-- customer id column is fine


SELECT 
  customer_state, COUNT(DISTINCT customer_city)  AS num_cities
FROM `olist.customers`
GROUP BY customer_state
ORDER BY 2 DESC;

SELECT 
  customer_state, COUNT(*) AS num_customers
FROM `olist.customers`
GROUP BY customer_state
ORDER BY 2 DESC;