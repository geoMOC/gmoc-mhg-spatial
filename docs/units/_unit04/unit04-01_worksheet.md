---
title: Warmup - Datensäuberung und Visualisierung
toc: true
toc_label: In this worksheet
---


Datenanalyse und Datenvisualisierung ist in der Regel begleitet von einer umfangreichen Vorbereitung der Daten. Üblicherweise kann dies von Hand mit einem Editor oder automatisiert durch entsprechende Scripte erfolgen. <!--more-->Insbesondere für die Reproduzierbarkeit und die einfache Anpassung weiterer Vorverarbeitungsschritte ist es oft sinnvoll sich mit einer automatischen Datenvorprozessirrung zu beschäftigen. Dies kann oft sehr mühevoll sein. Ungeachtet der Herausforderungen die sich einem Anfänger entgegenstellen ist es der Mühe wert da nicht nur im wissenschaftlichen Sinne Reproduzierbarkeit des vollständigen Arbeitsablaufs höchste Priorität hat sondern die gesamte Analyse von den Rohdaten bis zu den Ergebnissen transparent nachvollziehbar bleibt. 


## Lernziele

Die Lernziele der ersten Übung sind:

---

  * Installation von R Rstudio und den notwendigen Libraries
  * Erste Schritte mit R
  * Aufbereitung und Darstellung eines zusammengesetzten Datensatzes 
 
---

Im nachfolgenden Skript werden einigige wichtige Techniken der R-Programmiersprache benutzt. Einige kennen Sie bereits andere sind im Reader R-Intro erklärt. Vor allem die beiden "Arbeitspferde" für Wiederholungen `for` und Bedingungen `if` werden eingeführt. Bitte schauen sie für die grundsätzliche Funktionsweise in den Reader.


