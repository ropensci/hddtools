#' Function to identify the updated Koppen-Greiger climate zone (on a 0.1 x 0.1 degrees resolution map).
#' 
#' @author Claudia Vitolo
#' 
#' @description Given a bounding box, the function identifies the overlapping climate zones.
#' 
#' @param bbox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)   
#' @param updatedBy this can either be Kottek
#' @param verbose if TRUE more info are printed on the screen 
#' 
#' @references Kottek et al. (2006): http://koeppen-geiger.vu-wien.ac.at/. Peel et al. (2007): http://people.eng.unimelb.edu.au/mpeel/koppen.html. 
#' 
#' @return List of overlapping climate zones.
#' 
#' @export
#' 
#' @examples 
#' # Define a bounding box
#' # bbox <- list(lonMin=-3.82,latMin=52.41,lonMax=-3.63,latMax=52.52)
#' 
#' # Get climate classes
#' # KGClimateClass(bbox)
#'

KGClimateClass <- function(bbox,updatedBy="Peel",verbose=FALSE){
  
  # require(sp)
  # require(rgdal)
  # require(raster)
  
  # Latitude is the Y axis, longitude is the X axis.
  boundingBox <- matrix(c(bbox$lonMin,bbox$latMin,bbox$lonMax,bbox$latMax),
                        nrow=2)
  rownames(boundingBox) <- c("lon","lat")
  colnames(boundingBox) <- c('min','max')
  
  # clockwise, 5 points to close it
  boundingBoxMat <- rbind( c(boundingBox['lon','min'],boundingBox['lat','min']), 
                    c(boundingBox['lon','min'],boundingBox['lat','max']), 
                    c(boundingBox['lon','max'],boundingBox['lat','max']), 
                    c(boundingBox['lon','max'],boundingBox['lat','min']), 
                    c(boundingBox['lon','min'],boundingBox['lat','min']) ) 
  
  bbSP <- SpatialPolygons( list(Polygons(list(Polygon(boundingBoxMat)),"boundingBox")), 
                           proj4string=CRS("+proj=longlat +datum=WGS84")  )
  
  if (updatedBy == "Kottek") {
    
    # MAP UPDATED BY KOTTEK
    kgLegend <- read.table(system.file("KOTTEK_Legend.txt", 
                                       package = 'hddtools'))
    
    # message("OFFLINE results")
    
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
    
    # message("OFFLINE results")
    
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
  
  firstPart <- substr(temp$Class,1,1)
  secondPart <- substr(temp$Class,2,2)
  thirdPart <- substr(temp$Class,3,3)
    
  if (firstPart == "A"){
    
    description <- "A = Equatorial climates"
    criterion <- "A = Tmin >= +18 C"
    
    if (secondPart == "f"){
      description <- paste(description,"\nf = Equatorial rainforest, fully humid")
      criterion <- paste(criterion,"\nf = Pmin >= 60mm")
    }
    if (secondPart == "m"){
      description <- paste(description,"\nm = Equatorial monsoon")
      criterion <- paste(criterion,"\nm = Pann >= 25*(100 - Pmin)")
    }
    if (secondPart == "s"){
      description <- paste(description,"\ns = Equatorial savannah with dry summer")
      criterion <- paste(criterion,"\ns = Pmin < 60mm in summer")
    }
    if (secondPart == "w"){
      description <- paste(description,"\nw = Equatorial savannah with dry winter")
      criterion <- paste(criterion,"\nw = Pmin < 60mm in winter")
    }
  }
  
  if (firstPart == "B"){
    
    description <- "B = Arid climates"
    criterion <- "B = Pann < 10 Pth"
    
    if (secondPart == "S"){
      description <- paste(description,"\nS = Steppe climate")
      criterion <- paste(criterion,"\nS = Pann > 5 Pth")
    }
    if (secondPart == "W"){
      description <- paste(description,"\nW = Desert climate")
      criterion <- paste(criterion,"\nW = Pann <= 5 Pth")
    }
  }  
  
  if (firstPart == "C"){
    
    description <- "C = Warm temperate climates"
    criterion <- "C = -3 C < Tmin < +18 C"
    
    if (secondPart == "s"){
      description <- paste(description,"\ns = Warm temperate climate with dry summer")
      criterion <- paste(criterion,"\ns = Psmin < Pwmin , Pwmax > 3 Psmin and Psmin < 40mm")
    }
    if (secondPart == "w"){
      description <- paste(description,"\nw = Warm temperate climate with dry winter")
      criterion <- paste(criterion,"\nw = Pwmin < Psmin and Psmax > 10 Pwmin")
    }
    if (secondPart == "f"){
      description <- paste(description,"\nf = Warm temperate climate, fully humid")
      criterion <- paste(criterion,"\nf = neither Cs nor Cw","\n(Cs's criterion: Psmin < Pwmin , Pwmax > 3 Psmin and Psmin < 40mm. \nCw's criterion: Pwmin < Psmin and Psmax > 10 Pwmin.)")
    }
  }  
  if (firstPart == "D"){
    
    description <- "D = Snow climates"
    criterion <- "D = Tmin <= -3 C"
    
    if (secondPart == "s"){
      description <- paste(description,"\ns = Snow climate with dry summer")
      criterion <- paste(criterion,"\ns = Psmin < Pwmin , Pwmax > 3 Psmin and Psmin < 40mm")
    }
    if (secondPart == "w"){
      description <- paste(description,"\nw = Snow climate with dry winter")
      criterion <- paste(criterion,"\nw = Pwmin < Psmin and Psmax > 10 Pwmin")
    }
    if (secondPart == "f"){
      description <- paste(description,"\nf = Snow climate, fully humid")
      criterion <- paste(criterion,"\nf = neither Ds nor Dw","\n(Ds's criterion: Psmin < Pwmin , Pwmax > 3 Psmin and Psmin < 40mm. \nDw's criterion: Pwmin < Psmin and Psmax > 10 Pwmin.)")
    }
  }  
  if (firstPart == "E"){
    
    description <- "E = Polar climates"
    criterion <- "E = Tmax < +10 C"
    
    if (secondPart == "T"){
      description <- paste(description,"\nT = Tundra climate")
      criterion <- paste(criterion,"\nT = 0 C <= Tmax < +10 C")
    }
    if (secondPart == "F"){
      description <- paste(description,"\nF = Frost climate")
      criterion <- paste(criterion,"\nF = Tmax < 0 C")
    }
  }  
  
  if (thirdPart == "h"){
    description <- paste(description,"\nh = Hot steppe / desert")
    criterion <- paste(criterion,"\nh = Tann >= +18 C")
  }
  if (thirdPart == "k"){
    description <- paste(description,"\nk = Cold steppe /desert")
    criterion <- paste(criterion,"\nk = Tann < +18 C")
  }
  if (thirdPart == "a"){
    description <- paste(description,"\na = Hot summer")
    criterion <- paste(criterion,"\na = Tmax >= +22 C")
  }
  if (thirdPart == "b"){
    description <- paste(description,"\nb = Warm summer")
    criterion <- paste(criterion,"\nb = Tmax < +22 C & at least 4 Tmon >= +10 C")
  }
  if (thirdPart == "c"){
    description <- paste(description,"\nc = Cool summer and cold winter")
    criterion <- paste(criterion,"\nc = Tmax >= +22 C & 4 Tmon < +10 C & Tmin > -38 C")
  }
  if (thirdPart == "d"){
    description <- paste(description,"\nd = Extremely continental")
    criterion <- paste(criterion,"\nd = Tmax >= +22 C & 4 Tmon < +10 C & Tmin <= -38 C")
  }
  
  if ( verbose == TRUE ){
    
    message("Class:")
    message(temp$Class)
    message("Description:")
    message(description)
    message("Criterion:")
    message(criterion)
    
  }  
  
  return(df)
  
}
