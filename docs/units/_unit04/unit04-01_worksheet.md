---
title: Raum braucht einen Geltungsbereich
toc: true
toc_label: In this worksheet
---



## Lernziele

Die Lernziele der ersten Übung sind:

---

  * Einführung in Begrifflichkeiten und Definitionen
  * Installation von R Rstudio und den notwendigen Libraries
  * Aufbereitung und Darstellung eines zusammengesetzten Datensatzes 
 
---

## Einstieg in räumliche Daten


```
# Einlesen der libraries
library(sf)
library(mapview)
library(tmap)
library(ggplot)
library(jsonlite)

## Einlesen der Daten
# Aus dem Statistikkurs 
Kreise <- read.table ("Kreisdaten2010.csv",header=T,sep=';')

# Vektorgeometrien von Eurostat
download.file(url = "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/download/ref-nuts-2016-01m.geojson.zip",
              destfile="nuts3.json")

# Lookup-Tabellen Lokale Verwaltungseinheiten (LAU) <-> NUTS3 Konversion
# https://ec.europa.eu/eurostat/de/web/nuts/local-administrative-units
# https://ec.europa.eu/eurostat/documents/345175/501971/EU-28-LAU-2019-NUTS-2016.xlsx
download.file(url = "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/download/ref-nuts-2016-01m.geojson.zip",
              destfile="lkr.xlsx")
# mit Excel oder ähnlichem öffnen und nur den DE Reiter speichern
#lkr= readxl::read_xlsx("lkr.xlsx")

# einlesen der Lookuptabelle
lkr = read.table ("lkr.csv",header=T,sep=';' )

# Da die Kreise keine Endnullen besitzen werden die Spalten mit 100 multipliziert
Kreise$Kreis = as.numeric(Kreise$Kreis * 100)
# für den merge müssen beide Spalten den gleichen Datentyp enthalten
lkr$LAU.CODE = as.numeric(lkr$LAU.CODE)

# merge beide Tabellen bezogen auf die Lookupdaten
m_ = merge(Kreise,  lkr,
           by.x = c("Kreis"), by.y = c("LAU.CODE"),
           all.y = TRUE)
# Einlesen der Geometriedaten diese enthalten nur NUTS3 Kodierung

nuts3 = st_read("ref-nuts-2016-01m.geojson/NUTS_RG_01M_2016_3857_LEVL_3.geojson")

# klassisches data.frame filtern auf CNTR_CODE == DE also Deutschland
nuts3_de = nuts3[nuts3$CNTR_CODE=="DE",]

# merge der Geometriedaten mit der Tabelle
m_2 = merge(m, nuts3_de,
            by.y = c("NUTS_ID"), by.x = c("NUTS.3.CODE"),
            all.y = TRUE)

# visualisierung mit mapview
mapview(m2)
```