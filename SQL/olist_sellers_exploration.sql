SELECT 
  *
FROM `olist.sellers`;

SELECT 
  COUNT(*) AS num_rows
FROM `olist.sellers`;

SELECT 
  seller_state,
  COUNT(*) AS num_sellers
FROM `olist.sellers`
GROUP BY seller_state
ORDER BY 2 DESC;
