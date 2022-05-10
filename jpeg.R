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
