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
#' @references \url{https://bit.ly/2NA5PSF}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   boundingbox <- raster::extent(-180, +180, -50, +50)
#'   bbSP <- bboxSpatialPolygon(boundingbox = boundingbox)
#' }
#'

bboxSpatialPolygon <- function(boundingbox,
                               proj4stringFrom = NULL,
                               proj4stringTo = NULL) {

  if (is.null(proj4stringFrom)) {

    proj4stringFrom <- sp::CRS("+proj=longlat +datum=WGS84")

  }

  bb <- matrix(as.numeric(c(boundingbox@xmin, boundingbox@ymin,
                            boundingbox@xmax, boundingbox@ymax)),
               nrow = 2)
  rownames(bb) <- c("lon", "lat")
  colnames(bb) <- c("min", "max")

  # Create unprojected boundingbox as spatial object
  # clockwise, 5 points to close it
  bboxMat <- rbind(c(bb["lon", "min"], bb["lat", "min"]),
                   c(bb["lon", "min"], bb["lat", "max"]),
                   c(bb["lon", "max"], bb["lat", "max"]),
                   c(bb["lon", "max"], bb["lat", "min"]),
                   c(bb["lon", "min"], bb["lat", "min"]))

  bboxSP <- sp::SpatialPolygons(list(sp::Polygons(list(sp::Polygon(bboxMat)),
                                                  "bbox")),
                                proj4string = proj4stringFrom)

  if (!is.null(proj4stringTo)) {
    bboxSP <- sp::spTransform(bboxSP, proj4stringTo)
  }

  return(bboxSP)

}
