---
title: 'Sitzung 2: Region, Distanz und räumlicher Einfluß'
toc: true
toc_label: Inhalt
---


Geodaten sind prinzipiell wie gewöhnliche Daten zu betrachten. Allerdings sind die Aspekte der Skala, der Zonierung (aggregierte  Flächeneinheiten), der Topologie (der Lage im Verhältnis zu anderen Entitäten) der Geometrie (Entfernung zueinander) eine Ableitung aus der Grundeigenschaft dass Geodaten eine Position im Raum besitzen. <!--more-->

Im Rahmen der räumlichen Statistik wirft das Fragen der räumlichen Autokorrelation bzw. Inhomogenität auf. Also letztlich Fragen welche Raumkonstruktion auf welcher Skala einen Einfluss auf meine Fragestellung hat.

Die klassischen Bereiche der räumlichen Statistik sind Punktmusteranalyse, Regression und Inferenz mit räumlichen Daten, dann die Geostatistik (Interpolation z.B. mit Kriging) sowie  Methoden zur lokalen und globalen Regression und Klassifikation mit räumlichen Daten. 

Nahezu alle dieser Bereiche basieren auf Daten die als [Vektordatenmodell]({{ site.baseurl }}{% link _unit02/unit02-02_reader_gi_raum.md %}) vorliegen. Das heisst es handelt sich um diskrete Geoobjekte die Null-, Ein- bzw. Zwei-dimensional Raumeigenschaften aufweisen.


## Lernziele

Die Lernziele der zweiten Übung sind:

---

* Berechnen von Gewichtungsmatritzen für unterschiedliche Nachbarschaften
* Visualisierung der Ergebnisse


---


## Einrichten der Umgebung



```r
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
```


```r
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
```


## Regionalisierung oder Aggregationsräume

Die Analyse der räumlichen Daten erfolgt oft in regionaler oder Aggregierung. Auch wenn alle am Liebsten Daten auf einer möglichst hoch aufgelösten Ebene verfügbar hätten (im besten Fall Einzelpersonen, Haushalte, Grundstücke, Briefkästen etc.) ist der Regelfall, dass es sich um räumlich (und zeitlich) aggregierte  Daten handelt. Statt tägliche Daten über den Cornfllakes-Kosum in jeden Haushalt haben wir den  Jahresmittelwert aller verkauften Zerealien in einem Bundesland. So geht das mit den meisten Daten, die zudem oft unterschiedlich aggregiert sind wo in Europa z.B. nationale und subnationale Einheiten (z.B. NUTS1, NUTS3, NUTS3, AMR etc.) vorliegen. Häufig gibt es auch räumliche Datensätze die in Form von Rasterzellenwerten quasi-kontinuierlich vorliegen.

Bei der visuellen Exploration aber auch bei der statistischen Analyse ist es von erheblichem Einfluss wie die Gebiete zur Aggregation der Daten geschnitten sind. Da dieser Zusammenhang eher willkürlich (auch oft historisch oder durch wissenschaftlich begründet) ist, sind die Muster, die wir sehen äußerst subjektiv. Dieses sogenannte *Problem der veränderbaren Gebietseinheit* (Modifiable Areal Unit Problem, MAUP) bezeichnet. Der Effekt von höheren Einheiten auf niedrigere zu schließen ist hingegen als *ökologische Inferenz* (Ecological Inference) bekannt.


Betrachten wir diese Zusammenhänge einmal gan

## Distanz

