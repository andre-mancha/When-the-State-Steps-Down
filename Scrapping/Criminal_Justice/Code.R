
# Packages ----------------------------------------------------------------

rm(list = ls())

Packages <- c("dplyr", "ggplot2", "readxl", "readr","ggpubr","tidyverse","purrr","gtools","collapse",
              "tidygeocoder","sf","raster","geobr","stringr","lwgeom","plyr","tidyr","sp","rgeos",
              "rvest","magrittr","stargazer")

lapply(Packages, library, character.only = TRUE)

setwd("YOUR WORKING DIRECTORY HERE")

Sys.setlocale("LC_ALL", "pt_BR.UTF-8")

# Data Analysis -----------------------------------------------------------

files=list.files(,pattern = ".html")

# Vector to track any record in the judiciary (SUSPECTED CRIMINALS I)

toMatch <- c("Roubo", "Furto", "Tráfico", "Estelionato",
             "Apreensão de Bens", "Violência Doméstica", "Drogas",
             "Lei Maria da Penha", "Reintegração", "Organização Criminosa",
             "Falsificação", "Crimes de Trânsito", "Indébito",
             "Apelação Cível", "Crimes do Sistema Nacional de Armas",
             "Pena Privativa de Liberdade", "Carta Precatória",
             "Apelação Criminal", "Contravenção", "Receptação",
             "Outras Fraudes", "Falsidade Ideológica", "Busca e Apreensão")

for (i in seq_along(files)){
  
  baseline<- read.csv(files[i], fileEncoding="utf-8")
  
  character_vector <- as.vector(t(baseline))
  
  baseline <-  as.data.frame(sum(grepl(paste(toMatch,collapse="|"),character_vector), na.rm = TRUE))
  
  colnames(baseline) <- files[i]
  
  baseline <- gather(baseline, "Name","Indicator")
  
  save(baseline,file=paste0(files[i],".Rda"))
  
}

# Organize in a unique data base

datalist = list()

frames=list.files(,pattern = ".Rda")

for (i in 1:length(frames)){
  
  load(frames[i])
  datalist[[i]] <- baseline
  
}

Base_Zero <- do.call(rbind, datalist)

save(Base_Zero, file = "Base1.Rda")

write.csv2(Base_Zero,"Base1.csv")


############# Import texts in R files - SUSPECTED CRIMINALS II #################

toMatch <- c("Roubo", "Furto", "Tráfico", "Drogas",
             "Violência Doméstica", "Lei Maria da Penha", "Organização Criminosa",
             "Crimes do Sistema Nacional de Armas", "Pena Privativa de Liberdade",
             "Apelação Criminal", "contravenção", "Receptação")


for (i in seq_along(files)){
  
  baseline<- read.csv(files[i], fileEncoding="utf-8")
  
  character_vector <- as.vector(t(baseline))
  
  baseline <-  as.data.frame(sum(grepl(paste(toMatch,collapse="|"),character_vector), na.rm = TRUE))
  
  colnames(baseline) <- files[i]
  
  baseline <- gather(baseline, "Name","Indicator")
  
  save(baseline,file=paste0(files[i],".Rda"))
  
}

# Organize in a unique data base

datalist = list()

frames=list.files(,pattern = ".Rda")

for (i in 1:length(frames)){
  
  load(frames[i])
  datalist[[i]] <- baseline
  
}

Base_Intermediaria <- do.call(rbind, datalist)

save(Base_Intermediaria, file = "Base2.Rda")

write.csv2(Base_Intermediaria,"Base2.csv")



################ Import texts in R files - SUSPECTED CRIMINALS III ########################

toMatch <- c("Roubo","Tráfico", "Drogas",
             "Organização Criminosa","Crimes do Sistema Nacional de Armas", 
             "Pena Privativa de Liberdade","Apelação Criminal")

for (i in seq_along(files)){
  
  baseline<- read.csv(files[i], fileEncoding="utf-8")
  
  character_vector <- as.vector(t(baseline))
  
  baseline <-  as.data.frame(sum(grepl(paste(toMatch,collapse="|"),character_vector), na.rm = TRUE))
  
  colnames(baseline) <- files[i]
  
  baseline <- gather(baseline, "Name","Indicator")
  
  save(baseline,file=paste0(files[i],".Rda"))
  
}

# Organize in a unique data base

datalist = list()

frames=list.files(,pattern = ".Rda")

for (i in 1:length(frames)){
  
  load(frames[i])
  datalist[[i]] <- baseline
  
}

Base <- do.call(rbind, datalist)

save(Base, file = "Base3.Rda")

write.csv2(Base,"Base3.csv")


################ Import texts in R files -  SUSPECTED CRIMINALS IV ########################

toMatch <- c("Tráfico", "Drogas",
             "Organização Criminosa","Crimes do Sistema Nacional de Armas", 
             "Pena Privativa de Liberdade","Apelação Criminal")

for (i in seq_along(files)){
  
  baseline<- read.csv(files[i], fileEncoding="utf-8")
  
  character_vector <- as.vector(t(baseline))
  
  baseline <-  as.data.frame(sum(grepl(paste(toMatch,collapse="|"),character_vector), na.rm = TRUE))
  
  colnames(baseline) <- files[i]
  
  baseline <- gather(baseline, "Name","Indicator")
  
  save(baseline,file=paste0("YOUR WORKING DIRECTORY HERE",files[i],".Rda"))
  
}

# Organize in a unique data base
setwd("YOUR WORKING DIRECTORY HERE")

datalist = list()

frames=list.files(,pattern = ".Rda")

for (i in 1:length(frames)){
  
  load(frames[i])
  datalist[[i]] <- baseline
  
}

Base <- do.call(rbind, datalist)

save(Base, file = "Base4.Rda")

write.csv2(Base,"Base4.csv")
