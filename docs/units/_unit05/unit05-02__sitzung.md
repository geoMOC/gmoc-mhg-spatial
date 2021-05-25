---
title: 'Sitzung 2: Big Data Mikrozensus 2011'
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

* Handhabung grosser Daten am Beispiel der Mikrozensus Daten 
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



## Aufgabenstellung

Bitte bearbeiten Sie folgende Aufgabenstellung:
* Extrahieren Sie für einen Landkreis/Bundesland Ihrer Wahl alle Mikrozensusdaten.
* Erzeugen Sie ein sf Objekt das die Geometrie und diese Daten enthält
* visualisieren Sie diese Daten mit mapview 



