---
title: Geographische Daten
toc: true
toc_label: Inhalt
---

Trotz der bisherigen Erläuterungen ist die Beantwortung der Frage „Was sind geographische Daten bzw. Geodaten?“ nicht richtig greifbar. Bislang erscheint die Abstraktion willkürlich und nicht nachvollziehbar zu sein.

Geodaten oder geographische Daten (singl. Datum) liefern räumlich fixierte, maschinenlesbare Konstrukte aus Zeichen, Bildern oder Funktionen die mit entsprechenden Interpretationsregeln zu Informationen werden. Da Daten Interpretationsvorschriften benötigen, um zu Informationen zu werden, müssen wir dieses Wissen nur noch mit dem Ziel, eine geographische Repräsentation der Welt durchzuführen, verbinden.

Die zentrale Fragestellung lautet: Was ist spezifisch geographisch und wie können wir diese geographische Ableitungen der Wirklichkeit durchführen? Ein typisches Beispiel für Geodaten ist in folgender Aussage kodiert:

**Die Temperatur am Havanna Airport betrug am Donnerstag, den 17.09.2009 um 08:00 lokaler Zeit 23.0°C. Die Koordinaten lauten: 22° 59′ 21″ N, 82° 24′ 33″ W, 64 m ü. MSL.**

Analysieren wir diese Aussage so finden wir alle wesentlichen Elemente der geographischen Repräsentation eines Echtweltobjekts. Die Aussage verbindet Raum (Koordinaten und Höhe) mit Zeit (Datum/Zeitangabe) und der Eigenschaft bzw. dem Attribut der Lufttemperatur. Zusätzlich sind dem derart festgelegten Ort weitere Eigenschaften zugeordnet: Havanna und Airport. Aus dieser Aussage kann schließlich folgendes geographisches Datum gebildet werden:

**22° 59′ 21″ N; 82° 24′ 33″ W; 64 m ü. MSL; 8.00 Uhr LT; Havanna Airport; 23.0 °C**

Geographische Daten verbinden somit räumlich eindeutig verortete Objekte mit mindestens einer Merkmalsausprägung. Diese „Daten-Primitive“ können natürlich beliebig komplex werden und darüber hinaus direkt oder auch indirekt zueinander in Beziehung gesetzt bzw. voneinander abgeleitet werden. Auch scheinbar nicht geographische Aussagen wie:

„Der K2 hat den schwersten Normalweg eines 8000er Gipfels“

können in ein geographisches Datum überführt werden. Hierzu sind weitere Kenntnisse bzw. Dekodierungsvorschriften notwendig. So muss man wissen dass K2 der international bekanntere Namen des *Lambha Pahar*, des zweithöchsten Berges der Erde ist. Weiterhin muss bekannt sein, welche geographischen Koordinaten seinen Gipfel repräsentieren und dass „Normalweg“ im Alpinistenjargon der „am häufigsten begangene und in der Regel einfachste Aufstieg“ bedeutet. Aus dieser Interpretation wird somit das geographische Datum:

** 35° 53′ 0″ N; 76° 31′ 0″ O; Lambha Pahar; K2; >8000 m ü. MSL; schwerster Normalweg 8000+**

## Die Merkmale von Raumobjekten
Schon anhand dieser beiden Beispiele wird deutlich, dass die Attribute von Raumobjekten nahezu beliebige Ausprägungen aufweisen können. Manche dieser Ausprägungen können physikalischer Natur sein oder beschreiben soziologische Aspekte, verweisen auf Eigentumsrechte, sind fortlaufende Nummern etc.. Sie können Orte identifizieren (z.B. Adressen) oder Räume (z.b. manche Postleitzahlen). Sie können Maßzahlen sein (z.B. Einwohner/Fläche) oder kategoriale Ausprägungen haben (beliebte Kneipe, unbeliebte Kneipe). Da es in den Wissenschaften üblich ist mit Werten, Attributen und ihren Ausprägungen zu arbeiten, sind diese auch im Bereich Geographischer Informationssysteme bekannt. Die Skalenniveaus sind bereits aus der Statistik bekannt und werden Nominal-, Ordinal- und Kardinalskala genannt. Sind Merkmalsausprägungen zeitabhängig werden sie als zyklisch bezeichnet.