Als Distanz wird die Entfernung von zwei Positionen bezeichnet. Sie kann zunächst einmal als ein zentrales Konzept der Geographie angenommen werden. Erinnern sie sich an Waldo Toblers ersten Satz zur Geographie, dass "*alles mit allem anderen verwandt ist, aber nahe Dinge mehr verwandt sind als ferne Dinge*".  Die Entfernung ist scheinbar sehr einfach zu bestimmen. Natürlich können wir die Entfernung auf eine isometrischen und isomorhpen Fläche mittels der "*Luftlinie*" (euklidische Distanz) berechnen. Zentrales Problem ist das diese Betrachtung häufig wenn in der Regel nicht relevant ist. Es gibt nicht nur (nationale) Grenzen, Gebirge oder beliebige andere Hindernisse, die Entfernung zwischen A und B kann auch asymmetrisch sein (bergab geht's einfacher und  schneller  als bergauf). Das heißt Distanzen können auch über z.B. *Distanzkosten* gewichtet werden.

Üblicherweise werden Distanzen in einer "Distanzmatrix" dargestellt. Eine solche Matrix enthält als Spaltenüberschriften und als Zeilenbeschriftung die Kennung von jedem berechneten Ort. Im jedem Feld wird die Entfernung eingetragen. Für kartesische Koordinaten erfolgt dies einfach über den Satz des Pythagoras.


###  Distanz-Matrix
Wir nutzen für die geroreferenzierten Positionen von 10 deutschen Städten für die Berechnung einer Distanzmatrix. Wenn die Positionen in Länge/Breite angegeben sind ist die Distanzbeechnung etwas aufwendiger. In diesem Fall können wir die Funktion `pointDistance` aus dem `raster` Paket verwenden (allerdings nur wenn das Koordinatensystem korrekt angegeben wird). Eleganter ist jedoch die Konvertierung von Punktdaten in ein Geodatenformat z.B. als  `sf` Objekt. 

Zur direkten Überprüfung ob die Punkte richtig geokodiert sind eignet sich nach Erzeugung des Punkte-Objekts die Funktion  `mapview` hervorragend.
 

```r
geo_coord_city = readRDS("geo_coord_city.rds")

# visualize with mapview
mapview(geo_coord_city,  color='red',legend = FALSE)
```


{% include media url="/assets/misc/geo_city_city.html" %}
[Full-Screen Version der Karte]({{ site.baseurl }}/assets/misc/geo_city_city.html){:target="_blank"}

*Abbildung 04-02-05: Webkarte mit den erzeugten Punktdaten. In diesem Falle zehn nicht ganz zufällige Städte Deutschlands*

### Distanzberechnung von Geokoordinaten

Die Berechnung der Distanzen zwischen den 10 Städten greift einigermaßen tief in Geodaten-Verarbeitung ein. Die Punkte liegen als geographische Koordinaten, also als Längen und Breitengrade auf Grundlage des WGS84 Datum vor. Auf einem Ellipsoid ist es deutlich aufwendiger (oder fehlerträchtiger) Entfernungen zu rechnen als in in einem projizierten (also kartesischen) Koordinatensystem.

Daher transformieren wir zunächst den Datensatz in das amtlich gültige [Referenzsystem](https://de.wikipedia.org/wiki/Europ%C3%A4isches_Terrestrisches_Referenzsystem_1989) für Deutschland nämlich `ETRS89/UTM`. Im nachstehenden Beispiel nutzen wir die [EPSG](https://de.wikipedia.org/wiki/European_Petroleum_Survey_Group_Geodesy#EPSG-Codes) Konvention. Für das zuvor genannte System ist das der [EPSG-Code 25832](https://epsg.io/25832).


```r
staedte=c("München","Berlin","Hamburg","Köln","Bonn","Hannover","Nürnberg","Stuttgart","Freiburg","Marburg")

# Zuerst projizieren wir den Datensatz auf ETRS89/UTM
proj_coord_city = st_transform(geo_coord_city, crs = 25832)

# nun berechnen wir die Distanzen
city_distanz = dist(st_coordinates(proj_coord_city))
# mit Hilfe von dist_setNames können wir die Namen der distanzmatrix zuweisen
dist_setNames(city_distanz, staedte)
```

```
##            München   Berlin  Hamburg     Köln     Bonn Hannover Nürnberg
## Berlin    504156.6                                                      
## Hamburg   611337.7 253841.6                                             
## Köln      456511.6 477393.1 356810.5                                    
## Bonn      434329.5 478145.8 370325.9  24607.7                           
## Hannover  489061.8 248686.4 131348.9 249893.3 258162.1                  
## Nürnberg  150928.4 377495.0 460900.6 337014.5 318118.3 338167.6         
## Stuttgart 190926.8 511243.2 533104.9 288316.8 264173.9 401815.7 157508.4
## Freiburg  278029.8 639022.5 635366.9 333440.4 309440.8 505124.9 287407.8
## Marburg   359924.1 371191.0 315365.1 128538.4 118421.0 186154.7 223271.1
##           Stuttgart Freiburg
## Berlin                      
## Hamburg                     
## Köln                        
## Bonn                        
## Hannover                    
## Nürnberg                    
## Stuttgart                   
## Freiburg   131404.0         
## Marburg    227925.4 320161.6
```

```r
round(city_distanz,0)
```

```
##         1      2      3      4      5      6      7      8      9
## 2  504157                                                        
## 3  611338 253842                                                 
## 4  456512 477393 356811                                          
## 5  434330 478146 370326  24608                                   
## 6  489062 248686 131349 249893 258162                            
## 7  150928 377495 460901 337014 318118 338168                     
## 8  190927 511243 533105 288317 264174 401816 157508              
## 9  278030 639023 635367 333440 309441 505125 287408 131404       
## 10 359924 371191 315365 128538 118421 186155 223271 227925 320162
```

Wir erzeugen aus der Distanz-Matrix `class = dist` eine normale R-Matrix. Leider müssen dann die Namen wieder zugewiesen werden.


```r
# make a full matrix an
city_distanz <- as.matrix(city_distanz)
rownames(city_distanz)=staedte
colnames(city_distanz)=staedte
```

## Räumlicher Einfluss

Die beiden Aspekte zuvor haben die räumlichen Verhältnisse in Form von Raumabgrenzung und Distanz beschrieben. In der räumlichen Analyse ist es jedoch von zentraler Bedeutung den räumlichen **Einfluss** zwischen geographischen Objekten zu schätzen bzw. zu messen. Das generelle Problem ist, dass der räumliche Einfluss sehr komplex ist und faktisch nie gemessen werden kann. Daher gibt es zahllose Arten ihn zu schätzen. 

Dich beiden wichtigsten Ansätze sind dies prozessorientiert (funktional) durchzuführen (der oberliegende Teil eines Baches fließt in den unterliegenden) oder datengetrieben dann wird mit statistischen Verfahren die räumliche Autokorrelation ermittelt. Für den datengetriebnen Ansatz ist dieser Einfluss in der Regel eine Funktion der *Nachbarschaft* oder der *(inversen) Entfernung*. Um damit in statistischen Modellen arbeiten zu können werden diese Nachbarschaftskonzepte als *räumliche Gewichtungsmatrix* ausgedrückt. 


Zum Beispiel kann der räumliche Einfluss von Polygonen aufeinander (z.B, NUTS3 Verwaltungsbezirke) so ausgedrückt werden, dass sie eine/keine gemeinsame Grenze, sie kann als euklidische Distanz zwischen ihren Schwerpunkten bestimmt werden oder über die Länge gemeinsamer Grenzen gewichtet werden und so fort.

## Nachbarschaft

Die Nachbarschaft ist das vielleicht wichtigste Konzept. höherdimensionale Geoobjekte können als benachbart betrachtet werden wenn sie sich *berühren*, z.B. benachbarte Länder. Bei null-dimensionalen Objekten (Punkte) ist der gebräuchlichste Ansatz die Entfernung in Kombination mit einer Anzahl von Punkten für die Ermittlung der Nachbarschaft zu nutzen.


### Distanzbasierte Gewichtungs-Matrix für Punkte

Anstatt den räumlichen Einfluss als binären Wert (also topologisch benachbart ja/nein) auszudrücken, kann er als kontinuierlicher Wert ausgedrückt werden. Der einfachste Ansatz ist die Verwendung des inversen Abstands (je weiter entfernt, desto niedriger der Wert).



```r
# inverse Distanz
gewichtungs_matrix =  (1 / city_distanz)
```

```r
# inverse Distanz zum Quadrat
gewichtungs_matrix_q =  (1 / city_distanz ** 2)
```

Wie auch die *räumliche Gewichtung* wird die Matrix oft *zeilennormiert*, das heißt dass die Summe der Gewichte für jede Zeile (Position oder Wert der Position) in der Matrix gleich ist. 

```r
# löschen der Inf Werte die durch den Selbstbezug der Punkte entestehen
gewichtungs_matrix <- as.matrix(gewichtungs_matrix)
rownames(gewichtungs_matrix)=staedte
colnames(gewichtungs_matrix)=staedte

gewichtungs_matrix[!is.finite(gewichtungs_matrix)] <- NA
zeilen_summe <- rowSums(gewichtungs_matrix,  na.rm=TRUE)
zeilen_summe
```

```
##      München       Berlin      Hamburg         Köln         Bonn     Hannover 
## 2.839529e-05 2.299421e-05 2.748176e-05 6.894169e-05 7.021031e-05 3.435182e-05 
##     Nürnberg    Stuttgart     Freiburg      Marburg 
## 3.481930e-05 3.715831e-05 2.915882e-05 4.222911e-05
```


### Erweiterung Distanz-basierte Nachbarschaft für Flächen

Nachfolgend wird für den Mittelwert, das dritte Quartil und den Maximalwert der Distanzverteilung aller Kreis-Zentroide die Nachbarschaft bestimmt.


```r
# Extraktion der Koordinaten aus nut3_kreise
coords <- coordinates(as(nuts3_kreise,"Spatial"))

# berechne alle Distanzen für die Flächenschwerpunkte der Kreise
knn2nb = knn2nb(knearneigh(coords))

# erzeuge die Distanzen für die LAnd-Kreise
kreise_dist <- unlist(nbdists(knn2nb, coords))
summary(kreise_dist)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##    1026   11485   20205   19811   26498   56096
```

```r
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
```

![]({{ site.baseurl }}/assets/images/unit04/distanz-ngb-1.png)<!-- -->


*Abbildung 04-02-07: Distanzbasierte Nachbarschaften für die Landkreise Deutschlands, a) Nachbarschaften innerhalb der Maximaldistanz der Distanzmatrix, b) Nachbarschaften innerhalb der 3. Quartils der Distanzmatrix, c) b) Nachbarschaften innerhalb der Mittelwerts der Distanzmatrix*


