---
title: "Sitzung 2: -  Region, Distanz und räumlicher Einfluß"
---



Geodaten sind prinzipiell wie gewöhnliche Daten. Allerdings sind die Aspekte, die bei der Verwendung von Geodaten zu beachten sind auf Fragen der Skala, der Zonierung (aggregierte  Flächeneinheiten) der Topologie (der Lage im Verhältnis zu anderen Entitäten) und am einfachsten der Entfernung zueinander. <!--more-->

Dies berührt fragen der der räumlichen Autokorrelation und Inhomogenität, also letztlich der Konzeption auf welcher Skala hat Raum einen Einfluss.

Die klassischen Bereiche der räumlichen Statistik sind Punktmusteranalyse, Regression und Inferenz mit räumlichen Daten, dann die Geostatistik (Interpolation z.B. mit Kriging) sowie  Methoden zur lokalen und globalen Regression und Klassifikation mit räumlichen Daten.


## Lernziele

Die Lernziele der zweiten Übung sind:

---

  * Verständnis für die konzeptionellen Hintergründe der Begriffe Region, Distanz und räumlicher Einfluss bezogen auf die jeweilig verfügbaren Datenmodelle
  * 

 
---

## Zonierung

Die Analyse der räumlichen Daten erfolgt oft in regionaler oder Aggregierung. Auch wenn alle am Liebsten Daten auf einer möglichst hoch aufgelösten Ebene verfügbar hätten (im besten Fall Einzelpersonen, Haushalte, Grundstücke, Briefkästen etc.) ist der Regelfall, dass es sich um räumlich (und zeitlich) aggregierte  Daten handelt. Statt tägliche Daten über den Cornfllakes-Kosum in jeden Haushalt haben wir den  Jahresmittelwert aller verkauften Zerealien in einem Bundesland. So geht das mit den meisten Daten, die zudem oft unterschiedlich aggregiert sind wo in Europa z.B. nationale und subnationale Einheiten (z.B. NUTS1, NUTS3, NUTS3, AMR etc.) vorliegen. Häufig gibt es auch räumliche Datensätze die in Form von Rasterzellenwerten quasi-kontinuierlich vorliegen.

Bei der visuellen Exploration aber auch bei der statistischen Analyse ist es von erheblichem Einfluss wie die Gebiete zur Aggregation der Daten geschnitten sind. Da dieser Zusammenhang eher willkürlich (auch oft historisch oder durch wissenschaftlich begründet) ist, sind die Muster, die wir sehen äußerst subjektiv. Dieses sogenannte *Problem der veränderbaren Gebietseinheit* (Modifiable Areal Unit Problem, MAUP) bezeichnet. Der Effekt von höheren Einheiten auf niedrigere zu schließen ist hingegen als *ökologische Inferenz* (Ecological Inference) bekannt.