So einfach Geodaten erzeugt werden können, begegnen wir einer bekannten Problematik. Es ist zwar eindrucksvoll die Temperatur am Flughafen von Havanna um 8.00 Uhr lokaler Zeit am 17.09.2009 als Repräsentation des Wetters verfügbar zu haben. Doch wie gut beschreibt diese Repräsentation des Wetters den Durchzug eines Hurrikans um 8.15 Uhr des gleichen Tages?

Die Welt ist prinzipiell beliebig komplex. Unsere Computer hingegen sind in ihren Möglichkeiten Merkmalsausprägungen zu verarbeiten und abzuspeichern extrem endlich!  Die Möglichkeiten unseres Gehirns liegen irgendwo dazwischen. Als Folge kann, aufgrund mentaler und technischer Beschränktheit, nur eine außerordentlich limitierte Anzahl von Merkmalsausprägungen in die Repräsentation von Echtwelt eingehen. Es besteht folglich die Notwendigkeit zur zielgerichteten Vereinfachung der Echtwelt. Um während der Entwicklung geographischer Repräsentationen einen objektivierbaren Rahmen für diese Vereinfachungen zu haben, werden diese immer skalenorientiert auf der  Raum- **und** Zeitskala durchgeführt.

Aufgrund der Vielzahl von Möglichkeiten zur Reduktionen in der Erdbeschreibung gibt es für diesen Prozess innerhalb der GI eine unüberschaubare Vielzahl von Konzepten und Vorgehensweisen. Die Frage einer sinnhaften, gültigen und zweckdienlichen Vereinfachung von Repräsentationen von Echtwelt wird uns ständig beschäftigen.


Geodaten sind Merkmalsausprägungen, die hinsichtlich eines spezifischen Zwecks,  Geoobjekten (diskrete Gegenstände oder kontinuierliche Raumeigenschaften) zielführend charakterisieren. Geoobjekte sind immer Repräsentationen real existierender Objekte, die durch eine Position im Raum direkt (z.B. durch Koordinaten = Geometrie) oder indirekt (z.B. durch Beziehungen = Topologie) referenzierbar (=verortet) sind. Sie sind immer formale Kodierungen der Eigenschaften und der zugehörigen Interpretation (=Informationen) dieser echten Objekte (vgl. Abb. 01-08).
{: .notice--info}

<html>
 <a  href="https://www.flickr.com/photos/environmentalinformatics-marburg/13898323961" title="01-08-Geoobjekt-schema1 by Environmental Informatics Marburg, on Flickr">``<img src="https://farm8.staticflickr.com/7419/13898323961_21d8beca23_n.jpg" width="80%"  alt="01-08-Geoobjekt-schema1"></a>
</html>

*Abbildung 01-08: Schematische Strukturierung eines Geoobjekts in räumliche, dynamische und inhaltliche Aspekte (GIS.MA 2009)*


## Bearbeiten Sie…
Versuchen Sie diese sehr abstrakte Sichtweise auf räumliche Daten und Informationen im GIS-Alltag wiederzufinden. Besuchen Sie die  folgenden Webseiten. 

Hier die Links:

*    [Öffentliche WCs in Australien](https://toiletmap.gov.au/Plan)
*    [Aktuelle Pegel Lahn](http://www.wetterbote.de/wetter/pegel/lahn.htm)
*    [Bad Arolsen](http://www.hlug.de/medien/luft/recherche/recherche.php?station=1115)
*    [Cineplex](http://www.cineplex.de/kino/home/city32/)

* Welche Merkmale/Merkmalsausprägungen werden genannt (evtl. auch welche werden nicht genannt)? 
* Ist die Abstraktion für den von Ihnen *vermuteten* Zweck (Zielsetzung) sinnvoll? 
* Ist der geographische Aspekt für Sie ersichtlich?
*  Gibt es formale/inhaltliche Unterschiede in der geographischen Repräsentation der Bad Arolsener Lufthygiene-Messstation und des Marburger Cineplex?


