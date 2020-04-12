#' Data source: SEPA catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function provides the official SEPA database catalogue of
#' river level data
#' (from https://www2.sepa.org.uk/waterlevels/CSVs/SEPA_River_Levels_Web.csv)
#' containing info for hundreds of stations. Some are NRFA stations.
#' The function has no input arguments.
#'
#' @return This function returns a data frame containing the following columns:
#' \describe{
#'   \item{\code{SEPA_HYDROLOGY_OFFICE}}{}
#'   \item{\code{STATION_NAME}}{}
#'   \item{\code{LOCATION_CODE}}{Station id number.}
#'   \item{\code{NATIONAL_GRID_REFERENCE}}{}
#'   \item{\code{CATCHMENT_NAME}}{}
#'   \item{\code{RIVER_NAME}}{}
#'   \item{\code{GAUGE_DATUM}}{}
#'   \item{\code{CATCHMENT_AREA}}{in Km2}
#'   \item{\code{START_DATE}}{}
#'   \item{\code{END_DATE}}{}
#'   \item{\code{SYSTEM_ID}}{}
#'   \item{\code{LOWEST_VALUE}}{}
#'   \item{\code{LOW}}{}
#'   \item{\code{MAX_VALUE}}{}
#'   \item{\code{HIGH}}{}
#'   \item{\code{MAX_DISPLAY}}{}
#'   \item{\code{MEAN}}{}
#'   \item{\code{UNITS}}{}
#'   \item{\code{WEB_MESSAGE}}{}
#'   \item{\code{NRFA_LINK}}{}
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the whole catalogue
#'   SEPA_catalogue_all <- catalogueSEPA()
#' }
#'

catalogueSEPA <- function(){

  theurl <- paste0("https://www2.sepa.org.uk/waterlevels/CSVs/",
                   "SEPA_River_Levels_Web.csv")
  
  SEPAcatalogue <- utils::read.csv(theurl, stringsAsFactors = FALSE)
  SEPAcatalogue$CATCHMENT_NAME[SEPAcatalogue$CATCHMENT_NAME == "---"] <- NA
  SEPAcatalogue$WEB_MESSAGE[SEPAcatalogue$WEB_MESSAGE == ""] <- NA

  return(SEPAcatalogue)

}

#' Interface for the MOPEX database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and
#' streamflow discharge at one of the MOPEX locations.
#'
#' @param id hydrometric reference number (string)
#'
#' @return The function returns river level data in metres, as a zoo object.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   sampleTS <- tsSEPA(id = "10048")
#' }
#'

tsSEPA <- function(id){

  myTS <- NULL
  myList <- list()
  counter <- 0

  for (id in as.list(id)){
    counter <- counter + 1

    theurl <- paste("https://www2.sepa.org.uk/waterlevels/CSVs/",
                    id, "-SG.csv", sep = "")

    if(RCurl::url.exists(theurl)) {
      
      sepaTS <- utils::read.csv(theurl, skip = 6)

      # Coerse first column into a date
      datetime <- strptime(sepaTS[,1], "%d/%m/%Y %H:%M")
      myTS <- zoo::zoo(sepaTS[,2], order.by = datetime) # measured in m

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

