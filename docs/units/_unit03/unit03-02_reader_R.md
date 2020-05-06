---
title: "Beispiel: Vector Basics"
toc: true
toc_label: Inhalt
---


Vektoren sind die Grundlage für viele Datentypen in R.

## Erstellen eines Vektors
Ein Vektor wird mit der Funktion `c` erzeugt. Hier sind einige Beispiele:

```r
# manuelle Zuweisung der Zahlen 1 bis 4
my_vector_1 <- c(1,2,3,4,5)
print(my_vector_1)
```

```
## [1] 1 2 3 4 5
```

```r
# Zuweisung der Sequenz der Zahlen 1 bis 4
my_vector_2 <- c(1:4)
print(my_vector_2)

```

```
##  [1]  1  2  3  4
```

```r
# Zuweisung der umgekehrten Sequenz der Zahlen 1 bis 4
my_vector_3 <- c(4:1)
print(my_vector_3)
```

```
## [1] 4 3 2 1
```

```r
# Zuweisung der Sequenz der Zahlen 0 bis 30 unter Verwendung der 
# Funktion seq() in 10 Schritten
my_vector_4 <- seq(from=0, to=30, by=10)
print(my_vector_4)
```

```
## [1]  0 10 20 30
```
Die  `print` Funktion kann auch weggelassen und stattdessen nur der Variablen-Name eingegeben werden.

## Länge eines Vektors
Um die Länge eines Vektors, das heisst  die Anzahl seiner Elemente, zu erhalten dient die  `length` Funktion:

```r
my_vector <- c(1:10)
length(my_vector)
```

```
## [1] 10
```


## Anzeige und Zugriff auf den Inhalt eines Vektors
Um auf den/die Wert(e) eines Vektors zugreifen zukönnen, müssen Sie die Position des Elements innerhalb des Vektors in eckigen Klammern angeben. Bitte beachten Sie, dass die Indizierung mit 1 beginnt.

```r
# Abfrage des Vektorinhalts an (einer) definierten Position(en)
my_vector[5]
## [1] 5

my_vector[1:3]
## [1] 1 2 3

my_vector[c(1,3)]
## [1] 1 3
```


Für mehr Informationen kann unter den folgenden Ressourcen nachgeschaut werden: [Daten Typen](http://www.statmethods.net/input/datatypes.html){:target="_blank"}.

Natürlich ist es auch immer eine gute Idee, in die Paketdokumentation zu schauen oder im Internet zu suchen.