Betrachten wir diese Zusammenhänge einmal ganz praktisch (siehe hierzu auch Robert Hijmans [Spatial Data Analysis](https://rspatial.org/raster/analysis/2-scale_distance.html)):

Um den Zusammenhang von Zonierung und Aggregation grundsätzlich zu verstehen erzeugen wir einen synthesischen Datensatz, der eine *Region* (angenommen wird die gesamte Ausdehnung Deutschlands) mit 10000 *Haushalten* enthält. Für jeden Haushalt ist der Ort und sein Jahreseinkommen bekannt. In einem nächsten Schritt werden die Daten in unterschiedliche Zonen aggregiert. Zunächst werden die `nuts3_kreise` eingeladen. Sie dienen der Georefrenzierung der Beispiel-Daten. Zunächst wir ein Datensatz von 10k zufällig über dem Gebiet Deutschlands verteilter Koordinaten erzeugt. Diesem werden dann zufällige Einkommensdaten zu-gewürfelt.


```r
# einlesen der nuts3_kreise 
loadRDS("nuts3_kreise.rds")

# für die reproduzierbarkeit der Ergebnisse muss ein beliebiger seed gesetzt werden
set.seed(0)

# Normalverteilte Erzeugung von zufälligen der Koordinatenpaaren
# im Range der Ausdehnung der nuts3_kreise Daten
xy <- cbind(x=runif(10000, extent(nuts3_kreise)[1], extent(nuts3_kreise)[3]), y=runif(10000, extent(nuts3_kreise)[2], extent(nuts3_kreise)[4]))

# Normalverteilte Erzeugung Einkommensdaten
income <- (runif(10000) * abs((xy[,1] - (extent(nuts3_kreise)[1] - extent(nuts3_kreise)[3])/2) * (xy[,2] - (extent(nuts3_kreise)[2] - extent(nuts3_kreise)[4])/2))) / 500000000
```
Nachdem die Daten erzeugt wurden, schauen wir und die akkumulierte, klassifizierte und räumliche Verteilung der Daten an.

```r
# Festlegen der Grafik-Ausgabe
par(mfrow=c(1,3), las=4)
# Plot der sortieren Einkommen
plot(sort(income), col=rev(terrain.colors(500)), pch=20, cex=.75, ylab='income')

# Histogramm der Einkommensverteilung 
hist(income, main='', col=rev(terrain.colors(10)),  xlim=c(0,150000), breaks=seq(0,150000,10000))

# Räumlicher Plot der Haushälte Farbe und Größe markieren das Einkommen
plot(xy, xlim=c(extent(nuts3_kreise)[1], extent(nuts3_kreise)[3]), ylim=c(extent(nuts3_kreise)[2], extent(nuts3_kreise)[4]), cex=income/100000, col=rev(terrain.colors(50))[(income+1)/1200], xlab="Rechtwert",ylab="Hochwert" )

```
![Verteilungen]({{ site.baseurl }}/assets/images/unit04/verteilung.png){:target="_blank"}

*Abbildung 04-02-01: Die sortierte, aggregierte und räumliche Einkommensverteilung*


Gini Koeffizient und Lorenzkurve sind ein gutes Maß erstes MAß und die Ungleichheit einer Verteilung zu zeigen.

```r
# Berechnung Gini Koeffizient
ineq(income,type="Gini")

## [1] 0.3993752

# Plot der Lorenz Kurve
par(mfrow=c(1,1), las=1)
plot(Lc(income),col="darkred",lwd=2)
```
![Lorenz Kurve]({{ site.baseurl }}/assets/images/unit04/gini.png){:target="_blank"}

*Abbildung 04-02-02: Lorenzkurve der Einkommensverteilung*


Um die Bedeutung unterschiedlicher Zonierungen in Bezug auf die aggregierten Daten zu zeigen werden mit Hilfe des `raster` Pakets neun unterschiedliche Zonierungen erzeugt. 

```r
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
```
Die geplotteten Bilder verdeutlichen wie die räumliche Anordnung der Zonen verteilt ist. Es handelt sich um 2 Streifenzonierungen und dann 7 unterschiedliche Gitter von  4x4, 5x5, 10x10, 20x20, 50x50 und 100x100 Zonen.

```r
# Festlegen der Grafik-Ausgabe
par(mfrow=c(3,3), las=1)

# Plotten der 9 Regionen
plot(r1,main="ncol=1, nrow=4"); plot(r2,main="ncol=4, nrow=1");
plot(r3,main="ncol=2, nrow=2"); plot(r4,main="ncol=3, nrow=3");
plot(r5,main="ncol=5, nrow=5"); plot(r6,main="ncol=10,nrow=10");
plot(r7,main="ncol=20, nrow=20");plot(r8,main="ncol=50, nrow=50");
plot(r9,main="ncol=100, nrow=100")
```
![3 x 3 Matrix Zonen]({{ site.baseurl }}/assets/images/unit04/zonen_3_3.png){:target="_blank"}

*Abbildung 04-02-03: 3x3 Matrix der unterschiedlichen Zonen-Anordnungen*


Wenn man nun die korrespondierenden zonalen Histogramme anschaut, wird deutlich wie sehr eine Zonierung die Verteilung der Ergebnisse im Raum beinflusst.

```r

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

```
![3 x 3 Matrix Einkommensverteilung]({{ site.baseurl }}/assets/images/unit04/histogram_3_3.png){:target="_blank"}

*Abbildung 04-02-04: 3x3 Matrix der unterschiedlichen Zonen-Histogramme*



## Distanz

Als Distanz wird die Entfernung von zwei Positionen bezeichnet. Sie kann zunächst einmal als ein zentrales Konzept der Geographie angenommen werden. Erinnern sie sich an Waldo Toblers ersten Satz zur Geographie, dass "*alles mit allem anderen verwandt ist, aber nahe Dinge mehr verwandt sind als ferne Dinge*".  Die Entfernung ist scheinbar sehr einfach zu bestimmen. Natürlich können wir die Entfernung auf eine isometrischen und isomorhpen Fläche mittels der "*Luftlinie*" (euklidische Distanz) berechnen. Zentrales Prblem ist das diese Betrachtung häufig wenn in der Regel nicht relevant ist. Es gibt nicht nur (nationale) Grenzen, Gebirge oder beliebige andere Hindernisse, die Entfernung zwischen A und B kann auch asymmetrisch sein (bergab gehts einfacher und  schneller bergauf). Das heisst Distanzen können über *Kosten* gewichtet werden.

Üblicherweise werden Distanzen in einer "Distanzmatrix" dargestellt. Eine solche Matrix enthält als Spaltenüberschriften und als Zeilenbeschriftung die Kennung von jedem berechnteten Ort. Im jedem Feld wird die Entfernung eingetragen. Für kartesische Koordinaten erfölgt dies einfach über den Satz des Pythagoras.

Betrachten wir diese Zusammenhänge einmal ganz praktisch:

Wir erstellen für eine Anzahl Punkte eine Distanzmatrix. Wenn die Positionen in Länge/Breite angegeben sind wird es deutlich aufwendiger. In diesem Fall können wir die Funktion `pointDistance` aus dem `raster` Paket verwenden (allerdings nur wenn das Koordinatensystem korrekt angegeben wird). Eleganter ist jedoch die Erzeugung von Punktdaten als `sf` Objekt. Es ist leicht möglich  beliebige reale Punktdaten mit Hilfe des `tidygeocoder` Pakets zu erzeugen.Wir geben lediglich eine Städte oder Adressliste an:

```r
# Erzeugen von beliebigen Punkten mit Hilfe von tidygeocoder
# Städteliste
staedte=c("München","Berlin","Hamburg","Köln","Bonn","Hannover","Nürnberg","Stuttgart","Freiburg","Marburg")

# Abfragen der Geokoordinaten der Städte mit eine lapply Schleife
 coord_city = lapply(staedte, function(x){
 latlon = c(geo_osm(x)[2],geo_osm(x)[1])
 class(latlon) = "numeric"
  p = st_sfc(st_point(latlon), crs = 4326)
 st_sf(name = x,p)
 #st_sf(p)
 })
 
# Umwandeln der Liste in eine Matrix mit den Stadtnamen und Spalten die Lat Lon benannt sind
 geo_coord_city = do.call("rbind", coord_city)

# plotten der Punkte
 mapview(geo_coord_city,  color='red',legend = FALSE)

# Festlegen der Grafik-Ausgabe
 par(mfrow=c(1,1), las=1)
# klassisches Ploten eines sf Objects  erfordert den Zugriff auf die Koordinatenpaare
# mit Hilfe der Funktion st_coordinates(geo_coord_city) leicht möglich
# mit Hilfe der Funktion min(st_coordinates(geo_coord_city)[,1]) werden 
# minimum und maximum Ausdehnung bestimmt 
 plot(st_coordinates(geo_coord_city),
     xlim = c(min(st_coordinates(geo_coord_city)[,1]) - 0.5 
     ,max(st_coordinates(geo_coord_city)[,1]) + 1), 
     ylim = c(min(st_coordinates(geo_coord_city)[,2]) - 0.5
     ,max(st_coordinates(geo_coord_city)[,2]) + 0.5),
     pch=20, cex=2, col='red', xlab='Längengrad', ylab='Breitengrad')
     with(text(st_coordinates(geo_coord_city), labels = staedte, pos =4))
```


```r
# nun berechnen wir die Distanzen
 proj_coord_city = st_transform(geo_coord_city, crs = 25832)
 city_distanz = dist(st_coordinates(proj_coord_city))
# mit Hilfe von dist_setNames können wir die Namen der distanzmatrix zuweisen
 dist_setNames(city_distanz, staedte)

city_distanz
#            München   Berlin  Hamburg     Köln     Bonn Hannover Nürnberg Stuttgart Freiburg
# Berlin    504156.6                                                                     Hamburg   # 611337.7 253841.6                                                              
# Köln      456511.6 477393.1 356810.5                                                   
# Bonn      434329.5 478145.8 370325.9  24607.7                                          
# Hannover  489061.8 248686.4 131348.9 249893.3 258162.1                                 
# Nürnberg  150928.4 377495.0 460900.6 337014.5 318118.3 338167.6                        
# Stuttgart 190926.8 511243.2 533104.9 288316.8 264173.9 401815.7 157508.4               
# Freiburg  278029.8 639022.5 635366.9 333440.4 309440.8 505124.9 287407.8  131404.0     
# Marburg   359924.1 371191.0 315365.1 128538.4 118421.0 186154.7 223271.1  227925.4 320161.6
```
Wir erzeugen aus der Distanz-Mtrix `class = dist` eine normale R-Matrix. Leider müssen dann die Namen wieder zugewiesen werden.
```r
# make a full matrix an
city_distanz <- as.matrix(city_distanz)
rownames(city_distanz)=staedte
colnames(city_distanz)=staedte
city_distanz
```

## Räumlicher Einfluß

Die beiden Aspelte zuvor haben die räumlichen Verhältnisse in Form von Raumabgrenzung und Distanz beschrieben. In der räumlichen Analyse ist es jedoch von zentraler Bedeutung den räumlichen **Einfluss** zwischen geographischen Objekten zu schätzen bzw. zu messen. Dies kann prozessorienteirt funktional erfolgen, der oberliegende Teil eines Baches fließt in den unterliegenden. In der datengetriebnen Betrachtungsweise ist dies in der Regel eine Funktion der *Nachbarschaft* oder der *(inversen) Entfernung*. Um damit in statistischen Modellen arbeiten zu können werden diese Konzepte als *räumliche Gewichtungsmatrix* ausgedrückt. 

Das generelle und schwerwiegende Problem ist, dass der räumliche Einfluss sehr komplex ist und faktisch nie gemessen werden kann. Daher gibt es zahllose Arten ihn zu schätzen. 

Zum Beispiel kann der räumliche Einfluss von Polygonen aufeinander (z.B, NUTS3 Verwaltungsbezirke) so ausgedrückt werden, dass sie eine/keine gemeinsame Grenze, sie kann als euklidische Distanz zwischen ihren Schwerpunkten bestimmt werden oder über die Länge gemeinsamer Grenzen gewichtet werden und so fort.

### Nachbarschaft

Die Nachbarschaft ist das vielleicht wichtigste Konzept. höherdimensionale Geoobjekte können als benachbart betrachtet werden wenn sie sich *berühren*, z.B. benachbarte Länder. Bei nulldimensionalen Objekten (Punkte) ist der gebräuchlichste Ansatz die Entfernung in Kombination mit einer Anzahl von Punkten für die Nachbarschaftsbestimmung zu nutzen.

Betrachten wir diese Zusammenhänge einmal ganz praktisch:

Wir erstellen eine Nachbarschaftsmatrix für die oben erzeugten Punktdaten. Punkte seien *benachbart*, wenn sie innerhalb eines Abstands von z.B.50 liegen.

```r
# Distanzmatrix für Entfernungen > 250 km
city_distanz  < 250000
```

```r
#          München Berlin Hamburg  Köln  Bonn Hannover Nürnberg Stuttgart Freiburg Marburg
# München      TRUE  FALSE   FALSE FALSE FALSE    FALSE     TRUE      TRUE    FALSE   FALSE
# Berlin      FALSE   TRUE   FALSE FALSE FALSE     TRUE    FALSE     FALSE    FALSE   FALSE
# Hamburg     FALSE  FALSE    TRUE FALSE FALSE     TRUE    FALSE     FALSE    FALSE   FALSE
# Köln        FALSE  FALSE   FALSE  TRUE  TRUE     TRUE    FALSE     FALSE    FALSE    TRUE
# Bonn        FALSE  FALSE   FALSE  TRUE  TRUE    FALSE    FALSE     FALSE    FALSE    TRUE
# Hannover    FALSE   TRUE    TRUE  TRUE FALSE     TRUE    FALSE     FALSE    FALSE    TRUE
# Nürnberg     TRUE  FALSE   FALSE FALSE FALSE    FALSE     TRUE      TRUE    FALSE    TRUE
# Stuttgart    TRUE  FALSE   FALSE FALSE FALSE    FALSE     TRUE      TRUE     TRUE    TRUE
# Freiburg    FALSE  FALSE   FALSE FALSE FALSE    FALSE    FALSE      TRUE     TRUE   FALSE
# Marburg     FALSE  FALSE   FALSE  TRUE  TRUE     TRUE     TRUE      TRUE    FALSE    TRUE
```
### Gewichtungs-Matrix für Punkte

Anstatt den räumlichen Einfluss als binären Wert (also topüologisch benachbart ja/nein) auszudrücken, kann er als kontinuierlicher Wert ausgedrückt werden. Der einfachste Ansatz ist die Verwendung des inversen Abstands (je weiter entfernt, desto niedriger der Wert).


```r
# inverse Distanz
gewichtungs_matrix =  (1 / city_distanz)


# inverse Distanz zum Quadrat
gewichtungs_matrix_q =  (1 / city_distanz ** 2)

```

Wie auch die *räumliche Gewichtung* wird die Matrix oft *zeilennormiert*, das heißt dass die Summe der Gewichte für jede Zeile (Position oder Wert der Position) in der Matrix gleich ist. 
```r
# löschen der Inf Werte die durch den Selbstbezug der Punkte entestehen
gewichtungs_matrix[!is.finite(gewichtungs_matrix)] <- NA
zeilen_summe <- rowSums(gewichtungs_matrix,  na.rm=TRUE)
zeilen_summe
```

```r
#      München        Berlin       Hamburg          Köln          Bonn      Hannover      Nürnberg     Stuttgart      Freiburg       Marburg 
# 0.00002839529 0.00002299421 0.00002748176 0.00006894169 0.00007021031 0.00003435182 0.00003481930   0.00003715831 0.00002915882 0.00004222911 

```
### Gewichtungs-Matrix für Polygone

#### Binäre 4-er Nachbarschaft

Die Gewichtungsmatrix für Polygone zu bestimmen ist natürlich etwas komplexer dafür gibt es allerdings mit `spdep` ein bewährtes Paket.

Die Funktion `poly2nb` kann unter anderem um eine *Rook* Nachbarschaftsliste erzeugen. Sie dient als Grundlage einer Nachbarschaftsmatrix.

```r
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
```

![Binäre 4-er Nachbarschaft]({{ site.baseurl }}/assets/images/unit04/binary_4-ngb.png){:target="_blank"}

*Abbildung 04-02-05: Binäre 4-er Nachbarschaft für die Landkreise Deutschlands*




#### Nearest-Distance Nachbarn

nachfolgend werden exemplarisch die 3 bzw. 5 nächsten Nachbarn zu einem Kreis ausgewiesen.

```r
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

```

![Nearest 3/5-er Nachbarschaft]({{ site.baseurl }}/assets/images/unit04/ngb_3_5.png) 

*Abbildung 04-02-06:Nearest 3-er/5-er Nachbarschaft für die Landkreise Deutschlands*




#### Distanz-basierte Nachbarschaft

nachfolgend wird für den Mittelwert, das dritte Quartil und den Maximalwert der Distanzverteilung aller Kreis-Zentroide die Nachbarschaft bestimmt.

```r
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

```
![Distanbasierte Nachbarschaften]({{ site.baseurl }}/assets/images/unit04/dist_ngb.png) 

*Abbildung 04-02-07: Distanzbasierte Nachbarschaften für die Landkreise Deutschlands, a) Nachbarschaften innerhalb der Maximaldistanz der Distanzmatrix, b) Nachbarschaften innerhalb der 3. Quartils der Distanzmatrix, c) b) Nachbarschaften innerhalb der Mittelwerts der Distanzmatrix*



