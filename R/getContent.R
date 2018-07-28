#' Extracts links from ftp page
#'
#' @author Claudia Vitolo
#'
#' @description This function extracts all the links in a ftp page
#'
#' @param dirs is the url from which links should be extracted
#'
#' @return vector containing all the links in the page
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve mopex daily catalogue
#'   url <- "ftp://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/"
#'   getContent(dirs = url)
#' }
#'

getContent <- function(dirs) {

  # Get names of files
  fls <- strsplit(RCurl::getURL(dirs, dirlistonly = TRUE), "\n")[[1]]
  # Keep only files with extension .dly
  fls_dly <- fls[grepl(pattern = "*.dly", x = fls)]
  # Combine with url to get full path
  links <- unlist(mapply(paste, dirs, fls_dly, sep = "", SIMPLIFY = FALSE),
                  use.names = FALSE)

  return(links)

}
