#' Convert a bounding box to a SpatialPolygons object
#' Bounding box is first created (in lat/lon) then projected if specified
#'
#' @param boundingbox Bounding box: a 2x2 numerical matrix of lat/lon
#' coordinates
#' @param proj4stringFrom Projection string for the current boundingbox
#' coordinates (defaults to lat/lon, WGS84)
#' @param proj4stringTo Projection string, or NULL to not project
#'
#' @return A SpatialPolygons object of the bounding box
#'
#' @references \url{https://gis.stackexchange.com/questions/46954/clip-spatial-object-to-bounding-box-in-r}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' boundingbox <- terra::ext(-180, +180, -50, +50)
#' bbSP <- bboxSpatialPolygon(boundingbox = boundingbox)
#' }
#'
bboxSpatialPolygon <- function(boundingbox,
                               proj4stringFrom = NULL,
                               proj4stringTo = NULL) {
  if (!is.null(proj4stringFrom)) {
    stopifnot(class(proj4stringFrom) == "crs")
  }

  if (is.null(proj4stringFrom)) {
    proj4stringFrom <- "+proj=longlat +datum=WGS84"
  }

  if(is.matrix(boundingbox)) if(dim(boundingbox)==c(2,2)) bb <- boundingbox

  #For compatibility with raster input bounding box objects
  if(class(boundingbox) == "Extent"){
  bb <- matrix(as.numeric(c(
    boundingbox@xmin, boundingbox@ymin,
    boundingbox@xmax, boundingbox@ymax
  )),
  nrow = 2
  )}


  if(class(boundingbox) == "SpatExtent"){
    bb <- matrix(as.numeric(c(
      boundingbox$xmin, boundingbox$ymin,
      boundingbox$xmax, boundingbox$ymax
    )),
    nrow = 2
    )}

  if(!exists("bb")) stop("No valid bounding box provided")

  rownames(bb) <- c("lon", "lat")
  colnames(bb) <- c("min", "max")

  # Create unprojected boundingbox as spatial object
  # clockwise, 5 points to close it
  bboxMat <- rbind(
    c(bb["lon", "min"], bb["lat", "min"]),
    c(bb["lon", "min"], bb["lat", "max"]),
    c(bb["lon", "max"], bb["lat", "max"]),
    c(bb["lon", "max"], bb["lat", "min"]),
    c(bb["lon", "min"], bb["lat", "min"])
  )


  bboxSP <- terra::vect(bboxMat, "polygon", crs = proj4stringFrom)

  if (!is.null(proj4stringTo)) {
    stopifnot(class(proj4stringTo) == "crs")
    bboxSP <- sf::sf_project(bboxSP, proj4stringTo)
  }

  return(bboxSP)
}
