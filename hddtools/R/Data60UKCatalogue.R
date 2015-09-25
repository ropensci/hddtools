#' Interface for the Data60UK database catalogue
#' 
#' @author Claudia Vitolo
#' 
#' @description This function interfaces the Data60UK database catalogue (available from http://www.nwl.ac.uk/ih/nrfa/pub/index.html) containing 61 datasets. Dataset catalogue is available from http://www.nwl.ac.uk/ih/nrfa/pub/data.html. 
#' 
#' @param bbox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)   
#' @param metadataColumn name of the column to filter
#' @param entryValue value to look for in the column named metadataColumn
#' @param verbose if TRUE it returns whether the data is coming from live or cached data sources
#' 
#' @return This function returns a data frame made of 5 columns: "id" (hydrometric reference number), "name", "location", "Latitude", "Longitude" and "area".
#' 
#' @export
#' 
#' @examples 
#' # Retrieve the whole catalogue
#' # Data60UKCatalogue()
#' 
#' # Define a bounding box
#' # bbox <- list(lonMin=-3.82,latMin=52.41,lonMax=-3.63,latMax=52.52)
#' 
#' # Filter the catalogue
#' # Data60UKCatalogue(bbox)
#' # Data60UKCatalogue(metadataColumn="id",entryValue="62001")
#' 

Data60UKCatalogue <- function(bbox=NULL, 
                              metadataColumn=NULL, entryValue=NULL,
                              verbose=FALSE){
  
  # require(XML)
  # require(RCurl)
  
  CatalogueData60UK <- NULL # to avoid note in check
  
  # Latitude is the Y axis, longitude is the X axis.  
  if (!is.null(bbox)){
    lonMin <- bbox$lonMin
    lonMax <- bbox$lonMax
    latMin <- bbox$latMin
    latMax <- bbox$latMax
  }else{    
    lonMin <- -180
    lonMax <- +180
    latMin <- -90
    latMax <- +90
  }  
  
  # Check the url
  theurl <- "http://nrfaapps.ceh.ac.uk/datauk60/data.html" 
  
  if( url.exists(theurl) ) {
    
    message("Retrieving data from live web data source.")
    
    tables <- readHTMLTable(theurl)
    n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
    myTable <- tables[[which.max(n.rows)]]
    names(myTable) <- c("id", "River", "Location")
    IDs <- unlist(as.numeric(as.character(myTable$id)))
    
    # Find grid reference browsing the NRFA catalogue
    temp <- NRFA_Catalogue(metadataColumn="id", entryValue=IDs)
    refs <- temp$gridReference
    myTable$gridReference <- unlist(refs)
    
    temp <- OSG2LatLon(OSGParse(unlist(refs)))
    myTable$Latitude <- temp$Latitude
    myTable$Longitude <- temp$Longitude
    
    myTable <- subset(myTable, (myTable$Latitude <= latMax & myTable$Latitude >= latMin & myTable$Longitude <= lonMax & myTable$Longitude >= lonMin) )
    
    if (!is.null(metadataColumn) & !is.null(entryValue)){
      
      if (metadataColumn == "id" | metadataColumn == "name" | metadataColumn == "location"){
        myTable <- myTable[which(myTable[,metadataColumn] == entryValue),]
      }else{
        message("metadataColumn can only be one of the following: id, name, location")
      }    
      
    } 
    
    row.names(myTable) <- NULL
    
    return(myTable)
    
  }else{
    
    message("The connection with the live web data source failed.")
    
  }
  
}

#' Interface for the Data60UK database of Daily Time Series
#' 
#' @author Claudia Vitolo
#' 
#' @description This function extract the dataset containing daily rainfall and streamflow discharge at one of the Data60UK locations. 
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
#' # Data60UKDailyTS(39015)
#' 

Data60UKDailyTS <- function(hydroRefNumber, 
                            plotOption=FALSE, 
                            timeExtent = NULL){
  
  # require(zoo)
  # require(XML)
  # require(RCurl)
  
  theurl <- paste("http://www.ceh.ac.uk/data/nrfa/data/data60uk/data/rq",
                  hydroRefNumber,".txt",sep="")
  
  if( url.exists(theurl) ) {
    
    message("Retrieving data from live web data source.")
    temp <- read.table(theurl) #temp <- readHTMLTable(theurl)
    names(temp) <- c("P","Q","DayNumber","Year","nStations")
    
    # Combine the first four columns into a character vector
    date_info <- with(temp, paste(Year, DayNumber))
    # Parse that character vector
    datetime <- strptime(date_info, "%Y %j")
    P <- zoo(temp$P,order.by=datetime) # measured in mm
    Q <- zoo(temp$Q,order.by=datetime) # measured in m3/s
    
    myTS <- merge(P,Q)
    
    if ( !is.null(timeExtent) ){
      
      myTS <- window(myTS,
                     start=as.POSIXct(head(timeExtent)[1]),
                     end=as.POSIXct(tail(timeExtent)[6]))
      
      temp <- Data60UKCatalogue(metadataColumn="id",entryValue=hydroRefNumber)
      stationName <- as.character(temp$name)
      plot(myTS, main=stationName, xlab="",ylab=c("P [mm/d]","Q [m3/s]"))
      
    }
    
    if (plotOption == TRUE){
      
      temp <- Data60UKCatalogue(metadataColumn="id",entryValue=hydroRefNumber)
      stationName <- as.character(temp$name)
      plot(myTS, main=stationName, xlab="",ylab=c("P [mm/d]","Q [m3/s]"))
      
    }
    
    return(myTS)
    
  }else{
    
    message("The connection with the live web data source failed.")
    
  }  
  
}
