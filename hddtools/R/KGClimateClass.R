#' Function to identify the updated Koppen-Greiger climate zone (on a 0.1 x 0.1 degrees resolution map).
#' 
#' @author Claudia Vitolo
#' 
#' @description Given a bounding box, the function identifies the overlapping climate zones.
#' 
#' @param lonMin Minimum latitude of bounding box
#' @param lonMax Maximum latitude of bounding box
#' @param latMin Minimum longitude of bounding box
#' @param latMax Maximum longitude of bounding box
#'  
#' @param updatedBy this can either be Kottek (http://koeppen-geiger.vu-wien.ac.at/) or Peel (http://people.eng.unimelb.edu.au/mpeel/koppen.html) 
#' 
#' @return List of overlapping climate zones.
#' 
#' @export
#' 
#' @examples 
#' # KGClimateClass(lonMin=-3.82,lonMax=-3.63,latMin=52.41,latMax=52.52,updatedBy="Peel")
#' # KGClimateClass(lonMin=-3.82,lonMax=-3.63,latMin=52.41,latMax=52.52,updatedBy="Kottek")
#'

KGClimateClass <- function(lonMin,lonMax,latMin,latMax,updatedBy="Peel"){
  
  # require(sp)
  # require(rgdal)
  # require(raster)
  
  # lonMin=-3.82;lonMax=-3.63;latMin=52.41;latMax=52.52
  
  # Latitude is the Y axis, longitude is the X axis.
  bbox <- matrix(c(lonMin,latMin,lonMax,latMax),nrow=2)
  rownames(bbox) <- c("lon","lat")
  colnames(bbox) <- c('min','max')
  
  # clockwise, 5 points to close it
  bboxMat <- rbind( c(bbox['lon','min'],bbox['lat','min']), 
                    c(bbox['lon','min'],bbox['lat','max']), 
                    c(bbox['lon','max'],bbox['lat','max']), 
                    c(bbox['lon','max'],bbox['lat','min']), 
                    c(bbox['lon','min'],bbox['lat','min']) ) 
  
  bbSP <- SpatialPolygons( list(Polygons(list(Polygon(bboxMat)),"bbox")), 
                           proj4string=CRS("+proj=longlat +datum=WGS84")  )
  
  if (updatedBy == "Kottek") {
    
    # MAP UPDATED BY KOTTEK
    kgLegend <- read.table(system.file("KOTTEK_Legend.txt", 
                                       package = 'hddtools'))
    
    message("OFFLINE results")
    
    # create a temporary directory
    td <- tempdir()
    
    # create the placeholder file
    tf <- tempfile(tmpdir=td, fileext=".tar.gz")
    
    untar(system.file("KOTTEK_KG.tar.gz", 
                      package = 'hddtools'), exdir = td)
    
    kgRaster <- raster(paste(td,"/KOTTEK_koeppen-geiger.tiff",sep=""))
    
    temp <- data.frame(table(extract(kgRaster,bbSP)))
    temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),3]
    df <- data.frame(ID = temp$Var1, 
                     Class = temp$Class, 
                     Frequency = temp$Freq)
    
  }
  
  if (updatedBy == "Peel") {
    
    # MAP UPDATED BY PEEL
    kgLegend <- read.table(system.file("PEEL_Legend.txt", 
                                       package = 'hddtools'),
                           header=TRUE)
    
    message("OFFLINE results")
    
    # create a temporary directory
    td <- tempdir()
    
    # create the placeholder file
    tf <- tempfile(tmpdir=td, fileext=".tar.gz")
    
    untar(system.file("PEEL_KG.tar.gz", 
                      package = 'hddtools'), exdir = td)
    
    kgRaster <- raster(paste(td,"/PEEL_koppen_ascii.txt",sep=""))
    
    temp <- data.frame(table(extract(kgRaster,bbSP)))
    temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),2]
    
    df <- data.frame(ID = temp$Var1, 
                     Class = temp$Class, 
                     Frequency = temp$Freq)
  
  }
  
  return(df)
  
}
