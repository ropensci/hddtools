#' Interface for the MOPEX database catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the MOPEX database catalogue (available from ftp://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/) containing 438 daily datasets.
#'
#' @return This function returns a data frame made of 5 columns: "id" (hydrometric reference number), "name", "location", "Latitude" and "Longitude".
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the MOPEX catalogue
#'   catalogueMOPEX()
#' }
#'

catalogueMOPEX <- function(){

  # require(XML)
  # require(RCurl)

  myTable <- read.fwf(
    file = url(paste0("ftp://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/",
                      "Basin_Characteristics/usgs431.txt")),
    widths = c(8, 10, 10, 11, 11, 8, 8, 4, 4, 3, 9, 50)
    )
  myTable$V1 <- stringr::str_pad(myTable$V1, width=8, side="left", pad="0")

  names(myTable) <- c("id", "Longitude", "Latitude", "V4", "V5",
                      "start", "stop", "V8",
                      "V9", "STATEcode", "V11", "name")

  return(myTable)

}

#' Interface for the MOPEX database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and streamflow discharge at one of the MOPEX locations.
#'
#' @param hydroRefNumber hydrometric reference number
#' @param plotOption boolean to define whether to plot the results. By default this is set to TRUE.
#' @param timeExtent is a vector of dates and times for which the data should be retrieved
#'
#' @return The function returns a data frame containing 2 time series (as zoo objects): "P" (precipitation) and "Q" (discharge).
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   x <- tsMOPEX("14359000")
#' }
#'

tsMOPEX <- function(hydroRefNumber, plotOption=FALSE, timeExtent = NULL){

  # library(zoo)
  # library(XML)
  # library(RCurl)
  # library(stringr)
  # hydroRefNumber <- "14359000"

  theurl <- paste0("ftp://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/",
                   "Us_438_Daily/",hydroRefNumber,".dly")

  if(url.exists(theurl)) {
    message("Retrieving data from live web data source.")

    myTable <- read.fwf(
      file = url(theurl),
      widths = c(4, 2, 2, 10, 10, 10, 10, 10)
    )
    myTable[,2] <- stringr::str_pad(myTable[,2], width=2, side="left", pad="0")
    myTable[,3] <- stringr::str_pad(myTable[,3], width=2, side="left", pad="0")

    date <- paste(myTable[,1], "-", myTable[,2], "-", myTable[,3], sep = "")
    x <- data.frame(date, myTable[,4:8])
    names(x) <- c("date", "P", "E", "Q", "Tmax", "Tmin")

  }else{
    message(paste("The connection with the live web data source failed.",
                  "No cached results available."))
  }

  # From readme.txt
  # Col. 1: date (yyyymmdd)
  #      2: mean areal precipitation (mm)
  #      3: climatic potential evaporation (mm)
  #         (based NOAA Freewater Evaporation Atlas)
  #      4: daily streamflow discharge (mm)
  #      5: daily maximum air temperature (Celsius)
  #      6: daily minimum air temperature (Celsius)

  myTS <- zoo(x[,2:6], order.by = as.Date(x$date))

  if ( !is.null(timeExtent) ){

    myTS <- window(myTS,
                   start=as.POSIXct(head(timeExtent)[1]),
                   end=as.POSIXct(tail(timeExtent)[6]))
  }

  if (plotOption == TRUE){

    plot(myTS, main="", xlab="",
         ylab = c("P [mm/day]","E [mm/day]",
                  "Q [mm/day]", "Tmax [C]","Tmin [C]"))

  }

  return(myTS)

}
