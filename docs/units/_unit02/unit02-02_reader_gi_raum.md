---
title: Raumrepräsentation in der GI
toc: true
toc_label: In this worksheet
---
## Raum im GIS

Wir haben bislang ständig und ohne besondere Vorüberlegungen mit den Begriffen Raum und Zeit gearbeitet. Um die bereits im Abschnitt [Objekte im Raum]({{ site.baseurl }}{% link _unit01/unit01-03_reader_geo_raum.md %}) vorgestellten Raumkonzepte (diskrete Geoobjekte, kontinuierliche Räume) in GI-Systemen und letztlich auch insgesamt wissenschaftlich nutzbar zu machen, müssen wir diese Begriffe konkreter fassen.

Der Raum in GI-Systemen wird in Anlehnung an die Mathematik und Physik als dreidimensionaler euklidischer Raum verstanden. Aus dem Mathematikunterricht kennen wir die euklidische Ebene (mit 2 Dimensionen) und den euklidischen Raum (mit 3 Dimensionen). Am einfachsten kann der euklidische Raum mit Hilfe eines kartesischen Koordinatensystems beschrieben werden, in dem die Koordinaten entlang senkrecht aufeinander stehender Achsen abgetragen sind (vgl. Abb. 02-1)

<html><a
href="http://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Cartesian-coordinate-system.svg/354px-Cartesian-coordinate-system.svg.png" title="Cartesian Coordinate System"> <img src="http://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Cartesian-coordinate-system.svg/354px-Cartesian-coordinate-system.svg.png" width="50%"  alt="Cartesian Coordinate System"></a> </html>

*Abbildung 02-01: Ausschnitt aus einem zweidimensionalen kartesischen Koordinatensystem mit 3 eingetragenen Punkten in Koordinatenschreibweise (Bolino 2008)*

<html><a
href="http://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/3D_coordinate_system.svg/487px-3D_coordinate_system.svg.png" title="3D Cartesian Coordinate System"> <img src="http://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/3D_coordinate_system.svg/487px-3D_coordinate_system.svg.png" width="50%"  alt="3D Cartesian Coordinate System"></a> </html>

*Abbildung 02-2: Allgemeine Abbildung eines dreidimensionales kartesischen Koordinatensystem mit euklidischen Ebenen durch den Ursprungspunkt (Sakurambo 2007)*

## Die Raumrichtungen 

Bislang haben wir von Geoobjekten als definierten Objekten mit eindeutiger Position (Koordinaten) gesprochen. Mit Hilfe der Koordinate (x- und y-Wert) kann im zweidimensionalen Raum die Position eines Punktes eindeutig festgelegt werden. In der Regel spielt auch die Höhe des Punktes, im Sinne von z. B. der Höhe über dem Meeresspiegel oder der Höhe über der Erdoberfläche, eine Rolle. Hierfür muss folglich auch die dritte Raumdimension (z-Wert) berücksichtigt werden (vgl. Abb. 02-2).

Wenn ein Geoobjekt durch einen Punkt repräsentiert wird, dann ist für eine eindeutige Verortung ein Punkt (x, y, z) im dreidimensionalen Raum ausreichend. Oft haben die in Karten oder GI-Systemen repräsentierten Geoobjekte aber auch selbst eine mehrdimensionale Ausbildung. Dabei versteht man unter der Dimension eines Geoobjektes die voneinander unabhängigen Raumrichtungen, die zur Repräsentation des Geoobjekts verwendet werden (vgl. Abb. 02-3). Diese korrespondieren mit den geometrischen Eigenschaften von Punkten, Strecken, Flächen und Körpern in einem kartesischen Koordinatensystem:
* 0D Geoobjekte: Punkte (Orte); keine Länge und Fläche (z.B. Messstation, Bohrpunkt)
* 1D Geoobjekte: Strecken; definiert durch eine Länge aber keine Fläche (Gewässerlängsprofil, vertikales Bodenprofil)
* 2D Geoobjekte: Flächen; definieren einen geschlossenen Linienzug (Sportplatz,  Stadtgebiet, Einzugsgebiet)
* 3D Geoobjekte: Körper; werden z. B. als Volumen-Körper (Solide) oder Grenzflächen-Körper (Polyeder) definiert (Grundwasserkörper, Atmosphäre).

<html>
<a href="https://www.flickr.com/photos/environmentalinformatics-marburg/13970512442" title="Abbildung 02-03: Dimensionalitäten by Environmental Informatics Marburg, on Flickr"><img src="https://farm8.staticflickr.com/7087/13970512442_289d700fb6.jpg" width="125%" alt="Dimensionalitäten"></a>
</html>


*Abbildung 02-03: Dimensionalität von Geoobjekten (verändert nach Bartelme 2005)*

