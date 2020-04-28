---
title: "Beispiel: Data Frame Basics"
toc: true
toc_label: In this example
---


Data frames sind aufgrund ihrer Tabellenstruktur die wohl am häufigsten verwendete Datenstruktur in R.

## Erzeugen eines data frames
Ein data frame kann durch Verbinden von zwei vektoren mit Hilfe der Funktion  `data.frame` erzeugt werden:

```r
x <- c(2.5, 3.5, 3.4)
y <- c(5, 10, 1)
my_df <- data.frame(x, y)
my_df
```

```
##     x  y
## 1 2.5  5
## 2 3.5 10
## 3 3.4  1
```

```r
colnames(my_df) <- c("Floats", "Integers")

my_other_df <- data.frame(X = c(2, 3, 4), Y = c("A", "B", "C"))
my_other_df
```

```
##   X Y
## 1 2 A
## 2 3 B
## 3 4 C
```
Die `colnames` Funktion erlaubr es  Spaltennamen für existierende Spaltenköpfe zu vergeben. Alternativ können Spaltennamen auch durch ansprechen der Position in der Dataframe Matrix angesprochen werden.(Die Groß0buchstaben X and Y in obigem Beispiel).


## Dimensionen eines  data frames
Die Dimensionen  eines data frames werden mit der `ncol` (number of columns), 
`nrow` (number of rows) oder  `str` (structure) Funktion abgefragt:

```r
ncol(my_other_df)
```

```
## [1] 2
```

```r
nrow(my_other_df)
```

```
## [1] 3
```

```r
str(my_other_df)
```

```
## 'data.frame':	3 obs. of  2 variables:
##  $ X: num  2 3 4
##  $ Y: Factor w/ 3 levels "A","B","C": 1 2 3
```


## Darstellung und Abfragen der Inhalte eines data frames

Auf den Inhalt eines Datenrahmens wird entweder über eine Positionsinformation 
in eckigen Klammern angegeben (z.B. `df[3,4]`) oder ein Spaltenname nach einem $-Zeichen
(z.B. `df$Spaltenname`):




```r
my_other_df[1,]  # Shows first row
```

```
##   X Y
## 1 2 A
```

```r
my_other_df[,2]  # Shows second column
```

```
## [1] A B C
## Levels: A B C
```

```r
my_other_df$Y  # Shows second column
```

```
## [1] A B C
## Levels: A B C
```


Zusammenfassend lässt sich sagen, dass Dimensionen wie Zeilen oder Spalten, die ausgewählt werden sollten behandelt werden. Dabei sind negative Zahlen, Dimensionen, die ausgeblendet werden sollen und positive Zahlen Dimensionen die angezeigt werden sollen. Falls alle Einträge von
einer Dimension ausgewählt werden sollen, lässt man das Feld einfach leer. Wenn mehr als
eine Dimension ein- oder ausgeblendet werden soll, muss man diese Informationen mit einem 
Vektor, der durch die `c`-Funktion definiert ist ansprechen.

```r
my_other_df[c(1,3),]  # Shows rows 1 and 3
```

```
##   X Y
## 1 2 A
## 3 4 C
```

```r
my_other_df[c(1,2),]  # Shows rows 1 to 2
```

```
##   X Y
## 1 2 A
## 2 3 B
```

Wenn Sie an der ersten oder letzten Zeile interessiert sind, können Sie auch den `head` oder
`tail` Funktionen arbeiten. Die Standardanzahl der anzuzeigenden Zeilen ist fünf, aber dies kann mit dem zweiten Argument angepasst werden:


```r
head(my_other_df, 2)
```

```
##   X Y
## 1 2 A
## 2 3 B
```

Die letzten beiden Zeilen:

```r
tail(my_other_df, 2)
```

```
##   X Y
## 2 3 B
## 3 4 C
```

## Changing, adding or deleting an element of a data frame
Um ein Element eines Datenrahmens zu ändern (einzelner Wert oder ganze
Vektoren wie Zeilen oder Spalten), müssen Sie nach der obigen Logik darauf zugreifen.
Um eine Spalte hinzuzufügen oder zu löschen, müssen Sie einen Vektor an die angegebene Adresse eintragen/entfernen.

```r
# overwrite an element
my_other_df$X[3] <- 400  # same as my_other_df[3,1] <- 400
my_other_df
```

```
##     X Y
## 1   2 A
## 2   3 B
## 3 400 C
```

```r
# change an entire dimension
my_other_df[,1] <- c("200", "300", "401")  # same as my_other_df$X <- 400
my_other_df
```

```
##     X Y
## 1 200 A
## 2 300 B
## 3 401 C
```

```r
# add a new column
my_other_df$z <- c(255, 300, 100)
my_other_df
```

```
##     X Y   z
## 1 200 A 255
## 2 300 B 300
## 3 401 C 100
```

```r
# delete a column
my_other_df$z <- NULL
my_other_df
```

```
##     X Y
## 1 200 A
## 2 300 B
## 3 401 C
```
Wie bei den Listen, so muss ein Element, um tatsächlich gelöscht zu werden, auf `NULL` gesetzt werden.
Für mehr Informationen kann unter den folgenden Ressourcen nachgeschaut werden: [data type](http://www.statmethods.net/input/datatypes.html){:target="_blank"} 
Dort finden Sie auch [Information über Objekte](http://www.statmethods.net/input/contents.html){:target="_blank"}. 

Natürlich ist es auch immer eine gute Idee, in die Paketdokumentation zu schauen oder im Internet zu suchen.
