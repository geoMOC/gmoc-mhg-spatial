---
title: 'Sitzung 2: Big Data Zensus 2011'
toc: true
toc_label: Inhalt
---


Geodaten sind prinzipiell wie gewöhnliche Daten zu betrachten. Allerdings sind die Aspekte der Skala, der Zonierung (aggregierte  Flächeneinheiten), der Topologie (der Lage im Verhältnis zu anderen Entitäten) der Geometrie (Entfernung zueinander) eine Ableitung aus der Grundeigenschaft dass Geodaten eine Position im Raum besitzen. <!--more-->

Im Rahmen der räumlichen Statistik wirft das Fragen der räumlichen Autokorrelation bzw. Inhomogenität auf. Also letztlich Fragen welche Raumkonstruktion auf welcher Skala einen Einfluss auf meine Fragestellung hat.

Die klassischen Bereiche der räumlichen Statistik sind Punktmusteranalyse, Regression und Inferenz mit räumlichen Daten, dann die Geostatistik (Interpolation z.B. mit Kriging) sowie  Methoden zur lokalen und globalen Regression und Klassifikation mit räumlichen Daten. 

Nahezu alle dieser Bereiche basieren auf Daten die als [Vektordatenmodell]({{ site.baseurl }}{% link _unit02/unit02-02_reader_gi_raum.md %}) vorliegen. Das heisst es handelt sich um diskrete Geoobjekte die Null-, Ein- bzw. Zwei-dimensional Raumeigenschaften aufweisen.


## Lernziele
Die Handhabung aktueller und in der Regel großer Datenmengen ist in der quantitativen Auswertung von räumlichen Prozessen von erheblicher Bedeutung. Dabei gilt es gleich mehrere Probleme zu lösen:

* Was sind angemessene und aktuelle Daten für meine Fragestellung?
* Was sind offizielle Daten?
* Woher bekomme ich diese Daten?
* Wie bringe ich diese Daten in eine geeignete Form um sie statistisch auswerten zu können?

Die Lernziele der zweiten Übung sind:

---

* Recherche geeigneter offizieller räumlicher Daten zu soziökonomischen Parametern 
* Manipulation und Handhabung umfangreicher Datensätze (>> 10 Mio.) am Beispiel der Zensus Daten 2011
* Speicherung, Verschneidung und räumliche Operationen auf großen Daten
* Visualisierung der Daten


---
Dieser Teil ist umfangreich und sehr technisch. Leider ist die Datenmanipulation wirklich großer Datensätze einigermaßen herausfordernd für Maschinen und Analysten. Die Problematik liegt vorrangig in der ineffizienten Speichermethode von vektorbasierten Flächendaten in z.T. sehr alten Dateiformaten. Die Speicherung in räumlich organisierten Datenbanken, die auch mit grossen Datenmengen gut umgehen können ist jedoch aufwendig und komplex und bedarf ein deutlich vertieftes Wissen. 
Diese Problematik wird noch deutlicher wenn wir Daten räumlich inhomogen verteilt vorliegen haben - also nicht mit Flächendaten sondern mit Punktdaten arbeiten. 

