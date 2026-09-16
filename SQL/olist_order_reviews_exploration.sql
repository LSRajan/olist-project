SELECT 
  *
FROM `olist.order_reviews`;

SELECT
  review_score,
  COUNT(*) AS num_reviews
FROM `olist.order_reviews`
GROUP BY review_score
ORDER BY num_reviews DESC;

--most reviews as 4 or 5 stars. will investigate the data behind different review scores in another set of queries.

SELECT
   AVG(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day)) AS avg_answer_time,
  MAX(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day)) AS max_,
  MIN(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day)) AS min_,
  APPROX_QUANTILES(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day), 2)[OFFSET(1)] AS med,
  APPROX_QUANTILES(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day), 4)[OFFSET(1)] AS q1,
  APPROX_QUANTILES(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day), 4)[OFFSET(3)] AS q3,
  APPROX_QUANTILES(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day), 100)[OFFSET(90)] AS percentile_90
FROM `olist.order_reviews`;

SELECT
  review_score,
  AVG(TIMESTAMP_DIFF(review_answer_timestamp, review_creation_date, day)) AS average_answer_time
FROM `olist.order_reviews`
GROUP BY review_score
ORDER BY average_answer_time DESC;
--average answer time doesnt appear to significantly differ, could test this. table seems to follow same order as most reviews
