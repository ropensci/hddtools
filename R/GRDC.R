#' Data source: Global Runoff Data Centre catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Global Runoff Data Centre database
#' which provides river discharge data for about 9000 sites over 157 countries.
#'
#' @param areaBox bounding box, a list made of 4 elements: minimum longitude
#' (lonMin), minimum latitude (latMin), maximum longitude (lonMax), maximum
#' latitude (latMax)
#' @param columnName name of the column to filter
#' @param columnValue value to look for in the column named columnName
#' @param useCachedData logical, set to TRUE to use cached data, set to FALSE to
#' retrive data from online source. This is TRUE by default.
#'
#' @return This function returns a data frame made of 9481 rows (gauging
#' stations, as per October 2017) and 26 columns:
#' \itemize{
#'   \item{\code{grdc_no}}{: GRDC station number}
#'   \item{\code{wmo_reg}}{: WMO region}
#'   \item{\code{sub_reg}}{: WMO subregion}
#'   \item{\code{nat_id}}{: national station ID}
#'   \item{\code{river}}{: river name}
#'   \item{\code{station}}{: station name}
#'   \item{\code{country_code}}{: country code (ISO 3166)}
#'   \item{\code{lat}}{: latitude, decimal degree}
#'   \item{\code{long}}{: longitude, decimal degree}
#'   \item{\code{area}}{: catchment size, km2}
#'   \item{\code{altitude}}{: height of gauge zero, m above sea level}
#'   \item{\code{ds_stat_no}}{: GRDC station number of next downstream GRDC
#'   station}
#'   \item{\code{d_start}}{: daily data available from year}
#'   \item{\code{d_end}}{: daily data available until year}
#'   \item{\code{d_yrs}}{: length of time series, daily data}
#'   \item{\code{d_miss}}{: percentage of missing values (daily data)}
#'   \item{\code{m_start}}{: monthly data available from}
#'   \item{\code{m_end}}{: monthly data available until}
#'   \item{\code{m_yrs}}{: length of time series, monthly data}
#'   \item{\code{m_miss}}{: percentage of missing values (monthly data)}
#'   \item{\code{t_start}}{: earliest data available}
#'   \item{\code{t_end}}{: latest data available}
#'   \item{\code{t_yrs}}{: maximum length of time series, daily and monthly
#'   data}
#'   \item{\code{lta_discharge}}{: mean annual streamflow, m3/s}
#'   \item{\code{r_volume_yr}}{: mean annual volume, km3}
#'   \item{\code{r_height_yr}}{: mean annual runoff depth, mm}
#' }
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
                          columnName = NULL,
                          columnValue = NULL,
                          useCachedData = TRUE) {

  options(warn = -1)                                     # do not print warnings

  the_url <- "ftp://ftp.bafg.de/pub/REFERATE/GRDC/catalogue/"

  if (useCachedData | RCurl::url.exists(the_url) == FALSE) {

    if (RCurl::url.exists(the_url) == FALSE) {

      message(paste("There was a problem when trying to access the server,",
                    "either the server is down or",
                    "you have no internet connection.\n"))

    }

    message("Using cached data.")

    load(system.file(file.path("data", "GRDCcatalogue.rda"),
                     package = "hddtools"))

  }else{

    message("Retrieving data from data provider.")

    # Retrieve the catalogue
    result <- RCurl::getURL(the_url, ftp.use.epsv=TRUE, dirlistonly = TRUE)
    list_of_files <- strsplit(result, "\r*\n")[[1]]
    yesterday <- gsub(pattern = "-", replacement = "_", Sys.Date() - 1)
    today <- gsub(pattern = "-", replacement = "_", Sys.Date())
    latest_file <- 
      ifelse(test = length(list_of_files[grep(pattern = today,
                                              x = list_of_files)]),
             yes = list_of_files[grep(pattern = today, x = list_of_files)],
             no = list_of_files[grep(pattern = yesterday, x = list_of_files)])
    latest_file <- paste0(the_url, latest_file)
    
    my_tmp_file <- tempfile()
    x <- RCurl::getBinaryURL(latest_file, ftp.use.epsv = FALSE,crlf = TRUE)
    writeBin(object = x, con = my_tmp_file)
    GRDCcatalogue <- readxl::read_xlsx(my_tmp_file, sheet = "Catalogue")

    # Cleanup non ascii characters
    for (i in seq_along(names(GRDCcatalogue))) {
      # Substitute n.a. with NA
      idx <- which(GRDCcatalogue[, i] == "n.a." | GRDCcatalogue[, i] == "-" |
                     GRDCcatalogue[, i] == "-999")
      if (length(idx) > 0) {GRDCcatalogue[idx, i] <- NA}
    }
    
    # Convert to numeric some of the columns
    colx <- which(!(names(GRDCcatalogue) %in% c("grdc_no", "wmo_reg", "sub_reg",
                                             "nat_id", "river", "station",
                                             "country", "provider_id")))
    GRDCcatalogue[, colx] <- sapply(GRDCcatalogue[, colx], as.numeric)
  }

  if (!is.null(areaBox)) {

    grdcSelectedBB <- subset(GRDCcatalogue,
                             (GRDCcatalogue$lat <= areaBox@ymax &
                                GRDCcatalogue$lat >= areaBox@ymin &
                                GRDCcatalogue$long <= areaBox@xmax &
                                GRDCcatalogue$long >= areaBox@xmin))

  }else{

    grdcSelectedBB <- GRDCcatalogue

  }

  if (!is.null(columnName) & !is.null(columnValue)) {

    if (tolower(columnName) %in% tolower(names(grdcSelectedBB))) {

      if (class(grdcSelectedBB[, columnName]) == "character") {

        rows2select <- grep(columnValue,
                            as.vector(grdcSelectedBB[, columnName]),
                            ignore.case = TRUE)

      } else {

        rows2select <- eval(parse(text = paste0("which(grdcSelectedBB$",
                                                columnName, " ",
                                                columnValue, ")")))

      }

      grdcTable <- grdcSelectedBB[rows2select, ]

    }else{

      message("columnName should be one of the columns of the catalogue")

    }

  }else{

    grdcTable <- grdcSelectedBB

  }

  row.names(grdcTable) <- NULL

  return(grdcTable)

}

