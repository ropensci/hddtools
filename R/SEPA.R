#' Interface for the SEPA database catalogue
#' 
#' @author Claudia Vitolo
#' 
#' @description This function provides an unofficial SEPA database catalogue of river level data (available from http://pennine.ddns.me.uk/riverlevels/ConciseList.html) containing info for 1752 stations. Some are NRFA stations.
#' 
#' @param bbox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)   
#' @param metadataColumn name of the column to filter
#' @param entryValue value to look for in the column named metadataColumn
#' @param verbose if TRUE it returns whether the data is coming from live or cached data sources
#' 
#' @return This function returns a data frame made of 9 columns: "idNRFA","aspxpage"           , "stationId", "River", "Location", "GridRef", "Operator", "CatchmentArea(km2)" and "note". Column idNRFA shows the National River Flow Archive station id. Column "aspxpage" returns the Environment Agency gauges id. The column "stationId" is the id number used by SEPA. Use these id numbers to retrieve the time series of water levels.
#' 
#' @export
#' 
#' @examples 
#' # Retrieve the whole catalogue
#' # catalogueSEPA()
#' 

catalogueSEPA <- function(bbox=NULL, 
                           metadataColumn=NULL, entryValue=NULL,
                           verbose=FALSE){
  
  # require(XML)
  # require(RCurl)
  
  theurl <- "http://pennine.ddns.me.uk/riverlevels/ConciseList.html"
  
  if(url.exists(theurl)) {
    if (verbose == TRUE) message("Retrieving data from live web data source.")
    tables <- readHTMLTable(theurl)
    n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
    SEPAcatalogue <- tables[[which.max(n.rows)]]
    SEPAcatalogue <- SEPAcatalogue[SEPAcatalogue$stationId!=0,c(1:3,5:9)]
    row.names(SEPAcatalogue) <- NULL
    names(SEPAcatalogue) <- c("idNRFA","aspxpage","stationId","River","Location",
                              "GridRef","Operator","CatchmentArea(km2)")
  }else{
    if (verbose == TRUE) message("The connection with the live web data source failed. Cached results are now loaded.")
    load(system.file("data/SEPAcatalogue.rda",package="hddtools"))
  }   
  
  return(SEPAcatalogue)
  
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
#' @return The function returns river level data in a zoo object.
#' 
#' @export
#' 
#' @examples 
#' # tsSEPA("234253")
#' 

tsSEPA <- function(hydroRefNumber, plotOption=FALSE, timeExtent = NULL){
  
  # require(zoo)
  # require(XML)
  # require(RCurl)
  
  myTS <- NULL
  myList <- list()
  counter <- 0
  
  for (id in as.list(hydroRefNumber)){
    counter <- counter + 1
    
    theurl <- paste("http://apps.sepa.org.uk/database/riverlevels/",
                    id,"-SG.csv",sep="")
    
    if(url.exists(theurl)) {
      message("Retrieving data from live web data source.")       
      sepaTS <- read.csv(theurl, skip = 6)   
      
      # Coerse first column into a date
      datetime <- strptime(sepaTS[,1], "%d/%m/%Y %H:%M")
      myTS <- zoo(sepaTS[,2], order.by=datetime) # measured in m
      
      if ( !is.null(timeExtent) ){
        
        myTS <- window(myTS,
                       start=as.POSIXct(head(timeExtent)[1]),
                       end=as.POSIXct(tail(timeExtent)[6]))
        
      }
      
      if (plotOption == TRUE){
        
        #     temp <- MOPEXCatalogue(metadataColumn="id",entryValue=hydroRefNumber)
        #     stationName <- as.character(temp$name)
        #     plot(myTS, main=stationName, xlab="",ylab=c("P [mm/d]","Q [m3/s]"))
        
        plot(myTS, main="", xlab="",
             ylab = "River level [m]")
        
      }
      
      myList[[counter]] <- myTS
      
    }else{
      message(paste("For station id",id, "the connection with the live web data source failed. No cached results available."))
    }
    
  }
  
  if (counter == 1) {
    return(myTS)
  }else{
    return(myList)
  }
  
}

