---
title: "Beispiel: For-Schleifen"
toc: true
toc_label: In this example
---

For Schleifen sind die Grundform um wiederholt die gleichen  Aktionen ausführenzu lassen. Konkret wenn ich für eine bekannte Anzahl von Elementen oder Wiederholungen die gleiche Zeile oder den gleichen Block Programm-Code ausführen möchte nutze ich eine For-Schleife.

Hioerzu wird zu Beginn der Wiederholungs-Schleife die Anzahl der Widerholungen festgelegt. Zum Beispiel etwa durch die Anzahl der Einträge in einer Liste odr einem Vektor oder weil ich -n-mal etwas wiederholen möchte:



```r
for(i in seq(7,10)){
  print(i)
}
```

```
## [1] 7
## [1] 8
## [1] 9
## [1] 10
```
Da die Variable i in der for Bedingungen gesetzt wird muss sie in der Schleife nicht verändert werden.

Und natürlich kann man For-Schleifen beliebig verschachteln. Mit 'paste0()' können Variablen miteinander verkettet werden

```r
for(i in seq(7, 10)){
  print(paste0("Outer loop value of i: ", i))
  for(j in seq(7, 10)){
    print(paste0("   Inner loop value of i + j: ", i + j))
  }
}
```

```
##[1] "Outer loop value of i: 7"
##[1] "   Inner loop value of i + j: 14"
##[1] "   Inner loop value of i + j: 15"
##[1] "   Inner loop value of i + j: 16"
##[1] "   Inner loop value of i + j: 17"
##[1] "Outer loop value of i: 8"
##[1] "   Inner loop value of i + j: 15"
##[1] "   Inner loop value of i + j: 16"
##[1] "   Inner loop value of i + j: 17"
##[1] "   Inner loop value of i + j: 18"
##[1] "Outer loop value of i: 9"
##[1] "   Inner loop value of i + j: 16"
##[1] "   Inner loop value of i + j: 17"
##[1] "   Inner loop value of i + j: 18"
##[1] "   Inner loop value of i + j: 19"
##[1] "Outer loop value of i: 10"
##[1] "   Inner loop value of i + j: 17"
##[1] "   Inner loop value of i + j: 18"
##[1] "   Inner loop value of i + j: 19"
##[1] "   Inner loop value of i + j: 20"
```
Statt eine Sequenz zu definieren klann wie zu Beginn gesagt auch eine Vektor-Variable verwendet werdenDabei wird die Anzahl der Wiederholungen über die Länge (also die Anzahl der Einträge des Vektors iteriert.
Folglich wird in der Wiederholungschleife das erste Vektorelement in die Zählvariable eingesetzt und dann so fort:

```r
a <- c("A", "B", "C", "D")
for(elements in a){
  print(elements)
}
```

```
## [1] "A"
## [1] "B"
## [1] "C"
## [1] "D"
```



Natürlich könnennicht nur vektoren sondern auch data frames so manipuliert werden. Mit dem folgenden data frame können wir das exemplarisch zeigen:

```r
# create an arbitrary data frame

a <- c("A", "B", "C", "A", "B", "A", "A")
b <- c("X", "X", "X", "X", "Y", "Y", "Y")
df <- data.frame(Cat1 = a, Cat2 = b)
df
```

```r
     Cat1 Cat2
## 1    A    X
## 2    B    X
## 3    C    X
## 4    A    X
## 5    B    Y
## 6    A    Y
## 7    A    Y
```
Nun verändern wir den data frame mit hilfe einer Schleife die Zeile für Zeile über die Tabelle läuft und als Operation die Umwandlung der Grossbuchstaben in Cat 1 in Kleinbuchstabben ausführtWir nutzen hierfür die `tolower`  und die `nrow` Funktion. Die Ersetzung finden wie bereits bekannt in data frames statt:

```r
for (row in 1:nrow(df)) {
    df[row, "Cat1"] = tolower(df[row, "Cat1"])
    }
```
Dwer neue Dataframe sieht wie folgt aus:

```r
df

##   Cat1 Cat2
## 1    a    X
## 2    b    X
## 3    c    X
## 4    a    X
## 5    b    Y
## 6    a    Y
## 7    a    Y
```

Natürlich können Sie das auch über die Spalten oder in Kombination durchführen. 

Diese ersten Beispiele sollen nur andeuten dass Schleifen das Arbeitspferd für wiederholte Ausführungen gleicher Anweisungen darstellen.

Weitere Beispiele finden sich etwa unter [R-Bloggers](https://www.r-bloggers.com/how-to-write-the-first-for-loop-in-r/) oder ausführlicher und auch schematisch erläutert bei [datacamp](https://www.datacamp.com/community/tutorials/tutorial-on-loops-in-r?).

