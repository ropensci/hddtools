Hydrological Data Discovery Tools
==========

The R package ``hddtools'' is an open source project designed to facilitate non programmatic access to online data sources. This typically implies the download of a metadata catalogue, selection of information needed, formal request for dataset(s), de-compression, conversion, manual filtering and parsing. All those operation are made more efficient by re-usable functions. 

Depending on the data license, functions can provide offline and/or online modes. When redistribution is allowed, for instance, a copy of the dataset is cached within the package and updated twice a year. This is the fastest option and also allows offline use of package's functions. When re-distribution is not allowed, only online mode is provided.

### Basics
The package hddtools can be installed via devtools:

```R
library(devtools)
install_github("r_hddtools", username = "cvitolo", subdir = "hddtools")
library(hddtools)
```

# Data sources and Functions

## The Koppen Climate Classification map
The Koppen Climate Classification is the most widely used system for classifying the world's climates. Its categories are based on the annual and monthly averages of temperature and precipitation. It was first updated by Rudolf Geiger in 1961, then by Kottek et al. (2006), Peel et al. (2007) and then by Rubel et al. (2010). 

The package hddtools contains a function to identify the updated Koppen-Greiger climate zone, given a bounding box.

```R
# Extract climate zones from Peel's map:
KGClimateClass(lonMin=-3.82,lonMax=-3.63,latMin=52.41,latMax=52.52,updatedBy="Peel")

# Extract climate zones from Kottek's map:
KGClimateClass(lonMin=-3.82,lonMax=-3.63,latMin=52.41,latMax=52.52,updatedBy="Kottek")
```

## The Global Runoff Data Centre
The Global Runoff Data Centre (GRDC) is an international archive hosted by the Federal Institute of Hydrology (Bundesanstalt für Gewässerkunde or BfG) in Koblenz, Germany. The Centre operates under the auspices of the World Meteorological Organisation and retains services and datasets for all the major rivers in the world.

Catalogue, kml files and the product ``Long-Term Mean Monthly Discharges'' are open data and accessible via the hddtools.

```R
# 1. GRDC full catalogue
GRDCCatalogue()

# 2. Filter GRDC catalogue based on a bounding box
GRDCCatalogue(lonMin = -3.82,
              lonMax = -3.63,
              latMin = 52.43,
              latMax = 52.52,
              mdDescription = TRUE)
                
# 3. Monthly data extraction
GRDCMonthlyTS(1107700)
```

## The Data60UK dataset
In the decade 2003-2012, the IAHS Predictions in Ungauged Basins (PUB) international Top-Down modelling Working Group (TDWG) collated daily datasets of areal precipitation and streamflow discharge across 61 gauging sites in England and Wales. The database was prepared from source databases for research purposes, with the intention to make it re-usable. This is now available in the public domain free of charge. 

The hddtools contain two functions to interact with this database: one to retreive the catalogue and another to retreive time series of areal precipitation and streamflow discharge.

```R
# 1a. Data60UK full catalogue
Data60UKCatalogue()

# 1.b Filter Data60UK catalogue based on bounding box
Data60UKCatalogue(lonMin = -3.82,
                  lonMax = -3.63,
                  latMin = 52.43,
                  latMax = 52.52)

# 2. Extract time series 
Data60UKDailyTS(62001)
```

## NASA's Tropical Rainfall Measuring Mission (TRMM)
The Tropical Rainfall Measuring Mission (TRMM) is a joint mission between NASA and the Japan Aerospace Exploration Agency (JAXA) that uses a research satellite to measure precipitation within the tropics in order to improve our understanding of climate and its variability.

The TRMM satellite records global historical rainfall estimation in a gridded format since 1998 with a daily temporal resolution and a spatial resolution of 0.25 degrees. This information is openly available for educational purposes and downloadable from an FTP server.

HDDTOOLS provides a function, called \verb|TRMM|, to download and convert a selected portion of the TRMM dataset into a raster-brick that can be opened in any GIS software.

```R
# Retreive mean monthly recipitations from 3B43_V7 for 2012 (based on a bounding box)
TRMM(fileLocation="~/",
     url="ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",
     product="3B43",
     version=7,
     year=2012,
     lonMin=-3.82,
     lonMax=-3.63,
     latMin=52.43,
     latMax=52.52)
```

### Warnings
This package and functions herein are provided as is, without any guarantee.

# Please leave your feedback
I would greatly appreciate if you could leave your feedbacks either via email (cvitolodev@gmail.com) or taking a short survey (https://www.surveymonkey.com/s/QQ568FT).
