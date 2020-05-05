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
libs= c("sf","mapview","tmap","ggplot2","RColorBrewer","jsonlite","tidyverse","spdep","spatialreg","ineq","rnaturalearth", "rnaturalearthhires", "tidygeocoder","usedist","raster","kableExtra")
for (lib in libs){
  if(!lib %in% utils::installed.packages()){
    utils::install.packages(lib)
  }}
# nicht wundern lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package Namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))


## ----zones, echo=TRUE, message=FALSE, warning=FALSE, out.width="800px", results=TRUE----
rootDIR="~/Schreibtisch/spatialstatSoSe2020/"
# einlesen der nuts3_kreise 
nuts3_kreise = readRDS(file.path(rootDIR,"nuts3_kreise.rds"))

# für die Reproduzierbarkeit der Ergebnisse muss ein beliebiger `seed` gesetzt werden
set.seed(0) 


# Normalverteilte Erzeugung von zufälligen Koordinatenpaaren
# in der Ausdehnung der nuts3_kreise Daten
# mit cbind() wird die einzelne Zahl des Breiten und des
# Längengrads in zwei verbundene Spalten geschrieben
# runif(10000,) erzeugt 10000 Zahlen innerhalb der Werte extent()
xy <- cbind(x=runif(10000, extent(nuts3_kreise)[1], extent(nuts3_kreise)[3]), y=runif(10000, extent(nuts3_kreise)[2], extent(nuts3_kreise)[4]))

# Normalverteilte Erzeugung von Einkommensdaten
income <- (runif(10000) * abs((xy[,1] - (extent(nuts3_kreise)[1] - extent(nuts3_kreise)[3])/2) * (xy[,2] - (extent(nuts3_kreise)[2] - extent(nuts3_kreise)[4])/2))) / 500000000


## ----zone_result, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "1000px",out.height = "550px",fig.retina = 1----

# Festlegen der Grafik-Ausgabe
par(mfrow=c(1,3), las=1)
# Plot der sortieren Einkommen
plot(sort(income), col=rev(terrain.colors(500)), pch=20, cex=.75, ylab='income')

# Histogramm der Einkommensverteilung 
hist(income, main='', col=rev(terrain.colors(10)),  xlim=c(0,150000), breaks=seq(0,150000,10000))

# Räumlicher Plot der Haushalte, Farbe und Größe markieren das Einkommen
plot(xy, xlim=c(extent(nuts3_kreise)[1], extent(nuts3_kreise)[3]), ylim=c(extent(nuts3_kreise)[2], extent(nuts3_kreise)[4]), cex=income/100000, col=rev(terrain.colors(50))[(income+1)/1200], xlab="Rechtwert",ylab="Hochwert" )



## ----lorenz, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE, out.width = "400px",out.height = "400px",fig.retina = 1----
# Berechnung Gini Koeffizient
ineq(income,type="Gini")

## [1] 0.3993752

# Plot der Lorenz Kurve
par(mfrow=c(1,1), las=1)
plot(Lc(income),col="darkred",lwd=2)


