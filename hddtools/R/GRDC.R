#' Interface for the Global Runoff Data Centre database catalogue
#' 
#' @author Claudia Vitolo
#' 
#' @description This function interfaces the Global Runoff Data Centre database which provides river discharge data for about 9000 sites over 157 countries.
#' 
#' @param stationID Station ID number, it should be in the range [1104150,6990700]
#' 
#' @param lonMin Minimum latitude of bounding box
#' @param lonMax Maximum latitude of bounding box
#' @param latMin Minimum longitude of bounding box
#' @param latMax Maximum longitude of bounding box 
#' 
#' @param mdDescription boolean value. Default is FALSE (no description is printed)
#' 
#' @return list of stations within the bounding box
#' 
#' @export
#' 
#' @examples 
#' GRDCCatalogue(lonMin=-3.82,lonMax=-3.63,latMin=52.43,latMax=52.52)
#' 

GRDCCatalogue <- function(stationID=NULL,
                          lonMin=-180,lonMax=+180,latMin=-90,latMax=+90,
                          mdDescription=FALSE){

  # Retrieve the catalogue
  temp <- system.file("GRDC/GRDC_Stations_20140320.csv", package = 'hddtools')
  grdcAll <- read.csv(temp,sep=",")
  
  if (!is.null(stationID)) {
    grdcSelected <- subset(grdcAll, (grdcAll$grdc_no==stationID) )
  }else{
    grdcSelected <- grdcAll
  }
  
  grdcSelectedBB <- subset(grdcSelected, (grdcSelected$lat <= latMax & grdcSelected$lat >= latMin & grdcSelected$lon <= lonMax & grdcSelected$lon >= lonMin) )
    
  if (mdDescription==FALSE){ 
    
    grdcTable <- grdcSelectedBB    
  
  }else{
    temp <- system.file("GRDC/GRDC_legend.csv", package = 'hddtools')
    grdcLegend <- read.csv(temp, header=F)
    
    grdcTable <- cbind(grdcLegend,t(grdcSelectedBB))
    row.names(grdcTable) <- NULL 
    grdcTable$V1 <- NULL
  }  
  
  return(grdcTable)
  
}

#' Interface for the Global Runoff Data Centre database of Monthly Time Series
#' 
#' @author Claudia Vitolo
#' 
#' @description This function interfaces the Global Runoff Data Centre monthly mean daily discharges database.
#' 
#' @param stationID 7 character number that identifies a station, GRDC station number is called "grdc no" in the catalogue.
#' 
#' @return The function returns a list of 3 tables: \describe{
#'   \item{\strong{mddPerYear}}{This is a table containing mean daily discharges for each single year (n records, one per year). It is made of 7 columns which description is as follows:}\itemize{
#'   \item LQ:    lowest monthly discharge of the given year
#'   \item month: associated month of occurrence
#'   \item MQ:    mean discharge of all monthly discharges in the given year
#'   \item HQ:    highest monthly discharge of the given year
#'   \item month: associated month of occurrence
#'   \item n:    number of available values used for MQ calculationFirst item
#' }
#'   \item{\strong{mddAllPeriod}}{This is a table containing mean daily discharges for the entire period (Calculated only from years with less than 2 months missing). It is made of 6 columns which description is as follows:}\itemize{
#'   \item LQ:   lowest monthly discharge from the entire period
#'   \item MQ_1: mean discharge of all monthly discharges in the period [m3/s]
#'   \item MQ_2: mean discharge volume per year of all monthly discharges in the period [km3/a]
#'   \item MQ_3: mean runoff per year of all monthly discharges in the period [mm/a]
#'   \item HQ:   highest monthly discharge from the entire periode
#'   \item n:    number of available months used for MQ calculation
#' }
#' \item{\strong{mddPerMonth}}{This is a table containing mean daily discharges for each month over the entire period (12 records covering max. n years. Calculated only for months with less then or equal to 10 missing days). It is made of 7 columns which description is as follows:}\itemize{
#'   \item LQ:    lowest monthly discharge of the given month in the entire period
#'   \item year:  associated year of occurrence (only the first occurence is listed)
#'   \item MQ:    mean discharge from all monthly discharges of the given month in the entire period
#'   \item HQ:    highest monthly discharge of the given month in the entire period
#'   \item year:  associated year of occurrence (only the first occurence is listed)
#'   \item std:   standard deviation of all monthly discharges of the given month in the entire period
#'   \item n:     number of available daily values used for computation
#' }
#' }
#' 
#' @details Please note that not all the GRDC stations listed in the catalogue have monthly data available.
#' 
#' @export
#' 
#' @examples 
#' # x <- GRDCMonthlyTS(stationID=1107700)
#' 