#' Interface for the Global Runoff Data Centre database of Monthly Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Global Runoff Data Centre monthly
#' mean daily discharges database.
#'
#' @param stationID 7 string that identifies a station, GRDC station number is
#' called "grdc no" in the catalogue.
#' @param plotOption boolean to define whether to plot the results. By default
#' this is set to TRUE.
#' @param catalogue station catalogue obstained from \code{catalogueGRDC()}
#' @param ... additional argument to pass to \code{catalogueGRDC()}.
#'
#' @return The function returns a list of 6 tables:
#' \itemize{
#'   \item{\strong{LTVD}}{This is a table containing seasonal variability of
#'   river discharge based on original daily data. It is made of 8 columns:}
#'     \itemize{
#'       \item{LTV_LMM_Monthly__MM}{: calendar month}
#'       \item{LTV_LDM_Day__Value}{: lowest daily discharge value in each
#'       calendar month in the given time series, calculated from lowest values
#'       of each calendar month in consecutive calendar years.}
#'       \item{LTV_LDM_Day__YYYY_MM_DD}{: Date of occurrence of lowest daily
#'       discharge}
#'       \item{LTV_MDM_Day__MM}{: calendar month}
#'       \item{LTV_MDM_Day__Value}{: mean of daily discharge values in each
#'       calendar month in the given time series, calculated from monthly means
#'       of each calendar month in consecutive calendar years.}
#'       \item{LTV_HDM_Day__MM}{: calendar month}
#'       \item{LTV_HDM_Day__Value}{: highest daily discharge value in each
#'       calendar month in the given time series, calculated from highest values
#'       of each calendar month in consecutive calendar years.}
#'       \item{LTV_HDM_Day__YYYY_MM_DD}{: Date of occurrence of highest daily
#'       discharge}
#'     }
#'   \item{\strong{LTVM}}{This is a table containing seasonal variability of
#'   river discharge based on monthly data. It is made of 8 columns:}
#'     \itemize{
#'       \item{LTV_LMM_Monthly__MM}{: calendar month}
#'       \item{LTV_LMM_Monthly__Value}{: lowest monthly discharge value in each
#'       calendar month in the given time series, calculated from lowest values
#'       of each calendar month in consecutive calendar years.}
#'       \item{LTV_LMM_Monthly__YYYY_MM_DD}{: Date of occurrence of lowest
#'       monthly discharge}
#'       \item{LTV_MMM_Month__MM}{: calendar month}
#'       \item{LTV_MMM_Month__Value}{: mean of monthly discharge values in each
#'       calendar month in the given time series, calculated from values of each
#'       calendar month in consecutive calendar years..}
#'       \item{LTV_HMM_Month__MM}{: calendar month}
#'       \item{LTV_HMM_Month__Value}{: highest monthly discharge value in each
#'       calendar month in the given time series, calculated from highest values
#'       of each calendar month in consecutive calendar years.}
#'       \item{LTV_HMM_Month__YYYY_MM_DD}{: Date of occurrence of highest
#'       monthly discharge}
#'     }
#' \item{\strong{PVD}}{This is a table containing ... It is made of 7 columns:}
#'   \itemize{
#'     \item{LQ_Day__Value}{: lowest daily discharge value in the given time
#'     series, calculated from lowest values of consecutive calendar years.}
#'     \item{LQ_Day__YYYY_MM_DD}{: Date of occurrence of lowest daily discharge}
#'     \item{MLQ_Day__Value}{: mean of lowest daily discharge values in the
#'     given time series, calculated from lowest values of consecutive calendar
#'     years.}
#'     \item{MQ_Day__Value}{: mean of daily discharge values in the given time
#'     series, calculated from yearly means of consecutive calendar years.}
#'     \item{MHQ_Day__Value}{: mean of highest daily discharge values in the
#'     given time series, calculated from highest values of consecutive calendar
#'     years.}
#'     \item{HQ_Day__Value}{: highest daily discharge value in the given time
#'     series, calculated from highest values of consecutive calendar years.}
#'     \item{HQ_Day__YYYY_MM_DD}{: Occurrence date of highest daily discharge}
#'   }
#' \item{\strong{PVM}}{This is a table containing ... It is made of 5 columns:}
#'   \itemize{
#'     \item{LQ_Month__Value}{: lowest monthly discharge value in the given time
#'     series, calculated from lowest yearly values of consecutive calendar
#'     years.}
#'     \item{LQ_Month__YYYY_MM}{: month of first occurence of lowest monthly
#'     discharge}
#'     \item{MQ_Month__Value}{: mean of monthly discharge values in the given
#'     time series, calculated from yearly means of consecutive calendar years.}
#'     \item{HQ_Month__Value}{: highest monthly discharge value in the given
#'     time series, calculated from highest yearly values of consecutive
#'     calendar years.}
#'     \item{HQ_Month__YYYY_MM}{: month of first occurence of highest monthly
#'     discharge}
#'   }
#' \item{\strong{YVD}}{This is a table containing ... It is made of 12 columns:}
#'   \itemize{
#'     \item{Year_Min_Day__YYYY}{: calender year}
#'     \item{Year_Min_Day__Value}{: Lowest daily discharge value in the given
#'     calendar year, calculated from 12 lowest monthly values in the year in
#'     question.}
#'     \item{Year_Min_Day__YYYY_MM_DD}{:  date of first occurence}
#'     \item{Year_Mean_Min_Day__YYYY}{: calender year}
#'     \item{Year_Mean_Min_Day__Value}{: mean of lowest daily discharge values
#'     in the given calendar year, calculated from 12 lowest monthly values in
#'     the year in question.}
#'     \item{Year_Mean_Day__YYYY}{: calender year}
#'     \item{Year_Mean_Day__Value}{: Mean of daily discharge values in the given
#'     calendar year, calculated from 12 monthly means in the year in question.}
#'     \item{Year_Mean_Max_Day__YYYY}{: calender year}
#'     \item{Year_Mean_Max_Day__Value}{: mean of highest daily discharge values
#'     in the given calendar year, calculated from 12 highest monthly values in
#'     the year in question.}
#'     \item{Year_Max_Day__YYYY}{: calender year}
#'     \item{Year_Max_Day__Value}{: highest daily discharge value in the given
#'     calendar year, calculated from 12 highest monthly values in the year in
#'     question.}
#'     \item{Year_Max_Day__YYYY_MM_DD}{: date of first occurence}
#'   }
#' \item{\strong{YVM}}{This is a table containing ... It is made of 8 columns:}
#'   \itemize{
#'     \item{Year_Min_Month__YYYY}{: calender year}
#'     \item{Year_Min_Month__Value}{: lowest monthly discharge value in the
#'     given calendar year, calculated from 12 monthly values in the year in
#'     question.}
#'     \item{Year_Min_Month__YYYY_MM}{: month of first occurence}
#'     \item{Year_Mean_Month__Value}{: mean of monthly discharge values in the
#'     given calendar year, calculated from 12 monthly values in the year in
#'     question.}
#'     \item{Year_Max_Month__YYYY}{: calender year}
#'     \item{Year_Max_Month__Value}{: highest monthly discharge value in the
#'     given calendar year, calculated from 12 monthly values in the year in
#'     question.}
#'     \item{Year_Max_Month__YYYY_MM}{: month of first occurence}
#'   }
#' }
#'
#' @details Please note that not all the GRDC stations listed in the catalogue
#' have monthly data available.
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

