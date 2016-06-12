##
# File name: FetchTaiwanPowerCompanyData.R
# Author: Wu, Zhen-Hao
# Date: 2016.05.16 18:05 UTC+8
# Last Modified:
#   2016.05.16 18:05 UTC+8
# Note:
#

getWebData <- function(url, downloadFile) {
  # use download.file method -> libcurl
  download.file(url, destfile = downloadFile, method = "libcurl")
  # ensure disallocation of file release memory
  # unlink(downloadFile)
  
}

downloadInstantPowerGenerating <- function( destFile, forcedownload = FALSE ) {
  url = "http://data.taipower.com.tw/opendata01/apply/file/d006001/001.txt"
  message("Function: Download Air Box Measure Data")
  # get current datetime w/ hour
  currentHour <- format( Sys.time(), "%Y%m%d_%H%M" )
  destFile = paste0( downloadDir, "tpc/", currentHour, "_", destFile )
  if( ( !file.exists( destFile ) ) | ( forcedownload == TRUE ) ) {
    message( paste0( "  downloading ", destFile ) )
    getWebData( url, destFile )
    
  }
  else {
    message( paste0( "  file ", destFile, " is already exists" ) )
    
  }
  
}

tpc.DataDir = paste0( dataDir, )
tpc.AllData.File = 
load()

specifyDevRecords.subset <- as.data.frame( specifyDevRecords[ grep( "2016-05-28", time ), ])