GRDCMonthlyTS <- function(stationID){
  
  options(warn=-1) 
  
  # Retrieve look-up table
  temp <- system.file("GRDC/GRDC_LTMMD.csv", package = 'hddtools')
  grdcLTMMD <- read.csv(temp,sep="\t") 
  
  # Retrieve WMO region from catalogue
  wmoRegion <- GRDCCatalogue(stationID)$wmo_reg
  
  # Retrieve ftp server location
  zipFile <- as.character(grdcLTMMD[which(grdcLTMMD$WMO.Region==wmoRegion),
                                    "Archive"])
  
  # create a temporary directory
  td <- tempdir()
  
  # create the placeholder file
  tf <- tempfile(tmpdir=td, fileext=".zip")
  
  # download into the placeholder file
  download.file(zipFile, tf)
  
  # get the name of the file to unzip
  fname <- paste("pvm_",stationID,".txt",sep="")
  
  # unzip the file to the temporary directory
  unzip(tf, files=fname, exdir=td, overwrite=TRUE)
  
  # fpath is the full path to the extracted file
  fpath = file.path(td, fname)  
    
  if ( file.exists(fpath) ){
    
    message("Station has monthly records")
    
    TS <- readLines(fpath)
    
    header1 <- as.numeric(as.character(c(grep("year;LQ;month;MQ;;HQ;month;m",TS))))
    header2 <- as.numeric(as.character(c(grep("LQ;MQ_1;MQ_2;MQ_3;HQ;n",TS))))
    header3 <- as.numeric(as.character(c(grep("month;LQ;year;MQ;HQ;year;std;n",TS))))
    headerTS <- c(header1,header2,header3)
    
    myTables <- list("mddPerYear"=NULL,"mddAllPeriod"=NULL,"mddPerMonth"=NULL)
    
    for (i in 1:3){
      header <- headerTS[i]
      skipTS <- as.numeric(as.character(grep("#",TS)))
      skip01 <- 1:header
      rowStart01 <- header + 1
      if ( length(skipTS[which(skipTS > header)]) > 0 ){
        skip02 <- skipTS[which(skipTS > header)]
        rowEnd01 <- skip02[1] - 1
      }else{
        rowEnd01 <- length(TS)
      }      
      firstTS <- TS[rowStart01:rowEnd01]
      numberOfCol <- length( unlist( strsplit(TS[rowStart01:rowEnd01],";")[1] ) )
      numberOfRow <- length( unlist( strsplit(TS[rowStart01:rowEnd01],";") ) ) / numberOfCol
      m <- matrix( as.numeric(as.character(unlist( strsplit(TS[rowStart01:rowEnd01],";") ) )), ncol=numberOfCol, nrow=numberOfRow, byrow=TRUE)
      m[m==-999] <- NA
      m <- data.frame(m)
      n <- unlist(strsplit(TS[header],";"))
      n <- n[n!=""]
      names(m) <- n
      
      myTables[[i]] <- m
      
    }
    
  }else{
    message("Station does not have monthly records")
  }
  
  return(myTables)
  
}
