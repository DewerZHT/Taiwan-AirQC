##
# File name: CWBDownloadBatch.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.14 11:00 UTC+8
# Last Modified:
#   2016.05.14 11:13 UTC+8
# Note: 
#   
#

# set project directory path
srcDir = "D:/Desktop/Taiwan AirQC/source/"
dataDir = "D:/Desktop/Taiwan AirQC/data/"
plotDir = "D:/Desktop/Taiwan AirQC/plots/"
downloadDir = "D:/Desktop/Taiwan AirQC/downloads/"

# set working directory to source
setwd( srcDir )
# load function script
source( "FetchCWBOpenData.R" )


if( !file.exists( paste0( dataDir, "cwb/cwbDataSetList.Rdata" ) ) ) {
  message( "Loading CWB data set list from csv file.")
  if( !file.exists( paste0( dataDir, "cwb/CWBOpenDataList.csv" ) ) ) {
    message( "CWB data set list isn't exists." )
    
  } else {
    message( "Read from CWBOpenDataList.csv" )
    cwbDataSetList = loadDataSetList( paste0( dataDir, "cwb/CWBOpenDataList.csv" ) )
    save( cwbDataSetList, file = paste0( dataDir, "cwb/cwbDataSetList.Rdata" ) )
    
  }
  
} else {
  message( "Loading CWB data set list from cwbDataSetList.Rdata" )
  load( file = paste0( dataDir, "cwb/cwbDataSetList.Rdata") )
  
}



CWBAPIKey = "CWB-16CE8E67-DC15-4918-AA16-B3EA3D97AA02"
selectDataSet = c( "O-A0001-001",
                   "O-A0002-001",
                   "O-A0003-001",
                   "O-A0004-001" )



for( counter in 1:length( selectDataSet ) ) {
  selectData = which( cwbDataSetList$id == selectDataSet[ counter ] )
  currentHour = format( Sys.time(), "%Y%m%d_%H_" )
  destFile = paste0( downloadDir,
                     "cwb/",
                     currentHour,
                     cwbDataSetList$id[selectData],
                     ".xml" )
  
  getCWBOpenData( cwbDataSetList$id[selectData],
                  CWBAPIKey,
                  destFile )
  
  
}
