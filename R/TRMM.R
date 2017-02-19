#' Download and convert TRMM data
#'
#' @author Claudia Vitolo
#'
#' @description The TRMM dataset provide global historical rainfall estimation in a gridded format.
#'
#' @param product this is the code that identifies a product, default is "3B43"
#' @param version this is the version number, default is 7
#' @param type this is the type of information needed, default is "precipitation.accum". Other types could be "gaugeRelativeWeighting.bin" and "relativeError.bin"
#' @param twindow is a vector of dates and times for which the data should be retrieve
#' @param areaBox OPTIONAL bounding box, a list made of 4 elements: minimum longitude (xmin), minimum latitude (ymin), maximum longitude (xmax), maximum latitude (ymax)
#' @param method method to download, see \code{?download.file} for more info.
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
#'
#'   # Get 3-hourly data
#'   twindow <- seq(from = as.POSIXct("2012-1-1 0","%Y-%m-%d %H", tz="UTC"),
#'                  to = as.POSIXct("2012-1-1 23", "%Y-%m-%d %H", tz="UTC"),
#'                  by = 3*60*60)
#'   TRMMfile <- TRMM(product = "3B42", version = 7,
#'                    type = "precipitation.bin",
#'                    twindow = twindow, areaBox = areaBox)
#'   raster::plot(TRMMfile)
#'
#'   # Get monthly data
#'   twindow <- seq(from=as.Date("2012-01-01"),
#'                  to=as.Date("2012-02-28"),
#'                  by = "months")
#'   TRMMfile <- TRMM(product = "3B43", version = 7,
#'                    type = "precipitation.accum",
#'                    twindow = twindow, areaBox = areaBox)
#'   raster::plot(TRMMfile)
#' }
#'

TRMM <- function(product = "3B43",
                 version = 7,
                 type = "precipitation.accum",
                 twindow = NULL,
                 areaBox = NULL,
                 method = "auto"){

  # twindow contains dates and it can be used to identify the files to download
  rootURL <- "ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/"
  if (is.null(twindow)){
    stop("Please enter valid twindow")
  }else{
    filesURLs <- c()
    for (i in seq_along(twindow)){
      mydate <- twindow[i]
      if (product == "3B42"){
        myyear <- unique(format(mydate, "%Y"))
        mymonth <- format(mydate, "%m")
        myday <- format(mydate, "%d")
        myhour <- format(mydate, "%H")
        filePaths <- paste0(rootURL, product, "_V", version, "/",
                            myyear, mymonth, "/",
                            product, ".",
                            substr(x = myyear, start = 3, stop = 4),
                            mymonth, myday, ".", myhour, "z", ".", version, ".",
                            type)
      }
      if (product == "3B43"){
        myyear <- unique(format(mydate, "%Y"))
        mymonth <- format(mydate, "%m")
        filePaths <- paste0(rootURL, product, "_V", version, "/", myyear, "/",
                            product, ".",
                            substr(x = myyear, start = 3, stop = 4),
                            mymonth, "01.", version, ".", type)
      }
      filesURLs <- c(filesURLs, filePaths)
    }
  }

  # create a temporary directory
  td = tempdir()
  originalwd <- getwd()
  setwd(td)

  failedFiles <- c()
  for (j in seq_along(filesURLs)){

    x <- try(expr = download.file(url = filesURLs[j],
                                  destfile = file.path(td,
                                                       basename(filesURLs[j])),
                                  method = method, mode = "wb"),
             silent = TRUE)

    if (class(x) == "try-error") {
      failedFiles <- c(failedFiles, filesURLs[j])
    }
  }

  if (length(failedFiles) > 0) {
    message("The following files are currently not available for download: \n")
    print(failedFiles)
  }

  if (length(failedFiles) < length(filesURLs)){

    # Now I create a virtual file as the downloaded TRMM data come as binaries.
    # The VRT-file contains all the downloaded binary files with the appropriate
    # geo-informations.
    # To automate the process, there is a template script in inst/trmm.sh that
    # generates the VRT-file (TRMM.vrt) for all 2012 data.
    # Change "3B43.12" according to your twindow.
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
      message(paste0("Beware this function was tested on a unix machine. ",
                     "Please report any issues here: \n",
                     "https://github.com/ropensci/hddtools/issues"))
    }
    system(paste("sh","myTRMM.sh"))

    b <- raster::brick("TRMM.vrt")
    trmm <- raster::flip(b, direction = "y")
    # raster::plot(trmm)

    # Check bounding box extent is within original raster extent,
    # if not return intersect of the two extents
    if (is.null(areaBox)){
      # Use TRMM max extent
      areaBox <- raster::extent(-180, +180, -50, +50)
    }

    areaBox <- raster::intersect(areaBox, raster::extent(-180, +180, -50, +50))
    bbSP <- bboxSpatialPolygon(areaBox)

    # Crop TRMM raster based on areaBox, if necessary
    if ( raster::extent(bbSP) == raster::extent(trmm) ){
      message("Using full spatial extent.")
    }else{
      message("Cropping raster to areaBox extent.")
      trmm <- raster::crop(trmm, bbSP)
    }

    message("Removing temporary files")
    file.remove(c("TRMM.vrt", "myTRMM.sh"))

    return(trmm)

  }else{
    message("There are no files available, try a different temporal window.")
  }

  on.exit(expr = {setwd(originalwd)})

}
