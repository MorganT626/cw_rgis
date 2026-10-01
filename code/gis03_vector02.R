# vecter 2 spatial join

if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               sf,
               mapview)


sf_site <- readRDS("data/sf_finsync_nc.rds")
sf_nc_county <- readRDS ("data/sf_nc_county.rds")

mapview(sf_nc_county, legend = FALSE) + mapview(sf_site, legend = FALSE)

#join county info to sf_site

sf_site_join <- st_join(x = sf_site,
        y = sf_nc_county)

sf_site

sf_site_join

# count the number of fish survey sites within guilford county

sf_site_guilford <- sf_site_join %>% 
  filter(county == "guilford")

# count # of sites in clay county

sf_site_clay <- sf_site_join %>% 
  filter(county == "clay")

sf_str <- readRDS("data/sf_stream_gi.rds")

# produse a map with guilford county polygon, sites within guilford
# and use stream lines in guilford
# use ggplot() mapping functions

sf_gi_county <- sf_nc_county %>% 
  filter(county == "guilford")

ggplot() +
  geom_sf(data = sf_gi_county) +
  geom_sf(data = sf_str,
          color = "blue") +
  geom_sf(data = sf_site_guilford,
          color = "tomato")

# geometirc analysis --------

#leangth
sf_str_proj <- st_transform(sf_str, crs = 32617)

#calculate the leangth of each stream line segment
v_str_l <- st_length(sf_str_proj)
head(v_str_l)

sf_str_w_len <- sf_str %>% 
  mutate(length = v_str_l)

# area #
sf_nc_county_proj <- st_transform(sf_nc_county, crs = 32617)

#calculate the area of county polygon
v_area <- st_area(sf_nc_county_proj)

# create a column "area" in sf_nc_county_proj, and identify which county is largest

sf_nc_county_w_area <- sf_nc_county_proj %>% 
  mutate(area = as.numeric(v_area) / 1E+6) %>% # unit conversion from m^2 to km^2
  arrange(desc(area))

#subset polygon for mapping
sf_county1k <- sf_nc_county_w_area %>% 
  filter(area > 1000) # km^2

# map the subset of counties
ggplot() +
  geom_sf(data = sf_county1k)

# exersice

sf_quakes <- readRDS("data/sf_quakes.rds")

sf_nz <- readRDS("data/sf_nz.rds")

sf_quakes_join <- st_join(
  sf_quakes,
  sf_nz
)
sf_quakes_nz <- drop_na(sf_quakes_join, fid)
nrow(sf_quakes_nz)
sf_quakes_join <- st_join(sf_quakes, sf_nz)

df_n <- sf_site_join %>%
  as_tibble() %>%
  group_by(county) %>%
  summarize(n = n())
sf_n_site <- sf_nc_county %>%
  left_join(df_n, by = "county")
sf_n10 <- sf_n_site %>%
  filter(n > 10)
sf_n_site <- sf_nc_county %>%
  left_join(df_n, by = "county")

sf_n10 <- sf_n_site %>%
  filter(n > 10)
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_n_site, fill = "grey") +
  geom_sf(data = sf_n10, fill = "salmon") +
  theme_bw()