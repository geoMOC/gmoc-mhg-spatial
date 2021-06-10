#-------------------------------------------------------------------------------
# skript_sitzung_2_1.R 
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
# --- Schritt 1 Download und Vorbereitung der Mikrozensus Daten
# # Schalter auswahl = "mikrozensus"
auswahl = "mikrozensus"
mz_read=FALSE
source(paste("../skript_sitzung_2_0.R"))

# --- Schritt 2 Download und Vorbereitung der Geometriedaten
# Schalter auswahl = "NUTS"
auswahl = "NUTS"
source(paste("../skript_sitzung_2_0.R"))

# ---- Start Datenmanipulation und Analyse
#- 

# ------------
# - Beispiel 1  Mikrozensus Tabellen in eine SQLITE Datenbank einlesen
# ------------

# ACHTUNG die aktuelle Datei ist > 10 GB!
mydb <- dbConnect(RSQLite::SQLite(), paste0(rootDIR,"mikrozensus2011_BD_2.sqlite"),cache_size = "2000000")
dbWriteTable(mydb, "grid_bevoelkerung_2011", data.table::fread(paste0(rootDIR,"Zensus_Bevoelkerung_100m-Gitter.csv")))
dbWriteTable(mydb, "mz_demografie_2011", data.table::fread(fn[1]))


# listen aller enthaltenen tables
dbListTables(mydb)

# Zur Nutzung von dplyr das wesentlich einfacher zu bedienen ist als SQL
# ist es sinnvoll via dplyr::tbl auf eine spezifische Tabelle zu verlinken
gb_link  =  tbl(mydb,"grid_bevoelkerung_2011")
demo_link  =  tbl(mydb, "mz_demografie_2011")


# Die Daten können auch physisch einlgelesen werden aber das ist EXTREM langsam und ein Speichertod 
# NICHT empfohlen
# d_echt<- dbReadTable(mydb, dbListTables(mydb)[2]) 

# SQL Abfrage nach alle Ledigen in Deutschland
query <- "SELECT*FROM mz_demografie_2011 WHERE Auspraegung_Text =='Ledig'"
ledig = dbGetQuery(mydb, query)


# dplyr macht es r-ish heisst es erzeugt SQL Code via R syntax
# dplyr Abfrage nach alle Ledigen in Deutschland
demo_link %>%   filter(Auspraegung_Text =='Ledig') 

# Ausgabe der ersten 10 Zeilen
head(demo_link, n = 10)

# Pipen einer Anfrage
demo_link %>% 
  filter(Merkmal == "ALTER_KURZ") %>% 
  select(Gitter_ID_100m,Auspraegung_Code,Auspraegung_Text,Anzahl)  %>% group_by(Auspraegung_Code) %>% count()

# Abfrage über ein inner_join d.h. die erste Tabelle bildet die Referenz
ew25 = gb_link %>%
  filter(Einwohner > 25) %>%
  inner_join(demo_link) %>%
  collect()

# Schliessen der Datenbank
dbDisconnect(mydb)

# ------------
# - Beispiel 2  Gemeindedaten Mikrozensus 2011 
# ------------

# Zusammenführen der Informationen in eine Tabelle über die Schlüsselspalte "Gitter_ID_100m"
# dplyr::inner_join()ordnet jeder y zeile eine X Zeile zu. ACHTUNG die Reihenfolge ist wichtig!
# Geht natürlich auch mit tibble Tabellen Zum Einlesen der Daten als tibble() den Schalter mz_read=TRUE setzen
# Beide folgenden  Aufrufe sind identisch. Das  %>%  collect() ist notwendig um die Daten physisch in die Variable zu schreiben
mz_2011_BD = gb_link %>%
  inner_join(demo_link,by = "Gitter_ID_100m") %>%  collect()
# mz_2011_BD_2 = inner_join(demo_link,gb_link, by = "Gitter_ID_100m") %>%  collect()

# Projizieren der Gemeinden auf 3035
gemeinden_sf_3035 = st_transform(gemeinden_sf, 3035)
# Zuschneiden der Gemeindedaten auf Kreis MRBiko 06=Hessen 5=RPGiessen 34=MRBiko
MRBiKo_3035 = st_crop( gemeinden_sf_3035 %>% filter(substr(AGS,1,5)=="06534"),gemeinden_sf_3035)
# Grobe Filterung der Datentabelle auf das umlaufende Rechteck der Ausdehnung MRBiKo
MR_mz_2011_BD = mz_2011_BD %>% filter(x_mp_100m >=st_bbox(MRBiKo_3035)[1] & x_mp_100m <= st_bbox(MRBiKo_3035)[3] & y_mp_100m >= st_bbox(MRBiKo_3035)[2] & y_mp_100m <= st_bbox(MRBiKo_3035)[4] )


