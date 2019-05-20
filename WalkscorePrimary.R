
##-----------------------------------------------
##SETUP
##-----------------------------------------------

library(here)
library(RODBC)
library(walkscoreAPI)
library(RCurl)
library(httr)
library(jsonlite)
library(rjson)
library(RJSONIO)

WalkScoreKey <- '6ece4a5a45fd5df99a588173ddfd4b18'

myconn <-odbcConnect("EQRSQL30.GeoAnalytics")

AssetList <- sqlQuery(myconn, "SELECT * FROM [GeoAnalytics].[dbo].[EQR_ASSETS_GEOCODED]
                      WHERE Lat IS NOT NULL AND Long IS NOT NULL",stringsAsFactors=FALSE,rows_at_time=1)
AssetList_CompetitorsApp <- sqlQuery(myconn, "SELECT * FROM [GeoAnalytics].[dbo].[EQR_ASSETS_AND_REIT_COMPETITORS]")


##-----------------------------------------------
##PULL FROM WALKSCORE API
##-----------------------------------------------

##FROM ENTITY TABLE
##-----------------------------------------------

#WALKSCORE
for (i in 1:length(AssetList$MASTERENTITYID)){
  ws <- getWS(AssetList[i,"Long"],AssetList[i,"Lat"],WalkScoreKey)
  AssetList[i,"Walkscore"] <- ws$walkscore
}

##FROM EQR COMPETITORS TABLE
##-----------------------------------------------

#WALKSCORE FROM COMPETITORS TABLE
for (i in 1:length(AssetList_CompetitorsApp$OBJECTID)){
  ws <- tryCatch(getWS(AssetList_CompetitorsApp[i,"Long"],AssetList_CompetitorsApp[i,"Lat"],WalkScoreKey),error=function(e) e)
  if(inherits(ws, "error")) next
  AssetList_CompetitorsApp[i,"Walkscore"] <- ws$walkscore
}

##-----------------------------------------------
##SAVE TO REPO
##-----------------------------------------------

WalkScorePayload <- AssetList
WalkScorePayload_CompetitorsApp <- AssetList_CompetitorsApp

save(WalkScorePayload,file="WalkScorePayload.RDA")
write.csv(WalkScorePayload,file="WalkScorePayload.csv")

save(WalkScorePayload_CompetitorsApp,file="WalkScorePayload_CompetitorsApp.RDA")
write.csv(WalkScorePayload_CompetitorsApp,file="WalkScorePayload_CompetitorsApp.csv")
