#' Data source: Global Runoff Data Centre catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Global Runoff Data Centre database which provides river discharge data for about 9000 sites over 157 countries.
#'
#' @param bbox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)
#' @param stationID Station ID number, it should be in the range [1104150,6990700]
#' @param columnName name of the column to filter
#' @param columnValue value to look for in the column named columnName
#' @param mdDescription boolean value. Default is FALSE (no description is printed)
#' @param cached boolean value. Default is TRUE (use cached datasets).
#'
#' @return This function returns a data frame made of 8966 rows (gauging stations, as per October 2016) and 44 columns containing metadata.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the whole catalogue
#'   x <- catalogueGRDC()
#'
#'   # Define a bounding box
#'   bbox <- list(lonMin = -3.82, latMin = 52.41,
#'                lonMax = -3.63, latMax = 52.52)
#'   # Filter the catalogue based on bounding box
#'   x <- catalogueGRDC(bbox = bbox)
#'
#'   # Get only catchments with area above 5000 Km2
#'   x <- catalogueGRDC(columnName = "area", columnValue = ">= 5000")
#'
#'   # Get only catchments within river Thames
#'   x <- catalogueGRDC(columnName = "river", columnValue = "Thames")
#' }
#'

catalogueGRDC <- function(bbox = NULL, stationID = NULL,
                          columnName = NULL, columnValue = NULL,
                          mdDescription = FALSE, cached = TRUE){

  url <- "http://www.bafg.de/GRDC/EN/02_srvcs/21_tmsrs/211_ctlgs/GRDC_Stations.zip?__blob=publicationFile"

  if (cached == FALSE & RCurl::url.exists(url)){

    message("Downloading data from source")
    # Retrieve the catalogue
    temp <- tempfile()
    download.file(url,temp)
    GRDCcatalogue <- gdata::read.xls(utils::unzip(zipfile = temp,
                                                  exdir = dirname(temp)),
                                     sheet = "grdc_metadata")
    unlink(temp)
    GRDCcatalogue[] <- lapply(GRDCcatalogue, as.character)
    GRDCcatalogue$lat <- as.numeric(GRDCcatalogue$lat)
    GRDCcatalogue$long <- as.numeric(GRDCcatalogue$long)
    GRDCcatalogue$area <- as.numeric(GRDCcatalogue$area)
    GRDCcatalogue$altitude <- as.numeric(GRDCcatalogue$altitude)
    GRDCcatalogue$d_start <- as.numeric(GRDCcatalogue$d_start)
    GRDCcatalogue$d_end <- as.numeric(GRDCcatalogue$d_end)
    GRDCcatalogue$d_yrs <- as.numeric(GRDCcatalogue$d_yrs)
    GRDCcatalogue$d_miss <- as.numeric(GRDCcatalogue$d_miss)
    GRDCcatalogue$m_start <- as.numeric(GRDCcatalogue$m_start)
    GRDCcatalogue$m_end <- as.numeric(GRDCcatalogue$m_end)
    GRDCcatalogue$m_yrs <- as.numeric(GRDCcatalogue$m_yrs)
    GRDCcatalogue$m_miss <- as.numeric(GRDCcatalogue$m_miss)
    GRDCcatalogue$t_start <- as.numeric(GRDCcatalogue$t_start)
    GRDCcatalogue$t_end <- as.numeric(GRDCcatalogue$t_end)
    GRDCcatalogue$t_yrs <- as.numeric(GRDCcatalogue$t_yrs)
    GRDCcatalogue$lta_discharge <- as.numeric(GRDCcatalogue$lta_discharge)
    GRDCcatalogue$r_volume_yr <- as.numeric(GRDCcatalogue$r_volume_yr)
    GRDCcatalogue$r_height_yr <- as.numeric(GRDCcatalogue$r_height_yr)
    GRDCcatalogue$proc_tyrs <- as.numeric(GRDCcatalogue$proc_tyrs)
    GRDCcatalogue$proc_tmon <- as.numeric(GRDCcatalogue$proc_tmon)

  }else{

    message("Using cached data.")
    load(system.file("data/GRDCcatalogue.rda", package = "hddtools"))

  }

  if (!is.null(stationID)) {
    grdcSelected <- subset(GRDCcatalogue, (GRDCcatalogue$grdc_no == stationID))
  }else{
    grdcSelected <- GRDCcatalogue
  }

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

  grdcSelectedBB <- subset(grdcSelected, (grdcSelected$lat <= latMax &
                                            grdcSelected$lat >= latMin &
                                            grdcSelected$lon <= lonMax &
                                            grdcSelected$lon >= lonMin) )

  if ( !is.null(columnName) & !is.null(columnValue) ){

    if (tolower(columnName) %in% tolower(names(grdcSelectedBB))){

      col2select <- which(tolower(names(grdcSelectedBB)) ==
                            tolower(columnName))

      if (class(grdcSelectedBB[,col2select]) == "character"){
        rows2select <- which(tolower(grdcSelectedBB[,col2select]) ==
                               tolower(columnValue))
      }
      if (class(grdcSelectedBB[,col2select]) == "numeric"){
        # rows2select <- which(grdcSelectedBB[,col2select] == columnValue)
        rows2select <- eval(parse(text =
                                    paste0("which(grdcSelectedBB[,col2select] ",
                                           columnValue, ")")))
      }
      grdcTable <- grdcSelectedBB[rows2select,]

    }else{

      message("columnName should be one of the columns of the catalogue")

    }

  }else{

    grdcTable <- grdcSelectedBB

  }

  row.names(grdcTable) <- NULL
  names(grdcTable)[5] <- "id"
  names(grdcTable)[7] <- "name"
  names(grdcTable)[9]  <- "Latitude"
  names(grdcTable)[10] <- "Longitude"

  if (mdDescription == TRUE){

    temp <- system.file("extdata/GRDC/GRDC_legend.csv", package = "hddtools")
    grdcLegend <- read.csv(temp, header = FALSE)

    grdcTable <- cbind(grdcLegend,t(grdcTable))
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
#' @param stationID 7 string that identifies a station, GRDC station number is called "grdc no" in the catalogue.
#' @param plotOption boolean to define whether to plot the results. By default this is set to TRUE.
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
#' \dontrun{
#'   x <- tsGRDC(stationID = "1107700")
#' }
#'

tsGRDC <- function(stationID, plotOption = FALSE){

  options(warn = -1)

  temp <- catalogueGRDC()

  if ( temp[which(temp$grdc_no == stationID), "statistics"] == 1 ){

    # Retrieve look-up table
    grdcLTMMD <- NULL
    load(system.file("data/grdcLTMMD.rda", package = "hddtools"))

    # Retrieve WMO region from catalogue
    wmoRegion <- catalogueGRDC(stationID = stationID)$wmo_reg

    # Retrieve ftp server location
    zipFile <- as.character(grdcLTMMD[which(grdcLTMMD$WMO_Region == wmoRegion),
                                      "Archive"])

    # create a temporary directory
    td <- tempdir()

    # create the placeholder file
    tf <- tempfile(tmpdir = td, fileext = ".zip")

    # download into the placeholder file
    download.file(zipFile, tf)

    # get the name of the file to unzip
    fname <- paste("pvm_", stationID, ".txt", sep = "")

    # unzip the file to the temporary directory
    unzip(tf, files = fname, exdir = td, overwrite = TRUE)

    # fpath is the full path to the extracted file
    fpath <- file.path(td, fname)

    message("Station has monthly records")

    TS <- readLines(fpath)

    header1 <- as.numeric(as.character(c(grep("year;LQ;month;MQ;;HQ;month;m",
                                              TS))))
    header2 <- as.numeric(as.character(c(grep("LQ;MQ_1;MQ_2;MQ_3;HQ;n",TS))))
    header3 <- as.numeric(as.character(c(grep("month;LQ;year;MQ;HQ;year;std;n",
                                              TS))))
    headerTS <- c(header1,header2,header3)

    myTables <- list("mddPerYear" = NULL,
                     "mddAllPeriod" = NULL,
                     "mddPerMonth" = NULL)

    for (i in 1:3){
      header <- headerTS[i]
      skipTS <- as.numeric(as.character(grep("#", TS)))
      skip01 <- 1:header
      rowStart01 <- header + 1
      if ( length(skipTS[which(skipTS > header)]) > 0 ){
        skip02 <- skipTS[which(skipTS > header)]
        rowEnd01 <- skip02[1] - 1
      }else{
        rowEnd01 <- length(TS)
      }
      firstTS <- TS[rowStart01:rowEnd01]
      numberOfCol <- length(unlist(strsplit(TS[rowStart01:rowEnd01],";")[1]))
      numberOfRow <- length(unlist(strsplit(TS[rowStart01:rowEnd01],
                                            ";")))/numberOfCol
      mtemp <- as.numeric(as.character(unlist(strsplit(TS[rowStart01:rowEnd01],
                                                       ";"))))
      m <- matrix(mtemp, ncol = numberOfCol, nrow = numberOfRow, byrow = TRUE)
      m[m == -999] <- NA
      m <- data.frame(m)
      n <- unlist(strsplit(TS[header], ";"))
      n <- n[n != ""]
      names(m) <- n

      myTables[[i]] <- m

    }

    if ( plotOption == TRUE ){

      table1 <- myTables$mddPerYear
      table2 <- myTables$mddAllPeriod
      table3 <- myTables$mddPerMonth

      dummyTime <- seq(as.Date("2012-01-01"),
                       as.Date("2012-12-31"),
                       by = "months")

      plot(zoo(table3$MQ, order.by = dummyTime),
           main = paste("Monthly statistics: ",
                        catalogueGRDC(stationID = stationID)$name,
                        " (",
                        catalogueGRDC(stationID = stationID)$country_code,
                        ")",
                        sep=""),
           type = "l", ylim = c(min(table3$LQ), max(table3$HQ)),
           xlab = "", ylab = "m3/s", xaxt = "n")
      axis(1, at = dummyTime, labels = format(dummyTime, "%b"))
      polygon(c(dummyTime,rev(dummyTime)), c(table3$HQ,rev(table3$LQ)),
              col = "orange",
              lty = 0,
              lwd = 2)
      lines(zoo(table3$MQ, order.by = dummyTime), lty = 2, lwd = 3, col = "red")

      legend("top", legend = c("Min-Max range", "Mean"),
             bty = "n",
             col = c("orange", "red"),
             lty = c(0, 2), lwd = c(0, 3),
             pch = c(22, NA),
             pt.bg = c("orange", NA),
             pt.cex = 2)

    }

    return(myTables)

  }else{

    message("Station does not have monthly records")

  }

}
