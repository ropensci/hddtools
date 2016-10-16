#' Download and convert TRMM data
#'
#' @author Claudia Vitolo
#'
#' @description The TRMM dataset provide global historical rainfall estimation in a gridded format.
#'
#' @param inputLocation location where data is stored. By default it points to the TRMM ftp server (\url{ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/}) but it can also be a local directory. If you are using a local directory, this function expects to find inside 'inputLocation' a folder with the name of product and version (e.g. "i3B43_V7") and inside this a folder for each year( e.g. "2012").
#' @param product this is the code that identifies a product, default is "3B43"
#' @param version this is the version number, default is 7
#' @param type this is the type of information needed, default is "precipitation.accum". Other types could be "gaugeRelativeWeighting.bin" and "relativeError.bin"
#' @param timeExtent is a vector of dates and times for which the data should be retrieve
#' @param bbox OPTIONAL bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)
#' @param outputfileLocation file path where to save the GeoTiff
#'
#' @return Data is loaded as rasterbrick, then converted to a multilayer Geotiff that can
# be opened in any GIS software.
#'
#' @details This code is based upon Martin Brandt's blog post:
#' \url{http://matinbrandt.wordpress.com/2013/09/04/automatically-downloading-and-processing-trmm-rainfall-data/}
#' and on the TRMM FAQ: \url{http://disc.sci.gsfc.nasa.gov/additional/faq/precipitation_faq.shtml}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Define a bounding box
#'   bbox <- list(lonMin = -3.82, latMin = 48, lonMax = -3.63, latMax = 50)
#'   twindow <- seq(as.Date("2012-01-01"), as.Date("2012-01-31"), by = "months")
#'
#'   TRMM(inputLocation="ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",
#'        product = "3B43",
#'        version = 7,
#'        type = "precipitation.accum",
#'        timeExtent = twindow,
#'        bbox = bbox,
#'        outputfileLocation = "~/")
#'
#'   # or simply
#'   TRMM(timeExtent = twindow, bbox = bbox)#'
#'   plot(brick("~/trmm_acc.tif"))
#' }
#'

TRMM <- function(inputLocation="ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",
                 product = "3B43",
                 version = 7,
                 type = "precipitation.accum",
                 timeExtent = NULL,
                 bbox = NULL,
                 outputfileLocation = NULL
                 ){

  # Check output file location
  originalwd <- getwd()
  if ( is.null(outputfileLocation) ) outputfileLocation <- getwd()
  setwd(outputfileLocation)

  # Check bounding box extent is within original raster extent
  if (is.null(bbox)){
    # Use TRMM max extent
    bbox <- list(lonMin = -180, latMin = -50, lonMax = +180, latMax = +50)
  }
  if (bbox$lonMin < -180 | bbox$lonMin > 180) {
    bbox$lonMin <- -180
    message(paste("lonMin of bbox is out of the maximum extent [-180,180],",
                  "new lonMin of bbox is modified as follows:",
                  "lonMin =", bbox$lonMin))
  }
  if (bbox$lonMax < -180 | bbox$lonMax > 180) {
    bbox$lonMax <- 180
    message(paste("lonMax of bbox is out of the maximum extent [-180,180],",
                  "new lonMax of bbox is modified as follows:",
                  "lonMax =", bbox$lonMax))
  }
  if (bbox$latMin < -50 | bbox$latMin > 50) {
    bbox$latMin <- -50
    message(paste("latMin of bbox is out of the maximum extent [-50,50],",
                  "new latMin of bbox is modified as follows:",
                  "latMin =", bbox$latMin))
  }
  if (bbox$latMax < -50 | bbox$latMax > 50) {
    bbox$latMax <- 50
    message(paste("latMax of bbox is out of the maximum extent [-50,50],",
                  "new latMax of bbox is modified as follows:",
                  "latMax =", bbox$latMax))
  }
  bbSP <- bboxSpatialPolygon(bbox)

  # Check time extent
  years <- unique(format(timeExtent, "%Y"))
  months <- format(timeExtent, "%m")

  if ( any(years == "NULL", months == "NULL") ){

    message(paste("This function cannot be executed because your timeExtent",
                  "is not in the correct format.",
                  "Please enter a suitable timeExtent, then try again."))

  }else{

    selectedfilePaths <- c()

    for (myYear in years){

      myURL <- paste(inputLocation,
                     product, "_V", version, "/", myYear, "/", sep = "")

      filenames <- getURL(myURL,
                          ftp.use.epsv = FALSE,
                          ftplistonly=TRUE,
                          crlf=TRUE)

      # the following line allows to download only files with a certain pattern,
      # e.g. only certain months.
      # "*precipitation.accum" means monthly accumulated rainfall here.
      for (myMonth in months){
        filePaths <- paste(myURL, product, ".", substr(myYear, 3, 4),
                           myMonth, "01", ".", version, ".", type, sep = "")

        selectedfilePaths <- c(selectedfilePaths, filePaths)
      }

    }

    # download files
    # Thanks to Fabien Wagner this also works for windows' users!
    mapply(download.file, selectedfilePaths,
           basename(selectedfilePaths), method = "wget")

    # Now I create a virtual file as the downloaded TRMM data come as binaries.
    # The VRT-file contains all the downloaded binary files with the appropriate
    # geo-informations.
    # To automate the process, there is a template script in inst/trmm.sh that
    # generates the VRT-file (TRMM.vrt) for all 2012 data.
    # Change "3B43.12" according to your timeExtent.

    # fileConn <- file(paste(outputfileLocation,"myTRMM.sh",sep=""))
    fileConn <- file("myTRMM.sh")
    shOut <- readLines(system.file("extdata/trmm.sh", package = "hddtools"), -1)
    shOut[4] <- paste("for i in ", product, ".*", sep = "")
    writeLines(shOut, fileConn)
    close(fileConn)

    # Within R, the script (trmm.sh) is executed and the virtual-file (TRMM.vrt)
    # loaded as a rasterbrick. This is flipped in y direction and the files
    # written as multilayer Geotiff.
    # This Geotiff contains all the layers for 2012 and can
    # be opened in any GIS software.

    if (.Platform$OS.type != "unix"){
      message(paste("Beware this function was tested on a unix machine.",
                    "If you are not using a unix machine your results could be",
                    "wrong. Please report any problem to cvitolodev@gmail.com,",
                    "thanks!"))
    }
    system(paste("sh","myTRMM.sh"))

    b <- raster::brick("TRMM.vrt")
    trmm <- raster::flip(b, direction = "y")

    # Crop TRMM raster based on bbox, if necessary
    if ( raster::extent(bbSP) == raster::extent(trmm) ){
      message("Using full spatial extent.")
    }else{
      message("Cropping raster to bbox extent.")
      trmm <- raster::crop(trmm, bbSP)
    }

    raster::writeRaster(trmm,
                        filename = "trmm_acc.tif",
                        format = "GTiff",
                        overwrite = TRUE)

    message("Removing temporary files")
    file.remove(c("TRMM.vrt", "myTRMM.sh"))

    message(paste("Done. The raster-brick was saved in",
                  paste(outputfileLocation, "/trmm_acc.tif", sep = "")))

  }

  on.exit(expr = {setwd(originalwd)})

}
