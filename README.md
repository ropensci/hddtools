HDDTOOLS (R package)
=============================================

HDDTOOLS stands for Hydrological Data Discovery Tools. This R package is an open source project designed to facilitate non-programmatic access to avariety of online open data sources relevant for hydrologists and, more in general, environmental scientists and practitioners. 

This typically implies the download of a metadata catalogue, selection of information needed, formal request for dataset(s), de-compression, conversion, manual filtering and parsing. All those operation are made more efficient by re-usable functions. 

Depending on the data license, functions can provide offline and/or online modes. When redistribution is allowed, for instance, a copy of the dataset is cached within the package and updated twice a year. This is the fastest option and also allows offline use of package's functions. When re-distribution is not allowed, only online mode is provided.

### Basics
The stable version (preferred option) of hddtools is available from CRAN (http://www.cran.r-project.org/web/packages/hddtools/index.html):

```R
install.packages("hddtools")
```

The development version is, instead, on github and can be installed via devtools:

```R
library(devtools)
install_github("cvitolo/r_hddtools", subdir = "hddtools")
library(hddtools)
```

Source the additional function GenerateMap():
```R
source_gist("https://gist.github.com/cvitolo/f9d12402956b88935c38")
```

# Data sources and Functions

The functions provided can filter, slice and dice 2 and 3 dimensional information. 

```R
# Define a bounding box
bbox <- list(lonMin=-1,latMin=51,lonMax=0,latMax=52)

# Define a temporal extent
timeExtent <- seq(as.Date("2012-01-01"), as.Date("2012-12-31"), by="days")
```

## The Koppen Climate Classification map
The Koppen Climate Classification is the most widely used system for classifying the world's climates. Its categories are based on the annual and monthly averages of temperature and precipitation. It was first updated by Rudolf Geiger in 1961, then by Kottek et al. (2006), Peel et al. (2007) and then by Rubel et al. (2010). 

The package hddtools contains a function to identify the updated Koppen-Greiger climate zone, given a bounding box.

```R
# Extract climate zones from Peel's map:
KGClimateClass(bbox,updatedBy="Peel")

# Extract climate zones from Kottek's map:
KGClimateClass(bbox,updatedBy="Kottek")
```

## The Global Runoff Data Centre
The Global Runoff Data Centre (GRDC) is an international archive hosted by the Federal Institute of Hydrology (Bundesanstalt für Gewässerkunde or BfG) in Koblenz, Germany. The Centre operates under the auspices of the World Meteorological Organisation and retains services and datasets for all the major rivers in the world.

Catalogue, kml files and the product ``Long-Term Mean Monthly Discharges'' are open data and accessible via the hddtools.

```R
# GRDC full catalogue
x <- GRDCCatalogue()

# Filter GRDC catalogue based on a bounding box
x <- GRDCCatalogue(bbox=bbox, metadataColumn="statistics", entryValue=1)

# Plot a map
GenerateMap(x)

# Monthly data extraction
y <- GRDCMonthlyTS(stationID=x$grdc_no[[1]], plotOption=TRUE)
```

## NASA's Tropical Rainfall Measuring Mission (TRMM, only available for github version)
The Tropical Rainfall Measuring Mission (TRMM) is a joint mission between NASA and the Japan Aerospace Exploration Agency (JAXA) that uses a research satellite to measure precipitation within the tropics in order to improve our understanding of climate and its variability.

The TRMM satellite records global historical rainfall estimation in a gridded format since 1998 with a daily temporal resolution and a spatial resolution of 0.25 degrees. This information is openly available for educational purposes and downloadable from an FTP server.

The hddtools provides a function, called \verb|TRMM()|, to download and convert a selected portion of the TRMM dataset into a raster-brick that can be opened in any GIS software.

```R
# Retreive mean monthly recipitations from 3B43_V7 for 2012 (based on a bounding box)
TRMM(fileLocation="~/",
     url="ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",
     product="3B43",
     version=7,
     year=2012,
     bbox)
```

## Top-Down modelling Working Group 
The Top-Down modelling Working Group (TDWG) for the Prediction in Ungauged Basins (PUB) Decade (2003-2012) is an initiative of the International Association of Hydrological Sciences (IAHS) which collected datasets for hydrological modelling free-of-charge, available [here](http://tdwg.catchment.org/datasets.html). This package provides a common interface to retrieve, browse and filter information.

### The Data60UK dataset
The Data60UK initiative collated datasets of areal precipitation and streamflow discharge across 61 gauging sites in England and Wales (UK). The database was prepared from source databases for research purposes, with the intention to make it re-usable. This is now available in the public domain free of charge. 

The hddtools contain two functions to interact with this database: one to retreive the catalogue and another to retreive time series of areal precipitation and streamflow discharge.

```R
# Data60UK full catalogue
x <- Data60UKCatalogue()

# Filter Data60UK catalogue based on bounding box
x <- Data60UKCatalogue(bbox)

# Plot a map
GenerateMap(x)

# Extract time series 
y <- Data60UKDailyTS(39015, plotOption=TRUE)

# Extract time series for a specified teporal window
timeExtent <- seq(as.Date("1988-01-01"), as.Date("1989-12-31"), by="days")
y <- Data60UKDailyTS(39015, plotOption=TRUE, timeExtent)
```

### Warnings
This package and functions herein are part of an experimental open-source project. They are provided as is, without any guarantee.

# Please leave your feedback
I would greatly appreciate if you could leave your feedbacks either via email (cvitolodev@gmail.com) or taking a short survey [here](https://www.surveymonkey.com/s/QQ568FT).
