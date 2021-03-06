##
# File name: main.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.11 12:09 UTC+8
# Last Modified:
#   2016.07.09 16:23 UTC+8
# Note: 
#   
#

# install the libraries that the program needs
# install.packages( "ggmap" )
# install.packages( "rjson" )
# install.packages( "XML" )
# install.packages( "httr" )
# install.packages( "stringdist" )

# load the libraries that the program needs
library( ggmap ) # google map library
library( rjson )
library( XML )
library( httr )
library( stringr )
library( stringdist )

## check system local setting -----
Sys.getlocale(category = "LC_ALL" )


## set project directory path -----
srcDir = paste0( getwd(), '/source/' )
dataDir = paste0( getwd(), '/data/' )
plotDir = paste0( getwd(), '/plots/' )
downloadDir = paste0( getwd(), '/downloads/' )

## check the download source data information -----
# 
srcDataFile = paste0( downloadDir, "srcDataInfo.Rdata" )

if( file.exists( srcDataFile ) ) {
  message( "> INFO: load the data set last process" )
  load( srcDataFile )
  
} else {
  message( "> INFO: hasn't process download source data check")
  # initiate the data frame to record download source data state
  sourceData <- data.frame( file_id = integer(), file_name = character(), proceed = logical(), type = character() )
  
}


# set working directory to source
setwd( srcDir )
# load function script
source( "tpeAirQC.R" )
source( "cwbOpenData.R" )
source( "tpcOpenData.R" )

## insert taipei airbox download source info into dataframe -----
# get the file list from taipei airbox download source dir
fileList <- NULL
fileList <- list.files( paste0( downloadDir, "taipei airbox" ) )

# clear all column data for next use
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

# do all file name in fileList
for( counter in 1:( length( fileList ) ) ) {
  # check the file read now
  message( paste0( "> INFO: check file ", fileList[counter] ) )
  # if file contains string "AirBoxMeasure.json"
  if( str_count( fileList[counter], "AirBoxMeasure.json" ) ) {
    message( "> INFO: the file is specify target" )
    if( length( which( sourceData$file_name == fileList[counter] ) ) == 0 ) {
      message( "> INFO: add file information into DF" )
      file_id[counter] = dim( sourceData )[1] + counter
      file_name[counter] = fileList[counter]
      proceed[counter] = FALSE
      type[counter] = 'taipei airqc'
      
    } # end of if
    else {
      message( "> INFO: this file had already in DF" )
      
    } # end of else
    
  } # end of if
  else {
    message( "> INFO: the file isn't specify target" )
    
  }
  
} # end of for

newData = data.frame( file_id, file_name, proceed, type )
sourceData <- rbind( sourceData, newData )

## insert tpc download source info into dataframe -----
# get the file list from tpc download source dir
fileList <- NULL
fileList <- list.files( paste0( downloadDir, "tpc" ) )

# clear all column data for next use
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

# do all file name in fileList
for( counter in 1:( length( fileList ) ) ) {
  # check the file read now
  message( paste0( "> INFO: check file ", fileList[counter] ) )
  # if file contains string "tpcInstantPower.json"
  if( str_count( fileList[counter], "tpcInstantPower.json" ) ) {
    message( "> INFO: the file is specify target" )
    if( length( which( sourceData$file_name == fileList[counter] ) ) == 0 ) {
      message( "> INFO: add file information into DF" )
      file_id[counter] = dim( sourceData )[1] + counter
      file_name[counter] = fileList[counter]
      proceed[counter] = FALSE
      type[counter] = 'tpc'
      
    } # end of if
    else {
      message( "> INFO: this file had already in DF" )
      
    } # end of else
    
  } # end of if
  else {
    message( "> INFO: the file isn't specify target" )
    
  }
  
} # end of for

newData = data.frame( file_id, file_name, proceed, type )
sourceData <- rbind( sourceData, newData )

