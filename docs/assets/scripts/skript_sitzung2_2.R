#-------------------------------------------------------------------------------
# skript_sitzung2.R 
# Autor: Chris Reudenbach, creuden@gmail.com
# Urheberrecht: Chris Reudenbach 2021 GPL (>= 3)
#
# Beschreibung: Das vorliegende Skript zeigt exemplarisch das Laden und Säubern 
#               von Mikrozensus 2011, Bertelsmann Stiftung Gemeindedaten und
#               verschiedenskaligen Flächendaten (Verwaltungsgeometrien) 
#               Diese werden exemplarisch über räumliche oder kategoriale 
#               Merkmale verbunden und visualisiert.
#               Weiterhin wird der Export in eine sqlite Datenbank und 
#               grundsätzliche Analysen mit Hilfe der SQL Schnittstelle gezeigt.
#
# Eingabe:      Tabelle (CSV) mit Mikrozensus Daten (www.zensus2011.de), 
#               NUTS Geometrie in einem GDAL kompatiblen Dateiformat,
#               Gemeinde-Geometrien in einem GDAL kompatiblen Dateiformat
#               Bertelsmann Gemeindedaten 2006-2019
#
# Ausgabe:      Simple Feature (sf) Objekt mit allen Tabelleninhalten
#               sqlite Datenbank mit allen tabelleninhalten
#
# Anmerkungen:  Die Daten werden als Echt-Welt-Szenario von den zuständigen 
#               Behörden/Institutionen heruntergeladen, eingelesen und gesäubert
#-------------------------------------------------------------------------------


#-- Säubern der Arbeitsumgebung
rm(list=ls())
#-- Definition des Arbeitsverzeichnisses
# rootDIR enthält nur den Dateipfad, 
# die Tilde ~ steht dabei für das Nutzer-Home-Verzeichnis unter Windows 
# üblicherweise Nutzer/Dokumente
# path.expand() erweitert den relativen Dateipfad 
# !dir.exists() überprüft ob der Pfad bereits existiert damit er falls nein angelegt werden kann
rootDIR=path.expand("~/Desktop/lehre/MHG_2021/sitzung2/")
if (!dir.exists(rootDIR)) dir.create(path.expand(rootDIR))
setwd(rootDIR)

# --- Schritt 1 Download und Vorbereitung der Mikrozensus Daten
# # Schalter auswahl = "mikrozensus"
auswahl = "bertel"
mz_read=FALSE
source(paste("../skript_sitzung_2_0.R"))

# --- Schritt 2 Download und Vorbereitung der Geometriedaten
# Schalter auswahl = "NUTS"
auswahl = "NUTS"
source(paste("../skript_sitzung_2_0.R"))

# ---- Start Datenmanipulation und Analyse
#- 

# ------------
# - Beispiel 4  Gemeindedaten Bertelsmannstiftung
# ------------

# Erzeugen einer Hessen Geometrie für die Gemeinden
gemeinden_hessen_sf_3035 = gemeinden_sf_3035 %>% filter(SN_L=="06")

# merge der Gemeindegeometrien mit den aktuellen Datentabellen über die Spalte GEN
Bertel_HESSEN  = full_join(gemeinden_hessen_sf_3035 , gemeinde_tab_all)

# welche Indikatoren gibt es?
unique(Bertel_HESSEN $Indikatoren)

# Filtern der Bevölkerung und Beschäftigungsquoten
Anzahl_Bevoelkerung=Bertel_HESSEN  %>% filter(Indikatoren=="Bevölkerung (Anzahl)")
Beschäftigungsquote=Bertel_HESSEN  %>% filter(Indikatoren=="Beschäftigungsquote (%)")
Frauenbeschäftigungsquote=Bertel_HESSEN  %>% filter(Indikatoren=="Frauenbeschäftigungsquote (%)")
# Visualisierungsbeispiel mit Mapview
# Achtung NUR die Gemeinden > 5000 Ew. sind mit Datenzur Visualisierung versehen
jahr="2011"
mapview(gemeinden_hessen_sf_3035,alpha.regions=0.1,map.types="OpenStreetMap")+
  mapview(Anzahl_Bevoelkerung,zcol=jahr )+
  mapview(Beschäftigungsquote,zcol=jahr )+
  mapview(Frauenbeschäftigungsquote,zcol=jahr )


