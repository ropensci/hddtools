
<!-- Edit the README.Rmd only!!! The README.md is generated automatically from README.Rmd. -->
hddtools: Hydrological Data Discovery Tools
===========================================

[![DOI](https://zenodo.org/badge/22423032.svg)](https://zenodo.org/badge/latestdoi/22423032) [![status](http://joss.theoj.org/papers/3287a12e7ce5d7e89938a6b4f56fc225/status.svg)](http://joss.theoj.org/papers/3287a12e7ce5d7e89938a6b4f56fc225)

[![CRAN Status Badge](http://www.r-pkg.org/badges/version/hddtools)](https://cran.r-project.org/package=hddtools) [![CRAN Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/hddtools)](https://cran.r-project.org/package=hddtools) [![CRAN Monthly Downloads](http://cranlogs.r-pkg.org/badges/hddtools)](https://cran.r-project.org/package=hddtools)

[![Travis-CI Build Status](https://travis-ci.org/ropensci/hddtools.svg?branch=master)](https://travis-ci.org/ropensci/hddtools) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/hddtools?branch=master&svg=true)](https://ci.appveyor.com/project/ropensci/hddtools) [![codecov.io](https://codecov.io/github/ropensci/hddtools/coverage.svg?branch=master)](https://codecov.io/github/ropensci/hddtools?branch=master)

**hddtools** stands for Hydrological Data Discovery Tools. This R package is an open source project designed to facilitate access to a variety of online open data sources relevant for hydrologists and, in general, environmental scientists and practitioners.

This typically implies the download of a metadata catalogue, selection of information needed, a formal request for dataset(s), de-compression, conversion, manual filtering and parsing. All those operations are made more efficient by re-usable functions.

Depending on the data license, functions can provide offline and/or online modes. When redistribution is allowed, for instance, a copy of the dataset is cached within the package and updated twice a year. This is the fastest option and also allows offline use of package's functions. When re-distribution is not allowed, only online mode is provided.

Dependencies & Installation
---------------------------

The hddtools package depends on other CRAN packages. Check for missing dependencies and install them using the commands below:

``` r
packs <- c("zoo", "sp", "RCurl", "XML", "rnrfa", "Hmisc", "raster", 
           "stringr", "devtools", "leaflet")
new_packages <- packs[!(packs %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
```

Get the released version from CRAN:

``` r
install.packages("hddtools")
```

Or the development version from github using [devtools](https://github.com/hadley/devtools):

``` r
devtools::install_github("ropensci/hddtools")
```

Load the hddtools package:

``` r
library("hddtools")
```

Data sources and Functions
--------------------------

The package contains functions to interact with the data providers listed below. For examples of the various functionalities see the [vignette](vignettes/hddtools_vignette.Rmd).

-   [KGClimateClass](http://koeppen-geiger.vu-wien.ac.at/): The Koppen Climate Classification map is used for classifying the world's climates based on the annual and monthly averages of temperature and precipitation.

-   [GRDC](http://www.bafg.de/GRDC/EN/Home/homepage_node.html): The Global Runoff Data Centre (GRDC) provides datasets for all the major rivers in the world.

-   [TRMM](http://trmm.gsfc.nasa.gov/): The NASA's Tropical Rainfall Measuring Mission records global historical rainfall estimation in a gridded format since 1998 with a daily temporal resolution and a spatial resolution of 0.25 degrees. **Please note the TRMM function has been temporarily removed from hddtools v0.7 as the ftp at NASA containing the data has been migrated. A new function is under development and will be avalable at the next release (v0.8).**

-   [Data60UK](http://tdwg.catchment.org/datasets.html): The Data60UK initiative collated datasets of areal precipitation and streamflow discharge across 61 gauging sites in England and Wales (UK).

-   [MOPEX](http://tdwg.catchment.org/datasets.html): This dataset contains historical hydrometeorological data and river basin characteristics for hundreds of river basins in the US.

-   [SEPA](http://apps.sepa.org.uk/waterlevels/): The Scottish Environment Protection Agency (SEPA) provides river level data for hundreds of gauging stations in the UK.

-   [HadUKP](http://www.metoffice.gov.uk/hadobs/hadukp/): The Met Office Hadley Centre Observation Data Centre provides daily precipitation time series averaged over UK regions and subregions.

Meta
----

-   This package and functions herein are part of an experimental open-source project. They are provided as is, without any guarantee.
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
-   Please [report any issues or bugs](https://github.com/ropensci/hddtools/issues).
-   License: [GPL-3](https://opensource.org/licenses/GPL-3.0)
-   This package was reviewed by [Erin Le Dell](https://github.com/ledell) and [Michael Sumner](https://github.com/mdsumner) for submission to ROpenSci (see review [here](https://github.com/ropensci/onboarding/issues/73)) and the Journal of Open Source Software (see review status [here](https://github.com/openjournals/joss-reviews/issues/56)).
-   Get citation information for `hddtools` in R doing `citation(package = "hddtools")`

<br/>

[![ropensci\_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
