library(dplyr)
library(tidyverse)
library(ggplot2)

customers <- read.csv("../data/olist_customers_dataset.csv")
order_items <- read.csv("../data/olist_order_items_dataset.csv")
order_payments <- read.csv("../data/olist_order_payments_dataset.csv")
order_reviews <- read.csv("../data/olist_order_reviews_dataset.csv")
orders <- read.csv("../data/olist_orders_dataset.csv")
products <- read.csv("../data/olist_products_dataset.csv")
sellers <- read.csv("../data/olist_sellers_dataset.csv")
category_name_translation <- read.csv("../data/product_category_name_translation.csv")

summary(customers)
summary(order_items)
summary(order_payments)
summary(order_reviews)
summary(orders)
summary(products)
summary(sellers)
summary(category_name_translation)

#customers table
  
customers |> 
  count(customer_state) |> 
  top_n(10) |> 
  ggplot(aes(x = reorder(customer_state, desc(n)), y = n)) +
  geom_bar(stat = "identity",
           aes(fill = n > 5000)) +
  geom_text(aes(label = n), 
            vjust = 1.25,
            color = "white",
            size = 3.5,
            fontface = "bold") +
  scale_fill_manual(values = c("TRUE" = "blue", "FALSE" = "#D3D3D3")) +
  labs(x = "", y = "",
       title = "Majority of customers are from a small number of states") +
  theme(panel.background = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "none")
  
#to prove that these states have a majority we would have to show proportion not count
customers |> 
  count(customer_state) |>
  mutate(pct = round(n / sum(n) * 100, 1)) |> 
  slice_max(order_by = pct, n=10) |> 
  ggplot(aes(x = reorder(customer_state, desc(pct)), y = pct)) +
  geom_bar(stat = "identity",
           aes(fill = n > 5000)) +
  geom_text(aes(label = paste(pct, "%", sep="")), 
            vjust = 1.25,
            color = "white",
            size = 3.5,
            fontface = "bold") +
  scale_fill_manual(values = c("TRUE" = "blue", "FALSE" = "grey")) +
  labs(x = "", y = "",
       title = "Majority of customers are from a small number of states",
       subtitle = "More than 75% of customers are from a select few states") +
  theme(panel.background = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "none")

customers |> 
  count(customer_city) |> 
  arrange(desc(n)) |> 
  head(10)

customers |> 
  count(customer_city) |> 
  mutate(pct = round(n / sum(n) * 100, 1),
         pct_label = case_when(
           pct >= 2.5 ~ paste(pct, "%", sep=""),
           TRUE ~ ""
         )) |> 
  slice_max(order_by = pct, n=20) |> 
  ggplot(aes(x = reorder(customer_city, pct), y= pct)) +
  geom_bar(stat="identity",
           aes(fill = pct > 3)) +
  coord_flip() +
  geom_text(aes(label = pct_label), 
            hjust = 1.25,
            color = "white",
            size = 3.5,
            fontface = "bold") +
  scale_fill_manual(values = c("TRUE" = "darkgrey", "FALSE" = "grey")) +
  labs(x = "", y = "",
       title = "Customers spread across cities",
       subtitle = "Aside from two cities, the customers are thinly spread across cities") +
  theme(axis.ticks.y = element_blank(),
        legend.position = "none") +
  scale_y_continuous(limits = c(0,30), 
                     breaks = c(seq(0,30,5)),
                     expand = expansion(mult = c(0, 0.02)))
  

  

