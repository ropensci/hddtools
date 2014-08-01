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
  bboxMat <- rbind( c(bbox['lon','min'],bbox['lat','min']), c(bbox['lon','min'],bbox['lat','max']), c(bbox['lon','max'],bbox['lat','max']), c(bbox['lon','max'],bbox['lat','min']), c(bbox['lon','min'],bbox['lat','min']) ) # clockwise, 5 points to close it
  bbSP <- SpatialPolygons( list(Polygons(list(Polygon(bboxMat)),"bbox")), 
                           proj4string=CRS("+proj=longlat +datum=WGS84")  )
  
  if (updatedBy == "Kottek") {
    
    # MAP UPDATED BY KOTTEK
    kgLegend <- read.table(system.file("KOTTEK_Legend.txt", 
                                       package = 'hddtools'))
    
    message("OFFLINE results")
    
    kgRaster <- raster(system.file("KOTTEK_koeppen-geiger.tiff", 
                                   package = 'hddtools'))
    
    temp <- data.frame(table(extract(kgRaster,bbSP)))
    temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),3]
    df <- data.frame(ID = temp$Var1, 
                     Class = temp$Class, 
                     Frequency = temp$Freq)
    
#     message("ONLINE results")
#     
#     temp <- tempfile()
#     download.file("http://koeppen-geiger.vu-wien.ac.at/data/Koeppen-Geiger-ASCII.zip",temp)
#     df <- read.table(unz(temp, "Koeppen-Geiger-ASCII.txt"),header=TRUE)
#     unlink(temp)
#     # Look for points internal to bounding box
#     kgSelected <- subset(df, (df$Lat <= latMax & df$Lat >= latMin & df$Lon <= lonMax & df$Lon >= lonMin) )
#     if (dim(kgSelected)[1]==0){ # if there are no internal points
#       # Look for closest external points
#       LonMin <- max(df$Lon[which(lonMin >= df$Lon)])
#       LonMax <- min(df$Lon[which(df$Lon>=lonMax)])
#       LatMin <- max(df$Lat[which(latMin >= df$Lat)])
#       LatMax <- min(df$Lat[which(df$Lat>=latMax)])
#       kgSelected <- subset(df, 
#                            (df$Lat <= LatMax & df$Lat >= LatMin & df$Lon <= LonMax & df$Lon >= LonMin) )
#     }
#     temp <- data.frame(table(droplevels(kgSelected$Cls)))
#     df <- data.frame(ID = kgLegend$V1[which(kgLegend$V3==as.character(temp$Var1))], 
#                      Class = as.character(temp$Var1), 
#                      Frequency = as.character(temp$Freq) )
    
  }
  
  if (updatedBy == "Peel") {
    
    # MAP UPDATED BY Peel
    kgLegend <- read.table(system.file("PEEL_Legend.txt", 
                                       package = 'hddtools'),
                           header=TRUE)
    
    message("OFFLINE results")
    
    # MAP UPDATED BY PEEL
    kgRaster <- raster(system.file("PEEL_koppen_ascii.txt", 
                                   package = 'hddtools'))
    
    temp <- data.frame(table(extract(kgRaster,bbSP)))
    temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),2]
    
    df <- data.frame(ID = temp$Var1, 
                     Class = temp$Class, 
                     Frequency = temp$Freq)
    
#     message("ONLINE results")
#     
#     temp <- tempfile()
#     download.file("http://people.eng.unimelb.edu.au/mpeel/Koppen/koppen_ascii.zip",temp)
#     zipd = tempdir()
#     unzip(temp, exdir=zipd)
#     kgRaster = raster(file.path(zipd,"koppen_ascii.txt"))
#     unlink(temp)
#     unlink(zipd)
#     
#     temp <- data.frame(table(extract(kgRaster,bbSP)))
#     temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),2]
#     
#     df <- data.frame(ID = temp$Var1, 
#                      Class = temp$Class, 
#                      Frequency = temp$Freq)
    
  }
  
  return(df)
  
}
