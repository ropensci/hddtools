#' hddtools: Hydrological Data Discovery Tools
#'
#' Facilitates discovery and handling of hydrological data, access to catalogues and databases.
#'
#' @name hddtools
#' @docType package
#'
#' @description: Many governmental bodies and institutions are currently committed to publish open data as the result of a trend of increasing transparency, based on which a wide variety of information produced at public expense is now becoming open and freely available to improve public involvement in the process of decision and policy making. Discovery, access and retrieval of information is, however, not always a simple task. Especially when access to data APIs is not allowed, downloading metadata catalogue, select the information needed, request datasets, de-compression, conversion, manual filtering and parsing can become rather tedious. The R package hddtools is an open source project, designed to make all the above operations more efficient by means of reusable functions. The package facilitate access to various online data sources such as the Global Runoff Data Centre, NASA's TRMM mission, the Data60UK database amongst others. This package complements R's growing functionality in environmental web technologies to bridge the gap between data providers and data consumers and it is designed to be the starting building block of scientific workflows for linking data and models in a seamless fashion.
#'
#' @references
#' Vitolo C, Buytaert W, 2014, HDDTOOLS: an R package serving Hydrological Data
#' Discovery Tools, AGU Fall Meeting, 15-19 December 2014, San Francisco, USA.
#'
#' @importFrom graphics axis legend lines plot polygon
#' @importFrom stats window
#' @importFrom utils download.file head read.csv read.fwf read.table tail untar unzip
#' @importFrom zoo zoo
#' @import rgdal
#' @importFrom sp CRS SpatialPolygons Polygon Polygons
#' @importFrom RCurl url.exists getURL
#' @importFrom XML readHTMLTable
#' @importFrom rnrfa catalogue
#' @importFrom Hmisc monthDays
#' @importFrom raster raster extract brick flip extent crop writeRaster
#' @importFrom stringr str_pad
#'
NULL

#' SEPAcatalogue
#'
#' @description The SEPA catalogue
#'
#' @usage data("SEPAcatalogue")
#'
#' @format A data frame with 830 observations on the following 8 variables.
#' \describe{
#'   \item{\code{idNRFA}}{National River Flow Archive id number.}
#'   \item{\code{aspxpage}}{Environment Agency gauges id.}
#'   \item{\code{stationId}}{SEPA station id.}
#'   \item{\code{River}}{String describing the river's name.}
#'   \item{\code{Location}}{String describing the location.}
#'   \item{\code{GridRef}}{British National Grid Reference.}
#'   \item{\code{Operator}}{The operator's name.}
#'   \item{\code{CatchmentArea(km2)}}{Area of the catchment.}
#' }
#'
#' @keywords datasets
#'
#' @source \url{http://pennine.ddns.me.uk/riverlevels/ConciseList.html}
"SEPAcatalogue"
