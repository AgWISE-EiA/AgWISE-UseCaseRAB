#wkdir = Working directory where your files will be saved
#cell = The spatial resolution you want e.g 1 degree
#b = Choose the country shapefile you want e.g "ZM" for Zimbabwe
#date = How may years of weather do you want to download e.g c("1985-01-01","2022-01-01")
#crop = The crop in APSIM you want to simulate e.g. "maize.apsimx"
#clck = How many years do you want the simulation to run e.g. c("1985-01-01T00:00:00", "2020-12-31T00:00:00")
#sd = The start date e.g.  "1-jan"
#ed = The end date e.g.  "31-dec"
#variety = The cultivar you want to simulate e.g "A_103"
#rep1 = An additional value to report e.g. "[Maize].Grain.Total.Wt*10 as Yield" ,
#rep2 =An additional value to report e.g. "[Maize].SowingDate"
#' Title
#'
#' @param scfl 
#' @param my_list_clm 
#' @param wkdir 
#' @param crop 
#' @param clck 
#' @param variety 
#' @param ppln 
#' @param rep1 
#' @param rep2 
#'
#' @return
#' @export
#'
#' @examples
apsimSpatialFactorial <- function(scfl, my_list_clm, wkdir, crop, clck, variety, ppln, rep1, rep2) {
  my_packages <- c("spdep", "rgdal", "maptools", "raster", "plyr", "ggplot2", "rgdal",
                   "dplyr", "cowplot","readxl", "apsimx", "gtools", "foreach","doParallel",
                   "ranger")
  list.of.packages <- my_packages
  new.packages <- list.of.packages[!(my_packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(my_packages, require, character.only = TRUE)
  
  cores<- detectCores()
  myCluster <- makeCluster(cores -2, # number of cores to use
                           type = "PSOCK") # type of cluster
  registerDoParallel(myCluster)
  
  #Change depending on where you crop.apsimx file is stored, this script used the examples#
  setwd(wkdir)
  ex.dir <- scfl
  #ex.dir <- system.file("extdata", package = "apsimx")
  extd.dir <-wkdir
  file.copy(paste0(ex.dir, "/", crop),  extd.dir, overwrite = TRUE)
  
  list.files(ex.dir)
  list.files(extd.dir)
  
#saveRDS(my_list_sol, file="soil.RData")
#defaultsoil<- apsimx::get_isric_soil_profile(lonlat = c(29.025, -2.725), fix = TRUE)
  #APSIM PART##

  foreach (i =1:length(my_list_clm)) %dopar% {
    dir.create(paste0(extd.dir, '/', i))
    apsimx::edit_apsimx(paste0(crop), 
                        src.dir = extd.dir,
                        wrt.dir = paste0(extd.dir, '/', i),
                        root = c("pd", "Base_one"),
                        node = "Weather", 
                        value = paste0(extd.dir, "/", 'wth_loc_',i,'.met'), 
                        overwrite = TRUE)
  }
  # Edit the soil depending on location there is an issue with soil where one may be required to edit the BD, SAT
  foreach (i =1:length(my_list_clm)) %do% {  
    setwd(paste0(extd.dir, '/', i))
    #tryCatch({my_list_sol[[i]]$soil$BD <-  my_list_sol[[i]]$soil$BD * 0.86}, error=function(e) {NA}) 
    #tryCatch({my_list_sol[[i]]$soil$crop.LL <-  my_list_sol[[i]]$soil$LL15 + 0.01}, error=function(e) {NA}) 
    tryCatch({my_list_sol[[i]]$soil$SAT <-c(0.521, 0.521, 0.497, 0.488, 0.478, 0.440)}, error=function(e) {NA}) 
    tryCatch({my_list_sol[[i]]$soil$AirDry <- my_list_sol[[i]]$soil$LL15 - 0.02}, error=function(e) {NA})
    #tryCatch({my_list_sol[[i]]$soil$SAT <- my_list_sol[[1]]$soil- 0.02}, error=function(e) {NA})
    #tryCatch({edit_apsimx_replace_soil_profile(crop, root = c("pd", "Base_one"), soil.profile = my_list_sol[[i]], overwrite = TRUE)}, 
             #error=function(e) {NA})
    tryCatch({edit_apsimx_replace_soil_profile(crop, root = c("pd", "Base_one"), soil.profile = my_list_sol[[i]], overwrite = TRUE)},
             error=function(e) {NA})
    }
  
  
  
  # attr <- attributes(my_list_sol[[3]]$soilwat)
  # attr$class[2][1]
  
  #Edit clock#
  foreach (i =1:length(my_list_clm)) %dopar% {  
    setwd(paste0(extd.dir, '/', i))
    apsimx::edit_apsimx(crop, 
                        root = c("pd", "Base_one"),
                        node = "Clock",
                        parm = c("Start", "End"),
                        value = clck,
                        overwrite = TRUE)
  }
  # Change the sowing rule for when rain is available
  foreach (i =1:length(my_list_clm)) %dopar% {  
    setwd(paste0(extd.dir, '/', i))
     apsimx::edit_apsimx(crop, 
                        root = c("pd", "Base_one"),
                        node = "Manager",
                        manager.child = "SowingRule",
                        parm = "CultivarName", ## This is for end date
                        value = variety,
                        overwrite = TRUE)
     apsimx::edit_apsimx(crop, 
                 node = "Manager",
                 manager.child = "SowingRule",
                 parm = "Population", ## This is for end date
                 value = ppln,
                 overwrite = TRUE)
    apsimx::edit_apsimx(crop,
                        root = c("pd", "Base_one"),
                        node = "Report",
                        parm = "VariableNames", 
                        value = rep1, 
                        verbose = TRUE, overwrite = TRUE)
    apsimx::edit_apsimx(crop,
                        root = c("pd", "Base_one"),
                        node = "Report",
                        parm = "VariableNames", 
                        value = rep2, 
                        verbose = TRUE, overwrite = TRUE)
  }
 }


