---
title: "Sitzung 1: Datentabellen und Geometrien"
toc: true
toc_label: Inhalt
---



Datenanalyse und Datenvisualisierung ist in der Regel begleitet von einer umfangreichen Vorbereitung der Daten. Üblicherweise kann dies von Hand mit einem Editor oder automatisiert durch entsprechende Scripte erfolgen. <!--more-->Insbesondere für die Reproduzierbarkeit und die einfache Anpassung weiterer Vorverarbeitungsschritte ist es oft sinnvoll sich mit einer automatischen Datenvorprozessirrung zu beschäftigen. Dies kann oft sehr mühevoll sein. Ungeachtet der Herausforderungen die sich einem Anfänger entgegenstellen ist es der Mühe wert da nicht nur im wissenschaftlichen Sinne Reproduzierbarkeit des vollständigen Arbeitsablaufs höchste Priorität hat sondern die gesamte Analyse von den Rohdaten bis zu den Ergebnissen transparent nachvollziehbar bleibt. 


## Lernziele

Die Lernziele der ersten Übung sind:

---

  * Installation von R Rstudio und den notwendigen Libraries
  * Erste Schritte mit R
  * Aufbereitung und Darstellung eines zusammengesetzten Datensatzes 
 
---

In den nachfolgenden Skript Schnipseln werden einige wichtige Techniken der R-Programmiersprache benutzt und ausführlich erläutert. Einige kennen Sie bereits, andere sind im Reader [R-Intro]({{ site.baseurl }}{% link _unit03/unit03-01_reader_R.md %}
erklärt. Vor allem die beiden "*Arbeitspferde*" für Wiederholungen `for` und Bedingungen `if` werden eingeführt. Bitte schauen sie für die grundsätzliche Funktionsweise in die R-Reader.


## Einrichten der Umgebung



```r
#---------------------------------------------------------
# merge_LAU_NUTS3.R 
# Autor: Chris Reudenbach, creuden@gmail.com
# Urheberrecht: Chris Reudenbach 2020 GPL (>= 3)
#
# Beschreibung: Skript verbindet Kreisdaten die mit Hilfe von LAU Schlüsseln
# kodiert sind mit einer von Eurostat zur Verfügung gestellten Geometrie.
#  
#
# Eingabe: Tabelle (ASCII) mit LAU Schlüsselspalte, Lookuptabelle LAU-NUTS, NUTS Geometrie in eine GDAL kompatiblen Dateiformat.
#
# Ausgabe:  Simple Feature(sf) Objekt mit allen Tabelleninhalten
#
# Anmerkungen: Die Daten werden im Skript heruntergeladen und eingelesen. Da diese mit statischen URLs und Dateinamen versehen sind müssen etwaige Veränderungen angepasst werden.
# Das nachfolgende Script verbindet die Daten der Datei Kreise2010.csv mit 
# von von Eurostat zur Verfügung gestellten NUTS3 Geometriedaten (Vektordaten der Kreise)
# Um diese Verbinden zu können bedarf es in dem vorliegenden Fall einer weiteren Tabelle
# Diese stellt die Verbindung zwischen denen in der Datei Kreise2010.csv verwendeten LAU Kodierung
# und der NUTS3 Kodierung her.
# Um diese Beiden Tabellen verbinden zu können müssen einige Manipulationen an den  Daten vorgenommen werden
# Im letzten Schritt wird die gesäuberte Datentabelle über die NUTS3 Codes an die Geometrie an gehangen und mit 
# mapview und tmap visualisiert
#---------------------------------------------------------


# 0 - Umgebung einrichten, 
#     Pakete und Funktionen laden
#     Variablen definieren
#---------------------

## Säubern der Arbeitsumgebung
rm(list=ls())
## festlegen des Arbeitsverzeichnisses
# rootDIR enthält nur den Dateipfad
rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
setwd(rootDIR)
# die Tilde ~ steht dabei für das Nutzer-Home-Verzeichnis unter Windows 
# üblicherweise Nutzer/Dokumente

## laden der benötigten libraries
# wir definieren zuerst eine liste mit den Paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits installiert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("sf","mapview","tmap","ggplot2","RColorBrewer","jsonlite","tidyverse","spdep","spatialreg","ineq","rnaturalearth", "rnaturalearthhires", "tidygeocoder","usedist","downloader")

for (lib in libs){
if(!lib %in% utils::installed.packages()){
  utils::install.packages(lib)
}}
# nicht wundern lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))


# 1 - Daten Vorverarbeitung
#--------------------


##- Laden und Einlesen der Rohdaten
#--------------------

files = list.files(rootDIR,pattern ="xlxs|geojson|csv|zip|xml|pdf|txt",full.names = TRUE,recursive = TRUE)
file.remove(files)
```

```
##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [16] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [31] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [46] TRUE TRUE TRUE TRUE TRUE TRUE TRUE
```

```r
# Aus dem Statistik-Kurs lesen wir die Kreisdaten ein
# Sie sind aus Bequemlichkeitsgründen auf github verfügbar

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/Kreisdaten2010.csv",     destfile = paste0(rootDIR,"Kreisdaten2010.csv"))

# Aus dem Statistikkurs lesen wir die Kreisdaten ein
Kreise <- read.table ("Kreisdaten2010.csv",header=T,sep=';')

# von eurostat holen wir die Geometriedaten (also die GI Daten für die NUTS3 Kreise)

download(url = "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/download/ref-nuts-2016-01m.geojson.zip",destfile = paste0(rootDIR,"ref-nuts-2016-01m.geojson.zip")) 
# entpacken des Archivs
unzip(paste0(rootDIR,"ref-nuts-2016-01m.geojson.zip"))

# mit dem Paket sf und der Funktion sf_read lesen wir sie in eine Variable
nuts3 = st_read("NUTS_RG_01M_2016_3857_LEVL_3.geojson")
```

```
## Reading layer `NUTS_RG_01M_2016_3857_LEVL_3' from data source `/home/creu/Schreibtisch/spatialstat_SoSe2020/NUTS_RG_01M_2016_3857_LEVL_3.geojson' using driver `GeoJSON'
## Simple feature collection with 1522 features and 9 fields
## geometry type:  MULTIPOLYGON
## dimension:      XY
## bbox:           xmin: -7029958 ymin: -2438305 xmax: 6215611 ymax: 11465540
## projected CRS:  WGS 84 / Pseudo-Mercator
```

```r
# Um nur Deutschland Kreise zu erhalten filtern wir sie 
# auf den Wert "DE" in der Spalte CNTR_CODE
# Achtung wir legen eine neue Variable für Deutschland an
nuts3_de = nuts3[nuts3$CNTR_CODE=="DE",]

# herunter laden der offiziellen Zuweisungstabellen für Lokale Verwaltungseinheiten (LAU) <-> NUTS3 Konversion
# https://ec.europa.eu/eurostat/de/web/nuts/local-administrative-units
# https://ec.europa.eu/eurostat/documents/345175/501971/EU-28-LAU-2019-NUTS-2016.xlsx

download(url = "https://ec.europa.eu/eurostat/documents/345175/501971/EU-28-LAU-2019-NUTS-2016.xlsx",destfile =paste0(rootDIR,"EU-28-LAU-2019-NUTS-2016.xlsx"))

# wir lesen es direkt aus der xlsx Exceldatei ein. Da die Deutschlanddaten im
# Datenblatt "DE" abgespeichert sind lesen wir nur dieses sheet ein
lau_nuts3 = readxl::read_xlsx(paste0(rootDIR,"EU-28-LAU-2019-NUTS-2016-1.xlsx"),sheet = "DE")

##-  Säubern und Vorbereiten der Daten
#------------------------------------

# die unten eingeladene LAU-Kodierung enthält 8 Stellen wobei die letzten beiden lokale Untergruppen darstellen
# daher muss bei 4 Ziffern der Kreise Tabelle eine führende Null vorangestellt werden
# dies geschieht durch Abfrage der Stellen im der entsprechenden Spalte
Kreise$Kreis[nchar(Kreise$Kreis) < 5] = paste0("0",Kreise$Kreis[nchar(Kreise$Kreis) < 5])

# bei der LAU Tabelle sind die letzten 3 Ziffern für Unterregionen von Nuts3 daher können sie ignoriert werden
# einfache Lösung die Zeichenkette (character) wird auf die passende Länge abgeschnitten
# dazu muss dem data.frame Feld "LAU CODE" die von 1-5 gekappte Spalte zugewiesen werden
lau_nuts3$`LAU CODE`=substr(lau_nuts3$`LAU CODE`,start = 1,stop = 5)

# jetzt müssen nur noch die Duplikate entfernt werden Das Ausrufezeichen ist dabei die Verneinung 
# also sollen die nicht-Duplikate in der Spalte "LAU CODE" behalten werden
lau_nuts3 = lau_nuts3[!duplicated(lau_nuts3[,"LAU CODE"]),]

# nun gilt es die beiden bereinigten Tabellen nach diesen beeiden Spalten zusammen zu führen
lookup_merge_kreise = merge(Kreise,  lau_nuts3,
           by.x = "Kreis", by.y = "LAU CODE")

# und zuletzt wird diese Tabelle an die Geometrie angehangen
nuts3_kreise = merge(nuts3_de,lookup_merge_kreise,
            by.x = "NUTS_ID", by.y = "NUTS 3 CODE")

# Projektion in die die amtliche deutsche Projektion ETRS89 URM32
nuts3_kreise = st_transform(nuts3_kreise, "+init=EPSG:25832")

# säubern der Tabellen
# löschen nach Spaltennamen
nuts3_kreise[,c("id","FID","MOUNT_TYPE","LAU NAME NATIONAL","LEVL_CODE","LAU NAME LATIN","COAST_TYPE","COAST change compared to last year","CITY_ID","CITY_ID change compared to last year","CITY_NAME", "GREATER_CITY_ID","GREATER_CITY_ID change compared to last year","GREATER_CITY_NAME","FUA_ID" ,"FUA_ID change compared to last year",  "FUA_NAME","CHANGE (Y/N)","DEG change compared to last year")]= NULL
# umgruppieren nach Spaltenindex
nuts3_kreise[,c(1,2,3,14,4,5,6,7,8,9,10,11,12,15,16,17)]
```

```
## Simple feature collection with 400 features and 15 fields
## geometry type:  MULTIPOLYGON
## dimension:      XY
## bbox:           xmin: 280468 ymin: 5235855 xmax: 921238.6 ymax: 6101419
## projected CRS:  ETRS89 / UTM zone 32N
## First 10 features:
##    NUTS_ID CNTR_CODE             NUTS_NAME TOTAL AREA (km2) URBN_TYPE Kreis
## 1    DE111        DE Stuttgart, Stadtkreis           207.33         1 08111
## 2    DE112        DE             Böblingen            26.56         1 08115
## 3    DE113        DE             Esslingen             3.34         1 08116
## 4    DE114        DE             Göppingen             9.49         1 08117
## 5    DE115        DE           Ludwigsburg            10.15         1 08118
## 6    DE116        DE       Rems-Murr-Kreis            68.52         1 08119
## 7    DE117        DE Heilbronn, Stadtkreis            99.89         2 08121
## 8    DE118        DE  Heilbronn, Landkreis             9.66         2 08125
## 9    DE119        DE        Hohenlohekreis            64.68         3 08126
## 10   DE11A        DE       Schwäbisch Hall            90.17         3 08127
##    Beschaeftigte Beschaeftigte.Baugewerbe Anteil.Baugewerbe
## 1         344319                    11999        0.03484850
## 2         155017                     5097        0.03288026
## 3         178699                     9543        0.05340265
## 4          77103                     6306        0.08178670
## 5         165875                     8532        0.05143632
## 6         126212                     7869        0.06234748
## 7          61732                     1966        0.03184734
## 8         107661                     5529        0.05135564
## 9          46135                     2406        0.05215130
## 10         68472                     5050        0.07375277
##    Anteil.Hochschulabschluss Einkommen.Median Universitaeten.Mittel  Patente
## 1                 0.26424914             3631              438564.0 365.1500
## 2                 0.20488075             3801                   0.0 195.7210
## 3                 0.15511559             3147               31206.0 248.1260
## 4                 0.09536594             2870                8242.0  60.8690
## 5                 0.15887265             3063               25341.0 411.8070
## 6                 0.11638355             2896                   0.0 178.6590
## 7                 0.11166008             2858               22018.5  33.1814
## 8                 0.11916107             3057                   0.0 101.9680
## 9                 0.07861710             2962                6855.5  43.7738
## 10                0.08042704             2739                 603.0  40.0052
##    DEGURBA COASTAL AREA (yes/no)                       geometry
## 1        1                    no MULTIPOLYGON (((517913.6 54...
## 2        2                    no MULTIPOLYGON (((504766.1 54...
## 3        2                    no MULTIPOLYGON (((536978.7 54...
## 4        3                    no MULTIPOLYGON (((546037.5 54...
## 5        2                    no MULTIPOLYGON (((529190.5 54...
## 6        2                    no MULTIPOLYGON (((536577.5 54...
## 7        1                    no MULTIPOLYGON (((508327.4 54...
## 8        2                    no MULTIPOLYGON (((532201 5468...
## 9        2                    no MULTIPOLYGON (((562114.7 54...
## 10       3                    no MULTIPOLYGON (((580702.7 54...
```

```r
# abspeichern des Ergebnis nuts3_kreise als rds (r data stream)
saveRDS(nuts3_kreise,"nuts3_kreise.rds")

# 2 - Analyse
#--------------------
# findet in diesem Beispiel nicht statt


# 3 - Ergebnisausgabe und Visualisierung 
#--------------------
```
### Darstellung der Daten mit dem Paket `tmap`
`tmap` ist das derzeit wohl erfolgreichste und vielseitigste Kartographie-Paket in der R-Welt. Hier ein ganz einfaches Beispiel zuer Erzeugung statischer Karten. 

```r
# Einstellen der Plotausgabe 1 Reihe , zwei Abbildungen Beschriftungen Stil1
par(mfrow=c(1,2), las=1)
# Darstellung mit tmap Farbgebung nach Anteil.Baugewerbe
tm_shape(nuts3_kreise, projection = 25832) + 
  tm_polygons(c("Anteil.Baugewerbe","Anteil.Hochschulabschluss"),    breaks=seq(0,0.2, by=0.025))
```

![]({{ site.baseurl }}/assets/images/unit04/tmap-1.png)<!-- -->

*Abbildung 04-01-01: Statische Karte a) Anteil Baugewerbe, b) Anteil Hochschulabschluss*

