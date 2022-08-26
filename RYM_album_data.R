# RYM Artist album stats scraper v 1.0
# Tristan Louth-Robins - August 2022

# For use with Rate Your Music artist pages - https://rateyourmusic.com/artist/
# Will create a dataframe containing:
# - Album title
# - Year of release
# - Number of user ratings 
# - Number of user reviews 
# - Average user rating 
# 
# Currently this will only produce album data from official albums (no live albums, 
# singles, EPs or compilations.)

library(tidyverse)
library(rvest)

rym <- read_html("https://rateyourmusic.com/artist/grateful-dead")

album <- rym %>% html_nodes('div#disco_type_s div.disco_mainline a') %>% html_text() %>% 
  as_tibble() %>% 
  rename(title = value) # <-- album titles

year <- rym %>% html_nodes('div#disco_type_s div.disco_subline span') %>% html_text() %>% 
  as_tibble() %>% 
  filter(!grepl(' ', value)) %>% 
  rename(year = value) # <-- year of release
year$year <- as.numeric(year$year)

n_ratings <- rym %>% html_nodes('div#disco_type_s div.disco_ratings') %>% html_text() %>% 
  as_tibble() %>% 
  rename(n_ratings = value) # <-- n ratings
n_ratings$n_ratings <- as.numeric(gsub(",", "", n_ratings$n_ratings))

n_reviews <- rym %>% html_nodes('div#disco_type_s div.disco_reviews') %>% html_text() %>% 
  as_tibble() %>% 
  rename(n_reviews = value)  # <-- n reviews

n_reviews$n_reviews <- as.numeric(n_reviews$n_reviews)

avg_rating <- rym %>% html_nodes('div#disco_type_s div:nth-child(3)') %>% html_text() %>%  # <-- avg rating
  stringr::str_extract("\\d+\\.*\\d*") %>% 
  as_tibble() %>% 
  rename(avg_rating = value)
  
avg_rating$avg_rating <- as.numeric(avg_rating$avg_rating)
avg_rating <- avg_rating %>% filter(avg_rating < 5)

df <- cbind(album, year, n_ratings, n_reviews, avg_rating) %>% as_tibble() 
df 
