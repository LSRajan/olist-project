library(dplyr)
library(tidyverse)

customers <- read.csv("../data/olist_customers_dataset.csv")
order_items <- read.csv("../data/olist_order_items_dataset.csv")
order_payments <- read.csv("../data/olist_order_payments_dataset.csv")
order_reviews <- read.csv("../data/olist_order_reviews_dataset.csv")
orders <- read.csv("../data/olist_orders_dataset.csv")
products <- read.csv("../data/olist_products_dataset.csv")
sellers <- read.csv("../data/olist_sellers_dataset.csv")
category_name_translation <- read.csv("../data/product_category_name_translation.csv")

summary(customers)

nrows <- nrow(customers)
n_customers <- n_distinct(customers$customer_id)
n_customers_unique <- n_distinct(customers$customer_unique_id)
n_na_customers <- sum(is.na(customers$customer_id))
n_na_customers_unique <- sum(is.na(customers$customer_unique_id))

#we have duplicate unique_customer_ids, with no na values in either.
nrows == n_customers
n_na_customers

nrows == n_customers_unique
n_na_customers_unique

#unclear whether customer_id or customer_unique_id should be used. this checks which is relevant.
customer_id_sample <- sample(orders$customer_id, 10)
customer_id_sample %in% customers$customer_unique_id
customer_id_sample %in% customers$customer_id #this is the relevant id

n_distinct(customers$customer_city)
n_distinct(customers$customer_state)

customers |> 
  group_by(customer$customer_state) |> 
  