### Darstellung der Daten mit mapview
Das Paket `mapview` eignet sich besonders für eine schnelle interaktive Visualisierung der Daten auf der Grundlage einer Vielzahl von webbasierten Karten. Gerade für die explorative Interpretation oder aber auch für die visuelle Überprüfung der korrekten Lage der Daten ist dieses Paket ein sehr gute Alltagsunterstützung.


```r
# Interaktive Darstellung mit Mapview Farbgebung nach Anteil.Baugewerbe
# note you have to switch the layers on the upper left corner
nuts3_kreise = readRDS(paste0(rootDIR,"nuts3_kreise.rds"))
mapview(nuts3_kreise,zcol="Anteil.Baugewerbe",breaks=seq(0,0.2, by=0.025))+mapview(nuts3_kreise,zcol="Anteil.Hochschulabschluss",breaks=seq(0,0.2, by=0.025))
```
Die Karte kann auch mit Hilfe des Pakets `mapview` interaktiv dargestellt werden.

{% include media url="/assets/misc/nuts3_kreise.html" %}
[Full-screen version of the map]({{ site.baseurl }}/assets/misc/nuts3_kreise.html){:target="_blank"}

*Abbildung 04-01-02: Dynamische Webkarte  mit den Layern a) Anteil Baugewerbe, b) Anteil Hochschulabschluss*

