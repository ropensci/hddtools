---
title: 'hddtools: Hydrological Data Discovery Tools'
authors:
- affiliation: 1
  name: Claudia Vitolo
  orcid: 0000-0002-4252-1176
date: "27 December 2016"
output: pdf_document
bibliography: paper.bib
csl: hydrology-and-earth-system-sciences.csl
tags:
- open data
- hydrology
- R
affiliations:
- index: 1
  name: European Centre for Medium-range Weather Forecasts
---

# Summary

The hddtools [@hddtoolsCRAN] (**h**ydrological **d**ata **d**iscovery **tools**) is an R package [@R-base] designed to facilitate access to a variety of online open data sources relevant for hydrologists and, in general, environmental scientists and practitioners. This typically implies the download of a metadata catalogue, selection of information needed, formal request for dataset(s), de-compression, conversion, manual filtering and parsing. All those operation are made more efficient by re-usable functions. 

Depending on the data license, functions can provide offline and/or online modes. When redistribution is allowed, for instance, a copy of the dataset is cached within the package and updated twice a year. This is the fastest option and also allows offline use of package's functions. When re-distribution is not allowed, only online mode is provided.

Datasets for which functions are provided include: the Global Runoff Data Center (GRDC), the Scottish Environment Protection Agency (SEPA), the Top-Down modelling Working Group (Data60UK and MOPEX), Met Office Hadley Centre Observation Data (HadUKP Data) and NASA's Tropical Rainfall Measuring Mission (TRMM). 

This package follows a logic similar to other packages such as rdefra [@rdefraJOSS] and rnrfa [@rnrfa]: sites are first identified through a catalogue (if available), data are imported via the station identification number, then data are visualised and/or used in analyses. The metadata related to the monitoring stations are accessible through the functions: `catalogueGRDC()`, `catalogueSEPA()`, `catalogueData60UK()` and  `catalogueMOPEX()`. Time series data can be obtained using the functions: `tsGRDC()`, `tsSEPA()`, `tsData60UK()`, `tsMOPEX()` and `HadDAILY()`. Geospatial information can be retrieved using the functions: `KGClimateClass()` returning the Koppen-Greiger climate zone and `TRMM()` which retrieves global historical rainfall estimations.

The retrieved hydrological time series (e.g. using `tsData60UK()`) can be used to feed hydrological models such as fuse [@fuseGitHub; @fuseJOSS], topmodel [@topmodel] and hydromad [@Andrews20111171; @hydromad].

For more details and examples, please refer to the help pages and vignette.

# References
