#' Data source: MOPEX catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function retrieves the list of the MOPEX basins.
#' 
#' @param MAP Boolean, TRUE by default. If FALSE it returns a list of the USGS
#' station ID’s and the gage locations of all 1861 potential MOPEX basins.
#' If TRUE, it return a list of the USGS station ID’s and the gage locations of
#' the 438 MOPEX basins with MAP estimates.
#'
#' @return This function returns a data frame containing the following columns:
#' \describe{
#'   \item{\code{USGS_ID}}{Station id number}
#'   \item{\code{Longitude}}{Decimal degrees East}
#'   \item{\code{Latitude}}{Decimal degrees North}
#'   \item{\code{Drainage_Area}}{Square Miles}
#'   \item{\code{R_gauges}}{Required number of precipitation gages to meet MAP accuracy criteria}
#'   \item{\code{N_gauges}}{Number of gages in total gage window used to estimate MAP}
#'   \item{\code{A_gauges}}{Avaliable number of gages in the basin}
#'   \item{\code{Ratio_AR}}{Ratio of Available to Required number of gages in the basin}
#'   \item{\code{Date_start}}{Date when recordings start}
#'   \item{\code{Date_end}}{Date when recordings end}
#'   \item{\code{State}}{State of the basin}
#'   \item{\code{Name}}{Name of the basin}
#' }
#' Columns Date_start, Date_end, State, Name are taken from:
#' https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Basin_Characteristics/usgs431.txt
#' Date_start and Date_end are conventionally set to the first of the month
#' here, however actual recordings my differ. Always refer to the recording date
#' obtained as output of \code{tsMOPEX()}.
#'
#' @export
#' 
#' @source https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Documentation/
#'
#' @examples
#' \dontrun{
#'   # Retrieve the MOPEX catalogue
#'   catalogue <- catalogueMOPEX()
#' }
#'

catalogueMOPEX <- function(MAP = TRUE){

  service_url <- "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data"
  folder_name <- "Basin_Characteristics"

  # Get basic basin characteristics from the related file
  file_name <- ifelse(MAP == TRUE, "allrfc438.gls", "allrfc1861.gls")
  file_url <- paste(service_url, folder_name, file_name, sep = "/")

  # create a temporary file
  tf <- tempfile()
  # download into the placeholder file
  utils::download.file(url = file_url, destfile = tf, mode = "wb",
                       quiet = TRUE, method = "curl", extra="-L")
  
  # Read the file as a table
  mopexTable <- utils::read.table(file = tf)
  names(mopexTable) <- c("USGS_ID", "Longitude", "Latitude", "Drainage_Area",
                         "R_gauges", "N_gauges", "A_gauges", "Ratio_AR")

  # Get extra information for 431 basins only
  file_name <- "usgs431.txt"
  file_url <- paste(service_url, folder_name, file_name, sep = "/")
  extra_info <- utils::read.fwf(file = file_url,
                                widths = c(8, 10, 10, 11, 11, 8,
                                           8, 4, 4, 3, 9, 50))
  extra_info <- extra_info[, c("V1", "V6", "V7", "V10", "V12")]
  names(extra_info) <- c("USGS_ID", "Date_start", "Date_end", "State", "Name")
  
  # Join mopexTable and extra_info
  df <- merge(x = mopexTable, y = extra_info, by = "USGS_ID", all = TRUE)

  # Ensure USGS_ID is made of 8 digits, add leading zeros if needed
  # This is needed for consistency with the names of the time series files.
  df$USGS_ID <- sprintf("%08d", df$USGS_ID)
  
  # Convert all the factor to character
  character_cols <- c("Date_start", "Date_end", "State", "Name")
  df[, character_cols] <- lapply(df[, character_cols], as.character)
  
  # Remove spaces at the leading and trailing ends, not inside the string values
  df[, character_cols] <- lapply(df[, character_cols], trimws)
  
  # Convert dates
  date_cols <- c("Date_start", "Date_end")
  df$Date_start <- paste0("01/", df$Date_start)
  df$Date_end <- paste0("01/", df$Date_end)
  df[, date_cols] <- lapply(df[, date_cols], as.Date, format = "%d/%m/%Y")

  return(df)

}

#' Interface for the MOPEX database of Daily Time Series
#'
#' @author Claudia Vitolo
#'
#' @description This function extract the dataset containing daily rainfall and
#' streamflow discharge at one of the MOPEX locations.
#'
#' @param id String for the station ID number (USGS_ID)
#' @param MAP Boolean, TRUE by default. If FALSE it looks for data through all
#' the 1861 potential MOPEX basins.
#' If TRUE, it looks for data through the 438 MOPEX basins with MAP estimates.
#'
#' @return If MAP = FALSE, this function returns a time series of daily
#' streamflow discharge (Q, in mm). If MAP = TRUE, this function returns a data
#' frame containing the following columns (as zoo object):
#' \describe{
#'   \item{\code{Date}}{Format is "yyyymmdd"}
#'   \item{\code{P}}{Mean areal precipitation (mm)}
#'   \item{\code{E}}{Climatic potential evaporation (mm, based NOAA Freewater Evaporation Atlas)}
#'   \item{\code{Q}}{Daily streamflow discharge (mm)}
#'   \item{\code{T_max}}{Daily maximum air temperature (Celsius)}
#'   \item{\code{T_min}}{Daily minimum air temperature (Celsius)}
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   BroadRiver <- tsMOPEX(id = "01048000")
#' }
#'

tsMOPEX <- function(id, MAP = TRUE){
  
  service_url <- "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data"
  folder_name <- ifelse(MAP == TRUE, "Us_438_Daily", "Daily%20Q%201800")
  file_name <- ifelse(MAP == TRUE, paste0(id, ".dly"), paste0(id, ".dq"))
  file_url <- paste(service_url, folder_name, file_name, sep = "/")
  
  # create a temporary file
  tf <- tempfile()
  # download into the placeholder file
  utils::download.file(url = file_url, destfile = tf, mode = "wb",
                       quiet = TRUE, method = "curl", extra="-L")
  
  if (MAP == TRUE) {
    # Read the file as a table
    df <- utils::read.fwf(file = tf, widths = c(4, 2, 2, 10, 10, 10, 10, 10))
    Year <- df$V1
    Month <- sprintf("%02d", df$V2)
    Day <- sprintf("%02d", df$V3)
    df <- df[, 4:8]
    names(df) <- c("P", "E", "Q", "T_max", "T_min")
    df$Q[df$Q < 0] <- NA
  } else {
    # Read the file as a table
    df <- utils::read.table(file = tf, header = FALSE, skip = 1)
    df <- tidyr::pivot_longer(data = df, cols = 2:32,
                              values_to = "Q", names_to = "Day")
    Year <- substr(x = df$V1, start = 1, stop = 4)
    Month <- substr(x = df$V1, start = 5, stop = 6)
    Day <- trimws(substr(x = df$Day, start = 2, stop = nchar(df$Day)))
    Day <- sprintf("%02d", as.numeric(Day) - 1)
    # Remove dummy dates
    df <- df[df$Q >= 0, "Q"]
  }

  # Assemble date
  date <- as.Date(paste(Year, Month, Day, sep = "-"))
  # Remove dummy dates
  date <- date[!is.na(date)]

  # Create time series
  mopexTS <- zoo::zoo(df, order.by = date)

  return(mopexTS)

}
