---
title: "Beispiel: Vector Basics"
toc: true
toc_label: In this example
---


Vektoren sind die Grundlage für viele Datentypen in R.

## Erstellen eines Vektors
Ein Vektor wird mit der Funktion `c` erzeugt. Hier sind einige Beispiele:

```r
my_vector_1 <- c(1,2,3,4,5)
print(my_vector_1)
```

```
## [1] 1 2 3 4 5
```

```r
my_vector_2 <- c(1:10)
print(my_vector_2)
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10
```

```r
my_vector_3 <- c(10:5)
print(my_vector_3)
```

```
## [1] 10  9  8  7  6  5
```

```r
my_vector_4 <- seq(from=0, to=30, by=10)
print(my_vector_4)
```

```
## [1]  0 10 20 30
```
Die  `print` Funktion kann weggelassen und nur der Variable Name eingegeben werden.

## Länge eines Vektors
Um die Länge eines Vektors also die Anzahl seiner Elemente zu erhalten dient die  `length` Funktion:

```r
my_vector <- c(1:10)
length(my_vector)
```

```
## [1] 10
```


## Anzeige und Zugriff auf den Inhalt eines Vektors
Um auf den/die Wert(e) eines Vektors zuzugreifen, müssen Sie die 
Position des Elements innerhalb des Vektors in eckigen Klammern angeben. Bitte beachten Sie, dass
die Indizierung mit 1 beginnt:

```r
# get the value of the element(s) at the specified position(s)
my_vector[1]
```

```
## [1] 1
```

```r
my_vector[1:3]
```

```
## [1] 1 2 3
```

```r
my_vector[c(1,3)]
```

```
## [1] 1 3
```

## Ändern, Hinzufügen oder Löschen eines Elements eines Vektors
Um ein Element zu überschreiben, müssen Sie auf das Element zugreifen (gemäß der obigen Logik). Um ein Element hinzuzufügen, müssen Sie die vorhandenen Vektor an der angegebenen Position ausschneiden und anschliessend einfügen. Das Ergebnis muss in
eine neue Variable geschreiben werden. Sonst erfolgt die Ausgabe auf der Konsole. 
Analog erfolgt das löschen eines Vektors

```r
# modify an element at position 3
my_vector[3] <- 30

# add an element at position 4
my_added_vector <- c(my_vector[1:3], 20, my_vector[4:length(my_vector)])
my_added_vector
```

```
##  [1]  1  2 30 20  4  5  6  7  8  9 10
```

```r
# delete an element at position 4
my_deleted_vector <- c(my_vector[1:3], my_vector[5:length(my_vector)])
my_deleted_vector
```

```
## [1]  1  2 30  5  6  7  8  9 10
```

Für mehr Informationen kann unter den folgenden Ressourcen nachgeschaut werden: [Daten Typen](http://www.statmethods.net/input/datatypes.html){:target="_blank"}.

Natürlich ist es auch immer eine gute Idee, in die Paketdokumentation zu schauen oder im Internet zu suchen.