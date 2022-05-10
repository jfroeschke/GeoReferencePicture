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





old_wd <- getwd()
setwd("images/")
files <- list.files(pattern = "*.jpg")


dat <- read_exif(files)

dat2 <- select(dat, SourceFile, DateTimeOriginal,
               GPSLongitude, GPSLatitude)



# Come back to the main directory
setwd(old_wd)


write.csv(dat2, 'Exifdata.csv',
          row.names = F)

##
## https://www.r-bloggers.com/2016/11/extracting-exif-data-from-photos-using-r/

dat2 <- read.csv('Exifdata.csv')



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



library(leaflet)
map1 <- leaflet() %>% 
  addTiles('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
           options = providerTileOptions(noWrap = TRUE)) %>%
  addTiles('http://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/Mapserver/tile/{z}/{y}/{x}',
           options = providerTileOptions(noWrap = TRUE)) %>% 
  addMarkers(data=dat2.coords, group="fish") %>% 
  addPopupImages(files, group="fish",  width=200)

setwd(old_wd)
save.image("fishpics.RData")


## create standalone .html
mapshot(map1, url = paste0(getwd(), "/map.html"))
