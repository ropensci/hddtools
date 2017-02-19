## ----echo=FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  cache = FALSE,
  eval = FALSE
)

## ------------------------------------------------------------------------
#  packs <- c("zoo", "sp", "RCurl", "XML", "rnrfa", "Hmisc", "raster",
#             "stringr", "devtools", "leaflet")
#  new_packages <- packs[!(packs %in% installed.packages()[,"Package"])]
#  if(length(new_packages)) install.packages(new_packages)

## ------------------------------------------------------------------------
#  install.packages("hddtools")

## ------------------------------------------------------------------------
#  devtools::install_github("ropensci/hddtools")

## ---- eval = TRUE--------------------------------------------------------
library("hddtools")

## ---- eval = TRUE--------------------------------------------------------
# Define a bounding box
areaBox <- raster::extent(-10, 5, 48, 62)

# Extract climate zones from Peel's map:
KGClimateClass(areaBox = areaBox, updatedBy = "Peel")

# Extract climate zones from Kottek's map:
KGClimateClass(areaBox = areaBox, updatedBy = "Kottek")

## ---- eval = FALSE-------------------------------------------------------
#  # GRDC full catalogue
#  GRDC_catalogue_all <- catalogueGRDC()

## ------------------------------------------------------------------------
#  # Filter GRDC catalogue based on a country code
#  GRDC_catalogue_countrycode <- catalogueGRDC(columnName = "country_code",
#                                              columnValue = "IT")

## ------------------------------------------------------------------------
#  # Filter GRDC catalogue based on rivername
#  GRDC_catalogue_river <- catalogueGRDC(columnName = "river", columnValue = "PO")

## ------------------------------------------------------------------------
#  # Filter GRDC catalogue based on numerical value, for instance select all the stations for which daily data is available since 2000
#  GRDC_catalogue_dstart <- catalogueGRDC(columnName = "d_start",
#                                         columnValue = ">=2000")

## ------------------------------------------------------------------------
#  # Define a bounding box
#  areaBox <- raster::extent(-10, 5, 48, 62)
#  
#  # Filter GRDC catalogue based on a bounding box
#  GRDC_catalogue_bbox <- catalogueGRDC(areaBox = areaBox)

## ------------------------------------------------------------------------
#  # Define a bounding box
#  areaBox <- raster::extent(-10, 5, 48, 62)
#  
#  # Filter GRDC catalogue based on a bounding box plus keep only those stations where "statistics" value is 1
#  GRDC_catalogue_bbox_stats <- catalogueGRDC(areaBox = areaBox,
#                                             columnName = "statistics",
#                                             columnValue = 1)

## ------------------------------------------------------------------------
#  # Visualise outlets on an interactive map
#  library(leaflet)
#  leaflet(data = GRDC_catalogue_bbox_stats) %>%
#    addTiles() %>%  # Add default OpenStreetMap map tiles
#    addMarkers(~long, ~lat, popup = ~station)

## ---- eval = TRUE--------------------------------------------------------
# Monthly data extraction
WolfeToneBridge <- tsGRDC(stationID = catalogueGRDC()$grdc_no[7126],
                          plotOption = TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  # Define a bounding box
#  areaBox <- raster::extent(-10, 5, 48, 62)
#  
#  # Define a temporal extent
#  twindow <- seq(as.Date("2012-01-01"), as.Date("2012-03-31"), by = "months")
#  
#  # Retreive mean monthly precipitations from 3B43_V7 (based on a bounding box and time extent)
#  TRMMfile <- TRMM(twindow = twindow, areaBox = areaBox)
#  
#  library(raster)
#  plot(TRMMfile)

## ---- eval = TRUE--------------------------------------------------------
# Data60UK full catalogue
Data60UK_catalogue_all <- catalogueData60UK()

# Filter Data60UK catalogue based on bounding box
areaBox <- raster::extent(-4, -3, 51, 53)
Data60UK_catalogue_bbox <- catalogueData60UK(areaBox = areaBox)

## ------------------------------------------------------------------------
#  # Visualise outlets on an interactive map
#  library(leaflet)
#  leaflet(data = Data60UK_catalogue_bbox) %>%
#    addTiles() %>%  # Add default OpenStreetMap map tiles
#    addMarkers(~Longitude, ~Latitude, popup = ~Location)

## ---- eval = TRUE--------------------------------------------------------
# Extract time series 
stationID <- catalogueData60UK()$stationID[1]

# Extract only the time series
MorwickTS <- tsData60UK(stationID, plotOption = FALSE)
plot(MorwickTS)

# Extract time series for a specified temporal window
twindow <- seq(as.Date("1988-01-01"), as.Date("1989-12-31"), by = "days")
MorwickTSplot <- tsData60UK(stationID = stationID, 
                            plotOption = TRUE,
                            twindow = twindow)

## ---- eval = TRUE--------------------------------------------------------
# MOPEX full catalogue
MOPEX_catalogue_all <- catalogueMOPEX()

# Extract time series 
BroadRiver <- tsMOPEX(stationID = MOPEX_catalogue_all$stationID[1], 
                      plotOption = TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  # SEPA unofficial catalogue
#  SEPA_catalogue_all <- catalogueSEPA()

## ------------------------------------------------------------------------
#  # Single time series extraction
#  Kilphedir <- tsSEPA(stationID = catalogueSEPA()$stationId[1],
#                      plotOption = TRUE)

## ---- eval = TRUE--------------------------------------------------------
# Multiple time series extraction
y <- tsSEPA(stationID = c("234253", "234174", "234305"))
plot(y[[1]], ylim = c(0, max(y[[1]], y[[2]], y[[3]])), 
     xlab = "", ylab = "Water level [m]")
lines(y[[2]], col = "red")
lines(y[[3]], col = "blue")