## insert epa airqc download source info into dataframe -----
# get the file list from epa airqc download source dir
fileList <- NULL
fileList <- list.files( paste0( downloadDir, "epa" ) )

# clear all column data for next use
file_id = NULL
file_name = NULL
proceed = NULL
type = NULL

# do all file name in fileList
for( counter in 1:( length( fileList ) ) ) {
  # check the file read now
  message( paste0( "> INFO: check file ", fileList[counter] ) )
  # if file contains string "airqc.csv"
  if( str_count( fileList[counter], "airqc.csv" ) ) {
    message( "> INFO: the file is specify target" )
    if( length( which( sourceData$file_name == fileList[counter] ) ) == 0 ) {
      message( "> INFO: add file information into DF" )
      file_id[counter] = dim( sourceData )[1] + counter
      file_name[counter] = fileList[counter]
      proceed[counter] = FALSE
      type[counter] = 'epa'
      
    } # end of if
    else {
      message( "> INFO: this file had already in DF" )
      
    } # end of else
    
  } # end of if
  else {
    message( "> INFO: the file isn't specify target" )
    
  }
  
} # end of for

newData = data.frame( file_id, file_name, proceed, type )
sourceData <- rbind( sourceData, newData )
sourceData = na.omit( sourceData )

save( sourceData, file = paste0( downloadDir, "srcDataInfo.Rdata" ) )

## process tpc data (unfinished) -----
tpcInstantPower <- data.frame( id = integer(),
                               time = character(),
                               name = character(),
                               type = integer(),
                               longitude = double(),
                               latitude = double(),
                               generating_capacity = double() )

## process epa airqc data (unfinished) -----
# 
epaAirQCMeasure <- data.frame( site_id = integer(),
                               site_name = character(),
                               county_id = integer(),
                               psi = integer(),
                               wind_speed = double(),
                               wind_direction = double(),
                               pm2.5 = integer(),
                               pm10 = integer(),
                               so2 = double(),
                               co = double(),
                               time = character() )

epaFile = paste0( downloadDir, 'epa/', sourceData[which(sourceData$type == 'epa')[1], 'file_name'] )
epaFile
testDF = read.csv(file = epaFile, encoding = 'UTF-8', header = TRUE )
as.character( testDF$X.U.FEFF.SiteName )
columnNames = c( 'SiteName', 'County', 'PSI', 'MajorPollutant',
                 'Status', 'SO2', 'CO', 'O3', 'PM10', 'PM2.5',
                 'NO2', 'WindSpeed', 'WindDirec', 'FPMI',
                 'NOx', 'NO', 'PublishTime' )
colnames( testDF ) = columnNames

## process tpe airbox data () -----
# Load TPE airbox device data
tpeDownloadDir = paste0( downloadDir, "taipei airbox/")
tpeDeviceFile = paste0( tpeDownloadDir, "AirBoxDevice.json")
tpeAirQCDevice = getAirBoxDevice( tpeDeviceFile )

# set a path to store origin data
tpeOriDataFile = paste0( dataDir, "taipei airbox/origin/allData.Rdata" )

if( file.exists( tpeOriDataFile ) ) {
  message( "> INFO: load the data set last process" )
  load( tpeOriDataFile )
  
} else {
  message( "> INFO: hasn't load any TPE AirQC Measure")
  # initiate the data frame to record download source data state
  tpeAirQCMeasure = NULL
  
}

# 
tpeAirQCFiles = sourceData[ which( sourceData$type == 'taipei airqc' ), 2 ]
tpeAirQCFiles[1:20]
length( tpeAirQCFiles )

# load the specified data file into 
for( counter in 1:length( tpeAirQCFiles ) ) {
  if( sourceData[ which( sourceData$file_name == tpeAirQCFiles[counter] ), 3 ] ) {
    message( "> INFO: File had been processed")
    
  }
  else {
    message( "> INFO: Load file data into dataframe" )
    tpeAirQCMeasure = rbind( tpeAirQCMeasure, getAirBoxMeasure( paste0( tpeDownloadDir, tpeAirQCFiles[counter] ) ) )
    sourceData[ which( sourceData$file_name == tpeAirQCFiles[counter] ), 3 ] = TRUE
    
  }
  
}

