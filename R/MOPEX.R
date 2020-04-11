#' Data source: MOPEX catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the MOPEX database catalogue (available
#' from \url{https://hydrology.nws.noaa.gov/gcip/mopex/US_Data/Basin_Characteristics/usgs431.txt})
#' containing 431 daily datasets.
#'
#' @param areaBox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)
#' @param columnName name of the column to filter
#' @param columnValue value to look for in the column named columnName
#' @param useCachedData logical, set to TRUE to use cached data, set to FALSE to retrive data from online source. This is TRUE by default.
#'
#' @return This function returns a data frame made of 431 rows (gauging stations) and 12 columns containing stations metadata.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the MOPEX catalogue
#'   MOPEX_catalogue_all <- catalogueMOPEX()
#'
#'   # Define a bounding box
#'   areaBox <- raster::extent(-95, -92, 37, 41)
#'   # Filter the catalogue based on bounding box
#'   MOPEX_catalogue_bbox <- catalogueMOPEX(areaBox = areaBox)
#'
#'   # Get only catchments within NC
#'   MOPEX_catalogue_state <- catalogueMOPEX(columnName = "state",
#'                                           columnValue = "NC")
#'
#' }
#'

catalogueMOPEX <- function(areaBox = NULL,
                           columnName = NULL, columnValue = NULL,
                           useCachedData = TRUE){

  theurl <- paste0("https://hydrology.nws.noaa.gov/gcip/mopex/US_Data/",
                   "Basin_Characteristics/usgs431.txt")

  MOPEXcatalogue <- NULL

  if (useCachedData == TRUE | RCurl::url.exists(theurl) == FALSE){

    # message("Using cached data.")

    load(system.file(file.path("data", "MOPEXcatalogue.rda"),
                     package = "hddtools"))

    myTable <- MOPEXcatalogue

  }else{

    myTable <- utils::read.fwf(file = url(theurl),
                               widths = c(8, 10, 10, 11, 11, 8,
                                          8, 4, 4, 3, 9, 50))

    myTable$V1 <- sprintf("%08d", myTable$V1)
    # stringr::str_pad(myTable$V1, width = 8, side = "left", pad = "0")

    names(myTable) <- c("stationID", "longitude", "latitude", "elevation", "V5",
                        "datestart", "dateend", "V8",
                        "V9", "state", "V11", "basin")

    myTable[] <- lapply(myTable, as.character)
    myTable$longitude <- as.numeric(myTable$longitude)
    myTable$latitude <- as.numeric(myTable$latitude)
    myTable$elevation <- as.numeric(myTable$elevation)

  }

  if (!is.null(areaBox)){
    lonMin <- areaBox@xmin
    lonMax <- areaBox@xmax
    latMin <- areaBox@ymin
    latMax <- areaBox@ymax
  }else{
    lonMin <- -180
    lonMax <- +180
    latMin <- -90
    latMax <- +90
  }

  mopexSelected <- subset(myTable, (myTable$latitude <= latMax &
                                      myTable$latitude >= latMin &
                                      myTable$longitude <= lonMax &
                                      myTable$longitude >= lonMin))

  if (!is.null(columnName) & !is.null(columnValue)){

    if (tolower(columnName) %in% tolower(names(mopexSelected))){

      col2select <- which(tolower(names(mopexSelected)) ==
                            tolower(columnName))

      if (class(mopexSelected[,col2select]) == "character"){
        rows2select <- which(tolower(trimws(mopexSelected[,col2select])) ==
                               tolower(columnValue))
      }
      if (class(mopexSelected[,col2select]) == "numeric"){
        rows2select <- eval(parse(text =
                                    paste0("which(mopexSelected[,col2select] ",
                                           columnValue, ")")))
      }
      mopexTable <- mopexSelected[rows2select,]

    }else{

      message("columnName should be one of the columns of the catalogue")

    }

  }else{

    mopexTable <- mopexSelected

  }

  return(mopexTable)

}

#' Interface for the MOPEX database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and
#' streamflow discharge at one of the MOPEX locations.
#'
#' @param stationID hydrometric reference number (string)
#' @param plotOption boolean to define whether to plot the results. By default
#' this is set to TRUE.
#' @param timeExtent is a vector of dates and times for which the data should be
#' retrieved
#'
#' @return The function returns a data frame containing 2 time series (as zoo
#' objects): "P" (precipitation) and "Q" (discharge).
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   stationID <- catalogueMOPEX()$stationID[1]
#'   BroadRiver <- tsMOPEX(stationID = stationID)
#'   BroadRiver <- tsMOPEX(stationID = stationID, plotOption = TRUE)
#' }
#'

tsMOPEX <- function(stationID, plotOption = FALSE, timeExtent = NULL){

  theurl <- paste0("https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/",
                   "Us_438_Daily/", stationID, ".dly")

  if(RCurl::url.exists(theurl)) {

    message("Retrieving data from data provider.")

    myTable <- utils::read.fwf(file = url(theurl),
                               widths = c(4, 2, 2, 10, 10, 10, 10, 10))
    myTable[,2] <- sprintf("%02d", myTable[,2])
    # stringr::str_pad(myTable[,2], width = 2, side = "left", pad = "0")
    myTable[,3] <- sprintf("%02d", myTable[,3])
    # stringr::str_pad(myTable[,3], width = 2, side = "left", pad = "0")

    date <- paste(myTable[,1], "-", myTable[,2], "-", myTable[,3], sep = "")
    x <- data.frame(date, myTable[,4:8])
    names(x) <- c("date", "P", "E", "Q", "Tmax", "Tmin")

    # From readme.txt
    # Col. 1: date (yyyymmdd)
    #      2: mean areal precipitation (mm)
    #      3: climatic potential evaporation (mm)
    #         (based NOAA Freewater Evaporation Atlas)
    #      4: daily streamflow discharge (mm)
    #      5: daily maximum air temperature (Celsius)
    #      6: daily minimum air temperature (Celsius)

    myTS <- zoo::zoo(x[,2:6], order.by = as.Date(x$date))
    myTS$Q[myTS$Q == -99] <- NA

    if (!is.null(timeExtent)){

      myTS <- window(myTS,
                     start=as.POSIXct(range(timeExtent)[1]),
                     end=as.POSIXct(range(timeExtent)[2]))

    }

    if (plotOption == TRUE){

      locationMOPEX <- catalogueMOPEX(columnName = "stationID",
                                      columnValue = stationID)
      plot(myTS, main=locationMOPEX$basin, xlab="",
           ylab = c("P [mm/day]","E [mm/day]",
                    "Q [mm/day]", "Tmax [C]","Tmin [C]"))

    }

    return(myTS)

  }else{

    stop("Failed connection with the data provider, no cached data available.")

  }

}
