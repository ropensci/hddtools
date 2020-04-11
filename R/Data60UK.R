#' Data source: Data60UK catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Data60UK database catalogue
#' (available from http://nrfaapps.ceh.ac.uk/datauk60/data.html) containing 61
#' datasets. Dataset catalogue is available from
#' \url{http://nrfaapps.ceh.ac.uk/datauk60/data.html}.
#'
#' @param areaBox bounding box, a list made of 4 elements: minimum longitude
#' (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum
#' latitude (latMax)
#' @param columnName name of the column to filter
#' @param columnValue value to look for in the column named columnName
#' @param useCachedData logical, set to TRUE to use cached data, set to FALSE to
#' retrieve data from online source. This is TRUE by default.
#'
#' @return This function returns a data frame made of 61 rows (gauging stations)
#' and 6 columns: "id" (hydrometric reference number), "River", "Location",
#' "gridReference", "Latitude", "Longitude".
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the whole catalogue
#'   Data60UK_catalogue_all <- catalogueData60UK()
#'
#'   # Filter the catalogue based on a bounding box
#'   areaBox <- raster::extent(-4, -2, +52, +53)
#'   Data60UK_catalogue_bbox <- catalogueData60UK(areaBox)
#'
#'   # Filter the catalogue based on an ID
#'   Data60UK_catalogue_ID <- catalogueData60UK(columnName = "stationID",
#'                                              columnValue = "62001")
#' }
#'

catalogueData60UK <- function(areaBox = NULL, columnName = NULL,
                              columnValue = NULL, useCachedData = TRUE){

  # Data60UKcatalogue <- NULL   # To avoid note

  theurl <- "http://nrfaapps.ceh.ac.uk/datauk60/data.html"

  if (useCachedData == TRUE | RCurl::url.exists(theurl) == FALSE){

    # message("Using cached data.")

    load(system.file(file.path("data", "Data60UKcatalogue.rda"),
                     package = "hddtools"))

  }else{

    message("Retrieving data from data provider.")

    tables <- XML::readHTMLTable(theurl)
    n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
    Data60UKcatalogue <- tables[[which.max(n.rows)]]
    names(Data60UKcatalogue) <- c("stationID", "River", "Location")
    Data60UKcatalogue[] <- lapply(Data60UKcatalogue, as.character)
    
    # Find grid reference browsing the NRFA catalogue
    temp <- rnrfa::catalogue()
    temp <- temp[which(temp$id %in% Data60UKcatalogue$stationID), ]
    
    Data60UKcatalogue$gridReference <- temp$`grid-reference`$ngr
    Data60UKcatalogue$Latitude <- temp$latitude
    Data60UKcatalogue$Longitude <- temp$longitude

  }

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

  Data60UKcatalogue <- subset(Data60UKcatalogue,
                              (Data60UKcatalogue$Latitude <= latMax &
                                 Data60UKcatalogue$Latitude >= latMin &
                                 Data60UKcatalogue$Longitude <= lonMax &
                                 Data60UKcatalogue$Longitude >= lonMin))

  if (!is.null(columnName) & !is.null(columnValue)){

    if (columnName == "stationID" |
        columnName == "name" |
        columnName == "location"){
      Data60UKcatalogue <- Data60UKcatalogue[which(
        Data60UKcatalogue[,columnName] == columnValue),]
    }else{
      message(paste("columnName can only be one of the following:",
                    "stationID, name, location"))
    }

  }

  row.names(Data60UKcatalogue) <- NULL

  return(Data60UKcatalogue)

}

#' Interface for the Data60UK database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and streamflow discharge at one of the Data60UK locations.
#'
#' @param stationID hydrometric reference number (string)
#' @param plotOption boolean to define whether to plot the results. By default this is set to FALSE.
#' @param twindow is a vector of dates and times for which the data should be retrieved
#'
#' @return The function returns a data frame containing 2 time series (as zoo objects): "P" (precipitation) and "Q" (discharge).
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   stationID <- catalogueData60UK()$stationID[1]
#'   Morwick <- tsData60UK(stationID = stationID)
#'   Morwick <- tsData60UK(stationID = stationID, plotOption = TRUE)
#' }
#'

tsData60UK <- function(stationID, plotOption = FALSE, twindow = NULL){

  theurl <- paste("http://nrfaapps.ceh.ac.uk/datauk60/data/rq",
                  stationID, ".txt", sep="")

  if(RCurl::url.exists(theurl)) {

    message("Retrieving data from data provider.")
    temp <- utils::read.table(theurl)
    names(temp) <- c("P", "Q", "DayNumber", "Year", "nStations")

    # Combine the first four columns into a character vector
    date_info <- with(temp, paste(Year, DayNumber))
    # Parse that character vector
    datetime <- strptime(date_info, "%Y %j")
    P <- zoo::zoo(temp$P, order.by = datetime) # measured in mm
    Q <- zoo::zoo(temp$Q, order.by = datetime) # measured in m3/s

    myTS <- zoo::merge.zoo(P,Q)

    if (is.null(twindow)){

      twindow <- seq.Date(from = as.Date("1980-01-01"),
                          to = as.Date("1990-12-31"),
                          by = "days")

    }

    myTS <- window(myTS,
                   start = as.POSIXct(range(twindow)[1]),
                   end = as.POSIXct(range(twindow)[2]))

    if (plotOption == TRUE){

      temp <- catalogueData60UK(columnName = "stationID",
                                columnValue = stationID)
      stationName <- as.character(temp$Location)
      plot(myTS, main = stationName, xlab = "",
           ylab = c("P [mm/d]", "Q [m3/s]"))

    }

    return(myTS)

  }else{

    message("The connection with the data provider failed.")

  }

}