tsGRDC <- function(stationID, plotOption = FALSE, catalogue = NULL, ...) {

  options(warn = -1)
  grdcLTMMD <- NULL

  if (is.null(catalogue)) {
    catalogueTmp <- catalogueGRDC(...)
  }else{
    catalogueTmp <- catalogue
  }
  catalogueTmp <- catalogueTmp[which(catalogueTmp$grdc_no == stationID), ]

  if (nrow(catalogueTmp) > 0) {

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
    utils::download.file(zipFile, tf, quiet = TRUE)

    # Type of tables
    tablenames <- c("LTVD", "LTVM", "PVD", "PVM", "YVD", "YVM")

    # get the name of the file to unzip
    fname <- paste0(stationID, "_Q_", tablenames, ".csv")

    # unzip the file to the temporary directory
    utils::unzip(tf, files = fname, exdir = td, overwrite = TRUE)

    # fpath is the full path to the extracted file
    fpath <- file.path(td, fname)

    if (!all(file.exists(fpath))) {

      stop("Data are not available at this station")

    }

    # Initialise empty list of tables
    ltables <- list()

    # Populate tables
    for (j in seq_along(fpath)) {

      TS <- readLines(fpath[j])
      # find dataset content
      row_data <- grep(pattern = "# Data Set Content:", x = TS)
      data_names <- trimws(x = unlist(strsplit(TS[row_data], ":")),
                           which = "both")
      data_names <- data_names[seq(2, length(data_names), 2)]
      data_names <- gsub(pattern = " ", replacement = "", x = data_names)
      data_names <- gsub(pattern = ")", replacement = "", x = data_names)
      data_names <- gsub(pattern = "\\(", replacement = "_", x = data_names)
      data_names <- gsub(pattern = "\\.", replacement = "_", x = data_names)

      ## find data lines
      row_data_lines <- grep(pattern = "# Data lines:", x = TS)[1]
      chr_positions <- gregexpr(pattern = "[0-9]",
                                text = TS[row_data_lines])[[1]]
      lchr_positions <- length(chr_positions)
      rows_to_read <- as.numeric(substr(x = TS[row_data_lines],
                                        start = chr_positions[1],
                                        stop = chr_positions[lchr_positions]))

      if (rows_to_read > 0) {

        # find tables
        row_data <- grep(pattern = "# DATA", x = TS, ignore.case = FALSE)
        row_start <- row_data + 2
        row_end <- row_start + rows_to_read - 1

        # Read columns and assign names
        column_names <- c()
        for (k in seq_along(data_names)) {
          tempcolnames <- unlist(strsplit(TS[row_data[k] + 1], ";"))
          tempcolnames <- trimws(tempcolnames, which = "both")
          tempcolnames <- gsub(pattern = "-", replacement = "_",
                               x = tempcolnames)
          column_names <- c(column_names, paste0(data_names[k], "__",
                                                 tempcolnames))
        }

        for (w in seq_along(row_start)) {
          # Assemble data frame
          row_split <- unlist(strsplit(TS[row_start[w]:row_end[w]], ";"))
          no_spaces <- trimws(row_split, which = c("both"))
          if (w == 1) {
            tmp <- matrix(no_spaces, nrow = rows_to_read, byrow = TRUE)
          } else {
            tmp <- cbind(tmp, matrix(no_spaces, nrow = rows_to_read,
                                     byrow = TRUE))
          }
        }

        df <- data.frame(tmp, stringsAsFactors = FALSE)
        names(df) <- column_names

        ltables[[j]] <- df
      }else{
        message(paste(tablenames[j],
                      "data are not available at this station"))
        ltables[[j]] <- NULL
      }

    }

    names(ltables) <- tablenames

    if (plotOption == TRUE) {

      ltable <- ltables$LTVM

      dummyTime <- seq(as.Date("2012-01-01"),
                       as.Date("2012-12-31"),
                       by = "months")

      plot(zoo::zoo(ltable$LTV_MMM_Month__Value, order.by = dummyTime),
           main = paste("Monthly statistics: ",
                        catalogueTmp$station, " (",
                        catalogueTmp$country_code, ")", sep = ""),
           type = "l", ylim = c(min(as.numeric(ltable$LTV_LMM_Monthly__Value)),
                                max(as.numeric(ltable$LTV_HMM_Month__Value))),
           xlab = "", ylab = "m3/s", xaxt = "n")
      axis(1, at = dummyTime, labels = format(dummyTime, "%b"))
      polygon(c(dummyTime, rev(dummyTime)), c(ltable$LTV_LMM_Monthly__Value,
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

  }else{

    message("No data is available for this station!")

  }

}