save( tpeAirQCMeasure, file = paste0( dataDir, "taipei airbox/origin/allData.Rdata" ) )
save( sourceData, file = paste0( downloadDir, "srcDataInfo.Rdata" ) )

## sperate single device data into single data frame -----

# create a new empty list for specified device data
specDev.time = list()
specDev.device_id = list()
specDev.s_0 = list()
specDev.s_1 = list()
specDev.s_2 = list()
specDev.s_d0 = list()
specDev.s_t0 = list()
specDev.s_h0 = list()

# design function get origin data into a tmp list
tpeGetEachDevMeas = function( singleMeas ) {
  specDev.time <<- c( specDev.time, as.character( tpeAirQCMeasure[singleMeas, 'time'] ) )
  specDev.device_id <<- c( specDev.device_id, as.character( tpeAirQCMeasure[singleMeas, 'device_id'] ))
  specDev.s_0 <<- c( specDev.s_0, as.integer( tpeAirQCMeasure[singleMeas, 's_0'] ) )
  specDev.s_1 <<- c( specDev.s_1, as.integer( tpeAirQCMeasure[singleMeas, 's_1'] ) )
  specDev.s_2 <<- c( specDev.s_2, as.integer( tpeAirQCMeasure[singleMeas, 's_2'] ) )
  specDev.s_d0 <<- c( specDev.s_d0, as.integer( tpeAirQCMeasure[singleMeas, 's_d0'] ) )
  specDev.s_t0 <<- c( specDev.s_t0, as.double( tpeAirQCMeasure[singleMeas, 's_t0'] ) )
  specDev.s_h0 <<- c( specDev.s_h0, as.integer( tpeAirQCMeasure[singleMeas, 's_h0'] ) )
  
}

for( counter in 1:( dim(tpeAirQCDevice)[1] ) ) {
  # create a new empty list for specified device data
  specDev.time = list()
  specDev.device_id = list()
  specDev.s_0 = list()
  specDev.s_1 = list()
  specDev.s_2 = list()
  specDev.s_d0 = list()
  specDev.s_t0 = list()
  specDev.s_h0 = list()
  
  print( as.character( tpeAirQCDevice[counter, 'device_id'] ) )
  spec_devID = as.character( tpeAirQCDevice[counter, 'device_id'] )
  specMeasData = which( tpeAirQCMeasure$device_id == spec_devID )
  lapply( specMeasData, tpeGetEachDevMeas )
  
  # unlist all specified device data
  specDev.time = unlist( specDev.time )
  specDev.device_id = unlist( specDev.device_id )
  specDev.s_0 = unlist( specDev.s_0 )
  specDev.s_1 = unlist( specDev.s_1 )
  specDev.s_2 = unlist( specDev.s_2 )
  specDev.s_d0 = unlist( specDev.s_d0 )
  specDev.s_t0 = unlist( specDev.s_t0 )
  specDev.s_h0 = unlist( specDev.s_h0 )
  
  # create a new data frame to save specified device data
  specMeasData = data.frame( time = specDev.time,
                             device_id = specDev.device_id,
                             s_0 = specDev.s_0,
                             s_1 = specDev.s_1,
                             s_2 = specDev.s_2,
                             s_d0 = specDev.s_d0,
                             s_t0 = specDev.s_t0,
                             s_h0 = specDev.s_h0 )
  
  storeFile = paste0( dataDir, "taipei airbox/origin/" )
  storeFile = paste0( storeFile, specMeasData[1, 2], ".Rdata" )
  save( specMeasData, file = storeFile )
  
}

## reduce tpe measure data -----
tpeOriDataPath = paste0( dataDir, "taipei airbox/origin/" )
deviceFileList = list.files( tpeOriDataPath )
deviceFileList
load( paste0( tpeOriDataPath, deviceFileList[3] ) )