## Räumliche Autokorrelation

Das Konzept der räumlichen Autokorrelation komplizierter als das der zeitlichen Autokorrelation räumliche Objekte haben in der Regel zwei Dimensionen und komplexe Formen aufweisen und daher Nähe unterschiedlich dimensional zusammenhängen kann.

Grundsätzlich beschreiben die räumlichen Autokorrelationsmaße die Ähnlichkeit, der  beobachteten Werte zueinander. Räumliche Autokorrelation entstehen durch Beobachtungen und Beobachtungen und Positionen/Objekte im Raum.

Die räumliche Autokorrelation in einer Variable kann exogen (sie wird durch eine andere räumlich autokorrelierte Variable verursacht, z.B. Niederschlag) oder endogen (sie wird durch den Prozess verursacht, der im Spiel ist, z.B. die Ausbreitung einer Krankheit) sein.

Eine häufig verwendete Statistik ist Moran's I und invers dazu  Geary's C. Binäre Daten werden mit dem Join-Count-Index getestet.

Nehmen wir die Daten aus dem Vorbeispiel.

```r
nuts3_kreise_rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)

# Berechne die Anzahl der Nachbarn für jedes Gebiet
anzahl_nachbarn <- rowSums(nuts3_kreise_rook)

plot(st_geometry(nuts3_kreise), border="grey", reset=FALSE,
     main=paste("Binary neighbours", sep=""))
coords <- coordinates(as(nuts3_kreise,"Spatial"))
plot(nuts3_kreise_rook, coords, col='red', lwd=2, add=TRUE)
```

