## ----kintr_setup, include=FALSE---------------------------------------
rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(root.dir = rootDIR)
knitr::opts_chunk$set(fig.path='{{ site.baseurl }}/assets/images/unit04/')



## ----setup, echo=TRUE,message=FALSE, warning=FALSE--------------------
rm(list=ls())
rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
## laden der benötigten libraries
# wir definieren zuerst eine liste mit den Paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits installiert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("sf","mapview","tmap","spdep","ineq", "tidygeocoder","usedist","raster","kableExtra","downloader")
for (lib in libs){
  if(!lib %in% utils::installed.packages()){
    utils::install.packages(lib)
  }}
# nicht wundern lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package Namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))


## ----loaddata, echo=TRUE,message=FALSE, warning=FALSE-----------------
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

# Aus dem Statistik-Kurs lesen wir die Kreisdaten ein
# Sie sind aus Bequemlichkeitsgründen auf github verfügbar

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/nuts3_kreise.rds",     destfile = "nuts3_kreise.rds")

# Einlesen der nuts3 Daten
nuts3_kreise = readRDS("nuts3_kreise.rds")

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/geo_coord_city.rds",     destfile = "geo_coord_city.rds")

# Einlesen der nuts3 Daten
geo_coord_city = readRDS("geo_coord_city.rds")


## ----points_0, echo=TRUE, message=FALSE, warning=FALSE, results=FALSE,out.width = "800px",out.height = "600px",fig.retina = 1----

geo_coord_city = readRDS("geo_coord_city.rds")

# visualize with mapview
mapview(geo_coord_city,  color='red',legend = FALSE)


## ----point_dist, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
staedte=c("München","Berlin","Hamburg","Köln","Bonn","Hannover","Nürnberg","Stuttgart","Freiburg","Marburg")

# Zuerst projizieren wir den Datensatz auf ETRS89/UTM
proj_coord_city = st_transform(geo_coord_city, crs = 25832)

# nun berechnen wir die Distanzen
city_distanz = dist(st_coordinates(proj_coord_city))
# mit Hilfe von dist_setNames können wir die Namen der distanzmatrix zuweisen
dist_setNames(city_distanz, staedte)

round(city_distanz,0)



## ----matrix, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# make a full matrix an
city_distanz <- as.matrix(city_distanz)
rownames(city_distanz)=staedte
colnames(city_distanz)=staedte



## ----weight, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# inverse Distanz
gewichtungs_matrix =  (1 / city_distanz)


## ----invdist, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# inverse Distanz zum Quadrat
gewichtungs_matrix_q =  (1 / city_distanz ** 2)



## ----linnorm, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# löschen der Inf Werte die durch den Selbstbezug der Punkte entestehen
gewichtungs_matrix <- as.matrix(gewichtungs_matrix)
rownames(gewichtungs_matrix)=staedte
colnames(gewichtungs_matrix)=staedte

gewichtungs_matrix[!is.finite(gewichtungs_matrix)] <- NA
zeilen_summe <- rowSums(gewichtungs_matrix,  na.rm=TRUE)
zeilen_summe


## ----distanz-ngb, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,fig.retina = 1----

# Extraktion der Koordinaten aus nut3_kreise
coords <- coordinates(as(nuts3_kreise,"Spatial"))

# berechne alle Distanzen für die Flächenschwerpunkte der Kreise
knn2nb = knn2nb(knearneigh(coords))

# erzeuge die Distanzen für die LAnd-Kreise
kreise_dist <- unlist(nbdists(knn2nb, coords))
summary(kreise_dist)

# Extraktion der Kreisnamen
rn <- row.names(nuts3_kreise)

# berechne die Nachbarschaften für alle Kreise < mean 3. Quartil und Max Wert
nachbarschaft_mean <- dnearneigh(coords, 0, summary(kreise_dist)[4], row.names=rn)
nachbarschaft_max <- dnearneigh(coords, 0, summary(kreise_dist)[6], row.names=rn)
nachbarschaft_thirdQ <- dnearneigh(coords, 0, summary(kreise_dist)[5], row.names=rn)

# Plotten der drei Distanzen
par(mfrow=c(1,3), las=1)
# Maxwert
plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Nachbarkreise näher ",round(summary(kreise_dist)[6],0) ," km", sep=""))
plot(nachbarschaft_max, lwd =1,coords, add=TRUE,col="green")

# 3. Quartil
plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Nachbarkreise näher ",round(summary(kreise_dist)[5],0) ," km", sep=""))
plot(nachbarschaft_thirdQ, lwd = 2, coords, add=TRUE,col="red")

# Mittelwert
plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Nachbarkreise näher ",round(summary(kreise_dist)[4],0) ," km", sep=""))
plot(nachbarschaft_mean, lwd =3, coords, add=TRUE,col="blue")



## ----binary_ngb, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "1000px",out.height = "1000px",fig.retina = 1----
# Berchnen einer binären Nachbarschaftsliste mit der vierer Nachbarschaft "rook" (=wueen="FALSE")
rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)

# Ableiten der Nachbarschaftsmatrix aus der zuvor erzeugten Liste
rook_ngb_matrix = nb2mat(rook, style='B', zero.policy = TRUE)

# Berechne die Anzahl der Nachbarn für jedes Gebiet
anzahl_nachbarn <- rowSums(rook_ngb_matrix)

# Berechne die Anzahl der Nachbarn als Prozentsatz
prozentzahl_nachbarn  = round(100 * table(anzahl_nachbarn) / length(anzahl_nachbarn), 1)

# Plotten der Ergebnisse
plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Binary neighbours", sep=""))
coords <- coordinates(as(nuts3_kreise,"Spatial"))
plot(rook, coords, col='red', lwd=2, add=TRUE)


## ----neareast_ngb, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.height = "1000px",fig.retina = 1----
rn <- row.names(nuts3_kreise)

# Berechne die 3 und 5 Nachbarschaften
kreise_dist_k3 <- knn2nb(knearneigh(coords, k=3, RANN=FALSE))
kreise_dist_k5 <- knn2nb(knearneigh(coords, k=5, RANN=FALSE))

# Plotten der Ergebnisse
par(mfrow=c(1,2),las=1)
plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Drei Nachbarkreise", sep=""))

plot(kreise_dist_k3, lwd = 1, coords, add=TRUE,col="blue")

plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Fünf Nachbarkreise", sep=""))

plot(kreise_dist_k5, lwd =1, coords, add=TRUE,col="red")



## ----moran_setup, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,fig.retina = 1----
# Berechnung der Nachbarschaft
nuts3_kreise_rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)
# Extraktion der Koordinaten
coords <- coordinates(as(nuts3_kreise,"Spatial"))

w_nuts3_kreise_rook =  nb2listw(nuts3_kreise_rook, style='B',zero.policy = TRUE)
m_nuts3_kreise_rook =   nb2mat(nuts3_kreise_rook, style='B', zero.policy = TRUE)
nuts3_gewicht <- mat2listw(as.matrix(m_nuts3_kreise_rook))


# lineares Modell Anteil Hochschulabschluss / ANteil Baugewerbe
lm_uni_bau = lm(nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, data=nuts3_kreise)
summary(lm_uni_bau)

# Extraktion der Residuen
residuen_uni_bau <- lm( nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, data=nuts3_kreise)$resid

# Moran I test rondomisiert und nicht randomisiert
m_nr_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=FALSE)
m_r_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=TRUE)
m_r_residuen_uni_bau



## ----moran_plot, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "800px",out.height = "800px",fig.retina = 1----

moran.plot (residuen_uni_bau, nuts3_gewicht)


