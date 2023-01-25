setwd("C:/Users/tjoeun/Desktop/Rstudio")
load("./04_preprocess/04_preprocess.rdata")
load("./05_geocoding/05_juso_geocoding.rdata")

library(dplyr)
apt_price <- left_join(apt_price, juso_geocoding, by = c('jibun' = 'apt_juso'))
apt_price <- na.omit(apt_price)
head(apt_price,2)

install.packages('sp')
library(sp)
coordinates(apt_price) <- ~coord_x + coord_y
proj4string(apt_price) <- "+proj=longlat +datum=WGS84 +no_defs"
install.packages('sf')
library(sf)
apt_price <- st_as_sf(apt_price)

plot(apt_price$geometry, axes = T, pch = 1)
install.packages("leaflet")
library(leaflet)
leaflet() %>% addTiles() %>% addCircleMarkers(data=apt_price[1:1000,], label=~apt_nm)

dir.create("06_geodataframe")
save(apt_price, file="./06_geodataframe/06_apt_price.rdata")
write.csv(apt_price, "./06_geodataframe/06_apt_price.csv")
