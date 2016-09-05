#' Convert a bounding box to a SpatialPolygons object
#' Bounding box is first created (in lat/lon) then projected if specified
#'
#' @param bbox Bounding box: a 2x2 numerical matrix of lat/lon coordinates
#' @param proj4stringFrom Projection string for the current bbox coordinates (defaults to lat/lon, WGS84)
#' @param proj4stringTo Projection string, or NULL to not project
#'
#' @return A SpatialPolygons object of the bounding box
#'
#' @references http://gis.stackexchange.com/questions/46954/clip-spatial-object-to-bounding-box-in-r
#'
#' @examples
#' \dontrun{
#'   bbox <- list(lonMin=-180,latMin=-50,lonMax=+180,latMax=+50)
#'   bbSP <- bboxSpatialPolygon(bbox)
#' }
#'

bboxSpatialPolygon <- function(bbox,
                               proj4stringFrom = NULL,
                               proj4stringTo = NULL) {

  if (is.null(proj4stringFrom)){

    # message('proj4stringFrom is set to CRS("+proj=longlat +datum=WGS84")')
    proj4stringFrom <- sp::CRS("+proj=longlat +datum=WGS84")

  }

  if (is.null(proj4stringTo)){

    # message('proj4stringTo is NULL, no transformation required')

  }

  bb <- matrix(as.numeric(c(bbox$lonMin,bbox$latMin,bbox$lonMax,bbox$latMax)),
               nrow=2)
  rownames(bb) <- c("lon","lat")
  colnames(bb) <- c("min","max")

  # Create unprojected bbox as spatial object
  # clockwise, 5 points to close it
  bboxMat <- rbind( c(bb['lon','min'],bb['lat','min']),
                    c(bb['lon','min'],bb['lat','max']),
                    c(bb['lon','max'],bb['lat','max']),
                    c(bb['lon','max'],bb['lat','min']),
                    c(bb['lon','min'],bb['lat','min']) )

  bboxSP <- sp::SpatialPolygons(list(sp::Polygons(list(sp::Polygon(bboxMat)),
                                                  "bbox")),
                                proj4string = proj4stringFrom)

  if(!is.null(proj4stringTo)) {
    bboxSP <- sp::spTransform(bboxSP, proj4stringTo)
  }

  return(bboxSP)

}
