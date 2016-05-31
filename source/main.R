##
# File name: main.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.11 12:09 UTC+8
# Last Modified:
#   2016.05.18 11:21 UTC+8
# Note: 
#   
#

# install the libraries that the program needs
# install.packages( "ggmap" )
# install.packages( "rjson" )
# install.packages( "XML" )
# install.packages( "httr" )

# load the libraries that the program needs
library( ggmap ) # google map library
library( rjson )
library( XML )
library( httr )
library( stringr )

# set project directory path
srcDir = "C:/Users/DewerZHT/Documents/git-repositories/Taiwan AirQC/source/"
dataDir = "C:/Users/DewerZHT/Documents/git-repositories/Taiwan AirQC/data/"
plotDir = "C:/Users/DewerZHT/Documents/git-repositories/Taiwan AirQC/plots/"
downloadDir = "C:/Users/DewerZHT/Documents/git-repositories/Taiwan AirQC/downloads/"

# set working directory to source
setwd( srcDir )
# load function script
source( "FetchTPEAirBoxData.R" )
source( "FetchCWBOpenData.R" )
source( "FetchTPCData.R" )

load()

## -----
# initiate the data frame to record download source data state
sourceData <- data.frame( file_id = integer(), file_name = character(), proceed = logical(), type = character() )

## -----
# insert taipei airbox download source info into dataframe

# get the file list from taipei airbox download source dir
fileList <- NULL
fileList <- list.files( paste0( downloadDir, "taipei airbox" ) )

# clear all column data for next use
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

#
for( counter in 1:( length( fileList ) ) ) {
  # check the file read now
  message( paste0( "> Debug: check file ", fileList[counter] ) )
  # if file contains string "AirBoxMeasure.json"
  if( str_count( fileList[counter], "AirBoxMeasure.json" ) ) {
    message( "Debug: the file is specify target" )
    if( length( which( sourceData$file_name == fileList[counter] ) ) == 0 ) {
      message( "> Debug: add file information into DF" )
      file_id[counter] = dim( sourceData )[1] + counter
      file_name[counter] = fileList[counter]
      proceed[counter] = FALSE
      type[counter] = 'taipei airqc'
      
    } # end of if
    else {
      message( "> Debug: this file had already in DF" )
      
    } # end of else
    
  } # end of if
  
} # end of for

newData = data.frame( file_id, file_name, proceed, type )
sourceData <- rbind( sourceData, newData )

## -----
# insert tpc download source info into dataframe

# get the file list from tpc download source dir
fileList <- NULL
fileList <- list.files( paste0( downloadDir, "tpc" ) )

# clear all column data for next use
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

# 
for( counter in 1:( length( fileList ) ) ) {
  # check the file read now
  message( paste0( "> Debug: check file", fileList[counter] ) )
  if( str_count( fileList[counter], "tpcInstantPower.json" ) ) {
    message( "> Debug message for get file" )
    file_id[counter] = dim( sourceData )[1] + counter
    file_name[counter] = fileList[counter]
    proceed[counter] = FALSE
    type[counter] = 'tpc'
    
  }
  
}

newData = data.frame( file_id, file_name, proceed, type )
sourceData <- rbind( sourceData, newData )

startTime <- as.POSIXlt( "2016-05-11 15:00:00" )
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

for( counter in 1:( sum( str_count( fileList, "AirBoxMeasure.json" ) ) - 1 ) ) {
  print( paste0( "  >>Check the file: ", format( startTime, "%Y%m%d_%H" ), "_AirBoxMeasure.json" ) )
  file_id[ counter ] <- counter
  file_name[ counter ] <- paste0( format( startTime, "%Y%m%d_%H" ), "_AirBoxMeasure.json" )
  proceed[ counter ] <- FALSE
  type[ counter ] <- "taipei airqc"
  startTime = startTime + 3600
  
}

sourceData <- data.frame( file_id, file_name, proceed, type )

fileList <- NULL
fileList <- list.files( paste0( downloadDir, "tpc" ) )

startTime <- as.POSIXlt( "2016-05-17 16:07:00" )
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

