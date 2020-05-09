---
title: Best-Practice-Skripte
toc: true
toc_label: In diesem Arbeitsblatt
---



Die Meinungen darüber, wie ein Skript am besten zu strukturieren ist, gehen weit auseinander. Wir erstellen die einfachste Variante, ein Skript das Top Down abläuft.<!--more--> Es ist ein leicht durchschaubare und effektive Form um reproduzierbare Analysen zu gewährleisten.

### Kommentarblock zu Beginn des Skripts

Für den Anfang ist es eine Empfehlung, ein Skript mit einer Kopfzeile zu beginnen, die Informationen über den Autor des Skripts, den Zweck des Skripts, die Ein- und Ausgaben (falls zutreffend), die verwendeten/verwendbaren Daten und rechtliche Aspekte enthält. 

### Feste Struktur vermeidet Fehler
Es ist  sehr hilfreich, sich an eine feste Ablauf-Struktur zu halten. `Rstudio`  sammelt alle Variablen im Speicher und es sind schon viele sinnlose Stunden Arbeit entstanden weil auf *alte* Variableninhalte zugegriffen wurde oder mitten im Skript die Daten erneut manipuliert wurden. Gewöhnen sie sich daran eine strikte Struktur einzuhalten. Etwa zu Beginn jeden Skriptes ein definiertes Setup erstellen: Zuerst Arbeitsspeicher säubern, dann Pakete laden, dann weitere Skripte einlesen, dann Definieren von Variablen. Dann folgt die Datenvorverarbeitung dann die Analyse und so weiter.

Ein grundlegendes erstes Template kann wie folgt aussehen. Bitte beachten sie, dass sie nur sinnvolle Dinge in die Kopfzeilen schreiben, es ist keine Beschäftigungstherapie sondern dient der Klärung. Daher nutzen sie ausführlich die Möglichkeit Kommentare zu schreiben - selbst wenn auf den ersten Blick ihre Skriptdatei an Übersichtlichkeit verlieren sollte, werden sie sich im Verlaufe solcher Arbeiten irgendwann für eine gute Dokumentation feiern.



```r

# xyz.R 
# Autor: Chris Reudenbach, creuden@gmail.com
# Urheberrecht: Chris Reudenbach 2020 GPL (>= 3)
#
# Beschreibung: Skript verbindet Kreisdaten die mit Hilfe von LAU Schlüsseln
# kodiert sind mit einer von Eurostat zur Verfügung gestellten Geometrie.
#  
#
# Eingabe: Tabelle (ASCII) mit LAU Schlüsselspalte, Lookuptabelle LAU-NUTS, NUTS Geometrie in eine `GDAL` kompatiblen Dateiformat.
#
# Ausgabe:  Simple Feature(sf) Objekt mit allen Tabelleninhalten
#
# Anmerkungen: Die Daten werden im Skript heruntergeladen und eingelesen. Da diese mit statischen URLs und Dateinamen versehen sind müssen etwaige Veränderungen angepasst werden



# 0 - Umgebung einrichten, 
#     Pakete und Funktionen laden
#     Variablen definieren
#---------------------

## Säubern der Arbeitsumgebung
rm(list=ls())


# 1 - Daten Vorverarbeitung
#--------------------


# 2 - Analyse
#--------------------


# 3 - Ergebnisausgabe und Visualisierung 
#--------------------


```


## Benennung von Variablen und Kommentare


Auch wenn es aus dem Template ersichtlich ist, in `R` beginnen Zeilen die **nicht** ausgeführt werden sollen mit einem `#`. Diese Zeilen werden Kommentarzeilen genannt.

Die vielleicht wichtigste Konvention um Ordnung zu halten ist, bei der Benennung von Funktionen, Variablen usw. konsequent und sprechend zu bleiben. Das heißt gleiche Benennungssysteme für die Variablen und nach Möglichkeit Namen vergeben die in etwa erahnen lassen was in dieser Variablen gespeichert ist. Die Namen dürfen auch gerne länger sein zumal es Unterstützung von der `Autofill-Funktion` in Rstudio gibt...

Also für einen `data frame` der daten über die Beschäftigungsverhältnisse in Deutschland enthält, könnte der Namen `employment_germany` (snail case style genannt) oder `employmentGermany` (camel case style genannt) sinnvoll sein. Wichtig ist das Verständnis und es ist viel übersichtlicher Variablen immer in einem Stil mit gleicher konsequenter Groß-/Kleinschreibung zu benennen.



Für eine Vertiefung sind folgende Quellen einen Besuch wert - die Komplexität ist aufsteigend...<!--more-->
- [r-bloggers](https://www.r-bloggers.com/r-code-best-practices/){:target="_blank"} Einführung in bewährte Praktiken
- [Effiziente R-Programmierung](https://csgillespie.github.io/efficientR/coding-style.html){:target="_blank"} Kodierungsstil
- [USGS](https://owi.usgs.gov/blog/intro-best-practices/){:target="_blank"} Einführung bewährter Praktiken
