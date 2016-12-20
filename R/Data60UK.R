#' Data source: Data60UK catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Data60UK database catalogue (available from http://www.nwl.ac.uk/ih/nrfa/pub/index.html) containing 61 datasets. Dataset catalogue is available from \url{http://www.nwl.ac.uk/ih/nrfa/pub/data.html}.
#'
#' @param areaBox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)
#' @param columnName name of the column to filter
#' @param columnValue value to look for in the column named columnName
#' @param cached boolean value. Default is TRUE (use cached datasets).
#'
#' @return This function returns a data frame made of 61 rows (gauging stations) and 6 columns: "id" (hydrometric reference number), "River", "Location", "gridReference", "Latitude", "Longitude".
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the whole catalogue
#'   x <- catalogueData60UK()
#'
#'   # Define a bounding box
#'   areaBox <- raster::extent(c(-4, -2, +52, +53))
#'   # Filter the catalogue
#'   x <- catalogueData60UK(areaBox)
#'   x <- catalogueData60UK(columnName = "id", columnValue = "62001")
#' }
#'

catalogueData60UK <- function(areaBox = NULL, columnName = NULL,
                              columnValue = NULL, cached = TRUE){

  Data60UKcatalogue <- NULL

  # Latitude is the Y axis, longitude is the X axis.
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

  if (cached == FALSE){

    message("Downloading data from source")
    # Check the url
    theurl <- "http://nrfaapps.ceh.ac.uk/datauk60/data.html"

    if( url.exists(theurl) ) {

      message("Retrieving data from live web data source.")

      tables <- XML::readHTMLTable(theurl)
      n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
      myTable <- tables[[which.max(n.rows)]]
      names(myTable) <- c("id", "River", "Location")
      IDs <- unlist(as.numeric(as.character(myTable$id)))

      # Find grid reference browsing the NRFA catalogue
      temp <- rnrfa::catalogue(columnName = "id", columnValue = IDs)
      refs <- temp$gridReference
      myTable$gridReference <- unlist(refs)

      myTable$Latitude <- temp$lat
      myTable$Longitude <- temp$lon

    }

  }else{

    message("Using cached data.")
    load(system.file("data/Data60UKcatalogue.rda", package = "hddtools"))
    myTable <- Data60UKcatalogue

  }

  myTable <- subset(myTable, (myTable$Latitude <= latMax &
                                myTable$Latitude >= latMin &
                                myTable$Longitude <= lonMax &
                                myTable$Longitude >= lonMin) )

  if (!is.null(columnName) & !is.null(columnValue)){

    if (columnName == "id" |
        columnName == "name" |
        columnName == "location"){
      myTable <- myTable[which(myTable[,columnName] == columnValue),]
    }else{
      message(paste("columnName can only be one of the following:",
                    "id, name, location"))
    }

  }

  row.names(myTable) <- NULL

  return(myTable)

}

#' Interface for the Data60UK database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and streamflow discharge at one of the Data60UK locations.
#'
#' @param hydroRefNumber hydrometric reference number (string)
#' @param plotOption boolean to define whether to plot the results. By default this is set to TRUE.
#' @param twindow is a vector of dates and times for which the data should be retrieved
#'
#' @return The function returns a data frame containing 2 time series (as zoo objects): "P" (precipitation) and "Q" (discharge).
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   tsData60UK(hydroRefNumber = 39015)
#' }
#'

tsData60UK <- function(hydroRefNumber, plotOption = FALSE, twindow = NULL){

  # require(zoo)
  # require(XML)
  # require(RCurl)

  theurl <- paste("http://nrfaapps.ceh.ac.uk/datauk60/data/rq",
                  hydroRefNumber, ".txt", sep="")

  if( url.exists(theurl) ) {

    message("Retrieving data from live web data source.")
    temp <- read.table(theurl)
    names(temp) <- c("P", "Q", "DayNumber", "Year", "nStations")

    # Combine the first four columns into a character vector
    date_info <- with(temp, paste(Year, DayNumber))
    # Parse that character vector
    datetime <- strptime(date_info, "%Y %j")
    P <- zoo(temp$P, order.by = datetime) # measured in mm
    Q <- zoo(temp$Q, order.by = datetime) # measured in m3/s

    myTS <- merge(P,Q)

    if ( is.null(twindow) ){

      twindow <- seq(as.Date("1980-01-01"), as.Date("1990-12-31"),
                        by = "days")

    }

    myTS <- window(myTS,
                   start = as.POSIXct(head(twindow, n = 1)[1]),
                   end = as.POSIXct(tail(twindow, n = 1)[1]))

    if (plotOption == TRUE){

      temp <- catalogueData60UK(columnName = "id",
                                columnValue = hydroRefNumber)
      stationName <- as.character(temp$name)
      plot(myTS, main = stationName, xlab = "",
           ylab = c("P [mm/d]", "Q [m3/s]"))

    }

    return(myTS)

  }else{

    message("The connection with the live web data source failed.")

  }

}
