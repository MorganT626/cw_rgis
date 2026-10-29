# raters vester interaction

if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               sf,
               terra,
               tidyterra,
               exactextractr)

# data
sf_site <- readRDS("data/sf_finsync_nc.rds")
sf_nc_county <- readRDS("data/sf_nc_county.rds")
spr_prec_nc <- rast("data/spr_prec_nc.tif")

## point-wise extraction
ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_site) +
  scale_fill_viridis_c()

extract(
  x = spr_prec_nc,
  y = sf_site,
  bind = TRUE
) %>% 
  st_as_sf()

## zonal statsics
sf_nc_county_proj <- st_transform(sf_nc_county,
             crs = 32617)
spr_prec_nc_proj <- project(
  x = spr_prec_nc,
  y = crs(sf_nc_county_proj)
)

ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)
                            
df_prec_county <- exact_extract(x = spr_prec_nc_proj,
              y = sf_nc_county_proj,
              fun = "mean",
              append_cols = "county") %>% 
  as_tibble() %>% 
  rename(precipitation = mean)

sf_nc_county_prec <- sf_nc_county %>% 
  left_join(df_prec_county,
            by = "county")

# visualize the map with preciptation
# aes(fill = precipitation)

ggplot() +
  geom_sf(data = sf_nc_county_prec,
          aes(fill = precipitation)) +
  scale_fill_viridis_c()

## which county has the lowest precipitation
#use arrange() function (ulness you have other ideas)

sf_nc_county_prec %>% 
  arrange(precipitation)

## buffer-based analysis

sf_site_proj <- sf_site %>%
  st_transform(crs = 32617)
sf_site_buff_proj <- sf_site_proj %>%
  st_buffer(dist = 10000)

## visialize the sf_site_buff_proj and sf_site_proj together

ggplot() +
  geom_sf(data = sf_site_buff_proj) +
  geom_sf(data = sf_site_proj)

df_prec_buff <- exact_extract(
  x = spr_prec_nc_proj,
  y = sf_site_buff_proj,
  fun = "mean",
  append_cols = "site_id"
) %>% 
  as_tibble() %>% 
  rename(precipitation = mean)

## combine df_prec_buff with sf_site
sf_site_prec_buff <- sf_site %>% 
  left_join(
    df_prec_buff,
    by = "site_id"
  )
## visualization
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_site_prec_buff,
          aes(color = precipitation)) +
  scale_color_viridis_c()

#exercise--------------

# 1001 = forest
# 1010 = crop
# 1100 = urban

spr_land <- rast("data/spr_land_reclass.tif")
spr_land

# 1. reclassify spr_land to binary of crop (1) or else (0)

cm <- cbind(
  c(0, 1001, 1010, 1100),
  c(0, 0, 1, 0)
)

spr_crop <- classify(
  x = spr_land,
  rcl = cm
)

# 2. calculate the proportion of crop lands in each county

spr_crop_proj <- project(x = spr_crop,
                         y = crs(sf_nc_county_proj))

df_crop <- exact_extract(
  x = spr_crop_proj,                    # raster layer
  y = sf_nc_county_proj,                    # mask layer
  fun = "mean",            # what summary statistic
  append_cols = "county"          # column for labels
) %>% 
  as_tibble() %>% 
  rename(frac_crop = mean)

# 3. identify the county with the highest crop fraction

arrange(df_crop, desc(frac_crop))

# highest was pasquotank




