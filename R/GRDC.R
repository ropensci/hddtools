#' Data source: Global Runoff Data Centre catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Global Runoff Data Centre database which provides river discharge data for about 9000 sites over 157 countries.
#'
#' @param areaBox bounding box, a list made of 4 elements: minimum longitude (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum latitude (latMax)
#' @param columnName name of the column to filter
#' @param columnValue value to look for in the column named columnName
#' @param mdDescription boolean value. Default is FALSE (no description is printed)
#' @param useCachedData logical, set to TRUE to use cached data, set to FALSE to retrive data from online source. This is TRUE by default.
#'
#' @return This function returns a data frame made of 8966 rows (gauging stations, as per October 2016) and 44 columns containing metadata.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the whole catalogue
#'   GRDC_catalogue_all <- catalogueGRDC()
#'
#'   # Define a bounding box
#'   areaBox <- raster::extent(-3.82, -3.63, 52.41, 52.52)
#'   # Filter the catalogue based on bounding box
#'   GRDC_catalogue_bbox <- catalogueGRDC(areaBox = areaBox)
#'
#'   # Get only catchments with area above 5000 Km2
#'   GRDC_catalogue_area <- catalogueGRDC(columnName = "area",
#'                                        columnValue = ">= 5000")
#'
#'   # Get only catchments within river Thames
#'   GRDC_catalogue_river <- catalogueGRDC(columnName = "river",
#'                                         columnValue = "Thames")
#' }
#'

