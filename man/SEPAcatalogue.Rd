\name{SEPAcatalogue}
\alias{SEPAcatalogue}
\docType{data}
\title{SEPAcatalogue}
\description{
The SEPA catalogue, as found at http://pennine.ddns.me.uk/riverlevels/ConciseList.html.
}
\usage{data("SEPAcatalogue")}
\format{
  A data frame with 830 observations on the following 8 variables.
  \describe{
    \item{\code{idNRFA}}{National River Flow Archive id number.}
    \item{\code{aspxpage}}{Environment Agency gauges id.}
    \item{\code{stationId}}{SEPA station id.}
    \item{\code{River}}{String describing the river's name.}
    \item{\code{Location}}{String describing the location.}
    \item{\code{GridRef}}{British National Grid Reference.}
    \item{\code{Operator}}{The operator's name.}
    \item{\code{CatchmentArea(km2)}}{Area of the catchment.}
  }
}
\examples{
data(SEPAcatalogue)
## maybe str(SEPAcatalogue) ; plot(SEPAcatalogue) ...
}
\keyword{datasets}
