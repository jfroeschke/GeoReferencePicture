
# install.packages("exifr")
# install.packages("dplyr")
# install.packages("leaflet")

library(exifr)
library(dplyr)
library(leaflet)



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

leaflet(dat2) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addMarkers(~ GPSLongitude, ~ GPSLatitude)  