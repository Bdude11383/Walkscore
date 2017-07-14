
##-----------------------------------------------
##-----------------------------------------------
##SETUP
##=----------------------------------------------
##-----------------------------------------------

remove(list=ls())

library(RODBC)
library(walkscoreAPI)
library(RCurl)
library(httr)
library(jsonlite)
library(rjson)
library(RJSONIO)

##-----------------------------------------------
##-----------------------------------------------
##IMPORT EQR ASSETS
##=----------------------------------------------
##-----------------------------------------------

#psswd <- .rs.askForPassword("Database Password:")
#myconn <-odbcConnect("DEVSQL08", uid="bkerschner", pwd=psswd)

#AssetList <- sqlQuery(myconn, "SELECT * FROM [ARCGIS_DATAMART].[dbo].[EQR_ASSETS_GEOCODED_070817]")

#close(myconn)

load("C:/Users/bkerschner/desktop/repo/RentalIncomeGrowth/EQR_ASSETS_GEOCODED.RDA")

AssetList <- EQR_ASSETS_GEOCODED

##-----------------------------------------------
##-----------------------------------------------
##FORMAT IMPORTED DATA
##=----------------------------------------------
##-----------------------------------------------

AssetList$STATE <- as.character(AssetList$STATE)
AssetList$CITY <- as.character(AssetList$CITY)

trim <- function (x) gsub("^\\s+|\\s+$", "", x)
AssetList$STATE <- trim(AssetList$RegionAbbr)
AssetList$CITY <- trim(AssetList$City)

##-----------------------------------------------
##-----------------------------------------------
##PULL FROM WALKSCORE API
##=----------------------------------------------
##-----------------------------------------------

WalkScoreKey <- '6ece4a5a45fd5df99a588173ddfd4b18'

#WALKSCORE
for (i in 1:length(AssetList$MASTERENTITYID)){
  ws <- getWS(AssetList[i,52],AssetList[i,53],WalkScoreKey)
  AssetList[i,"Walkscore"] <- ws$walkscore
}

#TRANSITSCORE
for (i in 1:length(AssetList$MASTERENTITYID)){
  ts <- tryCatch(getTS(AssetList[i,52],AssetList[i,53],AssetList[i,150],AssetList[i,106],WalkScoreKey),error=function(e) e)
  if(inherits(ts, "error")) next
  AssetList[i,"TransitScore"] <- ts$transitscore
}

##-----------------------------------------------
##-----------------------------------------------
##EXPORT TO CSV
##=----------------------------------------------
##-----------------------------------------------