hour = NULL
hour.s_d0 = NULL
hour.s_t0 = NULL
hour.s_h0 = NULL
hour.s_d0.max = NULL
hour.s_t0.max = NULL
hour.s_h0.max = NULL
hour.s_d0.min = NULL
hour.s_t0.min = NULL
hour.s_h0.min = NULL
hour.s_d0.mean = NULL
hour.s_t0.mean = NULL
hour.s_h0.mean = NULL

cT = as.POSIXlt( "2016-05-12 01:00:00" )
mT = format( cT, "%Y-%m-%d %H:" )
mT

tpe.getHourlyMeasure = function( deviceMeasData ) {
    hour.s_h0 = NULL
    mT = format( cT, "%Y-%m-%d %H:" )
    hour <<- c( hour, format( cT, "%Y-%m-%d %H:%M:%S" ) )
    
    for( counter in 1:( dim( deviceMeasData )[1] ) ) {
      if( str_count( deviceMeasData[counter, 'time'], mT ) == 1 ) {
        hour.s_d0 <<- c( hour.s_d0, deviceMeasData[counter, 's_d0'] )
        hour.s_t0 <<- c( hour.s_t0, deviceMeasData[counter, 's_t0'] )
        hour.s_h0 <<- c( hour.s_h0, deviceMeasData[counter, 's_h0'] )
        
      }
      
    }
    hour.s_d0.max  <<- c( hour.s_d0.max, max( hour.s_d0 ) ) 
    hour.s_t0.max  <<- c( hour.s_t0.max, max( hour.s_t0 ) )
    hour.s_h0.max  <<- c( hour.s_h0.max, max( hour.s_h0 ) )
    hour.s_d0.min  <<- c( hour.s_d0.min, min( hour.s_d0 ) )
    hour.s_t0.min  <<- c( hour.s_t0.min, min( hour.s_t0 ) )
    hour.s_h0.min  <<- c( hour.s_h0.min, min( hour.s_h0 ) )
    hour.s_d0.mean <<- c( hour.s_d0.mean, mean( hour.s_d0 ) )
    hour.s_t0.mean <<- c( hour.s_t0.mean, mean( hour.s_t0 ) )
    hour.s_h0.mean <<- c( hour.s_h0.mean, mean( hour.s_h0 ) )
    
    cT = cT + 3600
    
  }
  
}

for( timeS in 1:(24 * 7) ) {
  hour.s_d0 = NULL
  hour.s_t0 = NULL

}

sig = specMeasData[113, ]
sig$time
str_count( sig$time , mT )

tpe.getHourlyMeasure( specMeasData )


## single measure data process -----
spec_devID = as.character( tpeAirQCDevice[10, 'device_id'] )
specMeasData = which( tpeAirQCMeasure$device_id == spec_devID )
tpeAirQCMeasure[specMeasData[1], ]
tpeAirQCMeasure[specMeasData[1], 's_d0']
lapply( specMeasData, tpeGetEachDevMeas )

# unlist all specified device data
specDev.time = unlist( specDev.time )
specDev.device_id = unlist( specDev.device_id )
specDev.s_0 = unlist( specDev.s_0 )
specDev.s_1 = unlist( specDev.s_1 )
specDev.s_2 = unlist( specDev.s_2 )
specDev.s_d0 = unlist( specDev.s_d0 )
specDev.s_t0 = unlist( specDev.s_t0 )
specDev.s_h0 = unlist( specDev.s_h0 )

# create a new data frame to save specified device data
specMeasData = data.frame( time = specDev.time,
                           device_id = specDev.device_id,
                           s_0 = specDev.s_0,
                           s_1 = specDev.s_1,
                           s_2 = specDev.s_2,
                           s_d0 = specDev.s_d0,
                           s_t0 = specDev.s_t0,
                           s_h0 = specDev.s_h0 )