### Binäre 4-er Nachbarschaft


Die Funktion `poly2nb` kann verwendet werden um binäre (=Nachbar ja/nein) Nachbarschaftslisten erzeugen. Sie dient als Grundlage einer Nachbarschaftsmatrix.


```r
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
```

<img src="{{ site.baseurl }}/assets/images/unit04/binary_ngb-1.png" width="1000px" height="1000px" />

*Abbildung 04-02-05: Binäre 4-er Nachbarschaft für die Landkreise Deutschlands*




#### Nächste Nachbarn

Natürlich können auch nicht nur die vier oder acht angenzenden Nachbarn ermittelt werden sondern beliebig viele. Nachfolgend werden exemplarisch die 3 bzw. 5 nächsten Nachbarn zu einem Kreis ausgewiesen.


```r
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
```

<img src="{{ site.baseurl }}/assets/images/unit04/neareast_ngb-1.png" height="1000px" />

*Abbildung 04-02-06:Nächste 3-er/5-er Nachbarschaft für die Landkreise Deutschlands*



## Räumliche Autokorrelation

Nachdem wir nun beliebige Nachbarschaften berechnen können sollten wir uns um die räumliche Autokorrelation der in disen Nachbarschaften ausgeprägten Merkmale Gedanken machen.  Die räumliche Autokorrelation die nach Tobler den Einfluß der nachbarschaftlichen Nähe beschreibt, ist komplizierter als das die zeitliche Autokorrelation. Räumliche Objekte haben in der Regel zwei Dimensionen und weisen komplexe Formen auf was zu einer mindestens zweidimensionalen Beeinflussung durch *Nähe* führt.

