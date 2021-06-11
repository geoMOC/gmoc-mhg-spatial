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
# Anmerkungen: Die Daten wurden zuvor heruntergeladen und eingelesen. Sie sind als RDS Daten im Repository des Kurses zu finden.
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
#rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
#setwd(rootDIR)
# die Tilde ~ steht dabei für das Nutzer-Home-Verzeichnis unter Windows 
# üblicherweise Nutzer/Dokumente

## laden der benötigten libraries
# wir definieren zuerst eine liste mit den Paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits installiert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("sf","mapview","tmap","RColorBrewer","usedist","downloader")
for (lib in libs){
if(!lib %in% utils::installed.packages()){
  utils::install.packages(lib)
}}
# lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))


# 1 - Daten Vorverarbeitung
#--------------------


##- Laden der Rohdaten
#--------------------

# Aus dem Statistik-Kurs lesen wir die Kreisdaten ein
# Sie sind aus Bequemlichkeitsgründen auf github verfügbar

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/Kreisdaten2010.csv",     destfile = "Kreisdaten2010.csv")

# Aus dem Statistikkurs lesen wir die Kreisdaten ein
Kreise <- read.table ("Kreisdaten2010.csv",header=T,sep=';')

# LAden der Geometriedaten (also die GI Daten für die NUTS3 Kreise)
download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/nuts3.rds",     destfile = "nuts3.rds")

# Einlesen der nuts3 Daten
nuts3 = readRDS("nuts3.rds")

# Um nur Deutschland Kreise zu erhalten filtern wir sie 
# auf den Wert "DE" in der Spalte CNTR_CODE
# Achtung wir legen eine neue Variable für Deutschland an
nuts3_de = nuts3[nuts3$CNTR_CODE=="DE",]

# laden der offiziellen Zuweisungstabellen für Lokale Verwaltungseinheiten (LAU) <-> NUTS3 Konversion

# LAden der Geometriedaten (also die GI Daten für die NUTS3 Kreise)
download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/lau_nuts3.rds",     destfile = "lau_nuts3.rds")

# Einlesen der nuts3 Daten
lau_nuts3 = readRDS("lau_nuts3.rds")


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
nuts3_kreise = nuts3_kreise[,c(1,2,3,14,4,5,6,7,8,9,10,11,12,15,16,17)]

##-  Säubern und Vorbereiten der Daten
#------------------------------------

# 2 - Analyse
#--------------------
# findet in diesem Beispiel nicht statt
```
### Darstellung der Daten mit dem Paket `tmap`
`tmap` ist das derzeit wohl erfolgreichste und vielseitigste Kartographie-Paket in der R-Welt. Hier ein ganz einfaches Beispiel zuer Erzeugung statischer Karten. 

```r
# 3 - Ergebnisausgabe und Visualisierung 
#--------------------
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
mapview(nuts3_kreise,zcol="Anteil.Baugewerbe",breaks=seq(0,0.2, by=0.025))+mapview(nuts3_kreise,zcol="Anteil.Hochschulabschluss",breaks=seq(0,0.2, by=0.025))
```
Die Karte kann auch mit Hilfe des Pakets `mapview` interaktiv dargestellt werden.

{% include media url="/assets/misc/nuts3_kreise.html" %}
[Full-screen version of the map]({{ site.baseurl }}/assets/misc/nuts3_kreise.html){:target="_blank"}

*Abbildung 04-01-02: Dynamische Webkarte  mit den Layern a) Anteil Baugewerbe, b) Anteil Hochschulabschluss*

## Download Skript
Das Skript kann unter [unit04-01_sitzung.R]({{ site.baseurl }}/assets/scripts/unit05-01_sitzung.R){:target="_blank"} heruntergeladen werden

## Was ist zu tun?
Versuchen Sie  `R`, `RStudio` und die notwendigen Pakete zu installieren. Bei Fragen nutzen Sie bitte das Forum oder senden eine email. Falls Sie das erfolgreich absolvieren konnten, versuchen Sie bitte folgende Aufgaben zu bearbeiten:

* gehen Sie das Skript schrittweise durch. Es kommt nicht darauf an dass Sie den Code bereits vollständig verstehen. Sie sollen nur eine grobe Idee bekommen was gerade durchgeführt wird. Für den schrittweisen Aufruf können Sie einfach mit dem Cursor in die jeweilige Zeile gehen (nichts markieren) und dann Alt+Enter drücken s.a. [RStudio Hilfe Ausführen von Code](https://support.rstudio.com/hc/en-us/articles/200484448-Editing-and-Executing-Code) bzw. unter `Hilfe->Cheatsheets->Rstudio IDE cheatsheets`.
* nutzen Sie RStudio um die Variableninhalte zu betrachten [Data Viewer](https://support.rstudio.com/hc/en-us/articles/205175388-Using-the-Data-Viewer)
