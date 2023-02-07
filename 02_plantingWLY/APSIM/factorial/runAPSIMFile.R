setwd("D:/RwandaData")
#######################################################
## sourcing the data 
stn<- read.csv("coordinates_Rwanda.csv")
names(stn)<- c("Longitude", 'Latitude', "Location")

rain<-read.csv("Rainfall.data.coordinates_Rwanda.csv")
rain$Date = seq(as.Date("1981-01-01"), as.Date("2020-12-31"), by="days")
date<- as.data.frame(rain$Date)
rain<-rain[,-1]

max<-read.csv("Tmax.data.coordinates_Rwanda.csv")
max<-max[,-1]

min<-read.csv("Tmin.data.coordinates_Rwanda.csv")
min<-min[,-1]

solar<-read.csv("S.Rad.data.coordinates_Rwanda.csv")
solar<-solar[,-1]

#########################################################
## sourcing function to create met file
setwd("D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/factorial/")
source('createMetFileFunction.R')

my_list_clm<-createMetFile(rain = rain,max = max,min = min,solar = solar,stn = stn)
save(my_list_clm, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/my_list_clm.RData")
#source soil and climate data

#Get soil data from iscric
my_list_sol <- foreach (i = 1:nrow(stn)-1) %dopar% {
  tryCatch(apsimx::get_isric_soil_profile(lonlat = c(stn$Longitude[i], stn$Latitude[[i]]))
           , error=function(err) NA)
}

save(my_list_sol, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/my_list_sol.RData")

#Write the weather files to a working directory and Edit the weather as per location
foreach (i =1:length(my_list_clm)) %dopar% {
  apsimx::write_apsim_met(my_list_clm[[i]], wrt.dir = "D:/project", filename = paste0('wth_loc_',i,'.met'))}

#########################################################
## sourcing function to create spatialize apsim
setwd("D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/factorial/")
source('aspimSpatialFactorial.R')

SimFebMar<- apsimSpatialFactorial(my_list_clm = my_list_clm,
                                      wkdir ="D:/project", 
                                      crop = "MaizeFactorialFebMar.apsimx", 
                                      clck = c("1981-01-01T00:00:00", "2020-12-31T00:00:00"),
                                      variety = "sc501",
                                      rep1 ="[Maize].Grain.Total.Wt*10 as Yield" ,
                                      rep2 ="[Maize].SowingDate")

SimAugSep<- apsimSpatialFactorial(my_list_clm = my_list_clm,
                        wkdir ="D:/project", 
                        crop = "MaizeFactorialAugSep.apsimx", 
                        clck = c("1981-01-01T00:00:00", "2020-12-31T00:00:00"),
                        variety = "sc501",
                        rep1 ="[Maize].Grain.Total.Wt*10 as Yield" ,
                        rep2 ="[Maize].SowingDate")

## sourcing function to run the spatialized apsim
setwd("D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/factorial/")
source('RunSim.R')
resultsFebMar<-my_list_sim(crop = "MaizeFactorialFebMar.apsimx",
                           my_list_clm = my_list_clm, 
                           extd.dir = "D:/project", 
                           stn = stn)

resultsAugSep<-my_list_sim(crop = "MaizeFactorialAugSep.apsimx",
                           my_list_clm = my_list_clm, 
                           extd.dir = "D:/project", 
                           stn = stn) 

save(resultsFebMar, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season1_output/resultsFebMar.RData")
save(resultsAugSep, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season2_output/resultsAugSep.RData")

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
save(PlantingDatesFebMar, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season1_output/PlantingDatesFebMar.RData")
save(PlantingDatesAugSep, file="D:/dev_agwise/AgWISE-UseCaseRAB/02_plantingWLY/APSIM/season2_output/PlantingDatesAugSep.RData")
