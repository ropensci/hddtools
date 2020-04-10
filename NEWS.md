# hddtools 0.8.3

* Updated URLs of SEPA and MOPEX data sources

# hddtools 0.8.2

* Connection to TRMM database removed as the web service is no longer available.
* Fixed problem with Rd file which prevented the manual to be created.
* Fixed problem with URL in DESCRIPTION file

# hddtools 0.8.1

* Any reference to TRMM database was removed as the web service is no longer available.

# hddtools 0.8

* tsGRDC function: this function now returns 6 tables (see documentation) according to latest updates on the GRDC side.
* GRDC data catalogue was updated in October 2017.

# hddtools 0.7

* TRMM function: this function has been temporarily removed from hddtools v0.7 as the ftp at NASA containing the data has been migrated. A new function is under development.

# hddtools 0.6

* TRMM function: set method for download.file to "auto" and added to arguments
* TRMM function: downloaded files are in temporary folder
* TRMM function: removed inputfileLocation
* TRMM function: added support for 3B42
* HadDAILY function removed as the service is no longer available
* The output of catalogueGRDC() is now a tibble table 

# hddtools 0.5

* Updated all the links to show the new repository (rOpenSci)

# hddtools 0.4

* Added a vignette
* Added paper for submission to JOSS
* Fixed bug with the TRMM function (for Windows users)

# hddtools 0.3

* Added unist tests (using testthat framework), 
* Added Travis CI
* Added Appveyor

# hddtools 0.2

* Added functions to get data from the following source:

  - TRMM
  - DATA60UK
  - MOPEX
  - GRDC
  - SEPA
  - Met Office Hadley Centre

# hddtools 0.1

* Initial release
