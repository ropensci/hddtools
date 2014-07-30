#' Function to identify the updated Koppen-Greiger climate zone (on a 0.1 x 0.1 degrees resolution map).
#' 
#' @author Claudia Vitolo
#' 
#' @description Given a bounding box, the function identifies the overlapping climate zones.
#' 
#' @param BBlonMin Minimum latitude of bounding box
#' @param BBlonMax Maximum latitude of bounding box
#' @param BBlatMin Minimum longitude of bounding box
#' @param BBlatMax Maximum longitude of bounding box
#' 
#' @param liveData bolean value that allows to switch between using online dataset (liveData=TRUE, the online datset might be updated) and offline dataset (liveData = FALSE, this might not be the latest version of the dataset). 
#' @param updatedBy this can either be Kottek (http://koeppen-geiger.vu-wien.ac.at/) or Peel (http://people.eng.unimelb.edu.au/mpeel/koppen.html) 
#' 
#' @return List of overlapping climate zones.
#' 
#' @examples 
#' # kgclimateclass(BBlonMin=-3.82,BBlonMax=-3.63,BBlatMin=52.41,BBlatMax=52.52,updatedBy="Peel",liveData=TRUE)
#' # kgclimateclass(BBlonMin=-3.82,BBlonMax=-3.63,BBlatMin=52.41,BBlatMax=52.52,updatedBy="Peel",liveData=FALSE)
#' # kgclimateclass(BBlonMin=-3.82,BBlonMax=-3.63,BBlatMin=52.41,BBlatMax=52.52,updatedBy="Kottek",liveData=TRUE)
#' # kgclimateclass(BBlonMin=-3.82,BBlonMax=-3.63,BBlatMin=52.41,BBlatMax=52.52,updatedBy="Kottek",liveData=FALSE)
#'

kgclimateclass <- function(BBlonMin,BBlonMax,BBlatMin,BBlatMax,liveData=FALSE,updatedBy="Peel"){
  
  # require(sp)
  # require(rgdal)
  # require(raster)
  
  # BBlonMin=-3.82;BBlonMax=-3.63;BBlatMin=52.41;BBlatMax=52.52
  
  # Latitude is the Y axis, longitude is the X axis.
  bbox <- matrix(c(BBlonMin,BBlatMin,BBlonMax,BBlatMax),nrow=2)
  rownames(bbox) <- c("lon","lat")
  colnames(bbox) <- c('min','max')
  bboxMat <- rbind( c(bbox['lon','min'],bbox['lat','min']), c(bbox['lon','min'],bbox['lat','max']), c(bbox['lon','max'],bbox['lat','max']), c(bbox['lon','max'],bbox['lat','min']), c(bbox['lon','min'],bbox['lat','min']) ) # clockwise, 5 points to close it
  bbSP <- SpatialPolygons( list(Polygons(list(Polygon(bboxMat)),"bbox")), 
                           proj4string=CRS("+proj=longlat +datum=WGS84")  )
  
  if (updatedBy == "Kottek") {
    
    # MAP UPDATED BY KOTTEK
    kgLegend <- read.table(system.file("KOTTEK_Legend.txt", 
                                       package = 'hddtools'))
    
    if (liveData == FALSE){
      
      message("OFFLINE results")
      
      kgRaster <- raster(system.file("KOTTEK_koeppen-geiger.tiff", 
                                     package = 'hddtools'))
      
      temp <- data.frame(table(extract(kgRaster,bbSP)))
      temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),3]
      df <- data.frame(ID = temp$Var1, 
                       Class = temp$Class, 
                       Frequency = temp$Freq)
      
    }else{
      
      message("ONLINE results")
      
      temp <- tempfile()
      download.file("http://koeppen-geiger.vu-wien.ac.at/data/Koeppen-Geiger-ASCII.zip",temp)
      df <- read.table(unz(temp, "Koeppen-Geiger-ASCII.txt"),header=TRUE)
      unlink(temp)
      # Look for points internal to bounding box
      kgSelected <- subset(df, (df$Lat <= BBlatMax & df$Lat >= BBlatMin & df$Lon <= BBlonMax & df$Lon >= BBlonMin) )
      if (dim(kgSelected)[1]==0){ # if there are no internal points
        # Look for closest external points
        LonMin <- max(df$Lon[which(BBlonMin >= df$Lon)])
        LonMax <- min(df$Lon[which(df$Lon>=BBlonMax)])
        LatMin <- max(df$Lat[which(BBlatMin >= df$Lat)])
        LatMax <- min(df$Lat[which(df$Lat>=BBlatMax)])
        kgSelected <- subset(df, 
                             (df$Lat <= LatMax & df$Lat >= LatMin & df$Lon <= LonMax & df$Lon >= LonMin) )
      }
      temp <- data.frame(table(droplevels(kgSelected$Cls)))
      df <- data.frame(ID = kgLegend$V1[which(kgLegend$V3==as.character(temp$Var1))], 
                       Class = as.character(temp$Var1), 
                       Frequency = as.character(temp$Freq) )
    }
    
  }
  
  if (updatedBy == "Peel") {
    
    # MAP UPDATED BY Peel
    kgLegend <- read.table(system.file("PEEL_Legend.txt", 
                                       package = 'hddtools'),
                           header=TRUE)
    
    if (liveData == FALSE){
      
      message("OFFLINE results")
      
      # MAP UPDATED BY PEEL
      kgRaster <- raster(system.file("PEEL_koppen_ascii.txt", 
                                     package = 'hddtools'))
      
      temp <- data.frame(table(extract(kgRaster,bbSP)))
      temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),2]
      
      df <- data.frame(ID = temp$Var1, 
                       Class = temp$Class, 
                       Frequency = temp$Freq)
      
    }else{
      
      message("ONLINE results")
      
      temp <- tempfile()
      download.file("http://people.eng.unimelb.edu.au/mpeel/Koppen/koppen_ascii.zip",temp)
      zipd = tempdir()
      unzip(temp, exdir=zipd)
      kgRaster = raster(file.path(zipd,"koppen_ascii.txt"))
      unlink(temp)
      unlink(zipd)
      
      temp <- data.frame(table(extract(kgRaster,bbSP)))
      temp$Class <- kgLegend[which(kgLegend[,1]==temp[,1]),2]
      
      df <- data.frame(ID = temp$Var1, 
                       Class = temp$Class, 
                       Frequency = temp$Freq)
    }
    
  }
  
  return(df)
  
}
