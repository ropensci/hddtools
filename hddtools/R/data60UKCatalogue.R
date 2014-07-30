#' Interface for the Data60UK database catalogue
#' 
#' @author Claudia Vitolo
#' 
#' @description This function interfaces the Data60UK database catalogue (available from http://www.nwl.ac.uk/ih/nrfa/pub/index.html) containing 61 datasets. Dataset catalogue is available from http://www.nwl.ac.uk/ih/nrfa/pub/data.html. 
#' 
#' @param BBlonMin Minimum latitude of bounding box
#' @param BBlonMax Maximum latitude of bounding box
#' @param BBlatMin Minimum longitude of bounding box
#' @param BBlatMax Maximum longitude of bounding box 
#' 
#' @return This function returns a data frame made of 5 columns: "id" (hydrometric reference number), "name", "location", "Latitude" and "Longitude".
#' 
#' @export
#' 
#' @examples 
#' # data60UKCatalogue()
#' # data60UKCatalogue(BBlonMin=-3.82,BBlonMax=-3.63,BBlatMin=52.41,BBlatMax=52.52)
#' 

data60UKCatalogue <- function(BBlonMin=-180,BBlonMax=+180,BBlatMin=-90,BBlatMax=+90){
  
  # require(sp)
  # require(rnrfa)
  # require(XML)
  
  # BBlonMin=-3.82;BBlonMax=-3.63;BBlatMin=52.41;BBlatMax=52.52
  # Latitude is the Y axis, longitude is the X axis.  
  
  data(StationSummary)
  
  theurl <- "http://www.nwl.ac.uk/ih/nrfa/pub/data.html"
  tables <- readHTMLTable(theurl)
  n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
  temp <- tables[[which.max(n.rows)]]
  names(temp)[1:3] <- c("id","name","location")
  
  refNumbers <- as.character(temp$id)
  stationID <- as.character(StationSummary$id)
  temp$Latitude <- StationSummary[match(refNumbers,stationID),"Latitude"]
  temp$Longitude <- StationSummary[match(refNumbers,stationID),"Longitude"]
  
  myTable <- subset(temp, (temp$Latitude <= BBlatMax & temp$Latitude >= BBlatMin & temp$Longitude <= BBlonMax & temp$Longitude >= BBlonMin) )
  
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
#' # data60UKDailyTS(62001)
#' 

data60UKDailyTS <- function(stationNumber){
  
  # require(XML)
  theurl <- paste("http://www.nwl.ac.uk/ih/nrfa/pub/data/rq",stationNumber,".txt",sep="")
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
