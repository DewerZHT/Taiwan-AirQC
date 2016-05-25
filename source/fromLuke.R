# install.packages( "jsonlite" )
library( ggmap ) # google map library
library( rjson )
library( XML )
library( httr )
library( stringr )
library( RCurl )
library( jsonlite )
cleanFun <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}
getTcpMeasure <- function( sourceFile ) {
  if( !file.exists( sourceFile ) ) {
    message( paste0( "ERROR: source file", sourceFile, "is not exists") )
    return(NULL)
    
  }
  else {
    tcpMeasureData <- fromJSON( sourceFile)
    tcpMeasureData[2][1]$aaData[,1] <- cleanFun(tcpMeasureData[2][1]$aaData[,1]) 
    z <- as.data.frame(tcpMeasureData)
    colnames(z) <- c("Timestamp", "TYPE", "Name", "Cap", "Gen", "發電量/裝置容量比", "備註")
    return( z )
    
  }
  
}

fileList <- list.files( paste0( downloadDir, "tpc" ) )
fileList
# count how many files named with AirBoxMeasure
sum( str_count( fileList, "tpc" ) )

# set private time variable to avoid modified system time
mytime <- as.POSIXlt( "2016-05-17 16:07:00" )
mytimestr <- format( mytime, "%Y%m%d_%H%M" )
mytimestr
# adjust private time variable past 10 mins
mynewtime <- mytime + 600
mynewtimestr <- format( mynewtime, "%Y%m%d_%H%M" )
mynewtimestr

# set airbox file started timestamp
startTime <- as.POSIXlt( "2016-05-17 16:07:00" )

tpcMeasure <- NULL
tpeAirQCFileState <- NULL
#
for( counter in 1:( sum( str_count( fileList, "tpcInstantPower" ) ) - 1 ) ) {
  tmp <- getTcpMeasure( paste0( downloadDir, "tpc/", format( startTime, "%Y%m%d_%H%M" ), "_tpcInstantPower.json" ) )
  tpcMeasure <- rbind( tpcMeasure, tmp )
  print( format( startTime, "%Y%m%d_%H%M" ) )
  startTime <- startTime + 600
}

sourceFile = paste0( downloadDir, "tpc/", format( startTime, "%Y%m%d_%H%M" ), "_tpcInstantPower.json" );
# show records belongs to device_id 28C2DDDD47D5
specifyRecords <- which( tpeAirQCMeasure$device_id == "28C2DDDD47D5" )
specifyRecords

# count the records
length(specifyRecords)

time <- tpeAirQCMeasure[ specifyRecords, "time"]
pm2.5 <- tpeAirQCMeasure[ specifyRecords, "s_d0"]
specifyDevRecords <- data.frame( time, pm2.5 )

specifyDevRecords.subset <- specifyDevRecords[ grep( "2016-05-12", time ), ]

reg1 <- lm(specifyDevRecords.subset$pm2.5 ~ specifyDevRecords.subset$time )
require(ggplot2)
theme_set(theme_bw()) # Change the theme to my preference
ggplot( aes( x = time, y = pm2.5 ), data = specifyDevRecords.subset ) + geom_point()
