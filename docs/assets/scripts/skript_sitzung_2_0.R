#-------------------------------------------------------------------------------
# skript_sitzung_2_0.R 
# Autor: Chris Reudenbach, creuden@gmail.com
# Urheberrecht: Chris Reudenbach 2021 GPL (>= 3)
#
# Beschreibung: Das vorliegende Skript zeigt exemplarisch das Laden und Säubern 
#               von Mikrozensus2011-, Bertelsmann Stiftung- Gemeinde- und
#               verschiedenskaligen Flächendaten (Verwaltungsgeometrien) 
#              
#
# Eingabe:      URLs für:
#                        - Mikrozensus Daten (www.zensus2011.de), 
#                        - NUTS Geometrien in einem GDAL kompatiblen Dateiformat,
#                        - Gemeinde-Geometrien in einem GDAL kompatiblen Dateiformat
#                        - Bertelsmann Gemeindedaten 2006-2019
#               
#
# Ausgabe:      Simple Feature (sf) Vektordaten-Objekte
#               sqlite Datenbanken 
#
# Anmerkungen:  Das Beispiel dient als Vorlage für ein typisches Echt-Welt-Szenario 
#               da offizielle/gültige Daten immer von den zuständigen 
#               Behörden/Institutionen bezogen und für die eigene Datenauswertung
#               eingelesen und gesäubert werden müssen.
#-------------------------------------------------------------------------------



# 0 - Umgebung einrichten, 
#     Pakete und Funktionen laden
#     Variablen definieren
#---------------------



#-- Laden der benötigten libraries (Pakete) Dies sollte IMMER zu Beginn und nicht
#  irgendwo im Skriptes erfolgen, da sonst Funktionen und Abhängigkeiten nicht kontrollierbar sind
# 1) Definition der Liste mit den Paketnamen 
# 2) Check ob installiert falls nicht wird es installiert ist
#    utils::installed.packages() 
libs= c("sf","mapview","tmap","RColorBrewer","usedist","downloader","tidyverse","DBI","RSQLite","readr","readxl","openxlsx","listviewer")
for (lib in libs){
  if(!lib %in% utils::installed.packages()){
    utils::install.packages(lib)}
}
# Laden aller Pakete mit lapply() (= "integrierte for Schleife" für Listen) 
# Übergabe des Paketnamen als Text an die Funktion library(), invisible() verbirgt output
invisible(lapply(libs, library, character.only = TRUE))

#-- Nutzerdefinierte Funktionen
# waiting() ist eine Funktion die das System die angegebenen Sekunden pausiert dient z.B. einem nice scraping von Websites
waiting  =  function(x) {
  p1  =  proc.time()
  Sys.sleep(x)
  proc.time() - p1 }

#-- Definition benötigter globaler Variablen
#  (Beliebige) Eckkordinaten um den Landkreis Marburg-Biedenkopf (CRS 3035)
#  Die Koordinaten werden mit  sf::st_box in konvertiert 
mr_box=st_bbox(c(xmin = 4160033, xmax = 4367802, ymax =3139843, ymin = 3012279), crs = st_crs(3035))
# Projektion der Boxdaten in das amtliche CRS 25832
mr_box_3035 = st_bbox( st_transform( st_as_sfc(mr_box), 3035))



