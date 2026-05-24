library(httr)
library(jsonlite)
library(socratadata)
library(data.table)
library(dplyr)
library(bit64)
#library(tidyverse)
library(lubridate)
library(ggplot2)
library(scales)
library(tigris)
library(janitor)

df_311 <- fread("/home/davidtboyd/Data-Analysis-Portfolio-R/ExploratoryDataAnalysis/311_Service_Requests_from_2020_to_Present_20260509.csv")

df_311 <- clean_names(df_311)

head(df_311, 20)
str(df_311)

Filter(Negate(is.character), df_311)  # returns the actual columns, not just their types

df_311 <- df_311 |> mutate(
  `unique_key` = as.character(`unique_key`),
  bbl = as.character(bbl),
  'created_date' = mdy_hms(`created_date`),
  'closed_date' = mdy_hms(`closed_date`),
  'due_date' = mdy_hms(`due_date`),
  'resolution_action_updated_date' = mdy_hms(`resolution_action_updated_date`)
)

na_pct <- colMeans(is.na(df_311)) * 100
na_pct[na_pct > 2]

start_date = min(df_311$`created_date`, na.rm = TRUE)
finish_date = max(df_311$`created_date`, na.rm = TRUE)
print(start_date)
print(finish_date)

set.seed(76)
top50 <- df_311 %>% slice_sample(n = 50)
write.csv(top50, "311_Sample_50.csv", row.names = FALSE)

df_agencies <- df_311 %>% distinct(`agency`)
df_boroughs <- df_311 |> distinct(`borough`)
print(df_agencies)
print(df_boroughs)

df_complaints <- filter(df_311, agency == "NYPD")

df_311 %>%
  group_by(borough) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = borough, y = count)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = label_number(scale = 1/1000000, suffix = "M", accuracy = 0.1))

borough_counts <- df_311 %>%
  filter(!is.na(borough), borough != "Unspecified") %>%
  mutate(borough = tolower(borough)) %>%
  count(borough, name = "calls")

nyc_boroughs <- counties(state = "NY", cb = TRUE, class = "sf") %>%
  filter(NAME %in% c("New York", "Bronx", "Queens", "Kings", "Richmond")) %>%
  mutate(Borough = case_when(
    NAME == "New York" ~ "MANHATTAN",
    NAME == "Kings"    ~ "BROOKLYN",
    NAME == "Richmond" ~ "STATEN ISLAND",
    TRUE               ~ toupper(NAME)
  ))

clean_names(nyc_boroughs)

write.csv(borough_counts, "borough_counts.csv", row.names = FALSE)
write.csv(nyc_boroughs, "nyc_boroughs.csv", row.names = FALSE)

borough_counts <- df_311 %>%
  filter(!is.na(borough), borough != "Unspecified") %>%
  mutate(borough = tolower(borough)) %>%
  count(borough, name = "calls")

nyc_boroughs <- counties(state = "NY", cb = TRUE, class = "sf") %>%
  filter(NAME %in% c("New York", "Bronx", "Queens", "Kings", "Richmond")) %>%
  mutate(Borough = case_when(
    NAME == "New York" ~ "MANHATTAN",
    NAME == "Kings"    ~ "BROOKLYN",
    NAME == "Richmond" ~ "STATEN ISLAND",
    TRUE               ~ toupper(NAME)
  ))

clean_names(nyc_boroughs)

nyc_choropleth <- nyc_boroughs %>%
  mutate(Borough = tolower(Borough)) %>%
  left_join(borough_counts, by = c("Borough" = "borough"))

ggplot(nyc_choropleth) +
  geom_sf(aes(fill = calls), color = "white", linewidth = 0.6) +
  geom_sf_label(aes(label = paste0(Borough, "\n", comma(calls))),
                size = 3, label.size = 0) +
  scale_fill_viridis_c(name = "311 Calls", labels = comma) +
  theme_void() +
  labs(title = "NYC 311 Calls by Borough")

