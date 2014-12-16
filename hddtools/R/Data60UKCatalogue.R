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
#' @return This function returns a data frame made of 5 columns: "id" (hydrometric reference number), "name", "location", "Latitude" and "Longitude".
#' 
#' @export
#' 
#' @examples 
#' # Retrieve the whole catalogue
#' Data60UKCatalogue()
#' 
#' # Define a bounding box
#' bbox <- list(lonMin=-3.82,latMin=52.41,lonMax=-3.63,latMax=52.52)
#' 
#' # Filter the catalogue
#' Data60UKCatalogue(bbox)
#' Data60UKCatalogue(metadataColumn="id",entryValue="62001")
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
  
  load(system.file("data60UK/CatalogueData60UK.rda", package = 'hddtools'))
  
  # Old URL: "http://www.nwl.ac.uk/ih/nrfa/pub/data.html"
  theurl <- "http://www.ceh.ac.uk/data/nrfa/data/data60uk/data.html" 
  
  if( url.exists(theurl) ) {
    if (verbose == TRUE) message("Retrieving data from live web data source.")
    #tables <- readHTMLTable(theurl)
    #n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
    #temp <- tables[[which.max(n.rows)]]
    #names(temp)[1:3] <- c("id","name","location")    
    # refNumbers <- as.character(temp$id)
    # stationID <- as.character(stationSummary$id)
    # temp$Latitude <- stationSummary[match(refNumbers,stationID),"Latitude"]
    # temp$Longitude <- stationSummary[match(refNumbers,stationID),"Longitude"]
  }else{
    if (verbose == TRUE) message("The connection with the live web data source failed. Using cached results.")
  }  
  
  myTable <- subset(CatalogueData60UK, (CatalogueData60UK$Latitude <= latMax & CatalogueData60UK$Latitude >= latMin & CatalogueData60UK$Longitude <= lonMax & CatalogueData60UK$Longitude >= lonMin) )
  
  if (!is.null(metadataColumn) & !is.null(entryValue)){
    
    if (metadataColumn == "id" | metadataColumn == "name" | metadataColumn == "location"){
      myTable <- myTable[which(myTable[,metadataColumn] == entryValue),]
    }else{
      message("metadataColumn can only be one of the following: id, name, location")
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
  
  # Old URL: paste("http://www.nwl.ac.uk/ih/nrfa/pub/data/rq",hydroRefNumber,".txt",sep="")  
  theurl <- paste("http://www.ceh.ac.uk/data/nrfa/data/data60uk/data/rq",
                  hydroRefNumber,".txt",sep="")
  
  if(url.exists(theurl)) {
    message("Retrieving data from live web data source.")
    temp <- read.table(theurl)
  }else{
    message("The connection with the live web data source failed. Using cached results.")
    # create a temporary directory
    td <- tempdir()
    
    # create the placeholder file
    tf <- tempfile(tmpdir=td, fileext=".zip")
    
    # get the name of the file to unzip
    fname <- paste("data60uk/rq",hydroRefNumber,".txt",sep="")
    
    # unzip the file to the temporary directory    
    unzip(system.file("data60UK/data60uk.zip", 
                      package = 'hddtools'), exdir = td, overwrite=TRUE)
    
    # fpath is the full path to the extracted file
    fpath = file.path(td, fname) 
    
    temp <- read.table(fpath)
  }  
  
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
  
}