Grundsätzlich beschreiben die räumlichen Autokorrelationsmaße die Ähnlichkeit der beobachteten Werte zueinander. Räumliche Autokorrelation entstehen durch Beobachtungen und Beobachtungen und Positionen/Objekte im Raum.

Die räumliche Autokorrelation in einer Variable kann exogen (sie wird durch eine andere räumlich autokorrelierte Variable verursacht, z.B. Niederschlag) oder endogen (sie wird durch den Prozess verursacht, der im Spiel ist, z.B. die Ausbreitung einer Krankheit) sein.

Eine häufig verwendete Statistik ist Moran's I und invers dazu  Geary's C. Binäre Daten werden mit dem Join-Count-Index getestet.

Wie bereits bekannt ist hängt der Wert von Morans I deutlich von den Annahmen ab, die in die räumliche Gewichtungsmatrix verwendet werden. Die Idee ist, eine Matrix zu konstruieren, die Ihre Annahmen über das jeweilige räumliche Phänomen passend wiedergibt. Der übliche Ansatz besteht darin, eine Gewichtung von 1 zu geben, wenn zwei *Zonen* Nachbarn sind falls nicht wird eine 0 vergeben. Natürlich variiert die Definition von *Nachbarn* (vgl. Reader räumliche Konzepte und oben). Quasi-kontinuierlich ist der Ansatz eine inverse Distanzfunktion zur Bestimmung der Gewichte zu verwenden. Auch wenn in der Praxis fast nie vorzufinden sollte die Auswahl räumlicher Gewichtungsmatritzen das betreffende Phänomen abbilden. So ist die Benachbartheit entlang von Autobahnen für Warentransporte anders zu gewichten als beispielsweise über ein Gebirge oder einen See.

