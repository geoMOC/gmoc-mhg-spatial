#-------------------------------------------------------------------------------
# skript_sitzung_3_1.R 
# Autor: Chris Reudenbach, creuden@gmail.com
# Urheberrecht: Chris Reudenbach 2021 GPL (>= 3)
#
# Beschreibung: Das vorliegende Skript zeigt exemplarisch die Handhabung der 
#               Mikrozensusdaten. Zunächst werden die Daten falls nicht bereis geschehen über das Skript 
#               skript_sitzung_2_0.R mit dem Schalter auswahl = "mikrozensus" heruntergeladen
#               Dann in eine sqlite Datenbank übertragen, bzw. Verschiedene Operationen auf Kreis und Gemeindedaten
#               durchgeführt
#              
#
# Eingabe:      URLs für:
#                        - Mikrozensus Daten (www.zensus2011.de), 
#                        - NUTS Geometrien in einem GDAL kompatiblen Dateiformat,
#                        - Gemeinde-Geometrien in einem GDAL kompatiblen Dateiformat
#               
#
# Ausgabe:      Simple Feature (sf) Vektordaten-Objekte
#               sqlite Datenbanken 
#
# Anmerkungen:  Das Beispiel dient als Vorlage für ein typisches Echt-Welt-Szenario 
#               da offizielle/gültige Daten immer von den zuständigen 
#               Behörden/Institutionen bezogen und für die eigene Datenauswertung
#               eingelesen und gesäubert werden müssen.
#
#               Die Beispiele bauen aufeinander auf d.h. verschiedene Variablen werden
#               in den Beispielen zuvor erzeugt
#-------------------------------------------------------------------------------



# 0 - Umgebung einrichten, 
#     Pakete und Funktionen laden
#     Variablen definieren
#---------------------

#-- Säubern der Arbeitsumgebung
rm(list=ls())
# rootDIR enthält nur den Dateipfad, 
# die Tilde ~ steht dabei für das Nutzer-Home-Verzeichnis unter Windows 
# üblicherweise Nutzer/Dokumente
# path.expand() erweitert den relativen Dateipfad 
# !dir.exists() überprüft ob der Pfad bereits existiert damit er falls nein angelegt werden kann
rootDIR=path.expand("~/Desktop/lehre/MHG_2021/sitzung2/")
if (!dir.exists(rootDIR)) dir.create(path.expand(rootDIR))
setwd(rootDIR)

# --- Schritt 2 Download und Vorbereitung der Geometriedaten
# Schalter auswahl = "NUTS"
auswahl = "NUTS"
source(paste("../skript_sitzung_2_0.R"))

auswahl = "bertel"
source(paste("../skript_sitzung_2_0.R"))

## laden der benötigten libraries
# wir definieren zuerst eine liste mit den Paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits installiert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("spdep","spatialreg","ineq","rnaturalearth",  "tidygeocoder","usedist","raster","kableExtra")
for (lib in libs){
  if(!lib %in% utils::installed.packages()){
    utils::install.packages(lib)
  }}
# nicht wundern lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package Namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))

# einlesen der nuts3_kreise 
nuts3_kreise = nuts3_3035

# Erzeugen einer Hessen Geometrie für die Gemeinden
gemeinden_hessen_sf_3035 = gemeinden_sf_3035 %>% filter(SN_L=="06")

# merge der Gemeindegeometrien mit den aktuellen Datentabellen über die Spalte GEN
Bertel_HESSEN= right_join(gemeinden_hessen_sf_3035 , gemeinde_tab_all)
Kriftel_9000 = st_intersects(st_buffer(st_centroid((Bertel_HESSEN[Bertel_HESSEN$GEN=="Kriftel",])), 9000),Bertel_HESSEN)
mapview(Bertel_HESSEN[Kriftel_9000[[1]],])
Kriftel=Bertel_HESSEN[Kriftel_9000[[1]],]

# Normalverteilte Erzeugung von zufälligen Koordinatenpaaren
# in der Ausdehnung der nuts3_kreise Daten
# mit cbind() wird die einzelne Zahl des Breiten und des
# Längengrads in zwei verbundene Spalten geschrieben
# runif(10000,) erzeugt 10000 Zahlen innerhalb der Werte st_bbox()
xy <- cbind(x=runif(10000, st_bbox(nuts3_kreise)[1], st_bbox(nuts3_kreise)[3]), y=runif(10000, st_bbox(nuts3_kreise)[2], st_bbox(nuts3_kreise)[4]))

# Normalverteilte Erzeugung von Einkommensdaten
income <- (runif(10000) * abs((xy[,1] - (st_bbox(nuts3_kreise)[1] - st_bbox(nuts3_kreise)[3])/2) * (xy[,2] - (st_bbox(nuts3_kreise)[2] - st_bbox(nuts3_kreise)[4])/2))) / 500000000