Neben den räumlichen Merkmalen sind Geoobjekte durch weitere Eigenschaften charakterisiert (z. B. kann einem Fluss ein Name zugeordnet sein, einer Stadt die Einwohnerzahl etc.). Diese, nicht die räumliche Geometrie betreffenden Merkmale eines Geoobjektes, werden als Attribute bezeichnet und bilden die thematische Dimension. Die zeitliche Veränderung von Geoobjekten oder Systemen wird in der Regel 4. Dimension genannt.

## Die Lage im Raum

Für die vollständige und korrekte Repräsentation von Geoobjekten benötigen wir neben dem Ort (Geometrie) und der thematischen Dimension auch noch die relative Lage der Objekte zueinander. Die relative Lage von Geoobjekten zueinander wird als Topologie bezeichnet. Sie zu bestimmen erscheint zunächst einfach. Wir können die geometrische Situation nutzen, um Sie zu berechnen. Schwieriger ist es, wenn diese Punkte exakt die gleichen Raumkoordinaten aufweisen und sich nur in der Höhenangabe (Dimensionalität) unterscheiden, wie etwa in einem Gebäudeplan die Ausgänge eines Aufzugs oder wenn es nicht auf die exakte Lage zueinander ankommt, sondern auf Information was ist benachbart. Ein bekanntes Praxisbeispiel für eine topologische Betrachtungsweise ist ein Liniennetzplan der in Abbildung 02-4 die Buslinien und Haltestellen für Marburg dargestellt.

![Full screen version of the map]({{ site.baseurl }}/assets/images/unit02/mr_biko_net.png){:target="_blank"}

*Abbildung 02-04: Tagesliniennetzplan der Stadtwerke Marburg. Nur die wenigsten Menschen würden einen Netzfahrplan nutzen, um etwa eine Stadtbesichtigung zu Fuß zu planen, oder aber die geometrisch exakte Lage der Haltestellen zueinander zu ermitteln (Stadtwerke Marburg 2020)*


## Geometrie, Dimensionen und Topologie

In vielen, ja den meisten Situationen ist die korrekte Verknüpfung von Geometrie, Topologie und Dimension unerlässlich. Verbindet man unterschiedliche Geoobjekte zu komplexen Einheiten, kann es zu Überschneidungen, Lücken oder anderen räumlichen Zuständen der Repräsentation der Wirklichkeit kommen. Bei Karten kennen wir dieses Problem nicht, da die bildhafte Wiedergabe der repräsentierten Welt zwangsweise zweidimensional ist und kartographische Symbolik zur Darstellung dieses Mangels verfügbar ist (z.B. Schraffen für die dritte Dimension der Höhe). Im GIS bilden wir die Welt hingegen multidimensional ab . So können sich zum Beispiel zwei Streckenabschnitte, die durch jeweils zwei Koordinaten bestimmt sind, kreuzen. Sind dies eine Bundesstraße und eine Autobahn, findet diese Kreuzung in der Echtwelt mit Hilfe einer Brücke statt. Im GI-System muss diese Brücke im Sinne einer fehlenden Verbindung zwischen Autobahn und Bundesstraße durch die exakte Geometrie, Topologie und Dimension abgebildet werden. Geschieht dies nicht, verlangt das Navigationsgerät vielleicht die direkte Auffahrt auf die Autobahn, weil es die Brücke für eine Kreuzung hält oder leitet gegen die Fahrtrichtung auf die Autobahn.

Eine geeignete räumliche und zeitliche Beschreibung von Geoobjekten und ihrer Eigenschaften macht es also erforderlich, neben der Geometrie auch die Topologie und Dimension des Objektes bzw. des räumlichen Kontinuums zu kennen und adäquat abzubilden.

## Bearbeiten Sie...
Besuchen Sie die folgenden Webseiten. Analysieren Sie vor dem Hintergrund Ihres neu erworbenen Wissens folgendes:

  * [Tank & Rast](http://maps.rast.de/standorte/rast/fullscreen)
  * [Wetterbote – Lahn](http://wetterbote.de/pegel/lahn.htm)
  * [HLUG Marburg](http://www.hlug.de/?id=7122&station=1004)
  * [Cineplex Marburg](http://www.cineplex.de)

  * Was wird repräsentiert? Geoobjekte oder Raumkontinua?
  * Welche Dimension und Geometrie liegt der Repräsentation ihrer Meinung nach zugrunde?
  *  Versuchen Sie einige weitere alltägliche Beispiele für die Bedeutung von Lage und Dimensionalität zu finden.
  *  Überlegen Sie sich unterschiedliche Konzepte wie die Höhe eines bestimmten Raumausschnitts repräsentiert werden kann