## ----zone_raster, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# create different sized and numbered regions
r1 <- raster(ncol=1, nrow=4, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r1 <- rasterize(xy, r1, income, mean)
r2 <- raster(ncol=4, nrow=1, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r2 <- rasterize(xy, r2, income, mean)
r3 <- raster(ncol=2, nrow=2, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r3 <- rasterize(xy, r3, income, mean)
r4 <- raster(ncol=3, nrow=3, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r4 <- rasterize(xy, r4, income, mean)
r5 <- raster(ncol=5, nrow=5, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r5 <- rasterize(xy, r5, income, mean)
r6 <- raster(ncol=10, nrow=10, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r6 <- rasterize(xy, r6, income, mean)
r7 <- raster(ncol=20, nrow=20, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r7 <- rasterize(xy, r7, income, mean)
r8 <- raster(ncol=50, nrow=50, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r8 <- rasterize(xy, r8, income, mean)
r9 <- raster(ncol=100, nrow=100, xmn=extent(nuts3_kreise)[1], xmx=extent(nuts3_kreise)[3], ymn=extent(nuts3_kreise)[2], ymx=extent(nuts3_kreise)[4], crs=NA)
r9 <- rasterize(xy, r9, income, mean)


## ----plot_zone_raster, echo=TRUE, message=FALSE, warning=FALSE, results=FALSE,out.width = "1100px",out.height = "900px",fig.retina = 1----
# Festlegen der Grafik-Ausgabe
par(mfrow=c(3,3), las=1)

# Plotten der 9 Regionen
# in main wird der Titel für jede Grafik definiert
plot(r1,main="ncol=1, nrow=4"); plot(r2,main="ncol=4, nrow=1");
plot(r3,main="ncol=2, nrow=2"); plot(r4,main="ncol=3, nrow=3");
plot(r5,main="ncol=5, nrow=5"); plot(r6,main="ncol=10,nrow=10");
plot(r7,main="ncol=20, nrow=20");plot(r8,main="ncol=50, nrow=50");
plot(r9,main="ncol=100, nrow=100")


## ----zone_hist, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,fig.retina = 1----

# Festlegen der Grafik-Ausgabe
par(mfrow=c(3,3), las=1)

# Plotten der zugehörigen Histogramme
hist(r1, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r2, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r3, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r4, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r5, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r6, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r7, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r8, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))
hist(r9, main='', col=rev(terrain.colors(10)), xlim=c(0,125000), breaks=seq(0, 125000, 12500))



## ----points_0, echo=TRUE, message=FALSE, warning=FALSE, results=FALSE,out.width = "800px",out.height = "600px",fig.retina = 1----
# Erzeugen von beliebigen Raumkoordinaten 
# mit Hilfe von tidygeocoder::geo_osm und sf
# Städteliste
staedte=c("München","Berlin","Hamburg","Köln","Bonn","Hannover","Nürnberg","Stuttgart","Freiburg","Marburg")

# Abfragen der Geokoordinaten der Städte mit eine lapply Schleife
# 1) die Stadliste wird in die apply Schleife (eine optimierte for-Schleife) eingelesen
# 2) für jeden Namen (X) in der Liste wird mit geo_osm die
# Koordinate ermittelt Die in eckigen Klammern angegebne Position 2
# ist die Latitude  (geo_osm(x)[2]) [1] enstprechend die Longitude
# 3) Umwandlung in numerische Werte
# 4) Jedes latlon Paar wird in einen sf-Punkt konvertiert und
# gleichzeitig das korrekte Georefrenzierungssystem zugewiesen (cres = 4326)
# 5) Zuletzt werden an die Koordinatenpaare die Städtenamen angehangen
coord_city = lapply(staedte, function(x){
  latlon = c(geo_osm(x)[2],geo_osm(x)[1])
  class(latlon) = "numeric"
  p = st_sfc(st_point(latlon), crs = 4326)
  st_sf(name = x,p)
})

# Umwandeln der aus der lapply Schleife zurückgegebnen Liste in eine Matrix 
geo_coord_city = do.call("rbind", coord_city)

# visualize with mapview
mapview(geo_coord_city,  color='red',legend = FALSE)


## ----points-2, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "800px",out.height = "600px",fig.retina = 1----

# klassisches Plotten eines sf Objects  erfordert den Zugriff auf die Koordinatenpaare
# mit Hilfe der Funktion st_coordinates(geo_coord_city) leicht möglich
# schliesslich wird mit der Funktion text() die Beschriftung hinzugefügt
plot(st_coordinates(geo_coord_city),
     pch=20, cex=1.5, col='darkgreen', xlab='Längengrad', ylab='Breitengrad')
text(st_coordinates(geo_coord_city), labels = staedte, cex=1.2, pos=4, col="purple")


## ----r-train-2, echo=TRUE, message=FALSE, warning=FALSE---------------
## mit Hilfe der Funktion min(st_coordinates(geo_coord_city)[,1]) werden 
## minimum und maximum Ausdehnung bestimmt 
## xlim und ylim sind die Minimum und Maximum Koordinaten der Plotausdehnung

# xlim = c(min(st_coordinates(geo_coord_city)[,1])  - 0.5 
#         ,max(st_coordinates(geo_coord_city)[,1]) + 0.5)

# ylim = c(min(st_coordinates(geo_coord_city)[,2])  - 0.5
#         ,max(st_coordinates(geo_coord_city)[,2]) + 0.5)



## ----point_dist, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----

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



## ----table_2, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# Ausgabe einer hübscheren Tabelle mit kintr::kable 
# die Notation mit ist das sogennante "pipen" aus der tidyverse Welt
# hier werden die Daten und Verarbeitungsschritte von der erstenVariable in
# die nächste weitergeleitet

knitr::kable(city_distanz) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


## ----matrix_operand, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# Distanzmatrix für Entfernungen > 250 km
cd = city_distanz  < 250000


## ----table_3, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# Ausgabe einer hübscheren Tabelle mit kintr::kable die Notation ist das sogenannte pipen aus der tidyverse Welt
knitr::kable(cd) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


## ----weight, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# inverse Distanz
gewichtungs_matrix =  (1 / city_distanz)


## ----invdist, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# inverse Distanz zum Quadrat
gewichtungs_matrix_q =  (1 / city_distanz ** 2)



## ----table_4, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# Ausgabe einer hübscheren Tabelle mit kintr::kable die Notation ist das sogenannte pipen aus der tidyverse Welt
knitr::kable(gewichtungs_matrix) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


## ----linnorm, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# löschen der Inf Werte die durch den Selbstbezug der Punkte entestehen
gewichtungs_matrix <- as.matrix(gewichtungs_matrix)
rownames(gewichtungs_matrix)=staedte
colnames(gewichtungs_matrix)=staedte

gewichtungs_matrix[!is.finite(gewichtungs_matrix)] <- NA
zeilen_summe <- rowSums(gewichtungs_matrix,  na.rm=TRUE)
zeilen_summe


## ----binary_ngb, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "1000px",out.height = "1000px",fig.retina = 1----
rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)
rook_ngb_matrix = nb2mat(rook, style='B', zero.policy = TRUE)

# Berechne die Anzahl der Nachbarn für jedes Gebiet
anzahl_nachbarn <- rowSums(rook_ngb_matrix)

# als prozentsatz
prozentzahl_nachbarn  = round(100 * table(anzahl_nachbarn) / length(anzahl_nachbarn), 1)

plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Binary neighbours", sep=""))
coords <- coordinates(as(nuts3_kreise,"Spatial"))
plot(rook, coords, col='red', lwd=2, add=TRUE)


## ----neareast_ngb, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.height = "1000px",fig.retina = 1----
rn <- row.names(nuts3_kreise)

# Berechne die 3 und 5 Nachbarschaften
kreise_dist_k3 <- knn2nb(knearneigh(coords, k=3, RANN=FALSE))
kreise_dist_k5 <- knn2nb(knearneigh(coords, k=5, RANN=FALSE))
##
par(mfrow=c(1,2),las=1)
plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Drei Nachbarkreise", sep=""))

plot(kreise_dist_k3, lwd = 1, coords, add=TRUE,col="blue")

plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Fünf Nachbarkreise", sep=""))

plot(kreise_dist_k5, lwd =1, coords, add=TRUE,col="red")



## ----distanz-ngb, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,fig.retina = 1----
# berechne alle Distanzen für die Flächenschwerpunkte der Kreise
knn2nb = knn2nb(knearneigh(coords))

# erzeuge die Kreisdistanzen
kreise_dist <- unlist(nbdists(knn2nb, coords))
summary(kreise_dist)

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



## ----moran_setup, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,fig.retina = 1----
nuts3_kreise_rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)

coords <- coordinates(as(nuts3_kreise,"Spatial"))

plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Binary neighbours", sep=""))
plot(nuts3_kreise_rook, coords, col='red', lwd=2, add=TRUE)


## ----moran, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE-----
nuts3_kreise_rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)
w_nuts3_kreise_rook =  nb2listw(nuts3_kreise_rook, style='B',zero.policy = TRUE)
m_nuts3_kreise_rook =   nb2mat(nuts3_kreise_rook, style='B', zero.policy = TRUE)
nuts3_gewicht <- mat2listw(as.matrix(m_nuts3_kreise_rook))


# lineares Modell
lm_uni_bau = lm(nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, data=nuts3_kreise)
summary(lm_uni_bau)


## ----residuen, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----

# Extraktion der Residuen
residuen_uni_bau <- lm (lm ( nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, data=nuts3_kreise))$resid

# Moran I test rondomisiert und nicht randomisiert
m_nr_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=FALSE)
m_r_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=TRUE)
m_r_residuen_uni_bau


## ----moran_plot, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "800px",out.height = "800px",fig.retina = 1----

moran.plot (residuen_uni_bau, nuts3_gewicht)


