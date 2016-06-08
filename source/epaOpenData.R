##
# File name: FetchEPAOpanData.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.18 10:44 UTC+8
# Last Modified:
#   2016.05.18 10:44 UTC+8
# Note: 
#   this file have some function to get epa open data
#   from internet by it's official API method
#   entry web site: http://opendata.epa.gov.tw/
#

downloadEPAData <- function( resourceID, token, destFile, format ) {
  baseURL = "http://opendata.epa.gov.tw/webapi/api/rest/datastore/"
  baseURL = paste0( baseURL, resourceID, "/?format=" )
  baseURL = paste0( baseURL, format, "&token=" )
  baseURL = paste0( baseURL, token )
  
  # use download.file method -> libcurl
  download.file( baseURL, destfile = destFile, method = "libcurl" )
  
  return( baseURL )
  
}