Der Moran-I-Test und der Geary C Test sind übliche Verfahren für die Überprüfung räumlicher Autokorrelation. Das Geary's-C ist invers mit Moran's-I, aber nicht identisch. Moran's-I ist eher ein Maß für die globale räumliche Autokorrelation, während Geary's-C eher auf eine lokale räumliche Autokorrelation reagiert. 

### Berechnung der räumlichen Autokorrelation für eine binäre Vierer-Nachbarschaft


```r
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
```

```
## 
## Call:
## lm(formula = nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, 
##     data = nuts3_kreise)
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -0.080237 -0.026671 -0.005943  0.017007  0.165641 
## 
## Coefficients:
##                                 Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                     0.175566   0.005368   32.71   <2e-16 ***
## nuts3_kreise$Anteil.Baugewerbe -0.988080   0.073797  -13.39   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.0382 on 398 degrees of freedom
## Multiple R-squared:  0.3105,	Adjusted R-squared:  0.3088 
## F-statistic: 179.3 on 1 and 398 DF,  p-value: < 2.2e-16
```

```r
# Extraktion der Residuen
residuen_uni_bau <- lm( nuts3_kreise$Anteil.Hochschulabschluss ~ nuts3_kreise$Anteil.Baugewerbe, data=nuts3_kreise)$resid

# Moran I test rondomisiert und nicht randomisiert
m_nr_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=FALSE)
m_r_residuen_uni_bau = moran.test(residuen_uni_bau, nuts3_gewicht,randomisation=TRUE)
m_r_residuen_uni_bau
```

```
## 
## 	Moran I test under randomisation
## 
## data:  residuen_uni_bau  
## weights: nuts3_gewicht    
## 
## Moran I statistic standard deviate = 11.344, p-value < 2.2e-16
## alternative hypothesis: greater
## sample estimates:
## Moran I statistic       Expectation          Variance 
##      0.3451598142     -0.0025062657      0.0009392513
```

*Abbildung 04-02-08: Berechnung der räumlichen Autokorrelation für Binäre 4-er Nachbarschaft für die Landkreise Deutschlands - Hier für die das lineare Modell lm(Anteil.Hochschulabschluss ~ Anteil.Baugewerbe)*



