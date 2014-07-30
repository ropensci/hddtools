#' Download and convert TRMM data
#' 
#' @author Claudia Vitolo
#' 
#' @description The TRMM dataset provide global historical rainfall estimation in a gridded format.  
#' 
#' @param fileLocation file path where to save the GeoTiff
#' @param url url where data is stored (e.g. "ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/3B43_V7/2012/")
#' @param product this is the code that identifies a product, default is "3B43"
#' @param version this is the version number, default is 7
#' @param year year of interest, default is 2012
#' @param type this is the type of information needed, default is "precipitation.accum". Other types could be "gaugeRelativeWeighting.bin" and "relativeError.bin"
#' @param BBlonMin Minimum latitude of bounding box
#' @param BBlonMax Maximum latitude of bounding box
#' @param BBlatMin Minimum longitude of bounding box
#' @param BBlatMax Maximum longitude of bounding box
#' 
#' @return Data is loaded as rasterbrick, then converted to a multilayer Geotiff that can 
# be opened in any GIS software.
#' 
#' @details This code is based upon Martin Brandt's blog post: 
# http://matinbrandt.wordpress.com/2013/09/04/automatically-downloading-and-processing-trmm-rainfall-data/
#' and on the TRMM FAQ: http://disc.sci.gsfc.nasa.gov/additional/faq/precipitation_faq.shtml
#' 
#' @examples 
#' trmm(fileLocation="~/",url="ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",product="3B43",version=7,year=2012,BBlonMin=-3.82,BBlonMax=-3.63,BBlatMin=52.43,BBlatMax=52.52)
#'

trmm <- function(fileLocation = "~/",
                 url = "ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",
                 product = "3B43",
                 version = 7,
                 year = 2012,
                 type = "precipitation.accum",
                 BBlonMin = NULL,
                 BBlonMax = NULL,
                 BBlatMin = NULL,
                 BBlatMax = NULL
                 ){
  
  require(raster)
  require(rgdal)
  require(RCurl)
  
  setwd(fileLocation)
  
  myURL <- paste(url, product, "_V", version, "/", year, "/", sep="")
  # by default this is 
  # myURL <- "ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/3B43_V7/2012/"
  
  filenames <- getURL(myURL, ftp.use.epsv = FALSE, ftplistonly=TRUE, crlf=TRUE)
  
  filePaths <- paste(myURL, strsplit(filenames, "\r*\n")[[1]], sep="")
  
  # the following line allows to download only files with a certain pattern,
  # e.g. only certain months or days. 
  # "*precipitation.accum" means monthly accumulated rainfall here.
  selectedfilePaths <- filePaths[grep(filePaths, 
                                      pattern=paste("*",type,sep=""))] 
  
  # download files
  mapply(download.file, selectedfilePaths, basename(selectedfilePaths)) 
  
  # Now I create a virtual file as the downloaded TRMM data come as binaries. 
  # The VRT-file contains all the downloaded binary files with the appropriate 
  # geo-informations. 
  # To automate the process, there is a template script in inst/trmm.sh that 
  # generates the VRT-file (TRMM.vrt) for all 2012 data. 
  # Change “3B43.12″ accordingly to the downloaded data. 

  fileConn <- file(paste(fileLocation,"myTRMM.sh",sep=""))
  shOut <- readLines(system.file("trmm.sh", package="hddtools"),-1)
  shOut[3] <- paste(" <SRS>WGS84</SRS>' >",fileLocation,"TRMM.vrt;",sep="")
  shOut[4] <- paste("for i in 3B43.",substr(as.character(year),3,4),"*",sep="")
  shOut[11] <- paste(" </VRTRasterBand>' >>",fileLocation,"TRMM.vrt",sep="")
  shOut[13] <- paste("echo '</VRTDataset>' >>",fileLocation,"TRMM.vrt",sep="")
  writeLines(shOut, fileConn)
  close(fileConn)
  
  # Within R, the script (trmm.sh) is executed and the virtual-file (TRMM.vrt)
  # loaded as a rasterbrick. This is flipped in y direction and the files written 
  # as multilayer Geotiff. This Geotiff contains all the layers for 2012 and can 
  # be opened in every GIS software.
  
  system(paste("sh ",fileLocation,"myTRMM.sh",sep=""))
  b <- brick(paste(fileLocation,"TRMM.vrt",sep=""))
  
  trmm <- flip(b, direction='y')
  
  if (!is.null(BBlonMin) & !is.null(BBlonMax) & !is.null(BBlatMin) & !is.null(BBlatMax)){
    # crop to bounding box  
    e <- extent(BBlatMin, BBlatMax,BBlonMin, BBlonMax)
    trmm <- crop(trmm, e)
  }  
  
  writeRaster(trmm, 
              filename=paste(fileLocation,"trmm_acc_",year,".tif",sep=""), 
              format="GTiff", 
              overwrite=TRUE)
  
  message("Removing temporary files")
  mapply(file.remove, selectedfilePaths, basename(selectedfilePaths)) 
  file.remove(paste(fileLocation,"TRMM.vrt",sep=""))
  file.remove(paste(fileLocation,"myTRMM.sh",sep=""))
  
  message(paste("Done. The raster-brick was saved in",
                paste(fileLocation,"trmm_acc_",year,".tif",sep="")))
  
}