## Download Skript
Das Skript kann unter [unit04-01_sitzung.R]({{ site.baseurl }}/assets/scripts/unit04-01_sitzung.R){:target="_blank"} heruntergeladen werden

## Was ist zu tun?
Versuchen Sie  `R`, `Rstudio` und die notwendigen Pakete zu installieren. Bei Fragen nutzen Sie bitte das Forum. Falls erfolgreich Versuchen Sie bitte folgende Aufgaben zu bearbeiten:

* das Skript schrittweise durchzugehen. Das geht sehr einfach mit Cursor in die Zeile und Alt+Enter näheres siehe unter [Rstudio Hilfe Ausführen von Code](https://support.rstudio.com/hc/en-us/articles/200484448-Editing-and-Executing-Code) bzw. unter `Hilfe->Cheatsheets->Rstudio IDE cheatsheets`.
* nutzen Sie Rstudio um die Variableninhalte zu betrachten [Data Viewer](https://support.rstudio.com/hc/en-us/articles/205175388-Using-the-Data-Viewer)
* Versuchen Sie sich mit der Datenvisualisierung vertraut zu machen. Hierzu können Sie die Vignetten von `tmap` und `mapview` nutzen. [tmap](https://cran.r-project.org/web/packages/tmap/vignettes/tmap-getstarted.html), [mapview](https://r-spatial.github.io/mapview/articles/articles/mapview_01-basics.html)