# 1 - Daten Daten Download und grundlegende Datensäuberung
#
#     (1) Download der Mikrozensus 2011 Daten
#     (2) Download der Geometriedaten (NUTS) von Eurostat
#     (3) Download der Zuordnungstabellen (Lokale Verwaltungseinheiten (LAU)) von Eurostat
#     (4) Download der Geometriedaten der Gemeindeflächen  (Bundesamt für Geodäsie und Kartographie)
#     (5) Download der offiziellen Gemeindeverzeichnisse (Statistisches Bundeamt) 
#     (6) Download der Bertelsmann Stiftung Gemeinde-Daten
#
# Alle Daten werden "gesäubert" und in die amtliche europäische Projektion CRS 23035 gebracht
# Hierzu werden sinnvollerweise angepasste und daher unterschiedliche Strategien verfolgt. 
# Diese können als Beispiel oder auch Vorlage für weiter/zukünftige eigene Datenmanipulationen dienen
# Für ALLE Datensätze gilt: Sie müssen gefunden und nutzbar gemacht werden. Klingt einfacher als es ist.
# Dazu ist viel googlen und das Lesen der Datenbeschreibungen zwingend!
#--------------------
cat(
  "Das Skript führt folgende Aktionen durch:\n
(1) Download der Mikrozensus 2011 Daten 
(2) Download der Geometriedaten (NUTS) von Eurostat 
(3) Download der Zuordnungstabellen (Lokale Verwaltungseinheiten (LAU)) von Eurostat 
(4) Download der Geometriedaten der Gemeindeflächen  (Bundesamt für Geodäsie und Kartographie) 
(5) Download der offiziellen Gemeindeverzeichnisse (Statistisches Bundeamt) 
(6) Download der Bertelsmann Stiftung Gemeinde-Daten\n
ACHTUNG: Die Daten sind zum Teil sehr umfangreich.\n Bitte nicht einfach 'durchlaufen' lassen sondern gezielt nutzen.
"
)
waiting(3)

