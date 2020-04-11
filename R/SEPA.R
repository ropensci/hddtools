#' Data source: SEPA catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function provides the official SEPA database catalogue of
#' river level data
#' (from http://apps.sepa.org.uk/database/riverlevels/SEPA_River_Levels_Web.csv)
#' containing info for hundreds of stations. Some are NRFA stations.
#'
#' @param columnName name of the column to filter
#' @param columnValue value to look for in the column named columnName
#' @param useCachedData logical, set to TRUE to use cached data, set to FALSE to retrive data from online source. This is TRUE by default.
#'
#' @return This function returns a data frame made of a maximum of 830 rows (stations) and 8 columns: "idNRFA","aspxpage", "stationId", "River", "Location", "GridRef", "Operator" and "CatchmentArea(km2)". Column idNRFA shows the National River Flow Archive station id. Column "aspxpage" returns the Environment Agency gauges id. The column "stationId" is the id number used by SEPA. Use the stationId to retrieve the time series of water levels.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the whole catalogue
#'   SEPA_catalogue_all <- catalogueSEPA()
#'
#'   # Get only catchments with area above 5000 Km2
#'   SEPA_catalogue_area <- catalogueSEPA(columnName = "CatchmentAreaKm2",
#'                                        columnValue = ">= 5000")
#'
#'   # Get only catchments within river Avon
#'   SEPA_catalogue_river <- catalogueSEPA(columnName = "River",
#'                                         columnValue = "Avon")
#' }
#'

catalogueSEPA <- function(columnName = NULL, columnValue = NULL,
                          useCachedData = FALSE){

  theurl <- paste0("https://www2.sepa.org.uk/waterlevels/CSVs/",
                   "SEPA_River_Levels_Web.csv")

  if (RCurl::url.exists(theurl) == FALSE | useCachedData == TRUE){

    message("Using cached data.")

    load(system.file(file.path("data", "SEPAcatalogue.rda"),
                     package = "hddtools"))

    catTMP <- SEPAcatalogue

  }else{

    message("Retrieving data from data provider.")

    catTMP <- utils::read.csv(theurl, stringsAsFactors = FALSE)
    catTMP$WEB_MESSAGE <- as.character(catTMP$WEB_MESSAGE)

  }

  if (!is.null(columnName) & !is.null(columnValue)){

    if (tolower(columnName) %in% tolower(names(catTMP))){

      col2select <- which(tolower(names(catTMP)) == tolower(columnName))

      if (class(catTMP[, col2select]) == "character"){
        rows2select <- which(tolower(catTMP[, col2select]) ==
                               tolower(columnValue))
      }
      if (class(catTMP[,col2select]) == "numeric" |
          class(catTMP[, col2select]) == "integer"){

        rows2select <- eval(parse(text =
                                    paste0("which(catTMP[,col2select] ",
                                           columnValue, ")")))

      }
      SEPAcatalogue <- catTMP[rows2select,]

    }else{

      message("columnName should be one of the columns of the catalogue")

    }

  }else{

    SEPAcatalogue <- catTMP

  }

  return(SEPAcatalogue)

}

#' Interface for the MOPEX database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and streamflow discharge at one of the MOPEX locations.
#'
#' @param stationID hydrometric reference number (string)
#' @param plotOption boolean to define whether to plot the results. By default this is set to TRUE.
#' @param timeExtent is a vector of dates and times for which the data should be retrieved
#'
#' @return The function returns river level data in a zoo object.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   sampleID <- catalogueSEPA()$stationId[1]
#'   sampleTS <- tsSEPA(stationID = sampleID, plotOption = TRUE)
#' }
#'

tsSEPA <- function(stationID, plotOption = FALSE, timeExtent = NULL){

  myTS <- NULL
  myList <- list()
  counter <- 0

  for (id in as.list(stationID)){
    counter <- counter + 1

    theurl <- paste("https://www2.sepa.org.uk/waterlevels/CSVs/",
                    id, "-SG.csv", sep = "")

    if(RCurl::url.exists(theurl)) {
      message("Retrieving data from data provider.")
      sepaTS <- utils::read.csv(theurl, skip = 6)

      # Coerse first column into a date
      datetime <- strptime(sepaTS[,1], "%d/%m/%Y %H:%M")
      myTS <- zoo::zoo(sepaTS[,2], order.by = datetime) # measured in m

      if ( !is.null(timeExtent) ){

        myTS <- window(myTS,
                       start=as.POSIXct(range(timeExtent)[1]),
                       end=as.POSIXct(range(timeExtent)[2]))

      }

      if (plotOption == TRUE){

        locationSEPA <- catalogueSEPA(columnName = "LOCATION_CODE",
                                      columnValue = paste("==", id))
        plot(myTS, main = locationSEPA$STATION_NAME,
             xlab = "", ylab = "River level [m]")

      }

      myList[[counter]] <- myTS

    }else{
      message(paste("For station id", id,
                    "the connection with the data provider failed.",
                    "No cached results available."))
    }

  }

  if (counter == 1) {
    return(myTS)
  }else{
    return(myList)
  }

}

