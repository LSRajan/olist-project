SELECT 
  *
FROM `olist.products`;

SELECT 
  product_category_name,
  COUNT(*) AS num_products
FROM `olist.products`
GROUP BY product_category_name
ORDER BY num_products DESC;
--interestingly there are 610 products with no category name (NULL)

SELECT 
  t.product_category_name_english,
  COUNT(*) AS num_products
FROM `olist.products` p
JOIN `olist.product_category_name_translation` t
  ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY num_products DESC;
--categories with most number of products, with their names translated to english

--remaining categories exploration is trivial, with just distribution being interesting which will be done in R