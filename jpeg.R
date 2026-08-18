library(jpeg)

pic <- readJPEG("IMG_4775.jpg")
picx <- readJPEG("x.jpg")
plot(1:2, type='n')
rasterImage(pic, 1.2, 1.27, 1.8, 1.73)

library(jpeg)

pic <- readJPEG("IMG_4775.jpg")


# read a sample file (R logo)
img <- readJPEG(system.file("img", "Rlogo.jpg", package="jpeg"))

# read it also in native format
img.n <- readJPEG(system.file("img", "Rlogo.jpg", package="jpeg"), TRUE)

# if your R supports it, we'll plot it
if (exists("rasterImage")) { # can plot only in R 2.11.0 and higher
  plot(1:2, type='n')
  
  rasterImage(img, 1.2, 1.27, 1.8, 1.73)
  rasterImage(img.n, 1.5, 1.5, 1.9, 1.8)
}

if(!require('OpenImageR')) {
  install.packages('OpenImageR')
  library('OpenImageR')
}

path = system.file("tmp_images", "1.png", package = "OpenImageR")

image = readImage(path)

image2 <- readImage("IMG_4775.jpg")
image3 <- rotateFixed(image2,90)
imageShow(image3)
writeImage(image3, 'image3.jpeg')