# Konvertieren der Tabelle in einen räumlichen sf Vektordatensatz Projektion 3035
MR_mz_2011_BD_sf_3035 = sf::st_as_sf(MR_mz_2011_BD ,
                                     coords = c("x_mp_100m", "y_mp_100m"),
                                     crs = 3035,
                                     agr = "constant")

# Exaktes Zuschneiden auf den Landkreis MRBiKo mit Hilfe von st_intersection()
MRBiKo_mz_2011_BD_sf_3035 = st_intersection(MR_mz_2011_BD,MRBiKo_3035)

# Öffnen der Datenbank
mydb <- dbConnect(RSQLite::SQLite(), paste0(rootDIR,"mikrozensus2011_BD.sqlite"),cache_size = "2000000")
sf::dbWriteTable(mydb, value=MRBiKo_mz_2011_BD_sf_3035, name = "MRBiKo_mz_2011_BD_sf_3035")
# Lesen aus der DB
MRBiKo =  read_sf(mydb, "MRBiKo_mz_2011_BD_sf_3035")
# Schliessen der Datenbank
dbDisconnect(mydb)

# Verschiedene Auswertungsmöglichkeiten
# "Klassisches" data frame subsetting für die unter 18 Jährigen
u18_1 = MRBiKo_mz_2011_BD_sf_3035[MRBiKo_mz_2011_BD_sf_3035$Einwohner>0 & MRBiKo_mz_2011_BD_sf_3035$Merkmal == "ALTER_KURZ" & MRBiKo_mz_2011_BD_sf_3035$Auspraegung_Code==1,]

# dplyr subsetting für die unter 18 Jährigen
u18_2 = MRBiKo %>% filter(Einwohner>0 & Merkmal == "ALTER_KURZ" & Auspraegung_Code==1) 

# dplyr subsetting mit Selektion
alter    = MRBiKo %>% filter(Einwohner>0 & Merkmal == "ALTER_KURZ") %>% group_by(Auspraegung_Code)  %>% select(AGS,GEN,Auspraegung_Code,Auspraegung_Text,EWZ,Anzahl,Einwohner)

# Visualisierung mit mapview unter Verwendung der Pipe
mapview(MRBiKo_3035,zcol="EWZ")+
  alter  %>% filter(Auspraegung_Code==1) %>% mapview(zcol="Anzahl",cex = "Anzahl", layer.name = "Unter 18", at = seq(1, 151, 25),alpha.regions=0.2)  +
  alter  %>% filter(Auspraegung_Code==2) %>%  mapview(zcol="Anzahl",cex = "Anzahl", layer.name =  "   18-29",at = seq(1, 151, 25),alpha.regions=0.2) +
  alter  %>% filter(Auspraegung_Code==3) %>%  mapview(zcol="Anzahl",cex = "Anzahl", layer.name = "   30-49",at = seq(1, 151, 25),alpha.regions=0.2)  +
  alter  %>% filter(Auspraegung_Code==4) %>%  mapview(zcol="Anzahl",cex = "Anzahl", layer.name = "    50-65",at = seq(1, 151, 25),alpha.regions=0.2) +
  alter  %>% filter(Auspraegung_Code==5) %>%  mapview(zcol="Anzahl",cex = "Anzahl", layer.name = " über 65",at = seq(1, 151, 25),alpha.regions=0.2) 

# Visualisierung mit tmap interaktiv
tmap_mode("view")
tm_shape(MRBiKo_3035) + 
  tm_fill("EWZ", palette = "YlOrRd", 
          title = "Einwohner", 
          breaks = c(0,5000,10000,20000,30000,40000,50000,60000,100000), colorNA = "darkgrey") + tm_borders("grey25",alpha = 0.7, lwd = 0.1)+
  tm_shape(u18_2)+
  tm_dots(group="Anzahl", size="Anzahl",col="Anzahl", palette = "viridis") 

# Visualisierung mit tmap interaktiv
tmap_mode("plot")
tm_shape(MRBiKo_3035) + 
  tm_fill("EWZ", palette = "YlOrRd", 
          title = "Einwohner", 
          breaks = c(0,5000,10000,20000,30000,40000,50000,60000,100000), colorNA = "darkgrey") + tm_borders("grey25",alpha = 0.7, lwd = 0.1)+
  tm_shape(u18_2)+
  tm_dots(group="Anzahl", size="Anzahl",col="Anzahl", palette = "viridis") 