## ----zone_result, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "1000px",out.height = "550px",fig.retina = 1----

# Festlegen der Grafik-Ausgabe
par(mfrow=c(1,3), las=1)
# Plot der sortieren Einkommen
plot(sort(income), col=rev(terrain.colors(500)), pch=20, cex=.75, ylab='income')

# Histogramm der Einkommensverteilung 
hist(income, main='', col=rev(terrain.colors(10)),  xlim=c(0,150000), breaks=seq(0,150000,10000))

# Räumlicher Plot der Haushalte, Farbe und Größe markieren das Einkommen
plot(xy, xlim=c(st_bbox(nuts3_kreise)[1], st_bbox(nuts3_kreise)[3]), ylim=c(st_bbox(nuts3_kreise)[2], st_bbox(nuts3_kreise)[4]), cex=income/100000, col=rev(terrain.colors(50))[(income+1)/1200], xlab="Rechtwert",ylab="Hochwert" )



## ----lorenz, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE, out.width = "400px",out.height = "400px",fig.retina = 1----
# Berechnung Gini Koeffizient
ineq(income,type="Gini")

## [1] 0.3993752

# Plot der Lorenz Kurve
par(mfrow=c(1,1), las=1)
plot(Lc(income),col="darkred",lwd=2)


## ----zone_raster, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE----
# create different sized and numbered regions
r1 <- raster(ncol=1, nrow=4, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r1 <- rasterize(xy, r1, income, mean)
r2 <- raster(ncol=4, nrow=1, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r2 <- rasterize(xy, r2, income, mean)
r3 <- raster(ncol=2, nrow=2, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r3 <- rasterize(xy, r3, income, mean)
r4 <- raster(ncol=3, nrow=3, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r4 <- rasterize(xy, r4, income, mean)
r5 <- raster(ncol=5, nrow=5, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r5 <- rasterize(xy, r5, income, mean)
r6 <- raster(ncol=10, nrow=10, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r6 <- rasterize(xy, r6, income, mean)
r7 <- raster(ncol=20, nrow=20, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r7 <- rasterize(xy, r7, income, mean)
r8 <- raster(ncol=50, nrow=50, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
r8 <- rasterize(xy, r8, income, mean)
r9 <- raster(ncol=100, nrow=100, xmn=st_bbox(nuts3_kreise)[1], xmx=st_bbox(nuts3_kreise)[3], ymn=st_bbox(nuts3_kreise)[2], ymx=st_bbox(nuts3_kreise)[4], crs=NA)
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
# 2) für jeden Namen (X) in der Liste wird mit geo() die
# Koordinate ermittelt $lat $long und in einen sf-Punkt Objekt mit (crs = 4326) konvertiert
# 3)Anfügen des Namens an das Koordinatenpaar
# 4) rbind()fügt die einzlnen listen zu einer MAtrix zusammen
geo_coord_city = do.call("rbind", lapply(staedte, function(x){
  p = st_sfc(st_point(c(geo(x,method = "osm")$long,geo(x,method = "osm")$lat)), crs = 4326)
  st_sf(name = x,p)
}))


# visualize with mapview
mapview(geo_coord_city,  color='red',legend = FALSE)


## ----points-2, echo=TRUE, message=FALSE, warning=FALSE, results=TRUE,out.width = "800px",out.height = "600px",fig.retina = 1----

# klassisches Plotten eines sf Objects  erfordert den Zugriff auf die Koordinatenpaare
# mit Hilfe der Funktion st_coordinates(geo_coord_city) leicht möglich
# schliesslich wird mit der Funktion text() die Beschriftung hinzugefügt
## mit Hilfe der Funktion min(st_coordinates(geo_coord_city)[,1]) werden 
## minimum und maximum Ausdehnung bestimmt 
## xlim und ylim sind die Minimum und Maximum Koordinaten der Plotausdehnung
## das dient nur der Möglichkeit die Städtenamen nicht abzuschneiden
xlim = c(min(st_coordinates(geo_coord_city)[,1])  - 1
         ,max(st_coordinates(geo_coord_city)[,1]) + 1)
ylim = c(min(st_coordinates(geo_coord_city)[,2])  - 1
         ,max(st_coordinates(geo_coord_city)[,2]) + 1)

plot(st_coordinates(geo_coord_city),
     pch=20, cex=1.5, col='darkgreen', xlab='Längengrad', ylab='Breitengrad',xlim=xlim)
text(st_coordinates(geo_coord_city), labels = staedte, cex=1.2, pos=4, col="purple")


# Projektion auf  ETRS89/UTM
proj_coord_city = st_transform(geo_coord_city, crs = 25832)

# Distanzberechnung
city_distanz = dist(st_coordinates(proj_coord_city))
# mit Hilfe von dist_setNames können wir die Namen der distanzmatrix zuweisen
dist_setNames(city_distanz, staedte)
# Runden auf Meter
round(city_distanz,0)


# Erweitern zu einer vollständigen Matrix
city_distanz <- as.matrix(city_distanz)
rownames(city_distanz)=staedte
colnames(city_distanz)=staedte


# Ausgabe einer hübscheren Tabelle mit kintr::kable 
# die Notation mit ist das sogennante "pipen" aus der tidyverse Welt
# hier werden die Daten und Verarbeitungsschritte von der erstenVariable in
# die nächste weitergeleitet
knitr::kable(city_distanz) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

# Distanzmatrix für Entfernungen > 250 km
cd_250km = city_distanz  < 250000

# Ausgabe einer hübscheren Tabelle mit kintr::kable
knitr::kable(cd_250km) %>% 
  kable_styling(bootstrap_options = "striped", full_width = F)

# inverse Distanz
inverse_distanz =  (1 / city_distanz)

# inverse Distanz zum Quadrat
inverse_distanz_q =  (1 / city_distanz ** 2)


# Ausgabe einer hübscheren Tabelle mit kintr::kable die Notation ist das sogenannte pipen aus der tidyverse Welt
knitr::kable(inverse_distanz) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

# löschen der Inf Werte die durch den Selbstbezug der Punkte entstehen
inverse_distanz <- as.matrix(inverse_distanz)
rownames(inverse_distanz)=staedte
colnames(inverse_distanz)=staedte

inverse_distanz[!is.finite(inverse_distanz)] <- 0

# Ausgabe einer hübscheren Tabelle mit kintr::kable die Notation ist das sogenannte pipen aus der tidyverse Welt
knitr::kable(inverse_distanz) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

zeilen_summe <- rowSums(inverse_distanz,  na.rm=TRUE)
zeilen_summe


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

rn <- row.names(nuts3_kreise)

# Berechne die 3 und 5 Nachbarschaften
kreise_dist_k3 <- knn2nb(knearneigh(coords, k=3))
kreise_dist_k5 <- knn2nb(knearneigh(coords, k=5))
##
par(mfrow=c(1,2),las=1)
plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Drei Nachbarkreise", sep=""))

plot(kreise_dist_k3, lwd = 1, coords, add=TRUE,col="blue")

plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Fünf Nachbarkreise", sep=""))

plot(kreise_dist_k5, lwd =1, coords, add=TRUE,col="red")

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


nuts3_kreise_rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)

coords <- coordinates(as(nuts3_kreise,"Spatial"))

plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Binary neighbours", sep=""))
plot(nuts3_kreise_rook, coords, col='red', lwd=2, add=TRUE)


# für geneinden
h= Kriftel  %>% filter(Indikatoren=="Beschäftigungsquote (%)")
Kriftel_rook = poly2nb(h, row.names= Kriftel$GEN, queen=FALSE)#
w_Kriftel_rook =  nb2listw(Kriftel_rook, style='B',zero.policy = TRUE)
m_Kriftel_rook =   nb2mat(Kriftel_rook, style='B', zero.policy = TRUE)
Kriftel_gewicht <- mat2listw(as.matrix(m_Kriftel_rook))


# lineares Modell

# Filtern der Bevölkerung und Beschäftigungsquoten

Beschaeftgungsquote_2006    =   (Kriftel  %>% filter(Indikatoren=="Beschäftigungsquote (%)"))[,30]
Frauenbeschaeftigungsquote_2006 = (Kriftel  %>% filter(Indikatoren=="Frauenbeschäftigungsquote (%)"))[,30]
  lm_2006 = lm(Beschaeftgungsquote_2006$`2006`  ~ Frauenbeschaeftigungsquote_2006$`2006`, data=Kriftel)
summary(lm_2006)



# Extraktion der Residuen
residuen_lm_2006 <- lm (lm (Beschäftgungsquote_2006$`2006` ~ Frauenbeschäftigungsquote_2006$`2006`, data=Kriftel))$resid

# Moran I test rondomisiert und nicht randomisiert
m_nr_residuen_lm_2006 = moran.test(residuen_lm_2006 , Kriftel_gewicht,randomisation=FALSE)
m_r_residuen_lm_2006  = moran.test(residuen_lm_2006 , Kriftel_gewicht,randomisation=TRUE)
summary(residuen_lm_2006 )



moran.plot (residuen_lm_2006 , Kriftel_gewicht)