storeFile = paste0( dataDir, "taipei airbox/origin/" )
storeFile = paste0( storeFile, specMeasData[1, 2], ".Rdata" )
save( specMeasData, file = storeFile )

## unfinished part -----
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

getwd()
source( paste0( srcDir, "cwbOpenData.R" ) )

xmlFile = paste0( downloadDir, "cwb/AutoWeatherMeasure/20160509_18 O-A0001-001.xml" )
cwbXML = xmlTreeParse( xmlFile, useInternalNodes = TRUE )
cwbXML = xmlRoot( cwbXML )
cwbXML = xmlToList( cwbXML )
cwbXML
lat = cwbXML[9][[ 1 ]][ "lat" ]
lat
lon = cwbXML[9][[ 1 ]][ "lon" ]
lon
locationName = cwbXML[9][[ 1 ]][ "locationName" ]
locationName
stationId = cwbXML[9][[ 1 ]][ "stationId" ]
stationId
obsTime = cwbXML[9][[ 1 ]][ "time" ][[ 1 ]][ "obsTime" ]
obsTime
ELEV = cwbXML[9][[ 1 ]][ 6 ][[ 1 ]][[ 2 ]]
ELEV
WDIR = cwbXML[9][[ 1 ]][ 7 ][[ 1 ]][[ 2 ]]
WDIR
WDSD = cwbXML[9][[ 1 ]][ 8 ][[ 1 ]][[ 2 ]]
WDSD
TEMP = cwbXML[9][[ 1 ]][ 9 ][[ 1 ]][[ 2 ]]
TEMP
HUMD = cwbXML[9][[ 1 ]][ 10 ][[ 1 ]][[ 2 ]]
HUMD
PRES = cwbXML[9][[ 1 ]][ 11 ][[ 1 ]][[ 2 ]]
PRES
SUN = cwbXML[9][[ 1 ]][ 12 ][[ 1 ]][[ 2 ]]
SUN
H_24R = cwbXML[9][[ 1 ]][ 13 ][[ 1 ]][[ 2 ]]
H_24R
WS15M = cwbXML[9][[ 1 ]][ 14 ][[ 1 ]][[ 2 ]]
WS15M
WD15M = cwbXML[9][[ 1 ]][ 15 ][[ 1 ]][[ 2 ]]
WD15M
WS15T = cwbXML[9][[ 1 ]][ 16 ][[ 1 ]][[ 2 ]]
WS15T
CITY = cwbXML[9][[ 1 ]][ 17 ][[ 1 ]][[ 2 ]]
CITY
CITY_SN = cwbXML[9][[ 1 ]][ 18 ][[ 1 ]][[ 2 ]]
CITY_SN
TOWN = cwbXML[9][[ 1 ]][ 19 ][[ 1 ]][[ 2 ]]
TOWN
TOWN_SN = cwbXML[9][[ 1 ]][ 20 ][[ 1 ]][[ 2 ]]
TOWN_SN

lat = list()
lon = list()
locationName = list()
stationId = list()
obsTime = list()
ELEV = list()
WDIR = list()
WDSD = list()
TEMP = list()
HUMD = list()
PRES = list()
SUN = list()
H_24R = list()
WS15M = list()
WD15M = list()
WS15T = list()
CITY = list()
CITY_SN = list()
TOWN = list()
TOWN_SN = list()