for( counter in 1:( sum( str_count( fileList, "tpcInstantPower.json" ) ) - 1 ) ) {
  print( paste0( "  >>Check the file: ", format( startTime, "%Y%m%d_%H%M" ), "_tpcInstantPower.json" ) )
  file_id[ counter ] <- counter + dim(sourceData)[1]
  file_name[ counter ] <- paste0( format( startTime, "%Y%m%d_%H%M" ), "_tpcInstantPower.json" )
  proceed[ counter ] <- FALSE
  type[ counter ] <- "tpc"
  startTime = startTime + 600
  
}

tpcSrcData <- data.frame( file_id, file_name, proceed, type )

sourceData <- rbind( sourceData, tpcSrcData )

fileList <- NULL
fileList <- list.files( paste0( downloadDir, "tpc" ) )

startTime <- as.POSIXlt( "2016-05-17 16:07:00" )
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

save()

## -----
# unfinished part
checkDownloadSouce <- function( filename, type ) {
  if( length( which( sourceData$file_name == filename ) ) == 0 ) {
    message( "File hasn't been add in data frame.")
    dims <- dim(sourceData)
    fid = dims[1] + 1
    proceed = FALSE
    single_row = c( fid, filename, proceed, type )
    sourceData <- rbind( sourceData, single_row)
    
  }
  else if( sourceData[ which( sourceData$file_name == filename ), 3] == FALSE ) {
    message( "File hasn't been proceed." )
    message( paste0( "please procee file: ", sourceData[ which( sourceData$file_name == filename ), 2]) )
    
  }
  else {
    message( "File had been proceed." )
    
  }
  
}
##
# load Taipei AirBox Data
# data source: [project directory]/downloads/taipei airbox/AirBoxDevice.json
tpeAirQCDevice <- getAirBoxDevice( paste0( downloadDir, "taipei airbox/AirBoxDevice.json" ) )
# save data frame to .Rdata file
save( tpeAirQCDevice, file = paste0( dataDir, "taipei airbox/", "airboxDevice.Rdata" ) )

##
# load the airbox measure data file

# list the files in Taiwan AirQC/downloads/taipei airbox
fileList <- list.files( paste0( downloadDir, "taipei airbox" ) )
fileList
# count how many files named with AirBoxMeasure
sum( str_count( fileList, "AirBoxMeasure" ) )

# set private time variable to avoid modified system time
mytime <- as.POSIXlt( "2016-05-11 15:00:00" )
mytimestr <- format( mytime, "%Y%m%d_%H%M" )
mytimestr
# adjust private time variable past 10 mins
mynewtime <- mytime + 600
mynewtimestr <- format( mynewtime, "%Y%m%d_%H%M" )
mynewtimestr

# set airbox file started timestamp
startTime <- as.POSIXlt( "2016-05-11 15:00:00" )

tpeAirQCMeasure <- NULL
tpeAirQCFileState <- NULL
#
for( counter in 1:( sum( str_count( fileList, "AirBoxMeasure" ) ) - 1 ) ) {
  tmp <- getAirBoxMeasure( paste0( downloadDir, "taipei airbox/", format( startTime, "%Y%m%d_%H" ), "_AirBoxMeasure.json" ) )
  tpeAirQCMeasure <- rbind( tpeAirQCMeasure, tmp )
  print( format( startTime, "%Y%m%d_%H" ) )
  startTime <- startTime + 3600
  
}

# load data by date into single spceify dataframe 
# list the files in Taiwan AirQC/downloads/taipei airbox
fileList <- list.files( paste0( downloadDir, "taipei airbox" ) )
fileList
# count how many files named with AirBoxMeasure
sum( str_count( fileList, "20160518_" ) )

# set airbox file started timestamp
startTime <- as.POSIXlt( "2016-05-18 00:00:00" )

tpeAirQCMeasure <- NULL
tpeAirQCFileState <- NULL
#
for( counter in 1:24 ) {
  tmp <- getAirBoxMeasure( paste0( downloadDir, "taipei airbox/", format( startTime, "%Y%m%d_%H" ), "_AirBoxMeasure.json" ) )
  tpeAirQCMeasure <- rbind( tpeAirQCMeasure, tmp )
  print( format( startTime, "%Y%m%d_%H" ) )
  startTime <- startTime + 3600
  
}

