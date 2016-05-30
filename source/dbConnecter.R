##
# File name: dbConnecter.R
# Author: Wu, Zhen-Hao (David, Wu)
# Date: 2016.05.30 14:34 UTC+8
# Last Modified:
#   2016.05.30 15:21 UTC+8
# Note: 
#   
#

# install.packages( "RMySQL" )
# install.packages( "stringr" )
library( RMySQL )

mysqlDB = dbConnect( MySQL(),
                     user = 'DewerZHT',
                     password = 'Dewer12FF6F1',
                     dbname = 'tw_airqc',
                     host = '140.135.11.98',
                     port = 51336 )

summary( mysqlDB )
dbGetInfo( mysqlDB )
dbListResults( mysqlDB )
dbListTables( mysqlDB )

sqlQuery = 'CREATE TABLE source_data ( file_id int NOT NULL AUTO_INCREMENT, file_name varchar(255) NOT NULL, proceed BOOLEAN, type varchar(255), PRIMARY KEY (file_id) )'
dbSendQuery( mysqlDB, sqlQuery )

dbWriteTable( mysqlDB, name = 'source_data', value = sourceData, overwrite = TRUE, row.names = FALSE)