## Moran's-I und Geary-C Test

Wie bereits bekannt ist hängt der Wert von Morans I deutlich von den Annahmen ab, die in die räumliche Gewichtungsmatrix verwendet werden. Die Idee ist, eine Matrix zu konstruieren, die Ihre Annahmen über das jeweilige räumliche Phänomen passend wiedergibt. Der übliche Ansatz besteht darin, eine Gewichtung von 1 zu geben, wenn zwei *Zonen* Nachbarn sind falls nicht wird eine 0 vergeben. Natürlich variiert die Definition von *Nachbarn* (vgl. Reader räumliche Konzepte und oben). Quasikontinuierlich ist der Ansatz eine inverse Distanzfuntion zur Bestimmung der Gewichte zu wverwenden. Auch wenn in der Praxis fast nie vorzufinden sollte die Auswahl räumlicher Gewichtungsmatritzen das betreffende Phänomen abbilden. So ist die Benachbarheit entlang von Autobahnen für Warentransporte anders zu gewichten als beispielsweise über ein Gebirge oder einen See.

Der Moran-I-Test und der Geary C Test sind übliche Verfahren für die Überprüfung räumlicher Autokorrelation. Das Geary's-C ist invers mit Moran's-I, aber nicht identisch. Moran's-I ist eher ein Maß für die globale räumliche Autokorrelation, während Geary's-C eher auf eine lokale räumliche Autokorrelation reagiert. 