save( tpeAirQCMeasure, file = paste0( dataDir, "taipei airbox/", format( startTime, "%Y%m%d" ), " measure.Rdata") )

# show records belongs to device_id 28C2DDDD4379
specifyRecordsTPE <- which( tpeAirQCMeasure$device_id == "28C2DDDD4379" )
specifyRecordsTEP

# count the records
length(specifyRecords)

time <- tpeAirQCMeasure[ specifyRecordsTPE, "time"]
pm2.5 <- tpeAirQCMeasure[ specifyRecordsTPE, "s_d0"]
specifyDevRecordsTPE <- data.frame( time, pm2.5 )

specifyDevRecords.subset <- specifyDevRecords[ grep( "2016-05-12", time ), ]

require(ggplot2)
theme_set(theme_bw()) # Change the theme to my preference
ggplot( aes( x = time, y = pm2.5 ), data = specifyDevRecords.subset ) + geom_point()

##
# load the tpc instant generating power data
downloadInstantPowerGenerating( "tpcInstatntPower.json" )


##
#
source( "FetchEPAOpenData.R" )

epaToken = "Z9bSQhgO+EatVIdL7umQpw"
testID = "315070000H-000001"
testFormat = "csv"
currentTime <- format( Sys.time(), "%Y%m%d_%H%M" )
epaDownloadFile = paste0( downloadDir, "cwb/", currentTime, "_rain.csv" )

downloadEPAData( testID, epaToken, epaDownloadFile, testFormat)

##
# AirQC
testID = "355000000I-000001"
testFormat = "csv"
currentTime <- format( Sys.time(), "%Y%m%d_%H%M" )
epaDownloadFile = paste0( downloadDir, "epa/", currentTime, "_airqc.csv" )

downloadEPAData( testID, epaToken, epaDownloadFile, testFormat)

airQC <- read.csv( epaDownloadFile , encoding = "UTF-8" )
airQC$X.U.FEFF.SiteName

rainCSVFile <- paste0( downloadDir, "cwb/20160518_1517_rain.csv" )
rain <- read.csv( rainCSVFile, encoding = "UTF-8" )

# load rain data by date into single spceify dataframe 
# list the files in Taiwan AirQC/downloads/taipei airbox
fileList <- list.files( paste0( downloadDir, "cwb" ) )
fileList
# count how many files named with AirBoxMeasure
sum( str_count( fileList, "rain" ) )

# set airbox file started timestamp
startTime <- as.POSIXlt( "2016-05-18 15:17:00" )

cwbRainMeasure <- NULL
tpeAirQCFileState <- NULL
#
for( counter in 1:144) {
  rainCSVFile <- paste0( downloadDir, "cwb/", format( startTime, "%Y%m%d_%H%M"), "_rain.csv" )
  tmp <- read.csv( rainCSVFile, encoding = "UTF-8" )
  cwbRainMeasure <- rbind( cwbRainMeasure, tmp )
  print( format( startTime, "%Y%m%d_%H%M" ) )
  startTime <- startTime + 600
  
}

which(tpcMeasure$Name == "協和#1" )

# show records belongs to device_id 28C2DDDD47D5
specifyRecords <- which(tpcMeasure$Name == "協和#2" )
specifyRecords

# count the records
length(specifyRecords)

timestamp <- tpcMeasure[ specifyRecords, "Timestamp" ]
timestamp
gen <- tpcMeasure[ specifyRecords, "Gen" ]
gen
specifyDevRecords <- data.frame( timestamp, gen )
specifyDevRecords.subset <- specifyDevRecords[ grep( "2016-05-18", timestamp ), ]

require(ggplot2)
theme_set(theme_bw()) # Change the theme to my preference
ggplot( aes( x = timestamp, y = gen ), data = specifyDevRecords.subset ) + geom_point()

theme_set(theme_bw()) # Change the theme to my preference
ggplot( aes( x = time, y = pm2.5 ), data = specifyDevRecordsTPE ) + geom_point()
