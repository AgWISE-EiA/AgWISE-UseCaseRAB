# Run the simulation for the entire study area  
#' Title
#'
#' @param my_list_clm 
#' @param extd.dir 
#' @param stn 
#'
#' @return
#' @export
#'
#' @examples
my_list_sim<- function(crop, my_list_clm, extd.dir, stn){
  my_list_sim<- foreach (i=1:length(my_list_clm)) %dopar% {  
  setwd(paste0(extd.dir, '/', i))  
  tryCatch(apsimx::apsimx(crop, value = "HarvestReport"), error=function(err) NA)
  #apsim.spatial("D:/project", 3, "KE", c("2020-01-01","2022-01-01"), "soybean.apsimx", c("2010-11-01T00:00:00", "2020-12-31T00:00:00"),"1-nov", "30-nov", "Davis")
}

foreach (i = 1:length(my_list_sim))%do%{
  my_list_sim[[i]]$Longitude<-stn$Longitude[[i]]
  my_list_sim[[i]]$Latitude<-stn$Latitude[[i]]
  my_list_sim[[i]]$Location<-stn$Location[[i]]
}

tryCatch(foreach (i = 1:length(my_list_sim))%do%{ 
  if(length(my_list_sim[[i]])< 5){
    my_list_sim[[i]] <- NULL
  }
}, error=function(err) NULL)

tryCatch(foreach (i = 1:length(my_list_sim))%do%{ 
  if(length(my_list_sim[[i]])< 5){
    my_list_sim[[i]] <- NULL
  }
}, error=function(err) NULL)

return(my_list_sim)
}

