#' Interface for the HadUKP - UK regional precipitation series
#'
#' @author Claudia Vitolo
#'
#' @description This function interfaces the Met Office Hadley Centre observations datasets: HadUKP which provides daily precipitation data for 3 regions and 8 subregions in the United Kingdom.
#'
#' @return list of 11 time series (1 per region/subregion)
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve the full dataset (list of 11 time series)
#'   HadDAILY_all <- HadDAILY()
#'   plot(x$EWP) # time series for England and Wales
#' }
#'

HadDAILY <- function(){

  baseURL <- "http://www.metoffice.gov.uk/hadobs/hadukp/data/daily/Had"
  regions <- data.frame(rbind( c("England & Wales", "EWP"),
                               c("South East England", "SEEP"),
                               c("South West England & Wales", "SWEP"),
                               c("Central England", "CEP"),
                               c("North West England & Wales", "NWEP"),
                               c("North East England", "NEEP"),
                               c("Scotland", "SP"),
                               c("South Scotland", "SSP"),
                               c("North Scotland", "NSP"),
                               c("East Scotland", "ESP"),
                               c("Northern Ireland", "NIP")))
  names(regions) <- c("names","code")

  dailydata <- list()
  regionCOUNTER <- 0

  for (region in as.character(regions$code)){

    regionCOUNTER <- regionCOUNTER + 1

    fullURL <- paste(baseURL, region, "_daily_qc.txt", sep = "")
    tmp <- read.table(fullURL, skip = 3, header = FALSE)

    # create empty time series
    dataSTART <- as.Date(paste(tmp[1,1], "-", tmp[1,2], "-", "01", sep = ""))
    dataEND <- as.Date(paste(tmp[dim(tmp)[1],1], "-",
                             tmp[dim(tmp)[1],2], "-",
                             Hmisc::monthDays(as.Date(paste(tmp[dim(tmp)[1],1],
                                                            "-",
                                                            tmp[dim(tmp)[1],2],
                                                            "-",
                                                            "01", sep = ""))),
                             sep = ""))

    dailydataREGION <- zoo(NA, seq(from = dataSTART, to = dataEND, by = "day"))
    counter <- 0

    for (i in 1:dim(tmp)[1]){

      tmpYear <- tmp[i,1]
      tmpMonth <- tmp[i,2]

      tmpDate <- as.Date(paste(tmpYear, "-", tmpMonth, "-", "01", sep = ""))

      for (tmpDay in 1:Hmisc::monthDays(tmpDate)){
        counter <- counter + 1
        dailydataREGION[[counter]] <- ifelse(tmp[i,tmpDay + 2] < 0, NA,
                                             tmp[i,tmpDay + 2])
      }
    }

    dailydata[[regionCOUNTER]] <- dailydataREGION

  }

  names(dailydata) <- as.character(regions$code)

  return(dailydata)

}
