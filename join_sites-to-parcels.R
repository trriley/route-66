library(tidyverse)
library(sf)
library(here)

data_dir <- here("data")
parcel_shp <- paste(data_dir, "parcels.shp", sep = "/")
r66_sites_csv <- paste(data_dir, "sites.csv", sep = "/")
output_db <- paste(data_dir, "route-66.gpkg", sep = "/")

parcels <- read_sf(parcel_shp) %>%
  filter(!is.na(PIN)) %>%
  st_centroid()

r66_sites <- read_csv(
  r66_sites_csv,
  col_types = list(
    web_map = col_logical(),
    year_start = col_integer(),
    year_end = col_integer(),
    .default = col_character()
  )
) %>%
  mutate(PIN = str_pad(PIN, 10, "left", pad = "0")) %>%
  print()

left_join(r66_sites, parcels) %>% filter(is.na(OBJECTID)) %>% select(PIN) %>% drop_na() # returns list of PINs that did not join

r66_sites_sf <- parcels %>% 
  right_join(r66_sites) %>%
  select(1:2,15:27)

write_sf(r66_sites_sf, output_db, "sites")
