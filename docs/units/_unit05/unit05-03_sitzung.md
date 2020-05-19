---
title: "Sitzung 3 - Datenvisualisierung Einführung"
toc: true
toc_label: Inhalt
---




Karten werden in einer Vielzahl von Bereichen verwendet, um Daten auf ansprechend und interpretierend darzustellen. Karten dienen der Informationskommunikation und es ist essentiel sowohl die gewisse Kommunkiations-Regeln der Kartographie als auch die  grundlegenden und erforderlichen Elemente zu idetifiziren. Layout und Formatierung sind der zweite kritische Aspekt, um die Daten visuell aufzuwerten. Die Verwendung von R zur Erstellung von Karten bietet viele dieser Notwendigkeiten  für die automatisierte und reproduzierbare Kartographie. 
<!--more-->

Räumliche Analysen und Zusammenhänge werden überwiegend als statische Karten kommuniziert. Statische Karten (plots) waren der historische R-Kartentyp allerdings sind mittlerweile sehr leistungstarke Kartogrphiewerkzeuge für R entwickelt worden die jede Arbeits und Kommunikationstechnick mit Karten unterstützen. Insbesondere das interaktive Webmapping und synamische Karten sind ein schnell wachsendes Gebiet in der Kommunikation räumlicher Informationen.
In dieser Sitzung sollen exepalrisch zwei Pakete einführend behandelt werden. Für die statische Kartenerstellung ist dies `tmap`.
## Einrichten der Umgebung



```r
rm(list=ls())
rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
## laden der benötigten libraries
# wir definieren zuerst eine liste mit den Paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits installiert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("sf","mapview","tmap","spdep","ineq","cartography", "tidygeocoder","usedist","raster","kableExtra","downloader","rnaturalearthdata")
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

# Aus der Sitzung Eins werden die gesäuberten Kreisdaten von github geladen und eingelesen

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/nuts3_kreise.rds",     destfile = "nuts3_kreise.rds")

# Einlesen der nuts3_kreise Daten
nuts3_kreise = readRDS("nuts3_kreise.rds")

# Gleiches gilt für die Punktdaten der Städte
download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/geo_coord_city.rds",     destfile = "geo_coord_city.rds")

# Einlesen der city  Daten
geo_coord_city = readRDS("geo_coord_city.rds")

# zu Demozwecken wird ein Rasterdatensatz  (Corine Daten für Deutschland heruntergeladen und eingelesen)

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/lulc_nuts3_kreise.tif",     destfile = "lulc_nuts3_kreise.tif")
lulc_nuts3_kreise = raster("lulc_nuts3_kreise.tif")
```

## Statische Karten mit tmap

### Konzept
Auch hinsichtlich der Kartographie-Werkzeuge in R gibt es konzeptionelle Unterschiede. `tmap` folgt wie `ggplot2` dem Paradigma der digitalen Kartographie das  von Wilkinson and Wills (2005) *grammar of graphics* benannt wurde. Dieser Ansatz ist zunächst gewöhnungsbedürftig mit ein bisschen Übung extrem leistungsstark und transparent sowie optimal um qualitativ hochwertige Karten in kürzester Zeit automatisch zu produzieren. 

Wichtigster Konzeptpunkt ist die Trennung von den darzustellenden Daten und der Art wie diese Daten visualisiert werden sollen. Das ist vergleichbar mit dem in Sitzung Eins eingeführten Konzept Daten zuerst zu säubern und korrigieren und dann den finalisierten Datensatz für Analysen und Auswertungen zu nutzen. 

Für die kartographische Darstellung kann so jeder Datensatz modular auf die angemessene Weise visualisiert werden. Dies schliesst sowohl das Kartenlayout, die Projektion und sämtliche kartographischen Elemente inklusive der visuellen Variablen mit ein. 

### Einstiegsbeispiel tmap

In `tmap` ist die Basisfunktion zur Definition des Datensatzes `tm_shape()`. Mit dieser Funktion werden die Eingangsdaten definiert. Es können beide Datenmodelle (Raster- und Vektordaten) genutzt werden. Die Basisfunktion die die Daten definiert muß immer von mindestens einer oder aber auch mehreren Funktionenergänzt werden,  die für das kartograpische *Tuning* der  Darstellung sorgen. Diese Layer-Elemente (z.B. `tm_fill()`, `tm_dots()` oder `tm_polygons()`) erzeugen "Folie" für Folie die eigentliche Karte.


```r
# Definition von nuts3_kreise mit der Aufforderung diese Fläche zu füllen
tm_shape(nuts3_kreise) +
  tm_fill() 
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-intro-1.png)<!-- -->

```r
# erzeuge geometrien
tm_shape(nuts3_kreise) +
  tm_borders() 
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-intro-2.png)<!-- -->

```r
# füllen und darstellen der geometrien
tm_shape(nuts3_kreise) +
  tm_fill() +
  tm_borders() 
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-intro-3.png)<!-- -->

```r
# abkürzung mit der Bequemlichkeitsfunktion qtm
qtm(nuts3_kreise) 
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-intro-4.png)<!-- -->

Was geschieht?
Das an `tm_shape()` übergebene Datenobjekt ist `nuts3_kreise` unser bekanntes `sf`-Objekt. dann werden die einzlnen Ebenen hinzugefügt wobei `tm_fill()` und `tm_borders()` das Objekt mit der Standard-Farbe und der Standardlinienstärke füllen bzw. die Geometrien darstellen. Das Hinzufügens neuer Ebenen wird durch den Operator `+`, gefolgt von `tm_*()` durchgeführt (* steht für alle verfügbaren Ebenentypen, siehe Hilfe "tmap-element" für eine vollständige Liste). Die Funktion `qtm()` (für quick thematic maps) bietet häufig eine gute Bequemlichkeitsfunktion zur Erzeugung einer geeigneten Kartengrundlage.
Das Ergebnis kann natürlich  R-üblich in eine Variable gespeichert werden. 
{: .notice--primary}

