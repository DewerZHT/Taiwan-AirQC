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
# install.packages( "ggplot2" )
# load the libraries
library( stringr )
library( ggplot2 )

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
epa.AirQCDataPath = paste0( dataDir, "epa/" )


if( file.exists( epa.AirQCMeasureFile ) ) {
  message( "> INFO: load the data set last process" )
  load( epa.AirQCMeasureFile )
  
} else {
  message( "> INFO: hasn't load any TPE AirQC Measure")
  # initiate the data frame to record download source data state
  epa.AirQCMeasure = NULL
  
} # END of 

epa.AirQCFiles = sourceData[ which( sourceData$type == "epa" ), "file_name"]
epa.AirQCFiles = unlist( epa.AirQCFiles )

epa.AirQCFiles[ 13 ]

read.csv( file = paste0( epa.AirQCSrcDataPath, epa.AirQCFiles[14]) , encoding = "UTF-8" )
epa.AirQCMeasureColNames = c( "SiteName", "County", "PSI", "MajorPollutant" ,
                              "Status", "SO2", "CO", "O3", "PM10", "PM2.5",
                              "NO2", "WindSpeed", "WindDirec", "FPMI", "NOx",
                              "NO", "PublishTime" )

# load the specified data file into 
for( counter in 13:150 ) {
  if( sourceData[ which( sourceData$file_name == epa.AirQCFiles[counter] ), 3 ] ) {
    message( "> INFO: File had been processed")
    
  }
  else {
    message( "> INFO: Load file data into dataframe" )
    newDF = read.csv( file = paste0( epa.AirQCSrcDataPath, epa.AirQCFiles[counter]) , encoding = "UTF-8" )
    colnames( newDF ) = epa.AirQCMeasureColNames
    epa.AirQCMeasure = rbind( epa.AirQCMeasure, newDF )
    # sourceData[ which( sourceData$file_name == epa.AirQCFiles[counter] ), 3 ] = TRUE
    
  }
  
}

save( epa.AirQCMeasure, file = epa.AirQCMeasureFile )
load( file = epa.AirQCMeasureFile )

epa.PlotOneDayAirQC = function( siteName, specifyDay ) {
  specifyTimeStr = format( specifyDay, "%Y-%m-%d" )
  # create a epa subset filiter by specified date
  epa.subset = as.data.frame( epa.AirQCMeasure[ grep( specifyTimeStr, epa.AirQCMeasure$PublishTime ), ] )
  # select data by a specified sitename in epa subset
  epa.subset = as.data.frame( epa.subset[ grep( siteName, epa.subset$SiteName ), ] )
  # drop na value from dataframe to avoid plot na values problem
  epa.subset = na.omit( epa.subset )
  
  ## draw a time line for this specified AirQc data
  # Start PNG device driver to save output to figure.png
  tmpSiteName = epa.AirQCSite[ which( epa.AirQCSite$SiteName == siteName), 2]
  epa.plotFile_name = paste0( plotDir, "epa/AirQC_", tmpSiteName, specifyTimeStr, ".png" )
  png( filename = epa.plotFile_name, height = 720, width = 1280, bg = "white" )
  
  # Define colors to be used for PSI, PM10, PM2.5
  plot_colors = c( "blue","red","forestgreen" )
  plot_name = c( "PSI", "PM10", "PM2.5" )
  # Set the plot title text
  plot_time = NULL
  plot_title = paste0( tmpSiteName, format( specifyDay, "%Y-%m-%d" ) )
  
  # compute the max value with y axis
  max_y = NULL
  max_y = c( max_y, max( epa.subset$PSI ) )
  max_y = c( max_y, max( epa.subset$PM10 ) )
  max_y = c( max_y, max( epa.subset$PM2.5 ) )
  max_y = max( max_y )
  
  plot( epa.subset$PSI, type="o", col=plot_colors[1], xlim = c( 0, 23 ), ylim = c( 0, max_y ), axes = FALSE, ann = FALSE, lwd = 6,
        cex.lab=1.5, cex.axis=1.5, cex.main=1.5 )
  
  plot_time = NULL
  for( counter in 1:24 ) {
    plot_time = c( plot_time, format( specifyDay, "%H:%M:%S" ) )
    specifyDay = specifyDay + 3600
    
  }
  
  # Make x axis using Mon-Fri labels
  axis( 1, at = 1:24, lab = plot_time )
  
  # Make y axis with horizontal labels that display ticks at 
  # every 4 marks. 4*0:max_y is equivalent to c(0,4,8,12).
  axis( 2, las = 1, at = 4*0:max_y )
  
  # Create box around plot
  box()
  
  # Graph trucks with red dashed line and square points
  lines( epa.subset$PM10, type = "o", pch = 22, lty = 2, col = plot_colors[2], lwd = 6 )
  
  # Graph suvs with green dotted line and diamond points
  lines( epa.subset$PM2.5, type = "o", pch = 23, lty = 3, col = plot_colors[3], lwd = 6 )
  
  # Create a title with a red, bold/italic font
  title( main = plot_title, col.main = "red", font.main = 4, cex = 2)
  
  # Label the x and y axes with dark green text
  title( xlab = "Time", col.lab = rgb( 0, 0.5, 0 ), cex.lab = 2 )
  title( ylab = "Value", col.lab = rgb( 0, 0.5, 0 ), cex.lab = 2 )
  
  # Create a legend at (1, 1) that is slightly smaller 
  # (cex) and uses the same line colors and points used by 
  # the actual plots
  legend( "bottomleft", legend = plot_name, cex = 2, col = plot_colors, pch = 21:23, lty = 1:3 )
  
  # Turn off device driver (to flush output to png)
  dev.off()
  
}

AirQCSite.Name = c( "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????", "??????", "??????", "??????",
                    "??????", "??????", "??????", "??????" )

for( siteCNT in 1:length( AirQCSite.Name ) ) {
  # get the specify site name
  print( AirQCSite.Name[siteCNT] )
  specifySite = AirQCSite.Name[siteCNT]
  
  # set start date 
  startTime = as.POSIXlt( "2016-05-22 00:00:00" )
  
  # create a sequence plot by a week data
  for( counter in 1:7 ) {
    print( format( startTime, "%Y-%m-%d") )
    epa.PlotOneDayAirQC( specifySite, startTime )
    startTime = startTime + 86400
    
  }
   
}

# set start date 
siteName = "??????"
# select data by a specified sitename in epa subset
epa.subset = as.data.frame( epa.AirQCMeasure[ grep( siteName, epa.AirQCMeasure$SiteName ), ] )
# drop na value from dataframe to avoid plot na values problem
epa.subset = na.omit( epa.subset )

save( epa.subset, file = paste0( epa.AirQCDataPath, "Linkou.Rdata" ) )

dim(epa.AirQCMeasure)

library(ggmap)
taiwan <- get_googlemap( 'taiwan', scale = 4 )
TaiwanMap <- ggmap( taiwan )
