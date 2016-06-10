##
# File name: FetchEPAOpanData.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.18 10:44 UTC+8
# Last Modified:
#   2016.06.09 09:43 UTC+8
# Note: 
#   this file have some function to get epa open data
#   from internet by it's official API method
#   entry web site: http://opendata.epa.gov.tw/
#

## setup dependency libraries for this script -----
# install the libraries (uncommit if you don't have the libraries as following)
# install.packages( "stringr" )
# load the libraries
library( stringr )

## function decleartion -----
downloadEPAData <- function( resourceID, token, destFile, format ) {
  baseURL = "http://opendata.epa.gov.tw/webapi/api/rest/datastore/"
  baseURL = paste0( baseURL, resourceID, "/?format=" )
  baseURL = paste0( baseURL, format, "&token=" )
  baseURL = paste0( baseURL, token )
  
  # use download.file method -> libcurl
  download.file( baseURL, destfile = destFile, method = "libcurl" )
  
  return( baseURL )
  
}

## Load EPA AirQC measure site information when this script is load-----
epa.AirQCSite = NULL
epa.AirQCSiteFile = paste0( downloadDir, "epa/airqc_site.csv" )
epa.AirQCSite = read.csv( epa.AirQCSiteFile, header = T, sep = ",", encoding = "UTF-8" )
siteColumnName = c( "SiteName", "SiteEngName", "AreaName", "County", 
                    "Township", "SiteAddress", "TWD97Lon", "TWD97Lat", "SiteType" )
colnames( epa.AirQCSite ) = siteColumnName
# delete the EPA AirQC site information file path
remove( epa.AirQCSiteFile )

## use  a dataframe to load all EPA AirQC Measure data -----
# setup the environment path for EPA source data
epa.AirQCMeasureFile = paste0( dataDir, "epa/allAirQCData.Rdata" )
epa.AirQCSrcDataPath = paste0( downloadDir, "epa/" )

if( file.exists( epa.AirQCMeasureFile ) ) {
  message( "> INFO: load the data set last process" )
  load( epa.AirQCMeasureFile )
  
} else {
  message( "> INFO: hasn't load any TPE AirQC Measure")
  # initiate the data frame to record download source data state
  epa.AirQCMeasure = NULL
  
} # END of 

which( sourceData$type == "epa" )