\\[I = \frac{n}{\sum_{i=1}^{n}\sum_{j=1}^{n}w_{ij}}
   \frac{\sum_{i=1}^{n}\sum_{j=1}^{n}w_{ij}(x_i-\bar{x})(x_j-\bar{x})}{\sum_{i=1}^{n}(x_i - \bar{x})^2}\\]

\\[ C = \frac{(n-1)}{2\sum_{i=1}^{n}\sum_{j=1}^{n}w_{ij}}
   \frac{\sum_{i=1}^{n}\sum_{j=1}^{n}w_{ij}(x_i-x_j)^2}{\sum_{i=1}^{n}(x_i - \bar{x})^2}\\]


wobei \\(x_i, i=1, \ldots, n\\)   \\({n}\\) Beobachtungen der interessierenden numerischen Variablen und \\(w_{ij}\\) die räumlichen Gewichte sind.

Im wesentlichen ist dies eine erweiterte Version der Formel zur Berechnung des Korrelationskoeffizienten mit einer Matrix an räumlichen Gewichten.

```r
nuts3_kreise_rook = poly2nb(nuts3_kreise, row.names=nuts3_kreise$NUTS_NAME, queen=FALSE)
w_nuts3_kreise_rook =  nb2listw(nuts3_kreise_rook, style='B',zero.policy = TRUE)
m_nuts3_kreise_rook =   nb2mat(nuts3_kreise_rook, style='B', zero.policy = TRUE)
nuts3_gewicht <- mat2listw(as.matrix(m_nuts3_kreise_rook))


# lineares Modell
lm_uni_bau = lm(nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, data=nuts3_kreise)
summary(lm_uni_bau)
```
```R
# Call:
# lm(formula = nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, 
#     data = nuts3_kreise)

# Residuals:
#       Min        1Q    Median        3Q       Max 
# -0.080237 -0.026671 -0.005943  0.017007  0.165641 

# Coefficients:
#                                 Estimate Std. Error t value Pr(>|t|)    
# (Intercept)                     0.175566   0.005368   32.71   <2e-16 ***
# nuts3_kreise$Anteil.Baugewerbe -0.988080   0.073797  -13.39   <2e-16 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# Residual standard error: 0.0382 on 398 degrees of freedom
# Multiple R-squared:  0.3105,	Adjusted R-squared:  0.3088 
# F-statistic: 179.3 on 1 and 398 DF,  p-value: < 2.2e-16
```
```r
# Extraktion der Residuen
residuen_uni_bau <- lm (lm ( nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, data=nuts3_kreise))$resid

# Moran I test rondomisiert und nicht randomisiert
m_nr_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=FALSE)
m_r_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=TRUE)
m_r_residuen_uni_bau
```
Anstelle des normalen Moran I  sollte eine Monte-Carlo-Simulation verwendet werden. Das ist eigentlich die einzige gute Methode um festzustellen, wie wahrscheinlich es ist, dass die beobachteten Werte als zufällige Ziehung angesehen werden können.

```r
# 	Moran I test under randomisation

# data:  residuen_uni_bau  
# weights: nuts3_gewicht    

# Moran I statistic standard deviate = 11.344, p-value < 2.2e-16
# alternative hypothesis: greater
# sample estimates:
# Moran I statistic       Expectation          Variance 
#      0.3451598142     -0.0025062657      0.0009392513 
```

```r
moran.mc(residuen_uni_bau, nuts3_gewicht,nsim=1000)


# 	Monte-Carlo simulation of Moran I

# data:  residuen_uni_bau 
# weights: nuts3_gewicht  
# number of simulations + 1: 1001 

# statistic = 0.34516, observed rank = 1001, p-value = 0.000999
# alternative hypothesis: greater


moran.plot (residuen_uni_bau, nuts3_gewicht)

```
![Moran-I Plot]({{ site.baseurl }}/assets/images/unit04/moran_plot.png) 

*Abbildung 04-02-08: Moran-I Plot*



