#' Data source: Global Runoff Data Centre catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Global Runoff Data Centre database
#' which provides river discharge data for almost 1000 sites over 157 countries.
#'
#' @return This function returns a data frame made with the following columns:
#' \itemize{
#'   \item{\code{grdc_no}}{: GRDC station number}
#'   \item{\code{wmo_reg}}{: WMO region}
#'   \item{\code{sub_reg}}{: WMO subregion}
#'   \item{\code{river}}{: river name}
#'   \item{\code{station}}{: station name}
#'   \item{\code{country}}{: 2-letter country code (ISO 3166)}
#'   \item{\code{lat}}{: latitude, decimal degree}
#'   \item{\code{long}}{: longitude, decimal degree}
#'   \item{\code{area}}{: catchment size, km2}
#'   \item{\code{altitude}}{: height of gauge zero, m above sea level}
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

catalogueGRDC <- function() {

  file_url <- "ftp://ftp.bafg.de/pub/REFERATE/GRDC/catalogue/grdc_stations.zip"

  # Create a temporary directory
  td <- tempdir()
  # Create the placeholder file
  tf <- tempfile(tmpdir = td, fileext = ".zip")
  
  # Retrieve the catalogue into the placeholder file
  x <- RCurl::getBinaryURL(file_url, ftp.use.epsv = FALSE, crlf = TRUE)
  writeBin(object = x, con = tf)
  
  # Unzip the file to the temporary directory
  utils::unzip(tf, exdir = td, overwrite = TRUE)
  
  xlxs_file <- list.files(path = td,
                          pattern = "GRDC_Stations.xlsx", full.names = TRUE)
  # Read
  GRDCcatalogue <- readxl::read_xlsx(path = xlxs_file,
                                     sheet = "station_catalogue")
  
  # Cleanup
  GRDCcatalogue <- data.frame(lapply(GRDCcatalogue,
                                     function(x) {gsub("n.a.|-999.0", NA, x)}),
                              stringsAsFactors = FALSE)
  
  # Convert to numeric some of the columns
  colx <- c("wmo_reg", "sub_reg",
            "d_start", "d_end", "d_yrs",
            "m_start", "m_end", "m_yrs",
            "t_start", "t_end", "t_yrs")
  GRDCcatalogue[, colx] <- lapply(GRDCcatalogue[, colx], as.integer)
  
  # Convert to integers some of the columns
  colx <- c("lat", "long", "area", "altitude", "d_miss", "m_miss",
            "lta_discharge", "r_volume_yr", "r_height_yr")
  GRDCcatalogue[, colx] <- lapply(GRDCcatalogue[, colx], as.numeric)

  return(GRDCcatalogue)

}
