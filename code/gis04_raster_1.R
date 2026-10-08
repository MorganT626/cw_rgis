# raster 1 basic terra operations

if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars)

# rster data format
#rast() 
spr_ex <- rast("data/spr_example.tif")

# writeRaster() is a function to export data
writeRaster(x = spr_ex,
            filename = "data/spr_elve.tif",
            overwrite = TRUE)
# visulize raster data 
ggplot() +
  geom_spatraster(
    data = spr_ex
  )

#if you want mapview to work

star_ex <- st_as_stars(spr_ex)
mapview(star_ex)


# data type in raster

# countinus
v_elve <- values(spr_ex)
v_elve

extract(spr_ex, y = cbind(6.0000, 50.0000))

extract(spr_ex, y = cbind(5.2, 40.37))
extract(spr_ex, y = cbind(5.1, 38.3))
extract(spr_ex, y = cbind(5.1, 49.5))
extract(spr_ex, y = cbind(6.4, 49.8))

# extract mutipal points
df_point <- tibble(
  lon = c(6, 5.9),
  lat = c(50, 49.96)
)

extract(spr_ex, y = df_point)

# discrete data

spr_for <- rast("data/spr_forest_nc.tif")
spr_for

ggplot() +
  geom_spatraster(data = spr_for)

unique(spr_for)

v_binary <- values(spr_for)
v_binary
mean(v_binary) * 100

# mutiple classes - code values with mutipal catagories

spr_land <- rast("data/spr_land_reclass.tif")
# 1001 = forest
# 1010 = crop
# 1100 = urban

unique(spr_land)

# coordinate lon -79.8063 lat 36.0710
extract(spr_land, cbind(-79.8063, 36.0701))

#reclass
# - matrix for category mapping

(cm <- cbind(c(0, 1001, 1010, 1100),
             c(0, 1, 0, 0)))
spr_bin <- classify(spr_land,
                    rcl = cm)
unique(spr_bin)
v_bin <- values(spr_bin)
mean(v_bin) * 100

#calculate % cropland
cm_crop <- cbind(
  c(0, 1001, 1010, 1100),
  c(0, 0, 1, 0)
)

spr_crop <- classify(
  x = spr_land,
  rcl = cm_crop
)

v_crop <- values(spr_crop)
mean(v_crop) * 100


#calculate % urban
cm_urban <- cbind(
  c(0, 1001, 1010, 1100),
  c(0, 0, 0, 1)
)

spr_urban <- classify(spr_land,
                      rcl = cm_urban)
unique(spr_urban)
v_urban <- values(spr_urban)
mean(v_urban) * 100


# exersise
#Q1
spr_prec_ncne <- rast("data/spr_prec_ncne.tif")

spr_prec_ncne

#Q2 
# rows,columns rows 162, collms 532

# Resolution = 0.0083..

# long = -79.89181, -75.45847
# lat = 35.24153, 36.59153

# Coordinates WGS84

# precipitation min 1063.1 - 1501.5 max

#Q3

ggplot() +
  geom_spatraster(data = spr_prec_ncne)

#Q4

sf_site <- readRDS("data/sf_finsync_nc.rds")

df_xy <- st_coordinates(sf_site)

df_land <- extract(spr_land, df_xy)

#forest
df_land %>% 
  filter(code == 1001) %>% 
  nrow()

#crop land
df_land %>% 
  filter(code == 1010) %>% 
  nrow()


# urban
df_land %>% 
  filter(code == 1100) %>% 
  nrow()


# quicker approch
table(df_land)