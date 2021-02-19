###############################################################################
## Christine Plumejeaud-Perreau, U.M.R 7266 LIENSS
## Script for cleaning lat/long of penguins
## Master 2, Geographic information
###############################################################################

setwd("C:/Travail/CNRS_mycore/Cours/Cours_M2_python/Projet_Arctox")

meslibrairiesR <- "C:/Tools/R4"

# Ajouter meslibrairiesR dans ces chemins : 
.libPaths(c( .libPaths(), meslibrairiesR) )
library(RPostgreSQL)
library(tidyverse)

install.packages("KernSmooth")
library(KernSmooth)


## 1. RÃ©cupÃ©rer les donnÃ©es depuis Postgres
system('passh -p zzzzzz  ssh -f tpm2@cchum-kvm-mapuce.in2p3.fr  -L 8005:localhost:5432 -N')

#
con <- dbConnect(dbDriver("PostgreSQL"), host='localhost', port='5432', dbname='savoie', user='postgres', password='postgres')
con <- dbConnect(dbDriver("PostgreSQL"), host='localhost', port='8005', dbname='savoie', user='yyyy', password='xxxxx')

###############################################################################################

query <- "select distinct bird_id, gls_id, clean_glsid , sex, wing, mass , migration_length 
from arctic.data_for_analyses
where bird_path is not null
order by clean_glsid"

data <- dbGetQuery(con, query)

dim(data)
[1] 18 7
[1] 60 7

write.table(data, "./data_subset06112020.csv", sep = "\t")#06 nov 2020


# 2. Lire les données depuis fichier CSV

#Préprocessing dans TD3
data <- read.table("./data_subset06112020.csv", sep = "\t")

## Utiliser mutate pour transformer le type d'une variable (par exemple)
## Rq : vu le nombre de variables de   pointcalls cela peut devenir ennuyeux.
## Donc on vous propose mutate_at qui agit sur un ensemble de variables listÃ©es par vars()
## et avec des fonctions listÃ©es dans list()
library(lubridate)
library(tidyverse)
penguins <- data %>%
  mutate_at(vars(sex ), list(as.factor))  %>%
  mutate_at(vars(wing, mass, migration_length), list(as.numeric)) 

penguins <- penguins %>% mutate(health = mass/wing)


summary(penguins)



ggplot(data = penguins , 
       mapping = aes(x = health, y = migration_length)) +
  geom_point(aes(color = sex))+
  labs(x = "ratio weight per wing size",
       y = "length of the migration (km)",
       title = "Relation entre santé et km parcourus durant la migration",
       subtitle = "Est-ce qu'un oiseau gras va plus loin ?",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))
dev.copy(png,'./figures/birds_migration_complet.png')
dev.off()


ggplot(data = penguins , 
       mapping = aes(x = wing, y = migration_length)) +
  geom_point(aes(color = sex))+
  labs(x = " wing size",
       y = "length of the migration (km)",
       title = "Relation entre taille de l'aile et km parcourus durant la migration",
       subtitle = "Est-ce qu'un oiseau avec des grandes ailes va plus loin ?",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))

dev.copy(png,'./figures/birds_migration2_complet.png')
dev.off()
# Une relation : petite aile avec aller plus loin


ggplot(data = penguins , 
       mapping = aes(x = mass, y = migration_length)) +
  geom_point(aes(color = sex))+
  labs(x = " weight of the bird",
       y = "length of the migration (km)",
       title = "Relation entre masse de l'oiseau et km parcourus durant la migration",
       subtitle = "Est-ce qu'un oiseau lourd va plus loin ?",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))

dev.copy(png,'./figures/birds_migration3_complet.png')
dev.off()
#Pas de relation

# est-ce que les femelles vont plus loin que les males
ggplot(data = penguins , 
       mapping = aes(x = sex, y = migration_length)) +
  geom_boxplot(aes(color = sex))+
  labs(x = " sex of the bird",
       y = "length of the migration (km)",
       title = "Relation entre sexe de l'oiseau et km parcourus durant la migration",
       subtitle = "Est-ce qu'un oiseau femelle va plus loin ?",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))

dev.copy(png,'./figures/birds_migration4_complet.png')
dev.off()


#######################################################################################################
## evolution of the distance to colony through time
#####################################################################################################

query <- "select id, timestampgps, distance_to_colony
from arctic.kap_hoegh_gls
order by id, timestampgps"


data <- dbGetQuery(con, query)

library(tidyverse)
gps <- data %>%
  mutate_at(vars(id ), list(as.factor))  %>%
  mutate_at(vars(distance_to_colony), list(as.numeric)) %>%
  mutate_at(vars(timestampgps), list(ymd)) %>%
  filter (distance_to_colony < 4500)