### Landnutzungsdaten Deutschland als Rasterdaten Karte

```r
map_nuts3_kreise = tm_shape(lulc_nuts3_kreise)

map_nuts3_kreise + tm_raster(style = "cont", palette = "YlGn") +
  tm_scale_bar(position = c("left", "bottom"))
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-1-1.png)<!-- -->


### Grundlagen der Kartengestaltung

Prinzipiell gibt es zwei verschiedne Kategorien von Gestaltungsmöglichkeiten in einer Karte: mit den Daten veränderbare Gestaltung (Merkmale)  und konstante Werte. `tmap` akzeptiert Argumente, die entweder variable Datenfelder (basierend auf Spaltennamen) oder konstante Werte beinhalten.  

Zu den am häufigsten verwendeten Ästhetik-Argumenten für Füll- und Randebenen gehören Farbe, Transparenz, Linienbreite und Linientyp, die mit den Argumenten `col`, `alpha`, `lwd` bzw. `lty` festgelegt werden. 


```r
tmap_mode("plot")
map1 = tm_shape(nuts3_kreise) + tm_fill(col = "red")
map2 = tm_shape(nuts3_kreise) + tm_fill(col = "red", alpha = 0.3)
map3 = tm_shape(nuts3_kreise) + tm_borders(col = "blue")
map4 = tm_shape(nuts3_kreise) + tm_borders(lwd = 3)
map5 = tm_shape(nuts3_kreise) + tm_borders(lty = 2)
map6 = tm_shape(nuts3_kreise) + tm_fill(col = "red", alpha = 0.3) +
  tm_borders(col = "blue", lwd = 3, lty = 2)
tmap_arrange(map1, map2, map3, map4, map5, map6)
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-aest-1.png)<!-- -->

### Beschriftungen und visuelle Klassifikation


```r
# Standardeinstellungen
tm_shape(nuts3_kreise) + 
  tm_fill(col = "Beschaeftigte")
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-aest2-1.png)<!-- -->

```r
# Darstellung mit tmap Farbgebung nach gleicher Klassenabstand
tm_shape(nuts3_kreise) + 
  tm_polygons("Beschaeftigte",    breaks=seq(0,1250000, by=150000))
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-aest2-2.png)<!-- -->

```r
# Darstellung mit tmap Farbgebung nach Jenks Methode mit 8 Klassen mit Hilfe der cartography::getBreaks() Funktion 
tm_shape(nuts3_kreise) + 
  tm_fill(col = "Beschaeftigte",breaks = getBreaks(nuts3_kreise$Beschaeftigte,nclass = 8,method = "jenks"))
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-aest2-3.png)<!-- -->

```r
# Darstellung mit tmap Farbgebung nach em Methode mit 8 Klassen mit Hilfe der cartography::getBreaks() Funktion  
tm_shape(nuts3_kreise) + tm_fill(col = "Beschaeftigte",breaks = getBreaks(nuts3_kreise$Beschaeftigte,nclass = 8,method = "em"))
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-aest2-4.png)<!-- -->


```r
# Darstellung mit tmap Farbgebung nach Jenks mit 5 Klassen mit Hilfe der tmap eigenen Funktion aus tm_fill()  
# dazu werden Titel und Legende auserhalb dargestellt und ein weiterer Datensatz (Anteil.Hochschulabschluss) überlagert
legend_title = expression("Beschäftigte /Kreis")
tm_shape(nuts3_kreise) + 
  tm_fill(col = "Beschaeftigte",title = legend_title, style = "jenks" ) + 
  tm_layout(main.title = "Landkreise in Deutschland",legend.outside = TRUE,main.title.size = 0.8,legend.title.size = 0.8) +  
  tm_symbols(col = "green",  border.col = "black", size = "Anteil.Hochschulabschluss") 
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-aest3-1.png)<!-- -->

## Was ist sonst noch zu tun?
Sobald wir unsere Tabellendaten als Geotabellendaten vorliegen haben (z.B. nuts3_kreise als sf Objekt) können wir auf mächtige Pakete zur visualisieurng und on the fly Analyse zurückgreifen. Beispielhaft wird hier tmap gezeigt.

* versuchen sie sich an der verlinkten Hilfe auf der Geocomuptation with R Ressource. Sie sollen Sie zum aktiven Umgang mit `R` ermuntern.
* *spielen* Sie mit den Einstellungen, lesen Sie Hilfen und lernen Sie schrittweise die Handhabung von R kennen. 
* **stellen Sie Fragen im Forum, im Kurs oder per email mit dem Betreff [M&S2020]**

## Wo gibt's mehr Informationen?
Für mehr Informationen kann unter den folgenden Ressourcen nachgeschaut werden: 

* [Spatial Data Analysis](https://rspatial.org/raster/analysis/2-scale_distance.html) von Robert Hijmans. Sehr umfangreich und empfehlenswert. Viel der Beispiele basieren auf seiner Vorlesung und sind für unsere Verhältnisse angepasst.

* [Geocomputation with R](https://geocompr.robinlovelace.net) von Robin Lovelace, Jakub Nowosad und Jannes Muenchow ist die herausragende Referenz für alles rund um  raumzeitliche Datenanalyse und -verarbeitung mit R. 
* [Making Maps with R](https://geocompr.robinlovelace.net/adv-map.html) bietet eine sehr gelungen Einstieg in das Thema. 

## Download Skript
Das Skript kann unter [unit05-03_sitzung.R]({{ site.baseurl }}/assets/scripts/unit05-03_sitzung.R){:target="_blank"} heruntergeladen werden

