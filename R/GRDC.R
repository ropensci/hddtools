#' Data source: Global Runoff Data Centre catalogue
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Global Runoff Data Centre database
#' which provides river discharge data for about 9000 sites over 157 countries.
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

catalogueGRDC <- function() {

  the_url <- "ftp://ftp.bafg.de/pub/REFERATE/GRDC/catalogue/"

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
  
  # Cleanup non
  GRDCcatalogue <- data.frame(lapply(GRDCcatalogue,
                                     function(x) {gsub("n.a.|-999|-", NA, x)}),
                              stringsAsFactors = FALSE)
  
  # Convert to numeric some of the columns
  colx <- which(!(names(GRDCcatalogue) %in% c("grdc_no", "wmo_reg", "sub_reg",
                                              "nat_id", "river", "station",
                                              "country", "provider_id")))
  GRDCcatalogue[, colx] <- lapply(GRDCcatalogue[, colx], as.numeric)

  return(GRDCcatalogue)

}
