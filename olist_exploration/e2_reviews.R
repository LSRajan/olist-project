library(dplyr)
library(tidyverse)
library(ggplot2)

reviews <- read.csv("../data/olist_order_reviews_dataset.csv")

summary(reviews)

reviews |> 
  ggplot(aes(x=review_score)) +
  geom_histogram()