Anstelle des üblichen einfachen  Moran I  Tests sollte eine Monte-Carlo-Simulation verwendet werden, da es eigentlich die einzige gute Methode ist festzustellen, wie wahrscheinlich die beobachteten Werte als zufällige Ziehung angesehen werden können.



```r
moran.plot (residuen_uni_bau, nuts3_gewicht)
```

<img src="{{ site.baseurl }}/assets/images/unit04/moran_plot-1.png" width="800px" height="800px" />

*Abbildung 04-02-08: Moran-I Plot*


## Download Skript
Das Skript kann unter [unit05-02_sitzung.R]({{ site.baseurl }}/assets/scripts/unit04-02_sitzung.R){:target="_blank"} heruntergeladen werden

## Aufgabenstellung

Bitte bearbeiten Sie folgende Aufgabenstellung:
* Berechnen Sie auf der Grundlage der `nuts3_kreise` eine [distanzbasierte Nachbarschaft]({{ site.baseurl }}/unit04/unit04-02_sitzung.html#berechnen-der-distanz-matrix) mit dem maximalen Distanzmaß des ersten Quartils. 
* Berechnen Sie für diese distanzbasierte Nachbarschaft eine neue Gewichtungsmatrix (analog zu `nuts3_gewicht`)
* Berechnen Sie mit dieser neu erstellten Gewichtungsmatrix und den `residuen_uni_bau ` aus obigem linearen Modell mit Hilfe von Moran I die Autokorrelation mit Hilfe der Monte Carlo Variante. und vergleichen Sie die dieses Ergebnis mit dem Beispielergebnis aus dieser Übung
* Erzeugen Sie zum Abschluss eine Karte mit den Residuen des verwendenten linearen Modells. Gehen Sie hierzu analog zum [tmap / mapview]({{ site.baseurl }}/unit04/unit04-01_sitzung.html#darstellung-der-daten-mit-dem-paket-tmap) Beispiel vor.
{: .notice--success}

## Was ist sonst noch zu tun?
Versuchen Sie sich zu verdeutlichen, dass die Mehrzahl der räumlichen  Regressions-Analysen und  -Modelle auf den Grundannahmen dieser Übung basieren. Das heisst es kommt maßgeblich auf Ihre konzeptionellen oder theoriegeleiteten Vorstellungen an, welche Nachbarschaft, welches Nähe-Maß und somit auch, welche räumlichen Korrelationen zustande kommen. Bitte beschäftigen Sie sich mitdem Skript. 

* gehen Sie die Skripte **schrittweise** durch. Lassen Sie es nicht von vorne bis hinten unkontrolliert durchlaufen 
* gleichen Sie ihre Kenntnisse aus dem Statistikkurs mit diesen praktischen Übungen ab und identifizieren Sie was Raum-Wirskamkeiten sind.
* *spielen* Sie mit den Einstellungen, lesen Sie Hilfen und lernen Sie schrittweise die Handhabung von R kennen. 
* lernen Sie quasi im "*Vorbeigehen*" wie Daten zu plotten sind oder wann Sie ein wenig Acht geben müssen wenn Sie mit Geodaten arbeiten (viele Hinweise und Erläuterungen sind in den Kommentarzeilen untergebracht).


* **stellen Sie Fragen im Forum, im Kurs oder per email mit dem Betreff [M&S2020]**

## Wo gibt's mehr Informationen?
Für mehr Informationen kann unter den folgenden Ressourcen nachgeschaut werden: 

* [Spatial Data Analysis](https://rspatial.org/raster/analysis/2-scale_distance.html) von Robert Hijmans. Sehr umfangreich und empfehlenswert. Viel der Beispiele basieren auf seiner Vorlesung und sind für unsere Verhältnisse angepasst.

* Der [UseR! 2019 Spatial Workshop](https://edzer.github.io/UseR2019/part2.html) von Roger Bivand. Roger ist die absolute Referenz hinischtlich räumlicher Ökonometrie mit R. Er hat unzählige Pakete geschrieben und ebensoviel Schulungs-Material und ist unermüdlich in  der Unterstützung der Community.