if ( auswahl=="mikrozensus"){
  # ---- Mikrozensus Daten
  # Download URLs der Mikrozensusdaten https://www.zensus2011.de/
  # Exemplarisch wird nur mit den Kategorien Bevoelkerung und Demographie gearbeitet 
  # Die csv_Bevoelkerung_100m_Gitter.zip Datei enthält die Geokoordinaten 
  # als x y Spalten in der Refrenzierung ETRS89-extended / LAEA Europe 3035
  # Bei Bedarf können die auskommentierten URLs aktiviert werden
  url=list()
  url$demo_grund_2011="https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Bevoelkerung_100m_Gitter.zip?__blob=publicationFile&v=3"
  url$demographie_2011="https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Demographie_100m_Gitter.zip?__blob=publicationFile&v=2"
  #url$familien_2011="https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Familien_100m_Gitter.zip?__blob=publicationFile&v=2"
  #url$haushalte_2011="https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Haushalte_100m_Gitter.zip?__blob=publicationFile&v=2"
  #url$haueser_2011="https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Gebaeude_100m_Gitter.zip?__blob=publicationFile&v=2"
  #url$wohnungen_2011="https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Wohnungen_100m_Gitter.zip?__blob=publicationFile&v=5"
  
  # Download und Entpacken der Mikrozensus 2011 Daten. Geht natürlich auch manuell
  for (mzu in url){
    # Download hierzu wird die URL aus der Liste einzeln in der Variable mzu verwendet der Ausgabedateiname wird durch paste0(...) erzeugt
    if (!file.exists( paste0(rootDIR,strsplit(basename(mzu),".",fixed=TRUE)[[1]][1],".zip")))
    res  =  curl::curl_download(mzu, paste0(rootDIR,strsplit(basename(mzu),".",fixed=TRUE)[[1]][1],".zip"), quiet = FALSE)
    # Das Entpacken muss evtl. manuell durchgeführt werden hier wird mit 7zip gearbeitet, das auf dem OS installiert sein muss
    print("Das Entpacken muss evtl. von Hand durchgeführt werden, \nda je nach Betriebssystem > 4GB Darteien von R nicht korrekt entpackt werden können\nund daher 7zip installiert sein muss")
    # Entzippen hier mit einem sogenannten Kommandozeilen-Aufruf über die Funktion system() 
    # Der zusammengesetzte Textstring paste(...) ist ein Befehlsaufruf der in der Shell die externe Software 7zip startet
    system(paste0("7z e -o.", " ", paste0(rootDIR,strsplit(basename(mzu),".",fixed=TRUE)[[1]][1],".zip")),
           intern = FALSE,
           ignore.stdout = FALSE,
           ignore.stderr = TRUE,
           wait = FALSE)
  }
  # Erstellen einer Dateiliste (inkl. Pfad) die AUSSCHLIESSLICH die Mikrozensus csv Dateien enthält. 
  # Zum Filtern werden sog. regex Ausdrücke verwendet
  # Liste im aktuellen Arbeitsverzeichnis und darunter liegenden Verzeichnissen ALLE Daten die  auf "100?.csv" enden
  # Das "?" ist notwendig da die Dateien mal 100m und mal 100M enthalten
  fn  =  list.files(pattern = "100.[.]csv$", path = getwd(), full.names = TRUE,recursive = TRUE)
  if (mz_read){
  # Die Dateien sind z.T. > 5 GB daher ist ein extrem schnelles Einlesen der Daten mit data.table zwingend
  # erste Variable Grid-Kodierung + Gesamtbevölkerung
  # erste Datei aus der fn-Liste  Demografie
  grid_bevoelkerung_2011 = as_tibble(data.table::fread(paste0(rootDIR,"Zensus_Bevoelkerung_100m-Gitter.csv")))
  mz_demografie_2011 = as_tibble(data.table::fread(fn[1]))
  # kann angepasst werden
  # mz_familie_2011 = as_tibble(data.table::fread(fn[2]))
  # mz_haushalte_2011 = as_tibble(data.table::fread(fn[3]))
  }
} else if ( auswahl == "NUTS"){
  # ---- Offizielle NUTS Geometriedaten (also die GI Daten für die NUTS3 Kreise)
  # Die offiziellen Verwaltungsgrenzen für Deutschland werden von der Eurostat vorgehalten. 
  # https://ec.europa.eu/eurostat/de/web/gisco/geodata/reference-data/administrative-units-statistical-units
  # In diesem Falle als sogenanntes GeoJson Format (GDAL kompatibel)
  if (!file.exists(paste0(rootDIR,"ref-nuts-2016-01m.geojson.zip")))
  download(url = "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/download/ref-nuts-2016-01m.geojson.zip",
           destfile = paste0(rootDIR,"ref-nuts-2016-01m.geojson.zip")) 
  # Entpacken des Archivs 
  # ACHTUNG die korrekte Archiv-Datei "ref-nuts-2016-01m.geojson.zip" wurde 
  # anhand der Datenbeschreibung manuell identifiziert
  unzip(zipfile = paste0(rootDIR,"ref-nuts-2016-01m.geojson.zip"),
        exdir = rootDIR, 
        overwrite = TRUE)
  # mit dem Paket sf und der Funktion sf_read lesen wir sie in eine Variable
  nuts3 = st_read(paste0(rootDIR,"NUTS_RG_01M_2016_3857_LEVL_3.geojson"))
  # Deutschland-Kreise durch data frame Filterung auf Wert "DE" in Spalte CNTR_CODE
  nuts3_de = nuts3[nuts3$CNTR_CODE=="DE",]
  # Projektion der Geometriedaten von Pseudo-Merkator 3857 in ETRS89-extended / LAEA Europe 3035
  nuts3_3035 = st_transform(nuts3_de, 3035)
  
  # ---- Offizielle Zuweisungstabellen für Lokale Verwaltungseinheiten (LAU)  = > NUTS3 Konversion (eurostat)
  # https://ec.europa.eu/eurostat/de/web/nuts/local-administrative-units
  if (!file.exists(paste0(rootDIR,"EU-28-LAU-2019-NUTS-2016.xlsx")))
  download(url = "https://ec.europa.eu/eurostat/documents/345175/501971/EU-28-LAU-2019-NUTS-2016.xlsx",
           destfile =paste0(rootDIR,"EU-28-LAU-2019-NUTS-2016.xlsx"))
  # Einlesen der xlsx Exceldatei (Daten für Deutschland sind im Datenblatt (=sheet) "DE")
  conv_lau_nuts3 = readxl::read_xlsx(path.expand(paste0(rootDIR,"EU-28-LAU-2019-NUTS-2016.xlsx")),
                                     sheet = "DE")
  
  # ----  Offizielle Geometriedaten der Gemeindeflächen  (Bundesamt für Geodäsie und Kartographie)
  # https://gdz.bkg.bund.de/index.php/default/open-data/verwaltungsgebiete-1-250-000-mit-einwohnerzahlen-ebenen-stand-31-12-vg250-ew-ebenen-31-12.html
  if (!file.exists(paste0(rootDIR,"gemeinden.zip")))
  download(url ="https://daten.gdz.bkg.bund.de/produkte/vg/vg250-ew_ebenen_1231/aktuell/vg250-ew_12-31.tm32.shape.ebenen.zip",
           destfile = paste0(rootDIR,"gemeinden.zip"))
  # Entpackt werden nur die benötigten Dateien (da es das SHP-Format handelt sind es mindestens 3 + Projektion also diese vier)
  unzip(zipfile = paste0(rootDIR,"gemeinden.zip"),
        files = c("vg250-ew_12-31.tm32.shape.ebenen/vg250-ew_ebenen_1231/VG250_GEM.shp",
                  "vg250-ew_12-31.tm32.shape.ebenen/vg250-ew_ebenen_1231/VG250_GEM.dbf",
                  "vg250-ew_12-31.tm32.shape.ebenen/vg250-ew_ebenen_1231/VG250_GEM.shx",
                  "vg250-ew_12-31.tm32.shape.ebenen/vg250-ew_ebenen_1231/VG250_GEM.prj"),
        exdir = "gemeinden/",
        junkpaths = TRUE)
  # Einlesen mit sf::sf_read 
  gemeinden_sf = st_read("gemeinden/VG250_GEM.shp")
  # Projektion der Geometriedaten von ETRS89 / UTM zone 32N (N-E) 3044 in ETRS89-extended / LAEA Europe 3035
  gemeinden_sf_3035 = st_transform(gemeinden_sf, 3035)
  
  # ---- Offizielle Gemeindeverzeichnisse (Statistische Bundeamt destatis) 
  # Die Gemeindeliste wird benötigt um die jeweils gültigen Gemeindenamen mit anderen Datenquellen zu verküpfen
  # Dafür sind teils umfangreiche Säuberungsmaßnahmen notwendig
  # https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/_inhalt.html
  # https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/beschreibung-gebietseinheiten.pdf?__blob=publicationFile
  # Laden der korrekten Gemeindeliste (Gemeinden > 5000 Einwohner ist kompatibel zu den Bertelsmann Daten)
  # ACHTUNG Durch kontinuierliche Gebietreformen existieren zu unterschiedlichen Stichjahren unterschiedliche Gemeinden/Kreise etc.
  # Einlesen erfolgt diesmal mit openxlsx::read.xlsx() zur einfacheren Steuerung der einzulesenden Matrix
  gemeinde_liste_raw = openxlsx::read.xlsx("https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/Archiv/Standardtabellen/07_GemeindenVorjahr.xlsx?__blob=publicationFile",
                                           sheet = "Gemeinden ab 5 000 Einwohnern",
                                           startRow = 8,
                                           colNames = FALSE,
                                           rowNames = FALSE,
                                           cols = c(2:7))
  #- Einlesen und allgemeine Listen
  # Erzeugen des LAU2 Codes aus den einzelnen Schlüsseln (siehe Datensatzbeschreibung)
  gemeinde_liste_LAU=paste0(gemeinde_liste_raw$X1,gemeinde_liste_raw$X2,gemeinde_liste_raw$X3,gemeinde_liste_raw$X4,gemeinde_liste_raw$X5)
  
  # Einlesen der Namensliste 
  gemeinde_liste_NAMES= stringr::str_split(gemeinde_liste_raw[1:nrow(gemeinde_liste_raw),6], ",",simplify = TRUE)[,1]
  
  # LAU2 + "normale" Namensliste für späteren Gebrauch
  gemeindeliste_combi=cbind(gemeinde_liste_LAU,gemeinde_liste_NAMES)
}  else if ( auswahl =="bertel"){
  # ---- Download der Bertelsmann Stiftung Gemeinde Daten
  # -
  # Aktuelle Gemeindedaten für Statistiken vorzuhalten ist in Deutschland kommunale Hoheit und wer 
  # Länderhoheit kennt ahnt bereits was das heißt
  # Die Bertelsmannstiftung sammelt solche Daten bereitet sie auf und stellt sie zur Verfügung  https://www.wegweiser-kommune.de/uber-den-wegweiser 
  # Nach Analyse der Seite ist klar dass für mindestens 10 Datenkategorien und 14 Jahre 
  # Daten für Gemeinden > 5000 Einwohner (2930)  für einen manuellen Downlad verfügbar sind
  # Für eine Automatisierung (da sonst ca. 120000  mal klicken) müssen zunächst die korrekten Downloadlinks erzeugt werden 
  # Beispiel: https://www.wegweiser-kommune.de/statistik/altdorf-bei-nuernberg+beschaeftigung+2006-2019+tabelle.xls
  
  # ACHTUNG: Bei dem direkten Download über die Webseite wird irgendwann der Hahn abgedreht (Zitat):
  # "Sie scheinen sich sehr für die Daten des Wegweisers Kommune zu interessieren. 
  # Gerne stellen wir Ihnen ein umfangreiches Datenset für nicht kommerzielle Zwecke zur Verfügung. 
  # Bitte haben Sie Verständnis, dass entsprechend große Datenmengen nicht direkt über unsere Website heruntergeladen werden können.
  # Kontaktieren Sie uns per E-Mail an info@wegweiser-kommune.de oder telefonisch unter (05241) 81 81 311."
  
  
  
  #- Teil1: Erzeugen der "Bertelsmann-Stiftung-Namen" aus der Gemeindeliste
  # Säubern für "Bertelsmann-Stiftung" kompatible Download-Namen
  # Für unser Beispiel nutzen wir Hessen
  # Filtern der Ursprungsliste auf die Gemeinden von Hessen (Landeskennziffer 06)
  hessen_kommunen=gemeinde_liste_raw %>% filter(X1=="06")
  # Säubern in mehreren Schritten um die von Bertelsmann benötigten URL-Textstrings zu erzeugen
  gemeinde_liste_HESSEN= stringr::str_split(hessen_kommunen[1:nrow(hessen_kommunen),6], ",",simplify = TRUE)[,1]
  # Säubern der Abkürzungen
  # gsub() ersetzt die gesuchten Zeichen. Das geht auch eleganter so ist es aber verständlicher
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN,pattern = "b.",replacement = "-bei-",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = "a.d.",replacement = "an-der-",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = "a. d.",replacement = "an-der-",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = "a.",replacement = "am-",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = "v. d.",replacement = "von-der-",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = "i. Odw.",replacement = "im-odenwald",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = " ",replacement = "-",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = ")",replacement = "",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = "(",replacement = "",fixed = TRUE)
  gemeinde_liste_HESSEN =gsub(gemeinde_liste_HESSEN ,pattern = "--",replacement = "-",fixed = TRUE)
  
  # Visuelle Inspektion ist sinnvoll weil vllt noch einige Abkürzungen übersehen wurden
  listviewer::jsonedit(gemeinde_liste_HESSEN)
  
  #- Teil1: # Erzeugen einer Download-URL Gemeinde/je Datenkategorie
  # Die csv Datei ist problematisch aufgrund der UTF8 Kodierung daher wird Excel ausgewählt
  # Definition der notwendigen Argumente
  # Namensliste der Gemeinden 
  gemeindeliste = gemeinde_liste_HESSEN
  # Basis-URL
  url=c("https://www.wegweiser-kommune.de/statistik/")
  # Datenkategorien (Auszug)
  kategorien= c("beschaeftigung","qualifikation","pendler","bildung","demographischer-wandel","finanzen","integration","nachhaltigkeit-sdgs","pflege","soziale-lage")
  # startjahr kann zwischen 2006 und 2019 angepasst werden
  startjahr="2006"
  # endjahr kann zwischen 2006 und 2019 angepasst werden
  endjahr="2019"
  
  # Initialisierung der Listenvariable
  url_gemeinde_liste=list()
  # Die Kategorien werden in einzelne Listen geschrieben. Kann durch zb. seq(1:3) statt seq(1:length(kategorien)) beliebig gesteuert werden
  for (i in seq(1:length(kategorien))){
    url_gemeinde_liste[[i]]=paste0(url,tolower(gemeindeliste),"+", kategorien[i],"+",startjahr,"-",endjahr,"+tabelle.xls",sep="")
  }
  # Visuelle Inspektion
  listviewer::jsonedit(url_gemeinde_liste)
  
  #- Teil 3: Download und Säubern der Daten (exemplarisch)
  # Daten liegen (uneinheitlich) in deutscher Notation (Tausendertrennzeichen = "." / Dezimaltrennzeichen="," vor
  # k.A. statt NA für "keine Daten/Angaben"
  
  # Zählvariable wird initialisiert
  i=1
  # Ausgabevariable wird als tibble-Tabelle (data.frame) initialisiert
  gemeinde_tab_all=tibble()
  
  # für jede Gemeinde (hier für die Gemeinden 1-10 der Liste [1:10])
  # und für jede Kategorie: [[1]] heisst also für Kategorie 1 = Beschäftigung
  for (u in url_gemeinde_liste[[1]]){
    # Check ob die Datei bereits existiert falls nicht download
    if (!file.exists(gsub("\\+","_",paste0(rootDIR,strsplit(basename(u),".",fixed=TRUE)[[1]][1],".xlsx"))))
      download.file(url = u,destfile =  gsub("\\+","_",paste0(rootDIR,strsplit(basename(u),".",fixed=TRUE)[[1]][1],".xlsx")),quiet = FALSE,overwrite=TRUE)
    # Hier kann in Sekunden eine Wartezeit angegeben werden um den Server nicht zu überlasten
    # waiting(runif(1, 5. , 15.))
    # Einlesen der Daten
    data=readxl::read_xlsx(gsub("\\+","_",paste0(rootDIR,strsplit(basename(u),".",fixed=TRUE)[[1]][1],".xlsx")), skip = 12, guess_max = 10)
    # Löschen der Tausendertrennung
    data=as_tibble(do.call(cbind,(lapply(data, function(x) { gsub("\\.", "",x)}))))
    # Ersetzen Komma durch Punkt (Dezimaltrennung)
    data=as_tibble(do.call(cbind,(lapply(data, function(x) { gsub(",", ".",x)}))))
    # Ersetzen von kA durch NA
    data=as_tibble(do.call(cbind,(lapply(data, function(x) { gsub("kA", "NA",x)}))))
    # Alle leeren Zellen mit NA beschreiben
    data=as_tibble(do.call(cbind,(lapply(data, function(x) { gsub("kA", "NA",x)}))))
    # Ersetzen von \n durch " "
    data=as_tibble(do.call(cbind,(lapply(data, function(x) { gsub("\n", " ",x)}))))
    # Erzeugen der Spalte mit dem Ortsnamen für die spätere Zuordnung (join)
    # Erzeugen der Spaltenbeschriftung  zu ausschliesslich den Jahreszahlen
    data$GEN=strsplit(names(data)[length(data)],split = "\n")[[1]][1]
    new_names=stringr::str_split(names(data), "\n",simplify = TRUE)[,2]
    new_names[1]=stringr::str_split(names(data), "\n",simplify = TRUE)[1,1]
    new_names[length(data)]=strsplit(names(data)[length(data)],split = "\n")[[1]][1]
    # Austausch der Spaltenbeschriftung  
    names(data)= new_names
    # Konvertierung der Tabelle von Character zu numeric
    data=as.data.frame(type_convert(data))
    # Anhängen der Ortstabelle n+1 an die vorherige Gesamttabelle
    gemeinde_tab_all=add_row(data,gemeinde_tab_all)
    # +1 zählen
    i=i+1
  }
  # Ausschreiben der Daten in eine CSV Datei die den Kategoriennamen enthält
  data.table::fwrite(gemeinde_tab_all,gsub("\\+","_",paste0(rootDIR,kategorien[1],"_gemeinde_daten_bertelsmann_hessen.csv")))
}