## ----kintr_setup, include=FALSE-----------------------------------------------------
rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(root.dir = rootDIR)
knitr::opts_chunk$set(fig.path='{{ site.baseurl }}/assets/images/unit05/')



## ----setup, echo=TRUE,message=FALSE, warning=FALSE----------------------------------
rm(list=ls())
rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
## laden der benötigten libraries
# wir definieren zuerst eine liste mit den Paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits installiert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("sf","mapview","tmap","spdep","ineq","cartography","spatialreg", "tidygeocoder","usedist","raster","kableExtra","downloader","rnaturalearthdata")
for (lib in libs){
  if(!lib %in% utils::installed.packages()){
    utils::install.packages(lib)
  }}
# nicht wundern lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package Namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))


## ----loaddata, echo=TRUE,message=FALSE, warning=FALSE-------------------------------
#---------------------------------------------------------
# nuts3_autocorr.R 
# Autor: Chris Reudenbach, creuden@gmail.com
# Urheberrecht: Chris Reudenbach 2020 GPL (>= 3)
#
# Beschreibung: Skript berechnet unterschiedliche Autokorrelationen aus den Kreisdaten
#  
#--------------------
##- Laden der Kreisdaten
#--------------------

# Aus der Sitzung Eins werden die gesäuberten Kreisdaten von github geladen und eingelesen

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/nuts3_kreise.rds",     destfile = "nuts3_kreise.rds")

# Einlesen der nuts3_kreise Daten
nuts3_kreise = readRDS("nuts3_kreise.rds")




## ----ols, echo=TRUE,message=FALSE, warning=FALSE------------------------------------
# für die Reproduzierbarkeit der Ergebnisse muss ein beliebiger `seed` gesetzt werden
set.seed(0) 

# lineares Modell Anteil Hochschulabschluss / ANteil Baugewerbe
lm_um = lm(Universitaeten.Mittel ~ Beschaeftigte, data=nuts3_kreise)
summary(lm_um)



## ----neighbors, echo=TRUE,message=FALSE, warning=FALSE------------------------------
# für die Reproduzierbarkeit der Ergebnisse muss ein beliebiger `seed` gesetzt werden
set.seed(0) 

##Berechnung einer distanzbasiereten Nachbarschaft
# extrahiere die Flächenschwerpunkte der Kreise
coords <- coordinates(as(nuts3_kreise,"Spatial"))
# berechne alle Distanzen für die Flächenschwerpunkte der Kreise
knn2nb = knn2nb(knearneigh(coords))
# erzeuge die Kreisdistanzen
kreise_dist <- unlist(nbdists(knn2nb, coords))
# extrahiere die namen der Kreise
rn <- row.names(nuts3_kreise)
# berechne die Nachbarschaften und Gewichte für alle Kreise < Median = summary(kreise_dist)[4]
nachbarschaft_1st <- dnearneigh(coords, 0, summary(kreise_dist)[4], row.names=rn)
m_nuts3_kreise_qd =   nb2mat(nachbarschaft_1st, style='W', zero.policy = TRUE)
nuts3_gewicht <- mat2listw(as.matrix(m_nuts3_kreise_qd))


## ----LM, echo=TRUE,message=FALSE, warning=FALSE-------------------------------------
LM  = lm.LMtests(lm_um,nuts3_gewicht , 999,test = "all",zero.policy = TRUE)
LM


## ----SAR, echo=TRUE,message=FALSE, warning=FALSE------------------------------------
# SAR Modell
spatlag = spatialreg::lagsarlm(Universitaeten.Mittel ~ Beschaeftigte, data=nuts3_kreise, listw = nuts3_gewicht,zero.policy=TRUE, tol.solve=1.0e-30)
summary(spatlag)

# zuweisen der Residuen in unseren nuts3_kreise Datensatz
nuts3_kreise$spatlagres = spatlag$residuals

# Moran I Test
moran.mc(nuts3_kreise$spatlagres,nuts3_gewicht , 999,zero.policy = TRUE)

# Darstellung

tm_shape(nuts3_kreise) +
  tm_borders() +
  tm_polygons(col = "spatlagres",style = "jenks" ) 


## ----SEM, echo=TRUE,message=FALSE, warning=FALSE------------------------------------
# SEM Modell Spatial Error Model
errspartlag = spatialreg::errorsarlm(Universitaeten.Mittel ~ Beschaeftigte, data=nuts3_kreise, listw = nuts3_gewicht,zero.policy=TRUE, tol.solve=1.0e-30)

# zuweisen der Residuen in unseren nuts3_kreise Datensatz
nuts3_kreise$errspatlagres = errspartlag$residuals
moran.mc(nuts3_kreise$er,nuts3_gewicht , 999,zero.policy = TRUE)

# Darstellen der TRResiduen
tm_shape(nuts3_kreise) +
  tm_borders() +
  tm_polygons(col = "errspatlagres",style = "jenks" ) 


