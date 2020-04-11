#' Function to identify the updated Koppen-Greiger climate zone (on a 0.1 x 0.1 degrees resolution map).
#'
#' @author Claudia Vitolo
#'
#' @description Given a bounding box, the function identifies the overlapping climate zones.
#'
#' @param areaBox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)
#' @param updatedBy this can either be "Kottek" or "Peel"
#' @param verbose if TRUE more info are printed on the screen
#'
#' @references Kottek et al. (2006): \url{http://koeppen-geiger.vu-wien.ac.at/}. Peel et al. (2007): \url{http://people.eng.unimelb.edu.au/mpeel/koppen.html}.
#'
#' @return List of overlapping climate zones.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Define a bounding box
#'   areaBox <- raster::extent(-3.82, -3.63, 52.41, 52.52)
#'   # Get climate classes
#'   KGClimateClass(areaBox = areaBox)
#' }
#'

KGClimateClass <- function(areaBox = NULL, updatedBy = "Peel", verbose = FALSE){

  # crop to bounding box

  if (is.null(areaBox)){
    areaBox <- raster::extent(c(-180, +180, -90, +90))
  }
  bbSP <- bboxSpatialPolygon(areaBox)

  if (updatedBy == "Kottek") {

    # MAP UPDATED BY KOTTEK
    kgLegend <- utils::read.table(system.file(file.path("extdata",
                                                        "KOTTEK_Legend.txt"),
                                              package = "hddtools"))

    # message("OFFLINE results")

    # create a temporary directory
    td <- tempdir()

    # create the placeholder file
    tf <- tempfile(tmpdir = td, fileext = ".tar.gz")

    utils::untar(system.file(file.path("extdata", "KOTTEK_KG.tar.gz"),
                             package = "hddtools"), exdir = td)

    kgRaster <- raster::raster(paste0(td, "/KOTTEK_koeppen-geiger.tiff",
                                      sep = ""))

    temp <- data.frame(table(raster::extract(kgRaster, bbSP)))
    temp$Class <- NA
    for (i in 1:dim(temp)[1]){
      class1 <- which(kgLegend[,1] == temp[i,1])
      if (length(class1) > 0){
        temp$Class[i] <- as.character(kgLegend[class1,3])
      }
    }

    temp <- temp[which(!is.na(temp$Class)),]

    df <- data.frame(ID = temp$Var1,
                     Class = temp$Class,
                     Frequency = temp$Freq)

  }

  if (updatedBy == "Peel") {

    # MAP UPDATED BY PEEL
    kgLegend <- utils::read.table(system.file(file.path("extdata",
                                                        "PEEL_Legend.txt"),
                                              package = "hddtools"),
                                  header = TRUE)

    # message("OFFLINE results")

    # create a temporary directory
    td <- tempdir()

    # create the placeholder file
    tf <- tempfile(tmpdir = td, fileext = ".tar.gz")

    utils::untar(system.file(file.path("extdata", "PEEL_KG.tar.gz"),
                             package = "hddtools"), exdir = td)

    kgRaster <- raster::raster(paste0(td, "/PEEL_koppen_ascii.txt", sep = ""))

    temp <- data.frame(table(raster::extract(kgRaster, bbSP)))
    temp$Class <- NA
    for (i in 1:dim(temp)[1]){
      class1 <- which(kgLegend[,1] == temp[i,1])
      if (length(class1) > 0){
        temp$Class[i] <- as.character(kgLegend[class1,2])
      }
    }

    temp <- temp[which(!is.na(temp$Class)),]

    df <- data.frame(ID = temp$Var1,
                     Class = temp$Class,
                     Frequency = temp$Freq)

  }

  firstPart <- substr(temp$Class,1,1)
  secondPart <- substr(temp$Class,2,2)
  thirdPart <- substr(temp$Class,3,3)

  description <- vector(mode="character", length=max(length(firstPart),
                                                           length(secondPart),
                                                           length(thirdPart)))

  criterion <- vector(mode="character", length=max(length(firstPart),
                                                         length(secondPart),
                                                         length(thirdPart)))


  for (j in 1:length(description)){

    if (firstPart[j] == "A"){

      description[j] <- "A = Equatorial climates"
      criterion[j] <- "A = Tmin >= +18 C"

      if (secondPart[j] == "f"){
        description[j] <- paste0(description[j],
                                 "; f = Equatorial rainforest, fully humid")
        criterion[j] <- paste0(criterion[j],"; f = Pmin >= 60mm")
      }
      if (secondPart[j] == "m"){
        description[j] <- paste0(description[j], "; m = Equatorial monsoon")
        criterion[j] <- paste0(criterion[j], "; m = Pann >= 25*(100 - Pmin)")
      }
      if (secondPart[j] == "s"){
        description[j] <- paste0(description[j],
                                 "; s = Equatorial savannah with dry summer")
        criterion[j] <- paste0(criterion[j], "; s = Pmin < 60mm in summer")
      }
      if (secondPart[j] == "w"){
        description[j] <- paste0(description[j],
                                 "; w = Equatorial savannah with dry winter")
        criterion[j] <- paste0(criterion[j], "; w = Pmin < 60mm in winter")
      }
    }

    if (firstPart[j] == "B"){

      description[j] <- "B = Arid climates"
      criterion[j] <- "B = Pann < 10 Pth"

      if (secondPart[j] == "S"){
        description[j] <- paste0(description[j], "; S = Steppe climate")
        criterion[j] <- paste0(criterion[j], "; S = Pann > 5 Pth")
      }
      if (secondPart[j] == "W"){
        description[j] <- paste0(description[j], "; W = Desert climate")
        criterion[j] <- paste0(criterion[j], "; W = Pann <= 5 Pth")
      }
    }

    if (firstPart[j] == "C"){

      description[j] <- "C = Warm temperate climates"
      criterion[j] <- "C = -3 C < Tmin < +18 C"

      if (secondPart[j] == "s"){
        description[j] <- paste0(description[j],
                                 "; s = Warm temperate climate with dry summer")
        criterion[j] <- paste0(criterion[j],
                               "; s = Psmin < Pwmin , Pwmax > 3",
                               "Psmin and Psmin < 40mm")
      }
      if (secondPart[j] == "w"){
        description[j] <- paste0(description[j],
                                 "; w = Warm temperate climate with dry winter")
        criterion[j] <- paste0(criterion[j],
                               "; w = Pwmin < Psmin and Psmax > 10 Pwmin")
      }
      if (secondPart[j] == "f"){
        description[j] <- paste0(description[j],
                                 "; f = Warm temperate climate, fully humid")
        criterion[j] <- paste0(criterion[j],
                               "; f = neither Cs nor Cw",
                               "; (Cs's criterion: Psmin <",
                               "Pwmin, Pwmax > 3 Psmin and Psmin < 40mm.; Cw's",
                               "criterion: Pwmin < Psmin and Psmax >10 Pwmin.)")
      }
    }
    if (firstPart[j] == "D"){

      description[j] <- "D = Snow climates"
      criterion[j] <- "D = Tmin <= -3 C"

      if (secondPart[j] == "s"){
        description[j] <- paste0(description[j],
                                 "; s = Snow climate with dry summer")
        criterion[j] <- paste0(criterion[j],
                               "; s = Psmin < Pwmin , Pwmax > 3",
                                     "Psmin and Psmin < 40mm")
      }
      if (secondPart[j] == "w"){
        description[j] <- paste0(description[j],
                                 "; w = Snow climate with dry winter")
        criterion[j] <- paste0(criterion[j],
                               "; w = Pwmin < Psmin and Psmax > 10 Pwmin")
      }
      if (secondPart[j] == "f"){
        description[j] <- paste0(description[j],
                                 "; f = Snow climate, fully humid")
        criterion[j] <- paste0(criterion[j],
                               "; f = neither Ds nor Dw","; (Ds's",
                               "criterion: Psmin < Pwmin , Pwmax > 3 Psmin and",
                               "Psmin < 40mm.;",
                               "Dw's criterion: Pwmin < Psmin and",
                               "Psmax > 10 Pwmin.)")
      }
    }
    if (firstPart[j] == "E"){

      description[j] <- "E = Polar climates"
      criterion[j] <- "E = Tmax < +10 C"

      if (secondPart[j] == "T"){
        description[j] <- paste0(description[j], "; T = Tundra climate")
        criterion[j] <- paste0(criterion[j], "; T = 0 C <= Tmax < +10 C")
      }
      if (secondPart[j] == "F"){
        description[j] <- paste0(description[j], "; F = Frost climate")
        criterion[j] <- paste0(criterion[j], "; F = Tmax < 0 C")
      }
    }

    if (thirdPart[j] == "h"){
      description[j] <- paste0(description[j], "; h = Hot steppe / desert")
      criterion[j] <- paste0(criterion[j], "; h = Tann >= +18 C")
    }
    if (thirdPart[j] == "k"){
      description[j] <- paste0(description[j], "; k = Cold steppe /desert")
      criterion[j] <- paste0(criterion[j], "; k = Tann < +18 C")
    }
    if (thirdPart[j] == "a"){
      description[j] <- paste0(description[j], "; a = Hot summer")
      criterion[j] <- paste0(criterion[j], "; a = Tmax >= +22 C")
    }
    if (thirdPart[j] == "b"){
      description[j] <- paste0(description[j], "; b = Warm summer")
      criterion[j] <- paste0(criterion[j],
                             "; b = Tmax < +22 C & at least 4 Tmon >= +10 C")
    }
    if (thirdPart[j] == "c"){
      description[j] <- paste0(description[j],
                               "; c = Cool summer and cold winter")
      criterion[j] <- paste0(criterion[j], "; c = Tmax >= +22 C ",
                             "& 4 Tmon < +10 C & Tmin > -38 C")
    }
    if (thirdPart[j] == "d"){
      description[j] <- paste0(description[j], "; d = Extremely continental")
      criterion[j] <- paste0(criterion[j], "; d = Tmax >= +22 C ",
                             "& 4 Tmon < +10 C & Tmin <= -38 C")
    }

  }

  if ( verbose == TRUE ){

    message("Class(es):")
    print(temp$Class)
    message("Description:")
    print(description)
    message("Criterion:")
    print(criterion)

  }

  return(df)

}