catalogueGRDC <- function(areaBox = NULL,
                          columnName = NULL, columnValue = NULL,
                          mdDescription = FALSE, useCachedData = TRUE){

  theurl <- paste0("http://www.bafg.de/GRDC/EN/02_srvcs/21_tmsrs/211_ctlgs/",
                   "GRDC_Stations.zip?__blob=publicationFile")

  if (useCachedData == TRUE | RCurl::url.exists(theurl) == FALSE){

    # message("Using cached data.")

    load(system.file(file.path("data", "GRDCcatalogue.rda"),
                     package = "hddtools"))

  }else{

    message("Retrieving data from data provider.")

    # Retrieve the catalogue
    temp <- tempfile()
    download.file(theurl,temp)
    fileLocation <- utils::unzip(zipfile = temp, exdir = dirname(temp))
    GRDCcatalogue <- gdata::read.xls(fileLocation, sheet = "grdc_metadata")
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

  }

  if (!is.null(areaBox)){
    lonMin <- areaBox@xmin
    lonMax <- areaBox@xmax
    latMin <- areaBox@ymin
    latMax <- areaBox@ymax
  }else{
    lonMin <- -180
    lonMax <- +180
    latMin <- -90
    latMax <- +90
  }

  grdcSelectedBB <- subset(GRDCcatalogue, (GRDCcatalogue$lat <= latMax &
                                            GRDCcatalogue$lat >= latMin &
                                            GRDCcatalogue$lon <= lonMax &
                                            GRDCcatalogue$lon >= lonMin) )

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

  if (mdDescription == TRUE){

    temp <- system.file(file.path("extdata", "GRDC", "GRDC_legend.csv"),
                        package = "hddtools")
    grdcLegend <- read.csv(temp, header = FALSE)

    grdcTable <- cbind(grdcLegend,t(grdcTable))
    row.names(grdcTable) <- NULL
    grdcTable$V1 <- NULL

  }

  return(tibble::as_tibble(grdcTable))

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
#'   \item year:  associated year of occurrence (only the first occurrence is listed)
#'   \item MQ:    mean discharge from all monthly discharges of the given month in the entire period
#'   \item HQ:    highest monthly discharge of the given month in the entire period
#'   \item year:  associated year of occurrence (only the first occurrence is listed)
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
#'   Adaitu <- tsGRDC(stationID = "1577602")
#'   Adaitu <- tsGRDC(stationID = catalogueGRDC()$grdc_no[1000],
#'                    plotOption = TRUE)
#' }
#'

tsGRDC <- function(stationID, plotOption = FALSE){

  # was options(warn = -1)
  grdcLTMMD <- NULL
  
  catalogueTmp <- catalogueGRDC(columnName = "grdc_no", columnValue = stationID)
  
  # Retrieve look-up table
  load(system.file(file.path("data", "grdcLTMMD.rda"), package = "hddtools"))
  
  # Retrieve WMO region from catalogue
  wmoRegion <- catalogueTmp$wmo_reg
  
  # Retrieve ftp server location
  zipFile <- as.character(grdcLTMMD[which(grdcLTMMD$WMO_Region == wmoRegion),
                                    "Archive"])
  
  # create a temporary directory
  td <- tempdir()
  
  # create the placeholder file
  tf <- tempfile(tmpdir = td, fileext = ".zip")
  
  # download into the placeholder file
  download.file(zipFile, tf)
  
  # Type of tables
  tablenames <- c("LTVD", "LTVM", "PVD", "PVM", "YVD", "YVM")
  
  # get the name of the file to unzip
  fname <- paste0(stationID, "_Q_", tablenames, ".csv")
  
  # unzip the file to the temporary directory
  unzip(tf, files = fname, exdir = td, overwrite = TRUE)
  
  # fpath is the full path to the extracted file
  fpath <- file.path(td, fname)
  
  if (!all(file.exists(fpath))) {
    
    stop("Station does not have monthly records")
    
  }
  
  message("Station has monthly records")
  
  # Initialise empty list of tables
  ltables <- list()
  
  # Populate tables
  for (j in seq_along(fpath)) {
    
    TS <- readLines(fpath[j])
    
    # find dataset content
    row_data <- grep(pattern = "# Data Set Content:", x = TS)
    data_names <- trimws(x = unlist(strsplit(TS[row_data], ":")), which = "both")
    data_names <- data_names[seq(2, length(data_names), 2)]
    data_names <- gsub(pattern = " ", replacement = "", x = data_names)
    data_names <- gsub(pattern = ")", replacement = "", x = data_names)
    data_names <- gsub(pattern = "\\(", replacement = "_", x = data_names)
    data_names <- gsub(pattern = "\\.", replacement = "_", x = data_names)
    
    ## find data lines
    row_data_lines <- grep(pattern = "# Data lines:", x = TS)[1]
    chr_positions <- gregexpr(pattern = "[0-9]", text = TS[row_data_lines])[[1]]
    lchr_positions <- length(chr_positions)
    rows_to_read <- as.numeric(substr(x = TS[row_data_lines],
                                      start = chr_positions[1],
                                      stop = chr_positions[lchr_positions]))
    
    # find tables
    row_data <- grep(pattern = "# DATA", x = TS, ignore.case = FALSE)
    row_start <- row_data + 2
    row_end <- row_start + rows_to_read - 1
    
    # Read columns and assign names
    column_names <- c()
    for (k in seq_along(data_names)) {
      tempcolnames <- unlist(strsplit(TS[row_data[k] + 1], ";"))
      tempcolnames <- trimws(tempcolnames, which = "both")
      tempcolnames <- gsub(pattern = "-", replacement = "_", x = tempcolnames)
      column_names <- c(column_names, paste0(data_names[k], "__", tempcolnames))
    }
    
    for (w in seq_along(row_start)) {
      # Assemble data frame
      row_split <- unlist(strsplit(TS[row_start[w]:row_end[w]], ";"))
      no_spaces <- trimws(row_split, which = c("both"))
      if (w == 1) {
        tmp <- matrix(no_spaces, nrow = rows_to_read, byrow = TRUE)
      } else {
        tmp <- cbind(tmp, matrix(no_spaces, nrow = rows_to_read, byrow = TRUE))
      }
    }
    
    df <- data.frame(tmp, stringsAsFactors = FALSE)
    names(df) <- column_names
    
    ltables[[j]] <- df
    
  }
  
  names(ltables) <- tablenames
  
  if ( plotOption == TRUE ){
    
    ltable <- ltables$LTVM
    
    dummyTime <- seq(as.Date("2012-01-01"),
                     as.Date("2012-12-31"),
                     by = "months")
    
    plot(zoo::zoo(ltable$LTV_MMM_Month__Value, order.by = dummyTime),
         main = paste("Monthly statistics: ",
                      catalogueTmp$station, " (",
                      catalogueTmp$country_code, ")", sep=""),
         type = "l", ylim = c(min(as.numeric(ltable$LTV_LMM_Monthly__Value)),
                              max(as.numeric(ltable$LTV_HMM_Month__Value))),
         xlab = "", ylab = "m3/s", xaxt = "n")
    axis(1, at = dummyTime, labels = format(dummyTime, "%b"))
    polygon(c(dummyTime,rev(dummyTime)), c(ltable$LTV_LMM_Monthly__Value,
                                           rev(ltable$LTV_HMM_Month__Value)),
            col = "orange",
            lty = 0,
            lwd = 2)
    lines(zoo::zoo(ltable$LTV_MMM_Month__Value, order.by = dummyTime),
          lty = 2, lwd = 3, col = "red")
    
    legend("top", legend = c("Min-Max range", "Mean"),
           bty = "n",
           col = c("orange", "red"),
           lty = c(0, 2), lwd = c(0, 3),
           pch = c(22, NA),
           pt.bg = c("orange", NA),
           pt.cex = 2)
  }
  
  return(ltables)

}