ggplot(data = gps , 
       mapping = aes(x = timestampgps, y = distance_to_colony)) +
  geom_point(aes(color = id))+
  labs(x = " elapsed time",
       y = "distance_to_colony",
       title = "Evolution of distance to colonly during winter",
       subtitle = "When do birds stop ?",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))
dev.copy(png,'./figures/travels_60_birds.png')
dev.off()

getwd()

dim(data)

#######################################################################################################
## Cleaning lat
#####################################################################################################

query <- "select pkid, id, timestampgps, lat, clean_lat 
from arctic.kap_hoegh_gls 
order by id, timestampgps"

# where id in (select distinct (id) from arctic.kap_hoegh_gls_dataset1)*

data <- dbGetQuery(con, query)


ggplot(data = data , 
       mapping = aes(x = timestampgps, y = lat)) +
  geom_point(aes(color = id))+
  labs(x = " elapsed time",
       y = "lat",
       title = "Evolution of latitude during winter",
       subtitle = "How to clean the latitudes",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))
dev.copy(png,'./figures/travels_60_lat.png')
dev.off()


ggplot(data = data , 
       mapping = aes(x = timestampgps, y = clean_lat)) +
  geom_point(aes(color = id))+
  labs(x = " elapsed time",
       y = "lat",
       title = "Evolution of latitude during winter",
       subtitle = "How to clean the latitudes",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))
dev.copy(png,'./figures/travels_60_clean_lat_withNA.png')
dev.off()

dataind <- data %>%
  filter(id == 3656)

library(zoo)
library(KernSmooth)

x <- dataind$clean_lat
h <- dpik(x)
h #1.425035

est <- bkde(x, bandwidth=h)
plot(est,type="l")




b=4
b <- h
estimate <- ksmooth(dataind$timestampgps, dataind$clean_lat , kernel = "normal", 
                    bandwidth = b, 
                    range.x = range(dataind$timestampgps), 
                    n.points = max(100L, length(dataind$timestampgps)), 
                    dataind$timestampgps)

dataind$test <- estimate$y 

estimate <- ksmooth(dataind$timestampgps, dataind$lat , kernel = "normal", 
                    bandwidth = b, 
                    range.x = range(dataind$timestampgps), 
                    n.points = max(100L, length(dataind$timestampgps)), 
                    dataind$timestampgps)

dataind$test2 <- estimate$y 

ggplot(data = dataind , 
       mapping = aes(x = timestampgps, y = lat)) +
  geom_point(color="black")+
  geom_line(mapping = aes(x = timestampgps, y = test), color="red", size =2)+
  geom_line(mapping = aes(x = timestampgps, y = test2), color="blue")+
  #ylim(c(35,85))
  labs(x = " elapsed time",
       y = "lat",
       title = "Evolution of latitude during winter",
       subtitle = "How to clean the latitudes",
       caption = "Source : ARCTOX 2010-2011")+
  scale_y_continuous(expand=c(0,0))
dev.copy(png,'./figures/travels_60_cleaning.png')
dev.copy(png,'./figures/travels_60_cleaning_v2.png')
dev.off()

ggplot(data = dataind , 
       mapping = aes(x = timestampgps, y = lat)) +
  geom_point(color="black")+
  geom_line(mapping = aes(x = timestampgps, y = test), color="red", size =2)+
  geom_line(mapping = aes(x = timestampgps, y = test2), color="blue")+
  #ylim(c(35,85))+
  labs(x = " elapsed time",
       y = "lat",
       title = "Evolution of latitude during winter",
       subtitle = "How to clean the latitudes",
       caption = "Source : ARCTOX 2010-2011")
dev.copy(png,'./figures/travels_60_cleaning_v2_ok.png')
dev.off()

for (i in 0:length(unique(data$id)) ){
  print(unique(data$id)[i]);
}

colnames(data)
"pkid" "id"           "timestampgps" "lat"          "clean_lat"
summary(data)

## Init the result
datares <- data.frame(
                  pkid=integer(),
                  id=character(), 
                  timestampgps=as.Date(character()),
                 lat=numeric(), 
                 clean_lat=numeric(),
                 smooth_lat=numeric(),
                 stringsAsFactors=FALSE)

for (i in (unique(data$id)) ){
  #i <- "148"
  print(i);
  dataind <- data %>%
    filter(id == i)
  x <- dataind$clean_lat
  h <- dpik(x)
  print(h)
  estimate <- ksmooth(dataind$timestampgps, dataind$clean_lat , kernel = "normal", 
                      bandwidth = h, 
                      range.x = range(dataind$timestampgps), 
                      n.points = max(100L, length(dataind$timestampgps)), 
                      dataind$timestampgps)
  
  dataind$smooth_lat <- estimate$y 
  #data <- data %>% full_join(dataind, by = c("id", "timestampgps", "lat", "clean_lat")
  datares <- rbind(datares, dataind)                      
}