Ein sehr gutes Beispiel sind die [Zensus-Daten](https://www.zensus2011.de/) aus dem Jahr 2011. Diese Daten sind nach einem [aufwendigen](https://www.zensus2011.de/SharedDocs/Downloads/DE/Publikationen/Aufsaetze_Archiv/2015_06_MethodenUndVerfahren.pdf?__blob=publicationFile&v=6) Verfahren erhoben worden und formal auf ein "Raster" von 100*100 Metern abgebildet worden. Also für jede dieser virtuellen Zellen gibt es eine Mittelpunktskoordinate an der vielfältige Daten angehangen sind. Ein [Beispiel für die Demographie](https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/Datensatzbeschreibung_Demograhie_100m_Gitter.xlsx?__blob=publicationFile&v=2) sieht wie folgt aus:

| Statistisches Bundesamt, Zensus 2011                                                           |          |                                                   |                                                                                                                                                    |
| ---------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Version 1; 13.02.2018                                                                          |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| **Merkmale und Merkmalsausprägungen**                                                          |          |                                                   |                                                                                                                                                    |
| **Bevölkerung je Hektar**                                                                      |          |                                                   |                                                                                                                                                    |
| **Ergebnisse des Zensus am 9. Mai 2011 in Gitterzellen**                                       |          |                                                   |                                                                                                                                                    |
|                                                                                        |          |                                                   |                                                                                                                                                    |
| Hier werden die Ausprägungen der einzelnen Merkmale aufgelistet.                               |          |                                                   |                                                                                                                                                    |
| Ausführliche Merkmalsdefinitionen sind auf dem Tabellenblatt "Merkmalsdefinitionen" zu finden. |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| **Merkmal**                                                                                    | **Code** | **Text**                                          | **Erläuterungen**                                                                                                                                  |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| INSGESAMT                                                                                      |          |                                                   | Gesamtzahl der Einheiten in der Gitterzelle<br>Kann aufgrund der Geheimhaltung von der Summe über alle Ausprägungen der anderen Merkmale abweichen |
|                                                                                                | 0        | Einheiten insgesamt                               |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| ALTER\_10JG                                                                                    |          |                                                   | Alter (10er-Jahresgruppen)                                                                                                                         |
|                                                                                                | 1        | Unter 10                                          |                                                                                                                                                    |
|                                                                                                | 2        | 10 - 19                                           |                                                                                                                                                    |
|                                                                                                | 3        | 20 - 29                                           |                                                                                                                                                    |
|                                                                                                | 4        | 30 - 39                                           |                                                                                                                                                    |
|                                                                                                | 5        | 40 - 49                                           |                                                                                                                                                    |
|                                                                                                | 6        | 50 - 59                                           |                                                                                                                                                    |
|                                                                                                | 7        | 60 - 69                                           |                                                                                                                                                    |
|                                                                                                | 8        | 70 - 79                                           |                                                                                                                                                    |
|                                                                                                | 9        | 80 und älter                                      |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| ALTER\_KURZ                                                                                    |          |                                                   | Alter (5 Altersklassen)                                                                                                                            |
|                                                                                                | 1        | Unter 18                                          |                                                                                                                                                    |
|                                                                                                | 2        | 18 - 29                                           |                                                                                                                                                    |
|                                                                                                | 3        | 30 - 49                                           |                                                                                                                                                    |
|                                                                                                | 4        | 50 - 64                                           |                                                                                                                                                    |
|                                                                                                | 5        | 65 und älter                                      |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| FAMSTND\_AUSF                                                                                  |          |                                                   | Familienstand (ausführlich)                                                                                                                        |
|                                                                                                | 1        | Ledig                                             |                                                                                                                                                    |
|                                                                                                | 2        | Verheiratet                                       |                                                                                                                                                    |
|                                                                                                | 3        | Verwitwet                                         |                                                                                                                                                    |
|                                                                                                | 4        | Geschieden                                        |                                                                                                                                                    |
|                                                                                                | 5        | Eingetr. Lebenspartnerschaft                      |                                                                                                                                                    |
|                                                                                                | 6        | Eingetr. Lebensparter/-in verstorben              |                                                                                                                                                    |
|                                                                                                | 7        | Eingetr. Lebenspartnerschaft aufgehoben           |                                                                                                                                                    |
|                                                                                                | 8        | Ohne Angabe                                       |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| GEBURTLAND\_GRP                                                                                |          |                                                   | Geburtsland (Gruppen)                                                                                                                              |
|                                                                                                | 1        | Deutschland                                       |                                                                                                                                                    |
|                                                                                                | 21       | EU27-Land                                         |                                                                                                                                                    |
|                                                                                                | 22       | Sonstiges Europa                                  |                                                                                                                                                    |
|                                                                                                | 23       | Sonstige Welt                                     |                                                                                                                                                    |
|                                                                                                | 24       | Sonstige                                          |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| GESCHLECHT                                                                                     |          |                                                   | Geschlecht                                                                                                                                         |
|                                                                                                | 1        | Männlich                                          |                                                                                                                                                    |
|                                                                                                | 2        | Weiblich                                          |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| RELIGION\_KURZ                                                                                 |          |                                                   | Religion                                                                                                                                           |
|                                                                                                | 1        | Römisch-katholische Kirche (öffentlich-rechtlich) |                                                                                                                                                    |
|                                                                                                | 2        | Evangelische Kirche (öffentlich-rechtlich)        |                                                                                                                                                    |
|                                                                                                | 3        | Sonstige, keine, ohne Angabe                      |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| STAATSANGE\_GRP                                                                                |          |                                                   | Staatsangehörigkeitsgruppen                                                                                                                        |
|                                                                                                | 1        | Deutschland                                       |                                                                                                                                                    |
|                                                                                                | 21       | EU27-Land                                         |                                                                                                                                                    |
|                                                                                                | 22       | Sonstiges Europa                                  |                                                                                                                                                    |
|                                                                                                | 23       | Sonstige Welt                                     |                                                                                                                                                    |
|                                                                                                | 24       | Sonstiges                                         |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| STAATSANGE\_HLND                                                                               |          |                                                   | Staatsangehörigkeit nach ausgewählten Ländern                                                                                                      |
|                                                                                                | 1        | Deutschland                                       |                                                                                                                                                    |
|                                                                                                | 2        | Bosnien und Herzegowina                           |                                                                                                                                                    |
|                                                                                                | 3        | Griechenland                                      |                                                                                                                                                    |
|                                                                                                | 4        | Italien                                           |                                                                                                                                                    |
|                                                                                                | 5        | Kasachstan                                        |                                                                                                                                                    |
|                                                                                                | 6        | Kroatien                                          |                                                                                                                                                    |
|                                                                                                | 7        | Niederlande                                       |                                                                                                                                                    |
|                                                                                                | 8        | Österreich                                        |                                                                                                                                                    |
|                                                                                                | 9        | Polen                                             |                                                                                                                                                    |
|                                                                                                | 10       | Rumänien                                          |                                                                                                                                                    |
|                                                                                                | 11       | Russ. Föderation                                  |                                                                                                                                                    |
|                                                                                                | 12       | Türkei                                            |                                                                                                                                                    |
|                                                                                                | 13       | Ukraine                                           |                                                                                                                                                    |
|                                                                                                | 14       | Sonstige                                          |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| STAATSANGE\_KURZ                                                                               |          |                                                   | Staatsangehörigkeit                                                                                                                                |
|                                                                                                | 1        | Deutschland                                       |                                                                                                                                                    |
|                                                                                                | 2        | Ausland                                           |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
|                                                                                                |          |                                                   |                                                                                                                                                    |
| STAATZHL                                                                                       |          |                                                   | Zahl der Staatsangehörigkeiten                                                                                                                     |
|                                                                                                | 1        | Eine Staatsangehörigkeit                          |                                                                                                                                                    |
|                                                                                                | 2        | Mehrere, deutsch und ausländisch                  |                                                                                                                                                    |
|                                                                                                | 3        | Mehrere, nur ausländisch                          |                                                                                                                                                    |
|                                                                                                | 4        | Nicht bekannt                                     |                                                                                                                                                    |

Quelle: [www.zensus2011.de/](https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/Datensatzbeschreibung_Demograhie_100m_Gitter.xlsx?__blob=publicationFile&v=2).

In dieser Datei sind > 66 Mio Datensätze im Textformat gespeichert. Wie kann damit sinnvoll umgegangen werden? Die Zensusdaten können von Bürger_innen durch ein [Webinterface](https://atlas.zensus2011.de/) abgerufen werden. Hierzu sind vorgefertigte Rasterdateien für *ausgewählte* Datensätze verfügbar gemacht worden. Die nachfolgende Druckversion der Karte zeigt ein Merkmal der oben stehenden Tabelle für den Raum Marburg-Biedenkopf.

<img src="{{ site.baseurl }}/assets/images/unit05/zensus_bev.png" width="500px" />

Quelle: [https://atlas.zensus2011.de/](https://atlas.zensus2011.de/)



## Einrichten der Umgebung

Zunächst ist es sinnvoll die Arbeitsumgebung einzurichten. Hier werden Die Pfade zum Arbeitsverzeichnis und alle benötigten Pakete geladen. Hier und in allen weiteren Programmbeispielen sind ausführliche Kommentare, die erläutern was warum gemacht wird. Es ist sehr ratsam dise zu Lesen und nach Möglichkeit zu verstehen.

```r
# 0 - Umgebung einrichten, 
#     Pakete und Funktionen laden
#     Variablen definieren
#---------------------

# rootDIR enthält nur den Dateipfad, 
# die Tilde ~ steht dabei für das Nutzer-Home-Verzeichnis unter Windows 
# üblicherweise Nutzer/Dokumente
# path.expand() erweitert den relativen Dateipfad 
# !dir.exists() überprüft ob der Pfad bereits existiert damit er falls nein angelegt werden kann
rootDIR=path.expand("~/Desktop/lehre/MHG_2021/sitzung2/")
if (!dir.exists(rootDIR)) dir.create(path.expand(rootDIR))
setwd(rootDIR)

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

```
## Datenaquise

Um zu reproduzierbaren Ergebnissen zu kommen sollten die Daten von den jeweiligen **offiziellen** Datenprovidern bezogen werden. Dies geschieht in der Regel durch Download. Hierzu ist es nötig die Datenquellenzu identifizieren und die entsprechenden Download-Adressn (URLs) zu kopieren. Ein Bilck in die Handbücher und Datenbeschreibungen wirkt zudem oft Wunder. Nachfolgender Code-Schnipsel besorgt dies für die Zensus Daten.
```r
  # ---- Zensus Daten
  # Download URLs der Zensusdaten https://www.zensus2011.de/
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
  
  # Download und Entpacken der Zensus 2011 Daten. Geht natürlich auch manuell
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
  # Erstellen einer Dateiliste (inkl. Pfad) die AUSSCHLIESSLICH die Zensus csv Dateien enthält. 
  # Zum Filtern werden sog. regex Ausdrücke verwendet
  # Liste im aktuellen Arbeitsverzeichnis und darunter liegenden Verzeichnissen ALLE Daten die  auf "100?.csv" enden
  # Das "?" ist notwendig da die Dateien mal 100m und mal 100M enthalten
  fn  =  list.files(pattern = "100.[.]csv$", path = getwd(), full.names = TRUE,recursive = TRUE)
 
 
```
Der nächste Schritt ist das schnelle Einlesen der Daten.

```r

  # Die Dateien sind z.T. > 5 GB daher ist ein extrem schnelles Einlesen der Daten mit data.table zwingend
  # erste Variable Grid-Kodierung + Gesamtbevölkerung
  # erste Datei aus der fn-Liste  Demographie
  grid_bevoelkerung_2011 = as_tibble(data.table::fread(paste0(rootDIR,"Zensus_Bevoelkerung_100m-Gitter.csv")))
  mz_demografie_2011 = as_tibble(data.table::fread(fn[1]))
  # kann angepasst werden
  # mz_familie_2011 = as_tibble(data.table::fread(fn[2]))
  # mz_haushalte_2011 = as_tibble(data.table::fread(fn[3]))
```
Mit `head(mz_demografie_2011)` können Sie sich die ersten Zeilen und die Dateistruktur anschauen.

Soweit so gut und auch nicht wirklich aufwendig (unter 10 Zeilen aktiver Code).


## Grundsätzliche Vorgehensweise skiziieren
Trotz dem einfachen Erfolg gibt es viele offene Fragen. Betrachten wir die Header-Daten (und schauen ins Handbuch) so sehen wir die räumliche Kodierung liegt als Datenbankschlüssel vor. In der Datei *Zensus_Bevoelkerung_100m-Gitter.csv* gibt es zusätzliche Koordinatenwerte mit der Bezeichnung `x_mp_100m, y_mp_100m` die jedoch **nicht** in den übrigen Dateien zu finden sind. Das Studium der Metadaten ergibt zusätzlich, dass die Daten in der Referenzierung `ETRS89-extended / LAEA Europe 3035` vorliegen. Eine Menge Informationen die eingeordnet werden müssen. 

Andererseits liegen keine Informationen über Landkreise Gemeinden oder Ortsnamen vor. Wir benötigen also zur Bearbeitung der unten stehenden Aufgabenstellung zumindest Gemeinde/Landkreisdaten und müssen diese mit den Zensusdaten verknüpfen.
Es wird also Zeit eine Aufgabenliste zu erstellen:
0. Lesen der HAndbücher und Datensatzbescheibungen (auszugsweise)
1. Recherche und Beschaffung von Gemeindegeometriedaten für 2011
2. (Optional) Recherche und Beschaffung von Landkreisgeometriedaten für 2011
3. Verknüpfung von Zensustabellen untereinander
4. Verknüpfung von Zensusdaten mit Gemeindegeometrien
5  Visualisierung

## Flächendaten

In einem föderalen System sind für offizielle Datensätze in der Regel sehr unterschiedliche Stellen zuständig. Gute Anlaufstellen sind das Statistische Bundesamt (destatis) die europäische Statistikbehörde (eurostat) und die das Bundesamt für Geodäsie und Kartographie. Darüber gibt es natürlich noch Landesämter und Einrichtungen des öffentlichen Rechts die hoheitliche Aufgaben übernehmen und schliesslich gibt es noch Stiftungen etc. Die Suche ist mühsam und es gibt keine zentralen Zusammenstellungen von Zuständigkeiten. 

Die folgende Liste soll ein wenig unterstützen:

* Die offiziellen Statisik-Verwaltungsgrenzen auf europäischer Ebene ([NUTS](https://de.wikipedia.org/wiki/NUTS)) werden von der Eurostat vorgehalten. 
   * [administrative-units-statistical-units](https://ec.europa.eu/eurostat/de/web/gisco/geodata/reference-data/administrative-units-statistical-units)
* Offizielle Zuweisungstabellen für Lokale Verwaltungseinheiten (LAU)  = > NUTS3 Konversion (eurostat)
   * [local-administrative-units](https://ec.europa.eu/eurostat/de/web/nuts/local-administrative-units)
* Offizielle Geometriedaten der Gemeindeflächen  (Bundesamt für Geodäsie und Kartographie)
   * [Verwaltungsgebiete 1:250000](https://gdz.bkg.bund.de/index.php/default/open-data/verwaltungsgebiete-1-250-000-mit-einwohnerzahlen-ebenen-stand-31-12-vg250-ew-ebenen-31-12.html)
* Offizielle Gemeindeverzeichnisse (Statistische Bundeamt destatis). Die Gemeindeliste wird benötigt um die jeweils gültigen Gemeindenamen mit anderen Datenquellen zu verküpfen
  * [Gemeindeverzeichnis Beschreibung](https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/_inhalt.html)
  * [Gemeindeverzeichnis Tabelle](https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/beschreibung-gebietseinheiten.pdf?__blob=publicationFile)
* Aktuelle Gemeindedaten für Statistiken vorzuhalten ist in Deutschland kommunale Hoheit. Die Bertelsmannstiftung sammelt solche Daten bereitet sie auf und stellt sie zur Verfügung  
  * [Kommunale Daten](https://www.wegweiser-kommune.de/uber-den-wegweiser ) Bertelsmann-Stiftung

Nun gilt es diese Daten zu beschaffen ihre Struktur zu sichten und für unsere Aufgaben vorzubereiten.

```r
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
```

Damit liegen alle Daten vor. 

## Aufgabenstellung

Bitte bearbeiten Sie folgende Aufgabenstellung:
* Extrahieren Sie für einen Landkreis/Bundesland Ihrer Wahl alle Zensusdaten.
* Erzeugen Sie ein sf Objekt das die Geometrie und diese Daten enthält
* Visualisieren Sie diese Daten mit mapview 


## Was ist sonst noch zu tun?
Sobald wir unsere Tabellendaten als Geotabellendaten vorliegen haben (z.B. Gemeindeflächendaten als sf Objekt) können wir auf mächtige Pakete zur Visualisieurng und on-the-fly Analyse zurückgreifen. Beispielhaft sollen `tmap` und `mapview` gezeigt werden.

* versuchen sie sich an der verlinkten Hilfe auf der Geocomuptation with R Ressource. Sie sollen Sie zum aktiven Umgang mit `R` ermuntern.
* *spielen* Sie mit den Einstellungen, lesen Sie Hilfen und lernen Sie schrittweise die Handhabung von R kennen. 
* **stellen Sie Fragen im Forum, im Kurs oder per email mit dem Betreff [M&S2020]**

## Wo gibt's mehr Informationen?
Für mehr Informationen kann unter den folgenden Ressourcen nachgeschaut werden: 

* [Geocomputation with R](https://geocompr.robinlovelace.net) von Robin Lovelace, Jakub Nowosad und Jannes Muenchow ist die herausragende Referenz für alles rund um  raumzeitliche Datenanalyse und -verarbeitung mit R. 
* [Making Maps with R](https://geocompr.robinlovelace.net/adv-map.html) bietet eine sehr gelungen Einstieg in das Thema. 

## Download Skript
Das Skript kann unter [skript_sitzung_2_0.R ]({{ site.baseurl }}/assets/scripts/skript_sitzung_2_0.R ){:target="_blank"} heruntergeladen werden

