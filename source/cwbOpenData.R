##
# File name: FetchCWBOpanData.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.13 20:58 UTC+8
# Last Modified:
#   2016.07.05 10:58 UTC+8
# Note: 
#   this file have some function to get cwb open data
#   from internet by it's official API method
#   entry web site: http://opendata.cwb.gov.tw/
#

# load the need libraries
library( XML )

## Function: loadDataSetList ----- 
# parameter:
#   csv file path: sourceCSV 
# return value:
#   data.frame with data: df
# description:
#   Load the specify csv file to get CWB Open Data Set List
#   The csv must contain data name, data id and cwb api key
loadDataSetList <- function( sourceCSV ) {
  print( "INFO: Loading the CWB Data Set List (CSV file)" )
  df <- read.csv( sourceCSV,
                  header = TRUE,
                  encoding = "UTF-8" )
  
  # return a dataframe with cwb open data set information
  return( df )
  
}

## Function: getOpenData -----
# parameters: 
#   dataID: String of CWB data set ID
#   apiKey: String of API key which can access CWB open data
#   downloadFile: 
# return value:
#   n/a
# description:
#   Get CWB Open data Set with CWB Web API (using curl)
#   Download data set file into spcefied path
getOpenData <- function(dataID, apiKey, downloadFile) {
  print( "INFO: Download CWB Open data: ", downloadFile )
  url = paste0( "http://opendata.cwb.gov.tw/opendataapi?dataid=", 
                dataID, 
                "&authorizationkey=", 
                apiKey )
  
  # use download.file method -> libcurl
  download.file(url, destfile = downloadFile, method = "libcurl")
  
  # ensure disallocation of file release memory
  # unlink(downloadFile)
  
}

## Function: parseRainStation -----
# parameters:
#   xmlFile: CWB rain measure data set file
# return value:
#   df: the data frame with rain measure data from xml file
# description: 
#   This functino is design to parse rain measure station information
#   from CWB open data set file, which is a xml file.
parseRainStation <- function( xmlFile ) {
  # print sys informaiton for state checking
  print( "INFO: Parse rain station infomation from rain measure file." )
  # get xml parse tree from xml source file
  cwbXML <- xmlTreeParse( xmlFile,
                          useInternalNodes = TRUE,
                          encoding = "UTF-8" )
  # show xml parse tree
  cwbXML
  
  xmlRoot <- xmlRoot(cwbXML)
  xmlRoot[9]
  
  t <- xmlToList(cwbXML)
  length(t)
  
  # get latitude from specified column in xml source file
  lats <- list()
  t[9][["location"]][["lat"]]
  t[length(t)][["location"]][["lat"]]
  
  # get lontitude from specified column in xml source file
  lons <- list()
  t[9][["location"]][["lon"]]
  t[length(t)][["location"]][["lon"]]
  
  # get station name from specified column in xml source file
  stationName <- list()
  t[9][["location"]][["locationName"]]
  t[length(t)][["location"]][["locationName"]]
  
  # get station ID from specified column in xml source file
  stationID <- list()
  t[9][["location"]][["stationId"]]
  t[length(t)][["location"]][["stationId"]]
  
  # get station elevation from specified column in xml source file
  elevation <- list()
  t[9][["location"]][[6]][["elementValue"]][["value"]]
  t[length(t)][["location"]][[6]][["elementValue"]][["value"]]
  
  # extract all specified data into their list
  for(location in 9:length(t) ) {
    lats[location] <- t[location][["location"]][["lat"]]
    lons[location] <- t[location][["location"]][["lon"]]
    stationName[location] <- t[location][["location"]][["locationName"]]
    stationID[location] <- t[location][["location"]][["stationId"]]
    elevation[location] <- t[location][["location"]][[6]][["elementValue"]]
  }
  
  # lats <- removeNullRecords(lats)
  length(lats)
  lats <- unlist(lats)
  lats <- as.numeric(lats)
  lats
  
  # lons <- removeNullRecords(lons)
  length(lons)
  lons <- unlist(lons)
  lons <- as.numeric(lons)
  lons
  
  # stationName <- removeNullRecords(rainStation.locationNames)
  length(stationName)
  stationName <- unlist(stationName)
  stationName
  
  # stationID <- removeNullRecords(stationID)
  length(stationID)
  stationID <- unlist(stationID)
  stationID
  
  # elevation <- removeNullRecords(rainStation.rains)
  length(elevation)
  elevation <- unlist(elevation)
  elevation <- as.numeric(elevation)
  elevation
  
  rainStaion <- data.frame(stationID, stationName, lats, lons, elevation)
  # return rain station data frame
  return( rainStaion )
  
}

## Function: -----
#
parseRainMeasure <- function( xmlFile, dataframe ) {
  
}

## Function: weathreXML2CSV -----
# parameters:
#   xmlFile: the source data from CWB open data set
#   csvFile: the output file path for this function
# return value:
#   dataFrame: the data frame contain the weather measure data
# description:
weatherXML2CSV <- function( xmlFile, csvFile ) {
  dataFrame = as.data.frame()
  
  return( dataFrame )
}

## Function: getWeatherStation -----
parseWeatherMeasure <- function( xmlFile, dataframe ) {
  
}


