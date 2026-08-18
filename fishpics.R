#### Purpose: really just get the xy coordinates of the sample location from image, mapped to sanity check.

#### Step 1: Read in images and extract exif data including lat long information
#### Subset the data to a small set of columns from the exif data
#### write the subset of data as a stand alone file, could be merged with other things
### In this case, the images need to be rotated.  Read in images, rotate and save back 
#### in a separate file. Rotating the file in Windows DID NOT work. Not sure why.
### Create a vector of image names to be read into the map
### Create a spatial object from dat2
### Plot the data with images in the popup
### Save the map object or share

# install.packages("exifr")
# install.packages("dplyr")
# install.packages("leaflet")

library(exifr)
library(dplyr)
library(leaflet)
library(OpenImageR)
library(leafpop)
library(sp)
library(leafem)
library(mapview)
library(sf)





old_wd <- getwd()
setwd("images10292025")
files <- list.files(pattern = "*.jpg")


dat <- read_exif(files)

dat2 <- select(dat, SourceFile, DateTimeOriginal,
               GPSLongitude, GPSLatitude) %>% 
              ## remove images with missing coordinates
               filter(!is.na(GPSLongitude)) 



# Come back to the main directory
setwd(old_wd)


write.csv(dat2, 'Exifdata10292025.csv',
          row.names = FALSE)

##
## https://www.r-bloggers.com/2016/11/extracting-exif-data-from-photos-using-r/

dat2 <- read.csv('Exifdata.csv')

JF_pics08012024 <- st_as_sf(dat2, coords = c("GPSLongitude", "GPSLatitude"), crs = 4326)
save(JF_pics08012024, file="JF_pics008012024.RData")
#################### Code to rotate images in necessary then plot


setwd(old_wd)
setwd("images/")
IMG_4774 <- readImage("IMG_4774.jpg")
IMG_4775 <- readImage("IMG_4775.jpg")

setwd(old_wd)
setwd("images2/")

IMG_4774 <- rotateFixed(IMG_4774,90)
writeImage(IMG_4774, 'IMG_4774.jpg')
IMG_4775 <- rotateFixed(IMG_4775,90)
writeImage(IMG_4775, 'IMG_4775.jpg')

files <- list.files(pattern = "*.jpg")

setwd(old_wd)
dat2 <- read.csv('Exifdata.csv')
setwd("images2/")



####  This process creates an actual spatial object for dat2

dat2.coords <- data.frame(x=dat2$GPSLongitude, y=dat2$GPSLatitude)
coordinates(dat2.coords) <- ~ x + y
class(dat2.coords)

### Assign wgs projection
proj4string(dat2.coords)  <- CRS("+proj=longlat +datum=WGS84")  ## for example
#plot(dat2.coords, axes=TRUE) ## sanity check

#load("fishpics.RData")




library(leaflet)
map1 <- leaflet() %>% 
  addTiles('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
           options = providerTileOptions(noWrap = TRUE)) %>%
  addTiles('http://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/Mapserver/tile/{z}/{y}/{x}',
           options = providerTileOptions(noWrap = TRUE)) %>% 
  addMarkers(data=JF_pics08012024, group="fish", popup=geometry) %>% 
  
  
  
  addPopupImages(files, group="fish",  width=200) %>% 
  addMouseCoordinates() %>%  #in leafem library
  addLogo("Shirt-Logo_revision.jpg", src="local", position = "bottomright")
map1
setwd(old_wd)
save.image("fishpics.RData")


## create standalone .html
mapshot(map1, url = paste0(getwd(), "/map.html"))
library(htmlwidgets)
saveWidget(map1,file="map2.html", selfcontained=TRUE )




##################### Experimental Code below #





### Add a logo
library(leafem)
library(png)
img <- system.file("img", "Rlogo.png", package="png")


leaflet() %>% addTiles() %>% addLogo(img, src = "local", alpha = 0.3)


###### Add a local file
library(devtools)
#devtools:::install_github("gearslaboratory/gdalUtils")
destfile = tempfile(fileext = ".gpkg")
leaflet() %>%
  addTiles() %>%
  addLocalFile(destfile, popup = TRUE)

# Libraries
library(leaflet)
library(leaflet.opacity)
library(raster)

# Create artificial layer
r <- raster(xmn = -2.8, xmx = -2.79, ymn = 54.04, ymx = 54.05, nrows = 30, ncols = 30)
values(r) <- matrix(1:900, nrow(r), ncol(r), byrow = TRUE)
crs(r) <- CRS("+init=epsg:4326")

# Create leaflet map with opacity slider  ## use this with the tampa bay bathymetry
leaflet() %>%
  addTiles() %>%
  addRasterImage(r, layerId = "raster") %>%
  addOpacitySlider(layerId = "raster")


library(raster)
#setwd("X:/Data_John/council meetings/April 2020/Bathymetry")

x <- raster("X:/Data_John/council meetings/April 2020/Bathymetry/Band11.tif")
x <- clamp(x, -24, -8)
crs(x) <- CRS("+init=epsg:4326")

### add a color legend
pal <- colorNumeric( "Spectral",values(x),na.color = "transparent")


map1 <- leaflet() %>% 
  addTiles('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
           options = providerTileOptions(noWrap = TRUE)) %>%
  addTiles('http://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/Mapserver/tile/{z}/{y}/{x}',
           options = providerTileOptions(noWrap = TRUE)) %>% 
  addMarkers(data=dat2.coords, group="fish") %>% 
  addPopupImages(files, group="fish",  width=200) %>% 
  addMouseCoordinates() %>%  #in leafem library
  addLogo("Shirt-Logo_revision.jpg", src="local", position = "bottomright") %>% 
  addRasterImage(x, layerId="raster", colors=pal, group="depth") %>%  ## raster too large
  addRasterImage(VRM33, layerId="terrain", group="terrain") %>%  ## raster too large
  addRasterImage(TRI3, layerId="tri", group="tri") %>%  ## raster too large
  addLegend(pal = pal, values = values(x),
          title = "Depth") %>% 

addLayersControl(
  
  overlayGroups = c("depth", "terrain", "tri"),
  options = layersControlOptions(collapsed = FALSE)
)
#addRasterImage(x, layerId="raster") ## raster too large
map1

### to plot a large raster
#If you have a large raster layer, you can provide a larger number of bytes and see how it goes, or use raster::resample or raster::aggregate to decrease the number of cells.