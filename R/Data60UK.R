#' Data source: Data60UK catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Data60UK database catalogue
#' listing 61 gauging stations.
#'
#' @param areaBox bounding box, a list made of 4 elements: minimum longitude
#' (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum
#' latitude (latMax)
#'
#' @return This function returns a data frame containing the following columns:
#' \describe{
#'   \item{\code{id}}{Station id number.}
#'   \item{\code{River}}{String describing the river's name.}
#'   \item{\code{Location}}{String describing the location.}
#'   \item{\code{gridReference}}{British National Grid Reference.}
#'   \item{\code{Latitude}}{}
#'   \item{\code{Longitude}}{}
#' }
#' 
#' @source \url{http://nrfaapps.ceh.ac.uk/datauk60/data.html}
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
#' }
#'

catalogueData60UK <- function(areaBox = NULL){

  file_url <- "http://nrfaapps.ceh.ac.uk/datauk60/data.html"

  tables <- XML::readHTMLTable(file_url)
  n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
  Data60UKcatalogue <- tables[[which.max(n.rows)]]
  names(Data60UKcatalogue) <- c("id", "River", "Location")
  Data60UKcatalogue[] <- lapply(Data60UKcatalogue, as.character)
  
  # Find grid reference browsing the NRFA catalogue
  temp <- rnrfa::catalogue()
  temp <- temp[which(temp$id %in% Data60UKcatalogue$id), ]
  
  Data60UKcatalogue$gridReference <- temp$`grid-reference`$ngr
  Data60UKcatalogue$Latitude <- temp$latitude
  Data60UKcatalogue$Longitude <- temp$longitude

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

  row.names(Data60UKcatalogue) <- NULL

  return(Data60UKcatalogue)

}

#' Interface for the Data60UK database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and streamflow discharge at one of the Data60UK locations.
#'
#' @param id String which identifies the station ID number
#'
#' @return The function returns a data frame containing 2 time series (as zoo objects): "P" (precipitation) and "Q" (discharge).
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   Morwick <- tsData60UK(id = "22001")
#' }
#'

tsData60UK <- function(id){

  file_url <- paste0("http://nrfaapps.ceh.ac.uk/datauk60/data/rq", id, ".txt")

  temp <- utils::read.table(file_url)
  names(temp) <- c("P", "Q", "DayNumber", "Year", "nStations")
  
  # Combine the first four columns into a character vector
  date_info <- with(temp, paste(Year, DayNumber))
  # Parse that character vector
  datetime <- strptime(date_info, "%Y %j")
  P <- zoo::zoo(temp$P, order.by = datetime) # measured in mm
  Q <- zoo::zoo(temp$Q, order.by = datetime) # measured in m3/s
  
  myTS <- zoo::merge.zoo(P,Q)
  
  return(myTS)

}
