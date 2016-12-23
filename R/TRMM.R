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
#' @param twindow is a vector of dates and times for which the data should be retrieve
#' @param areaBox OPTIONAL bounding box, a list made of 4 elements: minimum longitude (xmin), minimum latitude (ymin), maximum longitude (xmax), maximum latitude (ymax)
#' @param outputfileLocation file path where to save the GeoTiff
#'
#' @return Data is loaded as multilayer GeoTIFF and loaded as a RasterBrick.
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
#'   areaBox <- raster::extent(-10, 5, 48, 62)
#'   twindow <- seq(as.Date("2012-01-01"), as.Date("2012-01-31"), by = "months")
#'
#'   TRMMfile <- TRMM(product = "3B43", version = 7,
#'                    type = "precipitation.accum",
#'                    twindow = twindow, areaBox = areaBox)
#'
#'   raster::plot(TRMMfile)
#' }
#'

TRMM <- function(inputLocation = NULL,
                 product = "3B43",
                 version = 7,
                 type = "precipitation.accum",
                 twindow = NULL,
                 areaBox = NULL,
                 outputfileLocation = NULL){

  if (is.null(inputLocation)) {
    inputLocation <- "ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/"
  }

  # Check output file location
  originalwd <- getwd()
  if (is.null(outputfileLocation)) outputfileLocation <- getwd()
  setwd(outputfileLocation)

  # Check bounding box extent is within original raster extent
  if (is.null(areaBox)){
    # Use TRMM max extent
    areaBox <- raster::extent(c(-180, +180, -50, +50))
  }

  if (areaBox@xmin < -180 | areaBox@xmin > 180) {
    areaBox@xmin <- -180
    message(paste("xmin of areaBox is out of the maximum extent",
                  "[-180,180], new xmin of areaBox is modified as follows:",
                  "xmin =", areaBox@xmin))
  }
  if (areaBox@xmax < -180 | areaBox@xmax > 180) {
    areaBox@xmax <- 180
    message(paste("xmax of areaBox is out of the maximum extent",
                  "[-180,180], new xmax of areaBox is modified as follows:",
                  "xmax =", areaBox@xmax))
  }
  if (areaBox@ymin < -50 | areaBox@ymin > 50) {
    areaBox@ymin <- -50
    message(paste("ymin of areaBox is out of the maximum extent [-50,50],",
                  "new ymin of areaBox is modified as follows:",
                  "ymin =", areaBox@ymin))
  }
  if (areaBox@ymax < -50 | areaBox@ymax > 50) {
    areaBox@ymax <- 50
    message(paste("ymax of areaBox is out of the maximum extent [-50,50],",
                  "new ymax of areaBox is modified as follows:",
                  "ymax =", areaBox@ymax))
  }
  bbSP <- bboxSpatialPolygon(areaBox)

  # Check time extent
  if (is.null(twindow)) stop("Please enter valid twindow")
  years <- unique(format(twindow, "%Y"))
  months <- format(twindow, "%m")

  if (any(is.null(years), is.null(months))){

    message(paste("This function cannot be executed because your twindow",
                  "is not in the correct format.",
                  "Please enter a suitable twindow, then try again."))

  }else{

    selectedfilePaths <- c()

    for (myYear in years){

      myURL <- paste(inputLocation,
                     product, "_V", version, "/", myYear, "/", sep = "")

      filenames <- RCurl::getURL(myURL,
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
    # Change "3B43.12" according to your twindow.

    # fileConn <- file(paste(outputfileLocation,"myTRMM.sh",sep=""))
    fileConn <- file("myTRMM.sh")
    shOut <- readLines(system.file(file.path("extdata", "trmm.sh"),
                                   package = "hddtools"), -1)
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

    # Crop TRMM raster based on areaBox, if necessary
    if ( raster::extent(bbSP) == raster::extent(trmm) ){
      message("Using full spatial extent.")
    }else{
      message("Cropping raster to areaBox extent.")
      trmm <- raster::crop(trmm, bbSP)
    }

    # raster::writeRaster(trmm,
    #                     filename = "trmm_acc.tif",
    #                     format = "GTiff",
    #                     overwrite = TRUE)

    message("Removing temporary files")
    file.remove(c("TRMM.vrt", "myTRMM.sh"))

    # message(paste("Done. The raster-brick was saved in",
    #               paste(outputfileLocation, "/trmm_acc.tif", sep = "")))

  }

  on.exit(expr = {setwd(originalwd)})

  # return(paste(outputfileLocation, "/trmm_acc.tif", sep = ""))
  return(trmm)

}
