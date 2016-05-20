##
# File name: FetchCWBOpanData.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.13 20:58 UTC+8
# Last Modified:
#   2016.05.13 20:58 UTC+8
# Note: 
#   this file have some function to get cwb open data
#   from internet by it's official API method
#   entry web site: http://opendata.cwb.gov.tw/
#

##
# Function: loadDataList
# parameter:
#   source: the path of 
# return:
#   data.frame
# description:
#   Load the specify csv file to get CWB Open Data List
#   The csv must contain data name, data id and cwb api key
loadDataSetList <- function( source ) {
  message( "Loading the CWB Data Set List" )
  df <- read.csv( source,
                  header = TRUE,
                  encoding = "UTF-8" )
  return(df)
  
}

# get Taiwan CWB Open data with CWB API
getCWBOpenData <- function(dataid, apikey, downloadFile) {
  message( "Download CWB Open data: ", downloadFile )
  url <- paste0("http://opendata.cwb.gov.tw/opendataapi?dataid=", dataid, "&authorizationkey=", apikey)
  # use download.file method -> libcurl
  
  download.file(url, destfile = downloadFile, method = "libcurl")
  
  # ensure disallocation of file release memory
  # unlink(downloadFile)
  
}

parseRainStation <- function( xmlFile, dataframe ) {
  cwbXML <- xmlTreeParse(xmlFile, useInternalNodes = TRUE, encoding = "UTF-8")
  # cwbXML <- xmlParse(file = xmlFile, encoding = "big5")
  cwbXML
  
  xmlRoot <- xmlRoot(cwbXML)
  xmlRoot[9]
  
  t <- xmlToList(cwbXML)
  length(t)
  
  rainStation.lats <- list()
  t[9][["location"]][["lat"]]
  t[length(t)][["location"]][["lat"]]
  
  rainStation.lons <- list()
  t[9][["location"]][["lon"]]
  t[length(t)][["location"]][["lon"]]
  
  rainStation.StationNames <- list()
  t[9][["location"]][["locationName"]]
  t[length(t)][["location"]][["locationName"]]
  
  rainStation.StationID <- list()
  t[9][["location"]][["stationId"]]
  t[length(t)][["location"]][["stationId"]]
  
  rainStation.elevation <- list()
  t[9][["location"]][[6]][["elementValue"]][["value"]]
  t[length(t)][["location"]][[6]][["elementValue"]][["value"]]
  
  for(location in 9:length(t) ) {
    rainStation.lats[location] <- t[location][["location"]][["lat"]]
    rainStation.lons[location] <- t[location][["location"]][["lon"]]
    rainStation.StationNames[location] <- t[location][["location"]][["locationName"]]
    rainStation.StationID[location] <- t[location][["location"]][["stationId"]]
    rainStation.elevation[location] <- t[location][["location"]][[6]][["elementValue"]]
  }
  
  removeNullRecords <- function(dataList){
    
    dataList <- dataList[ !sapply( dataList, is.null ) ]
    if( is.list(dataList) ){
      dataList <- lapply( dataList, removeNullRecords)
    }
    return(dataList)
  }
  
  # rainStation.lats <- removeNullRecords(rainStation.lats)
  length(rainStation.lats)
  rainStation.lats <- unlist(rainStation.lats)
  rainStation.lats <- as.numeric(rainStation.lats)
  rainStation.lats
  
  # rainStation.lons <- removeNullRecords(rainStation.lons)
  length(rainStation.lons)
  rainStation.lons <- unlist(rainStation.lons)
  rainStation.lons <- as.numeric(rainStation.lons)
  rainStation.lons
  
  # rainStation.StationNames <- removeNullRecords(rainStation.locationNames)
  length(rainStation.StationNames)
  rainStation.StationNames <- unlist(rainStation.StationNames)
  rainStation.StationNames
  
  # rainStation.StationID <- removeNullRecords(rainStation.StationID)
  length(rainStation.StationID)
  rainStation.StationID <- unlist(rainStation.StationID)
  rainStation.StationID
  
  # rainStation.elevation <- removeNullRecords(rainStation.rains)
  length(rainStation.elevation)
  rainStation.elevation <- unlist(rainStation.elevation)
  rainStation.elevation <- as.numeric(rainStation.elevation)
  rainStation.elevation
  
  rainStaion <- data.frame(rainStation.StationID, rainStation.StationNames, rainStation.lats, rainStation.lons, rainStation.elevation)
  
}

parseRainMeasure <- function( xmlFile, dataframe ) {
  
}

parseWeatherStation <- function( xmlFile, dataframe ) {
  
}

parseWeatherMeasure <- function( xmlFile, dataframe ) {
  
}


