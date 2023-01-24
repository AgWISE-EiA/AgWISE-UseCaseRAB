setwd("D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/")
#######################################################
## sourcing the data 
stn<- read.csv("Rwanda_dummy_data/station.csv")
names(stn)<- c("Longitude", 'Latitude', "Location")

rain<-read.csv("Rwanda_dummy_data/Rainfall.data.coordinates_Rwanda.csv")
rain$Date = seq(as.Date("1981-01-01"), as.Date("2020-12-31"), by="days")
date<- as.data.frame(rain$Date)
rain<-rain[,-1]

max<-read.csv("Rwanda_dummy_data/Tmax.data.coordinates_Rwanda.csv")
max<-max[,-1]

min<-read.csv("Rwanda_dummy_data/Tmin.data.coordinates_Rwanda.csv")
min<-min[,-1]

solar<-read.csv("Rwanda_dummy_data/S.Rad.data.coordinates_Rwanda.csv")
solar<-solar[,-1]

#########################################################
## sourcing function to create met file
setwd("D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/factorial/")
source('createMetFileFunction.R')

my_list_clm<-createMetFile(rain = rain,max = max,min = min,solar = solar,stn = stn)


#########################################################
## sourcing function to create spatialize apsim
setwd("D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/factorial/")
source('aspimSpatialFactorial.R')

resultsFebMar<- apsimSpatialFactorial(my_list_clm = my_list_clm,
                                      wkdir ="D:/project", 
                                      crop = "MaizeFactorialFebMar.apsimx", 
                                      clck = c("1981-01-01T00:00:00", "2020-12-31T00:00:00"),
                                      variety = "sc501",
                                      rep1 ="[Maize].Grain.Total.Wt*10 as Yield" ,
                                      rep2 ="[Maize].SowingDate")

resultsAugSep<- apsimSpatialFactorial(my_list_clm = my_list_clm,
                        wkdir ="D:/project", 
                        crop = "MaizeFactorialAugSep.apsimx", 
                        clck = c("1981-01-01T00:00:00", "2020-12-31T00:00:00"),
                        variety = "sc501",
                        rep1 ="[Maize].Grain.Total.Wt*10 as Yield" ,
                        rep2 ="[Maize].SowingDate")

saveRDS(resultsFebMar, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season1_output/resultsFebMar.RData")
saveRDS(resultsAugSep, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season2_output/resultsAugSep.RData")

#########################################################
## sourcing function to create plot

setwd("D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/factorial/")
source('ApsimPlotFactorial.R')

PlantingDatesFebMar<-apsim.plots(stn = stn,
            results=resultsFebMar, 
            b= "RWANDA",
            wkdir= "D:/project")

PlantingDatesAugSep<-apsim.plots(stn = stn,
                                 results=resultsAugSep, 
                                 b= "RWANDA",
                                 wkdir= "D:/project")

#You can also choose to save all the files together as opposed to a list
saveRDS(PlantingDatesFebMar, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season1_output/PlantingDatesFebMar.RData")
saveRDS(PlantingDatesAugSep, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season2_output/PlantingDatesAugSep.RData")