```r
# 0 --- Arbeitsablauf
# Das nachfolgende Script verbindet die Daten der Datei Kreise2010.csv mit 
# von von Eurostat zur Verfügung gestellten NUTS3 Geometriedaten (Vektordaten der Kreise)
# Um diese Verbinden zu können bedarf es in dem vorliegenden Fall einer weiteren Tabelle
# Diese stellt die Verbindung zwischen denen in der Datei Kreise2010.csv verwendeten LAU Kodierung
# und der NUTS3 Kodierung her.
# Um diese Beiden Tabellen verbinden zu können müßen einige Manipulationen an den  Daten vorgenommen werden
# Im letzten Schritt wird die gesäuberte Datentabelle über die NUTS3 Codes an die Geometrie an gehangen und mit 
# mapview und tmap visualisiert

# 1---  Vorbereitung der Arbeitsumgebung
## Säubern der Arbeitsumgebung
rm(list=ls())
## festlegen des Arbeitsverzeichnisses
# rootDIR enthält nur den Dateipfad
# die Tilde ~ steht dabei für das Nutzer-Home-Verzeichnis unter Windows 
# üblicherweise Nutzer/Dokumente
# mit setwd() wird das working directory festgelegt
rootDIR="~/Schreibtisch/spatialstatSoSe2020/"
setwd(rootDIR)

## laden der benötigten libraries
# wir definieren zuerst eine liste mit den paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits intalliert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("sf","mapview","tmap","ggplot2","RColorBrewer","jsonlite","tidyverse")
for (lib in libs){
if(!lib %in% utils::installed.packages()){
  utils::install.packages(lib)
}}
# nicht wundern lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))

# 2---  Herunterladenund Einlesen der Daten

# Aus dem Statistikkurs lesen wir die Kreisdaten ein
# Sie sind aus Bequemlichkeitsgründen auf github verfügbar

download.file(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/Kreisdaten2010.csv",     destfile = "Kreisdaten2010.csv")


# von eurostat holen wir die Geometriedaten (also die GI Daten für die NUTS3 Kreise)
download.file(url = "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/download/ref-nuts-2016-01m.geojson.zip",
              destfile="nuts3.zip")
# entpacken des Archivs
unzip("nuts3.zip")

# mit dem Paket sf und der Funktion sf_read lesen wir sie in eine Variable
nuts3 = st_read("NUTS_RG_01M_2016_3857_LEVL_3.geojson")

# Um nur Deutschland Kreise zu erhalten filtern wir sie 
# auf den Wert "DE" in der Spalte CNTR_CODE
# Achtung wir legen eine neue Variable für Deutschland an
nuts3_de = nuts3[nuts3$CNTR_CODE=="DE",]

# herunter laden der offiziellen Zuweisungstabellen für Lokale Verwaltungseinheiten (LAU) <-> NUTS3 Konversion
# https://ec.europa.eu/eurostat/de/web/nuts/local-administrative-units
# https://ec.europa.eu/eurostat/documents/345175/501971/EU-28-LAU-2019-NUTS-2016.xlsx
download.file(url = "https://ec.europa.eu/eurostat/documents/345175/501971/EU-28-LAU-2019-NUTS-2016.xlsx",
              destfile = "EU-28-LAU-2019-NUTS-2016.xlsx")

# wir lesen es direkt aus der xlsx Exceldatei ein. Da die Deutschlanddaten im
# Datenblatt "DE" abgespeichert sind lesen wir nur dieses sheet ein
lau_nuts3 = readxl::read_xlsx("EU-28-LAU-2019-NUTS-2016-1.xlsx",sheet = "DE")

# 3---  Säubern und Vorbereiten der Daten

# die unten eingeladene LAU-Kodierung enthält 8 Stellen wobei die letzen beiden lokale Untegruppen darstellen
# daher muss bei 4 Ziffern der Kreise Tabelle eine führende Null vorangestellt werden
# dies geschieht durch Abffrage der Stellen im der entsprechenden Spalte
Kreise$Kreis[nchar(Kreise$Kreis) < 5] = paste0("0",Kreise$Kreis[nchar(Kreise$Kreis) < 5])

# bei der LAU Tabelle sind die letzten 3 Ziffern für Unterregionen von Nuts3 daher können sie ignoriert werden
# einfache lösung die zeichenkette (character) wird auf die passende länge abgeschnitten
# dazu muss dem data.frame Feld "LAU CODE" die von 1-5 gekappte Spalte zugewieden werden
lau_nuts3$`LAU CODE`=substr(lau_nuts3$`LAU CODE`,start = 1,stop = 5)

# jetzt müssen nur noch die Duplikate entfernt werden Das Ausrufezeichen ist dabei die Verneinung 
# also sollen die nicht-Duplikate in der Spalte "LAU CODE" behalten werden
lau_nuts3 = lau_nuts3[!duplicated(lau_nuts3[,"LAU CODE"]),]

# nun gilt es die beiden bereinigten Tabellen nach diesen beeiden Spalten zusammen zu führen
lookup_merge_kreise = merge(Kreise,  lau_nuts3,
           by.x = "Kreis", by.y = "LAU CODE")

# und zuletzt wird diese Tabelle an die Geometrie angehengen
nuts3_kreise = merge(nuts3_de,lookup_merge_kreise,
            by.x = "NUTS_ID", by.y = "NUTS 3 CODE")

# Projektion in die die amtliche deutsche Projection ETRS89 URM32
nuts3_kreise = st_transform(nuts3_kreise, "+init=EPSG:25832")


# 4---  Visualisierung der Daten

# map it with mapview
# note you have to switch the layers on the upper left corner
mapview(nuts3_kreise,zcol="Anteil.Baugewerbe",breaks=seq(0,0.2, by=0.025))+mapview(nuts3_kreise,zcol="Anteil.Hochschulabschluss",breaks=seq(0,0.2, by=0.025))

# map it with tmap
tm_shape(nuts3_kreise, projection = 25832) + 
  tm_polygons(c("Anteil.Baugewerbe","Anteil.Hochschulabschluss"),    breaks=seq(0,0.2, by=0.025))


```
## Download Skript
Das Skript kann unter [arbeitsblatt_01]({{ site.baseurl }}/assets/scripts/arbeitsblatt_01.R){:target="_blank"} heruntergeladen werden

## Bearbeiten Sie…
Versuchen Sie  `R`, `Rstudio` und die notwendigen Pakete zu installieren. Bei Fragen nutzen Sie bitte das Forum. Falls erfolgreich Versuchen Sie bitte folgende Aufgaben zu bearbeiten:

* das Skript schrittweise durchzugehen. Das geht sehr einfach mit Cursor in die Zeile und Alt+Enter näheres siehe unter [Rstudio Hilfe Ausführen von Code](https://support.rstudio.com/hc/en-us/articles/200484448-Editing-and-Executing-Code) bzw. unter `Hilfe->Cheatsheets->Rstudio IDE cheatsheets`.
* nutzen Sie Rstudio um die Variableninhalte zu betrachten [Data Viewer](https://support.rstudio.com/hc/en-us/articles/205175388-Using-the-Data-Viewer)
* Versuchen Sie sich mit der Datenvisualisierung vertraut zu machen. Hierzu können Sie die Vignetten von `tmap` und `mapview` nutzen. [tmap](https://cran.r-project.org/web/packages/tmap/vignettes/tmap-getstarted.html), [mapview](https://r-spatial.github.io/mapview/articles/articles/mapview_01-basics.html)

