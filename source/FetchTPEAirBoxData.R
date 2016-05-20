##
# File name: FetchTaipeiAirBoxData.R
# Author: Wu, Zhen-Hao
# Date: 2016.05.10 19:20 UTC+8
# Last Modified:
#   2016.05.16 18:05 UTC+8
# Note:
#   This file has define some function to download AirBox Data in Taipei City
#   from Open Data Taipei
#

require(rjson)
require(RCurl)

# set the project and data directory path
scriptDir = "C:/Users/DewerZHT/Desktop/Taiwan AirQC/source/"
downloadDir = "C:/Users/DewerZHT/Desktop/Taiwan AirQC/downloads/"
deviceDataURL = "https://tpairbox.blob.core.windows.net/blobfs/AirBoxDevice.gz"
measureDataURL = "https://tpairbox.blob.core.windows.net/blobfs/AirBoxData.gz"
deviceDataFile = paste0(downloadDir, "AirBoxDevice.json")

getWebData <- function(url, downloadFile) {
  # use download.file method -> libcurl
  download.file(url, destfile = downloadFile, method = "libcurl")
  # ensure disallocation of file release memory
  # unlink(downloadFile)
  
}

downloadAirBoxDevice <- function( destFile, forcedownload = FALSE ) {
  message("Function: Download Air Box Device Data")
  if( ( !file.exists( destFile ) ) | ( forcedownload == TRUE ) ) {
    message( paste0( "  downloading ", destFile ) )
    downloadFile = paste0( downloadDir, "AirBoxDevice.gz" )
    getWebData( deviceDataURL, downloadFile )
    gzData <- gzfile( downloadFile, open = "rb" )
    jsonData <- readLines( gzData )
    writeLines( jsonData, destFile )
    unlink(downloadFile)
    
  }
  else {
    message( paste0( "  file ", destFile, " is already exists" ) )
    
  }
  
}

getAirBoxDevice <- function( sourceFile, forcedownload = FALSE ) {
  if( ( !file.exists( sourceFile ) ) | ( forcedownload == TRUE ) ) {
    downloadFile = paste0( downloadDir, "AirBoxDevice.gz" )
    getWebData( deviceDataURL, downloadFile )
    gzData <- gzfile( downloadFile, open = "rb" )
    jsonData <- readLines( gzData )
    writeLines( jsonData, sourceFile )
    close(sourceFile)
    
  }
  else {
    
    
  }
  AirBoxDeviceData <- fromJSON( file = sourceFile )
  AirBoxDeviceData <- do.call( "rbind", lapply( AirBoxDeviceData$entries, as.data.frame ) )
  return( AirBoxDeviceData )
  
}

downloadAirBoxMeasure <- function( destFile, forcedownload = FALSE ) {
  message("Function: Download Air Box Measure Data")
  # get current datetime w/ hour
  currentHour <- format( Sys.time(), "%Y%m%d_%H" )
  measureDataFile = paste0( downloadDir, currentHour, "_", destFile )
  if( ( !file.exists( measureDataFile ) ) | ( forcedownload == TRUE ) ) {
    message( paste0( "  downloading ", measureDataFile ) )
    downloadFile = paste0( downloadDir, "AirBoxData.gz" )
    getWebData( measureDataURL, downloadFile )
    gzData <- gzfile( downloadFile, open = "rb" )
    jsonData <- readLines( gzData )
    writeLines( jsonData, measureDataFile )
    unlink(downloadFile)
    
  }
  else {
    message( paste0( "  file ", measureDataFile, " is already exists" ) )
    
  }
  
}

getAirBoxMeasure <- function( sourceFile ) {
  if( !file.exists( sourceFile ) ) {
    message( paste0( "ERROR: source file", sourceFile, "is not exists") )
    return(NULL)
    
  }
  else {
    AirBoxMeasureData <- fromJSON( file = sourceFile )
    AirBoxMeasureData <- do.call( "rbind", lapply( AirBoxMeasureData$entries, as.data.frame ) )
    return( AirBoxMeasureData )
    
  }
  
}