# for loop for testing
for( count in 9:( length( cwbXML ) ) ) {
  lat[ count - 8 ] = cwbXML[count][[ 1 ]][ "lat" ]
  lon[ count - 8 ] = cwbXML[count][[ 1 ]][ "lon" ]
  locationName[ count - 8 ] = cwbXML[count][[ 1 ]][ "locationName" ]
  stationId[ count - 8 ] = cwbXML[count][[ 1 ]][ "stationId" ]
  obsTime[ count - 8 ] = cwbXML[count][[ 1 ]][ "time" ][[ 1 ]][ "obsTime" ]
  ELEV[ count - 8 ] = cwbXML[count][[ 1 ]][ 6 ][[ 1 ]][[ 2 ]]
  WDIR[ count - 8 ] = cwbXML[count][[ 1 ]][ 7 ][[ 1 ]][[ 2 ]]
  WDSD[ count - 8 ] = cwbXML[count][[ 1 ]][ 8 ][[ 1 ]][[ 2 ]]
  TEMP[ count - 8 ] = cwbXML[count][[ 1 ]][ 9 ][[ 1 ]][[ 2 ]]
  HUMD[ count - 8 ] = cwbXML[count][[ 1 ]][ 10 ][[ 1 ]][[ 2 ]]
  PRES[ count - 8 ] = cwbXML[count][[ 1 ]][ 11 ][[ 1 ]][[ 2 ]]
  SUN[ count - 8 ] = cwbXML[count][[ 1 ]][ 12 ][[ 1 ]][[ 2 ]]
  H_24R[ count - 8 ] = cwbXML[count][[ 1 ]][ 13 ][[ 1 ]][[ 2 ]]
  WS15M[ count - 8 ] = cwbXML[count][[ 1 ]][ 14 ][[ 1 ]][[ 2 ]]
  WD15M[ count - 8 ] = cwbXML[count][[ 1 ]][ 15 ][[ 1 ]][[ 2 ]]
  WS15T[ count - 8 ] = cwbXML[count][[ 1 ]][ 16 ][[ 1 ]][[ 2 ]]
  CITY[ count - 8 ] = cwbXML[count][[ 1 ]][ 17 ][[ 1 ]][[ 2 ]]
  CITY_SN[ count - 8 ] = cwbXML[count][[ 1 ]][ 18 ][[ 1 ]][[ 2 ]]
  TOWN[ count - 8 ] = cwbXML[count][[ 1 ]][ 19 ][[ 1 ]][[ 2 ]]
  TOWN_SN[ count - 8 ] = cwbXML[count][[ 1 ]][ 20 ][[ 1 ]][[ 2 ]]
  
}

# unlist the measure latitude data
lat = unlist( lat )
# convert latitude from string to double float
lat = as.double( lat )
lat

lon = unlist( lon )
lon = as.double( lon )
lon

locationName = unlist( locationName )
locationName

stationId = unlist( stationId )
stationId

obsTime = unlist( obsTime )
obsTime

ELEV = unlist( ELEV )
ELEV = as.double( ELEV )
ELEV

WDIR = unlist( WDIR )
WDIR = as.double( WDIR )
WDIR

WDSD = unlist( WDSD )
WDSD = as.double( WDSD )
WDSD

TEMP = unlist( TEMP )
TEMP = as.double( TEMP )
TEMP

HUMD = unlist( HUMD )
HUMD = as.double( HUMD )
HUMD

PRES = unlist( PRES )
PRES = as.double( PRES )
PRES

SUN = unlist( SUN )
SUN = as.double( SUN )
SUN

H_24R = unlist( H_24R )
H_24R = as.double( H_24R )
H_24R

WS15M = unlist( WS15M )
WS15M = as.double( WS15M )
WS15M

WD15M = unlist( WD15M )
WD15M = as.double( WD15M )
WD15M

WS15T = unlist( WS15T )
WS15T = as.double( WS15T )
WS15T

CITY = unlist( CITY )
CITY

CITY_SN = unlist( CITY_SN )
CITY_SN = as.integer( CITY_SN)
CITY_SN

TOWN = unlist( TOWN )
TOWN

TOWN_SN = unlist( TOWN_SN )
TOWN_SN

weatherMeasure = data.frame( lat, lon, locationName, stationId, obsTime, 
            ELEV, WDIR, WDSD, TEMP, HUMD, PRES, SUN, H_24R,
            WS15M, WD15M, WS15T, CITY, CITY_SN, TOWN, TOWN_SN )

weatherMeasure$locationName

length( cwbXML )
cwbXML[ length( cwbXML ) ][[ 1 ]][ 1 ]
