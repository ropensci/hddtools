#' Interface for the Data60UK database catalogue
#' 
#' @author Claudia Vitolo
#' 
#' @description This function interfaces the Data60UK database catalogue (available from http://www.nwl.ac.uk/ih/nrfa/pub/index.html) containing 61 datasets. Dataset catalogue is available from http://www.nwl.ac.uk/ih/nrfa/pub/data.html. 
#' 
#' @param lonMin Minimum latitude of bounding box
#' @param lonMax Maximum latitude of bounding box
#' @param latMin Minimum longitude of bounding box
#' @param latMax Maximum longitude of bounding box 
#' 
#' @return This function returns a data frame made of 5 columns: "id" (hydrometric reference number), "name", "location", "Latitude" and "Longitude".
#' 
#' @export
#' 
#' @examples 
#' # Data60UKCatalogue()
#' # Data60UKCatalogue(lonMin=-3.82,lonMax=-3.63,latMin=52.41,latMax=52.52)
#' 

Data60UKCatalogue <- function(lonMin=-180,lonMax=+180,latMin=-90,latMax=+90){
  
  # require(XML)
  # require(rnrfa)
  
  # lonMin=-3.82;lonMax=-3.63;latMin=52.41;latMax=52.52
  # Latitude is the Y axis, longitude is the X axis.  
  
  load(system.file("data/stationSummary.rda", package = 'rnrfa'))
  stationSummary <- stationSummary
    
  theurl <- "http://www.nwl.ac.uk/ih/nrfa/pub/data.html"
  tables <- readHTMLTable(theurl)
  n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
  temp <- tables[[which.max(n.rows)]]
  names(temp)[1:3] <- c("id","name","location")
  
  refNumbers <- as.character(temp$id)
  stationID <- as.character(stationSummary$id)
  temp$Latitude <- stationSummary[match(refNumbers,stationID),"Latitude"]
  temp$Longitude <- stationSummary[match(refNumbers,stationID),"Longitude"]
  
  myTable <- subset(temp, (temp$Latitude <= latMax & temp$Latitude >= latMin & temp$Longitude <= lonMax & temp$Longitude >= lonMin) )
  
  return(myTable)
  
}

#' Interface for the Data60UK database of Daily Time Series
#' 
#' @author Claudia Vitolo
#' 
#' @description This function extract the dataset containing daily rainfall and streamflow discharge at one of the Data60UK locations. 
#' 
#' @param hydroRefNumber hydrometric reference number
#' 
#' @return The function returns a data frame containing 2 time series (as zoo objects): "P" (precipitation) and "Q" (discharge).
#' 
#' @export
#' 
#' @examples 
#' # Data60UKDailyTS(62001)
#' 

Data60UKDailyTS <- function(hydroRefNumber){
  
  # require(zoo)
  # require(XML)
  
  theurl <- paste("http://www.nwl.ac.uk/ih/nrfa/pub/data/rq",hydroRefNumber,".txt",sep="")
  temp <- read.table(theurl)
  names(temp) <- c("P","Q","DayNumber","Year","nStations")
  
  # Combine the first four columns into a character vector
  date_info <- with(temp, paste(Year, DayNumber))
  # Parse that character vector
  datetime <- strptime(date_info, "%Y %j")
  P <- zoo(temp$P,order.by=datetime) # measured in mm
  Q <- zoo(temp$Q,order.by=datetime) # measured in m3/s
  
  myTS <- merge(P,Q)
  
  return(myTS)
  
}
