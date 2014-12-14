#' Interface for the MOPEX database catalogue
#' 
#' @author Claudia Vitolo
#' 
#' @description This function interfaces the MOPEX database catalogue (available from ftp://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/) containing 438 daily datasets.
#' 
#' @param bbox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)   
#' @param metadataColumn name of the column to filter
#' @param entryValue value to look for in the column named metadataColumn
#' @param verbose if TRUE it returns whether the data is coming from live or cached data sources
#' 
#' @return This function returns a data frame made of 5 columns: "id" (hydrometric reference number), "name", "location", "Latitude" and "Longitude".
#' 
#' @export
#' 
#' @examples 
#' # Retrieve the whole catalogue
#' # mopexCatalogue()
#' 

mopexCatalogue <- function(bbox=NULL, 
                           metadataColumn=NULL, entryValue=NULL,
                           verbose=FALSE){
  
  # require(XML)
  # require(RCurl)
  
  theurl <- "ftp://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily" 
  
  if(url.exists(theurl)) {
    if (verbose == TRUE) message("Retrieving data from live web data source.")
    x <- getContent(theurl)
    stationID <- c()
    for (i in 1:length(x)) {
      if ( !grepl("readme.txt", x[i]) ){
        stationID <- c(stationID, substr(x[i],66,73))
      }
    }
  }else{
    if (verbose == TRUE) message("The connection with the live web data source failed. No cached results available.")
  } 
  
  myTable <- data.frame("id"=stationID)
  myTable$name <- NA
  myTable$location <- NA
  myTable$Latitude <- NA
  myTable$Longitude <- NA  
  
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
#' # mopexTS("14359000")
#' 

mopexTS <- function(hydroRefNumber, plotOption=FALSE, timeExtent = NULL){
  
  # require(zoo)
  # require(XML)
  # require(RCurl)
  
  theurl <- paste("ftp://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/",hydroRefNumber,".dly",sep="")
  
  if(url.exists(theurl)) {
    message("Retrieving data from live web data source.")   
    temp <- getURL(theurl, ftp.use.epsv = FALSE) 
    temp2 <- unlist(strsplit(temp,"\r\n"))
    
    # From readme.txt
    # Col. 1: date (yyyymmdd)
    #      2: mean areal precipitation (mm)
    #      3: climatic potential evaporation (mm)
    #         (based NOAA Freewater Evaporation Atlas)
    #      4: daily streamflow discharge (mm)
    #      5: daily maximum air temperature (Celsius)
    #      6: daily minimum air temperature (Celsius)
    
    date <- c()    
    P <- c() 
    E <- c() 
    Q <- c() 
    Tmax <- c() 
    Tmin <- c() 
    
    for ( i in 1:length(temp2) ){
      year <- as.numeric(substr(temp2[i],1,4))
      month <- as.numeric(substr(temp2[i],5,6))
      day <- as.numeric(substr(temp2[i],7,8))
      date <- c(date, as.character(as.POSIXct(paste(year,month,day,sep="-",
                                 format="%Y-%m-%d", tz = "UTC"))) )     
      P <- c(P, as.numeric(substr(temp2[i],9,18)) )
      E <- c(E, as.numeric(substr(temp2[i],19,28)) )
      Q <- c(Q, as.numeric(substr(temp2[i],29,38)) )
      Tmax <- c(Tmax, as.numeric(substr(temp2[i],39,48)) )
      Tmin <- c(Tmin, as.numeric(substr(temp2[i],49,58)) )   
    }
    
  }else{
    message("The connection with the live web data source failed. No cached results available.")
  }  
  
  # Coerse first column into a date
  datetime <- strptime(date, "%Y-%m-%d")
  P <- zoo(P,order.by=datetime) # measured in ?
  E <- zoo(E,order.by=datetime) # measured in ?
  Q <- zoo(Q,order.by=datetime) # measured in ?
  Tmax <- zoo(Tmax,order.by=datetime) # measured in ?
  Tmin <- zoo(Tmin,order.by=datetime) # measured in ?
  
  myTS <- merge(P,E,Q,Tmax,Tmin)
  
  if ( !is.null(timeExtent) ){
    
    myTS <- window(myTS,
                   start=as.POSIXct(head(timeExtent)[1]),
                   end=as.POSIXct(tail(timeExtent)[6]))
  }
  
  if (plotOption == TRUE){
    
#     temp <- mopexCatalogue(metadataColumn="id",entryValue=hydroRefNumber)
#     stationName <- as.character(temp$name)
#     plot(myTS, main=stationName, xlab="",ylab=c("P [mm/d]","Q [m3/s]"))
    
    plot(myTS, main="", xlab="",
         ylab = c("P [mm/day]","E [mm/day]", "Q [mm/day]", "Tmax [C]","Tmin [C]"))
    
  }
  
  return(myTS)
  
}
