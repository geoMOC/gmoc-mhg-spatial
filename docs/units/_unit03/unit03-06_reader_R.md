---
title: "Example: if - else"
toc: true
toc_label: In this example
---

Entscheidungsstrukturen sind die Kontrollstruktur in einer Analyse. Hier wird entschieden **was** in einem **spezifischen** Fall **wie** weiter abgearbeitet wird. Im folgenden Beispiel wird a mit b über den Operator *kleiner* verglichen:

```r
a <- 5.0
b <- 10.0
if (a < b) {
  print("a is smaller than b")
}
```

```
## [1] "a is smaller than b"
```
Ein `if` Abfrage kann um eine `else` Anweisung erweitert werden. Wir erzeugen mit der Funktion `runif` jeweils eine Zufahlszahl aus der angegebenen Normalverteilung zwischen 1 und 10. Wir benutzen in dem Beispiel sowohl `if` als auch `elseif` und `else`. Mit Verwendung von `if` und `elsif` wird ausschliessend auf die jeweilige Bedingung geprüft, Falls diese erfüllt ist wird nur diese und sonst keine weitere Bedingung überprüft. In unserem Beispiel wird gezielt überprüft ob a kleiner b oder a größer b sollten beide Fälle nicht eintreten wird mit dem `else` angenommen dass die beiden Zajlen gleich sind. `else` ist also eine Art Lumpensammler für nicht erfüllte Abfragen.

```r
a <- runif(1, 1, 10)
b <- runif(1, 1, 10)
if (a < b) {
  print("a is smaller than b")
} else if (a > b) {
  print("a is bigger than b")
} else {
  print("a equals b what is a little miracale")
} 
```

Auch hier gilt das ist nur der Anfang. Weitere Beispiele finden sich etwa unter [R-Bloggers](https://www.r-bloggers.com/on-the-ifelse-function/) oder ausführlicher und auch schematisch erläutert bei [datacamp](https://www.datacamp.com/community/tutorials/conditionals-and-control-flow-in-r).



