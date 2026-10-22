if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               tidyterra,
               mapview,
               stars)
#erace existing objests
rm(list = ls())


#practice example
(spr_prec <- rast("data/spr_prec_us.tif"))
ext(spr_prec)

## load county vector 
sf_nc_county <- readRDS("data/sf_nc_county.rds")

ggplot() +
  geom_spatraster(data = spr_prec)

spr_prec_crop <- crop(x = spr_prec,
                      y = c(-80, -75, 34, 37))


# get county polygon data
sf_nc_county <- readRDS("data/sf_nc_county.rds")

ggplot() +
  geom_spatraster(data = spr_prec_crop) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

# use polygon layer to crop raster

spr_prec_nc <- crop(x = spr_prec,
     y = sf_nc_county)

ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25) 

spr_nw <- rast("data/spr_prec_ncnw.tif") 
spr_ne <- rast("data/spr_prec_ncne.tif") 
spr_sw <- rast("data/spr_prec_ncsw.tif")
spr_se <- rast("data/spr_prec_ncse.tif") 

# north west 
ggplot() +
  geom_spatraster(data = spr_nw) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

#south west
ggplot() +
  geom_spatraster(data = spr_sw) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)


# merge() function to combine two pannals

spr_n <- merge(spr_nw, spr_ne)

ggplot() +
  geom_spatraster(data = spr_n) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

#merge more than two pannals into one
list_spr <- list(spr_nw,
                 spr_ne,
                 spr_sw,
                 spr_se)
#convert from list to spatrsater collection
spr_col <- sprc(list_spr)

#merge more than two pannals
spr_merge <- merge(spr_col)

# map spr_merge and sf_nc_county
ggplot() +
  geom_spatraster(data = spr_merge) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25,
          fill = "tomato")
writeRaster(spr_merge,
            "data/spr_prec_nc.tif",
            overwrite = TRUE)

# stack ------------

spr_prec_nc <- rast("data/spr_prec_nc.tif")

spr_tmp_nc <- rast("data/spr_tmp_nc.tif")

ggplot() +
  geom_spatraster(data = spr_tmp_nc) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)
#create mulit layer raster (stack)
spr_pt_nc <- c(spr_prec_nc,
               spr_tmp_nc)

# access one layer precenpatation
spr_pt_nc$precipitation

# temp
spr_pt_nc$temperature

#try to stack spr_ne and spr_tmp_nc
# c (spr_ne , spr_tmp_nc)
#this would not work because of spatial extent mismatch

# reprojection -----------

# reprojection - transform CRS from one to another
#most cases,geodectic to projected CRS

(spr_prec_nc_proj <- project(x = spr_prec_nc,
                             y = "EPSG:32617"))  # 32617 UTM zone 17n
# excerise------------------

#Q1

spr_tmp_ncnw <- rast("data/spr_tmp_ncnw.tif") 
spr_tmp_ncne <- rast("data/spr_tmp_ncne.tif") 
spr_tmp_ncsw <- rast("data/spr_tmp_ncsw.tif")
spr_tmp_ncse <- rast("data/spr_tmp_ncse.tif")

list_tmp <- list(
  spr_tmp_ncnw,
  spr_tmp_ncne,
  spr_tmp_ncsw,
  spr_tmp_ncse
)

tmp_sprc <- sprc(list_tmp)

spr_merge <- merge(tmp_sprc)

ggplot() +
  geom_spatraster(data = spr_merge) +
  geom_sf(data = sf_nc_county,
          fill = "green",
          alpha = 0.25)

#Q2

sf_camden <- readRDS("data/sf_nc_county.rds") %>% 
  filter(county == "camden")

ext(sf_camden)

spr_tmp_camden <- crop(x = spr_merge,
     y = sf_camden)

ggplot() +
  geom_spatraster(data = spr_tmp_camden) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)
#Q3

spr_tmp_camden_proj <- project(x = spr_tmp_camden,
        y = "EPSG:32618",
        method = "bilinear")