dbGetQuery(con, "drop table if exists arctic.smoothed")
dbWriteTable(con, c('arctic', 'smoothed'), datares, row.names=FALSE, append=TRUE)

ggplot(data = datares , 
       mapping = aes(x = timestampgps, y = lat)) +
  geom_point(aes(color = id))+
  geom_line(data = datares %>% filter(id=="148"), mapping = aes(x = timestampgps, y = smooth_lat), size =2)+
  labs(x = " elapsed time",
       y = "lat",
       title = "Evolution of latitude during winter",
       subtitle = "How to clean the latitudes",
       caption = "Source : ARCTOX 2010-2011")+
  #scale_y_continuous(expand=c(0,0))
  ylim(c(35,85))
dev.copy(png,'./figures/travels_60_lat_smoothed_ok.png')
dev.off()


#######################################################################################################
## Cleaning lat and long
#####################################################################################################

query <- "select pkid, id, timestampgps, lat, clean_lat, long, clean_long 
from arctic.kap_hoegh_gls 
order by id, timestampgps"


data <- dbGetQuery(con, query)

dim(data) #28833     7
colnames(data)
"pkid"         "id"           "timestampgps" "lat"          "clean_lat"    "long"         "clean_long"

ggplot(data = data , 
       mapping = aes(x = timestampgps, y = long)) +
  geom_point(aes(color = id))+
  labs(x = " elapsed time",
       y = "long",
       title = "Evolution of longitude during winter",
       subtitle = "How to clean the longitudes",
       caption = "Source : ARCTOX 2010-2011")
  #scale_y_continuous(expand=c(0,0))
dev.copy(png,'./figures/travels_60_long.png')
dev.off()

ggplot(data = data , 
       mapping = aes(x = timestampgps, y = clean_long)) +
  geom_point(aes(color = id))+
  labs(x = " elapsed time",
       y = "clean long",
       title = "Evolution of longitude during winter",
       subtitle = "How to clean the longitudes",
       caption = "Source : ARCTOX 2010-2011")
#scale_y_continuous(expand=c(0,0))
dev.copy(png,'./figures/travels_60_cleanlong.png')
dev.off()

dataind <- data %>%
  filter(id == "148")
x <- as.matrix(dataind[, c("clean_long", "clean_lat")])
h1 <- dpik(x[,1])
h2 <- dpik(x[,2])

dim(x)

bkde2D(x, bandwidth = c(h1, h2), gridsize = c(499, 499)) #gridsize = c(51L, 51L), range.x, truncate = TRUE

## Init the result
datares <- data.frame(
  pkid=integer(),
  id=character(), 
  timestampgps=as.Date(character()),
  lat=numeric(), 
  clean_lat=numeric(),
  smooth_lat=numeric(),
  long=numeric(), 
  clean_long=numeric(),
  smooth_long=numeric(),
  stringsAsFactors=FALSE)

for (i in (unique(data$id)) ){
  #i <- "148"
  print(i);
  dataind <- data %>%
    filter(id == i)
  
  x <- dataind$clean_lat
  h <- dpik(x)
  print(h)
  estimate <- ksmooth(dataind$timestampgps, dataind$clean_lat , kernel = "normal", 
                      bandwidth = h, 
                      range.x = range(dataind$timestampgps), 
                      n.points = max(100L, length(dataind$timestampgps)), 
                      dataind$timestampgps)
  
  dataind$smooth_lat <- estimate$y 
  
  x <- dataind$clean_long
  h <- dpik(x)
  print(h)
  estimate <- ksmooth(dataind$timestampgps, dataind$clean_long , kernel = "normal", 
                      bandwidth = h, 
                      range.x = range(dataind$timestampgps), 
                      n.points = max(100L, length(dataind$timestampgps)), 
                      dataind$timestampgps)
  
  dataind$smooth_long <- estimate$y 
  #data <- data %>% full_join(dataind, by = c("id", "timestampgps", "lat", "clean_lat")
  datares <- rbind(datares, dataind)                      
}

dbGetQuery(con, "drop table if exists arctic.smoothed")
dbWriteTable(con, c('arctic', 'smoothed'), datares, row.names=FALSE, append=TRUE)

ggplot(data = datares %>% filter(id %in% c( "3683", "17585")) , 
       mapping = aes(x = timestampgps, y = long)) +
  geom_point(aes(color = id))+
  geom_line(mapping = aes(x = timestampgps, y = smooth_long), size =0.5)+
  labs(x = " elapsed time",
       y = "lat",
       title = "Evolution of longitude during winter",
       subtitle = "How to clean the longitude",
       caption = "Source : ARCTOX 2010-2011")
  #scale_y_continuous(expand=c(0,0))
  #ylim(c(35,85))
dev.copy(png,'./figures/travels_n148_long_smoothed_ok.png')
dev.off()

sessionInfo()
