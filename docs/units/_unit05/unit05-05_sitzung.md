---
title: "Sitzung 5 - Datenvisualisierung Fortsetzung"
toc: true
toc_label: Inhalt
---
Die Visualisierung von Daten in `R` bietet sehr viel mehr Möglichkeiten als die in der Einführung gezeigten Beispiele. Es werden mehre Vorlagen die in der Alltagsarbeit hilfreich sind vorgestellt.
<!--more-->


## Einrichten der Umgebung



```r
rm(list=ls())
rootDIR="~/Schreibtisch/spatialstat_SoSe2020/"
## laden der benötigten libraries
# wir definieren zuerst eine liste mit den Paketnamen und 
# nutzen dann eine for  schleife die jedes element aus der  liste nimmt 
# und schaut ob es bereits installiert ist utils::installed.packages() 
# falls nicht wird es installiert 
libs= c("sf","mapview","tmap","tmaptools","spdep","ineq","cartography","spatialreg","ggplot2","usedist","raster","downloader","RColorBrewer","colorspace","viridis")
for (lib in libs){
  if(!lib %in% utils::installed.packages()){
    utils::install.packages(lib)
  }}
# nicht wundern lapply()ist eine integrierte for Schleife die alle im vector libs
# enthaltenen packages lädt indem sie den package Namen als character string an die 
# function library übergibt
invisible(lapply(libs, library, character.only = TRUE))
```


```r
#---------------------------------------------------------
# nuts3_autocorr.R 
# Autor: Chris Reudenbach, creuden@gmail.com
# Urheberrecht: Chris Reudenbach 2020 GPL (>= 3)
#
# Beschreibung: Skript berechnet unterschiedliche Autokorrelationen aus den Kreisdaten
#  
#--------------------
##- Laden der Kreisdaten
#--------------------

# Aus der Sitzung Eins werden die gesäuberten Kreisdaten von github geladen und eingelesen

download(url ="https://raw.githubusercontent.com/GeoMOER/moer-mhg-spatial/master/docs/assets/data/nuts3_kreise.rds",     destfile = "nuts3_kreise.rds")

# Einlesen der nuts3_kreise Daten
nuts3_kreise = readRDS("nuts3_kreise.rds")
```

## Traditionelle Regressionsvisualisierung und -Analyse 

Die Visualisierung der linearen Modelle haben wir bislang vernachlässigt. neben der R-Basis Visualisierung bietet sich das überaus mächtige Paket `ggplot` an. Es basiert auf der gleichen Semantik der "grammar of graphics die für `tmap` bereits vorgestellt wurde. 

Als Beispiel nehemen wir unser OLS Modell. Die normale `plot()` Funktion liefert uns für die visuelle Analyse einige wichtige Grafiken die durch Enter weitergeschaltet werden können.


```r
lm_um = lm(Universitaeten.Mittel ~ Beschaeftigte, data=nuts3_kreise)
summary(lm_um)
```

```
## 
## Call:
## lm(formula = Universitaeten.Mittel ~ Beschaeftigte, data = nuts3_kreise)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -341649  -40552   -7942   16099  856057 
## 
## Coefficients:
##                 Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   -5.839e+04  7.579e+03  -7.704 1.06e-13 ***
## Beschaeftigte  1.718e+00  6.566e-02  26.167  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 120900 on 398 degrees of freedom
## Multiple R-squared:  0.6324,	Adjusted R-squared:  0.6315 
## F-statistic: 684.7 on 1 and 398 DF,  p-value: < 2.2e-16
```


```r
plot(nuts3_kreise$Beschaeftigte,nuts3_kreise$Universitaeten.Mittel, pch = 2, cex = 1.0, col = "red", main = "Universitaeten.Mittel ~ Beschaeftigte", xlab = "Beschaftigte", ylab = "Universitaeten.Mittel")
# hinzufügen der Regressionsgeraden
abline(lm_um )
```

![]({{ site.baseurl }}/assets/images/unit05/lmplot1-1.png)<!-- -->
In der nachfolgenden Abbildung wird diese direkt mit `ggplot` berechnet und geplottet.


```r
# berechnung und plotten des Regressionsmodells lm_um
ggplot(nuts3_kreise, aes(x = Beschaeftigte, y = Universitaeten.Mittel)) + 
  geom_point() +
  stat_smooth(method = "lm")
```

![]({{ site.baseurl }}/assets/images/unit05/ggplot0-1.png)<!-- -->

Natürlich können Beschriftungen  und viele weitere Einstellungen manipuliert werden.


```r
# initialisiert den Basisdatensatz
  ggplot(lm_um$model, aes_string(x = names(lm_um$model)[2], y = names(lm_um$model)[1])) + 
# für den scatterplot hinzu
    geom_point() +
# sttistische glättungfals zuviele Daten corhanden sind     
    stat_smooth(method = "lm", col = "red") +
# fügt die Überschrift mit hilfe der in lm_um gespeicherten Modelldaten hinzu
    labs(title = paste("Adj R2 = ",signif(summary(lm_um)$adj.r.squared, 5),
                       "Intercept =",signif(lm_um$coef[[1]],5 ),
                       " Slope =",signif(lm_um$coef[[2]], 5),
                       " P =",signif(summary(lm_um)$coef[2,4], 5)))
```

![]({{ site.baseurl }}/assets/images/unit05/ggplot2-1.png)<!-- -->

Zur Automatisierung kann es als Funktion geschrieben  sehr einfach für beliebige Modelle genutzt werden.



```r
ggplotRegression <- function (fit,method="lm") {

ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
  geom_point() +
  stat_smooth(method = method, col = "red") +
  labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                     "Intercept =",signif(fit$coef[[1]],5 ),
                     " Slope =",signif(fit$coef[[2]], 5),
                     " P =",signif(summary(fit)$coef[2,4], 5)))
}

ggplotRegression(lm(Universitaeten.Mittel ~ Beschaeftigte, data=nuts3_kreise))
```

![]({{ site.baseurl }}/assets/images/unit05/ggplot3-1.png)<!-- -->

```r
# loess model (Locally Weighted Scatterplot Smoothing)
ggplotRegression(lm(Universitaeten.Mittel ~ Beschaeftigte, data=nuts3_kreise),method = "loess")
```

![]({{ site.baseurl }}/assets/images/unit05/ggplot3-2.png)<!-- -->


## Regressionsanalyse mit ggplot

Zur Analyse eines Regressionmodell gibt es einen typischen Ablauf. Neben den einfachen  gezeigten Plots sind analytische Plots sehr hilfreich. Plotten wir unser `lm_um` Modell erhalten wir die folgenden 4 Abbildungen:


```r
par(mfrow = c(2, 2))  
plot(lm_um)  
```

![]({{ site.baseurl }}/assets/images/unit05/lmplot2-1.png)<!-- -->

```r
par(mfrow = c(1, 1))  
```

Sie stellen eine traditionelle Methode dar, um Residuen zu interpretieren und visuell zu analysieren, ob es Probleme mit dem Modell geben könnte. 

Abbildung 1 (Residuals vs fitted) zeigt, ob die Residuen nichtlineare Muster aufweisen. Es könnte eine nicht-lineare Beziehung zwischen Prädiktorvariablen und einer Ergebnisvariablen bestehen, und das Muster könnte in dieser Darstellung auftauchen, wenn das Modell die nicht-lineare Beziehung nicht erfasst. Abbildung 2 (Normal Q-Q) zeigt, ob die Residuen normal verteilt sind. Folgen die Residuen einer geraden Linie oder weichen sie stark ab? Abbildung 3 (Scale Locattion) zeigt ob die Residuen gleichmäßig über die Bereiche der Prädiktoren verteilt sind. Auf diese Weise kann die Annahme gleicher Varianz (Homoskedastizität) überprüft werden. Es sollte eine horizontale Linie mit gleichmäßig (zufällig) verteilten Punkten sein. Abbildung 4 (Residuals vs Leverage) Dieser Plot hilft uns, einflussreiche Aussreißer existieren. Als Faustregel  werden Randwerte in der oberen rechten Ecke oder in der unteren rechten Ecke betrachtet. Wichtig sind Ausreißer außerhalb der Cook'schen Distanz. Wenn wir diese Fälle ausschließen, werden die Regressionsergebnisse verändert.

Diese übliche Vorgehensweise kann seh relegant durch `ggplot` erweitert werden. Dabei folgen wir wieder dem üblichen Ansatz:

1  Anpassung eines Regressionsmodells zur Vorhersage der Variablen (Y).
2  Ermittlung von Vorhersage- und Residualwerten, die mit jeder Beobachtung auf (Y) verbunden sind.
3  Visualisierung der tatsächlichen und vorhergesagten Werte von (Y) 
4  Analyse der  Residuen, um eine visuelle Interpretation zu ermöglichen (z.B. rote Farbe, wenn die Residuen sehr hoch sind), um Punkte herauszustellen, die vom Modell schlecht vorhergesagt werden.




```r
# 1) Standrd ggplot des Regressionsmodells
ggplot(nuts3_kreise, aes(x = Beschaeftigte, y = Universitaeten.Mittel)) + 
  geom_point() +
  stat_smooth(method = "lm")
```

![]({{ site.baseurl }}/assets/images/unit05/ggplot1-1.png)<!-- -->

```r
# 2) Zuweisung der Vorhersage- und Residualwerte ins nuts3_kreise Objekt
nuts3_kreise$predicted <- predict(lm_um)
nuts3_kreise$residuals <- residuals(lm_um)

# Wiederholung von 1) nur wird hier das Konfidenzintervall ausgeblendet se=FALSE, und als Farbe für die Gereade lightgrey gesetzt
# geom_segment zieht Linien  zwischen den Vorhersagewerten und Residuen während alpha die Linien transparent macht
ggplot(nuts3_kreise, aes(x = Beschaeftigte, y = Universitaeten.Mittel)) +
  geom_smooth(method = "lm", se = FALSE, color = "lightgrey") +
  geom_segment(aes(xend = Beschaeftigte, yend = predicted), alpha = .2) +

# Hier werden die Größen und Farben der Residuen erzeugt
  geom_point(aes(color = abs(residuals), size = abs(residuals))) + 
  scale_color_continuous(low = "black", high = "red") +
  guides(color = FALSE, size = FALSE) +  
  geom_point(aes(y = predicted), shape = 1) +
  theme_bw()
```

![]({{ site.baseurl }}/assets/images/unit05/ggplot1-2.png)<!-- -->

```r
# alternativ mit Farben und ohne Größen
ggplot(nuts3_kreise, aes(x = Beschaeftigte, y = Universitaeten.Mittel)) +
  geom_smooth(method = "lm", se = FALSE, color = "lightgrey") +
  geom_segment(aes(xend = Beschaeftigte, yend = predicted), alpha = .2) +
  geom_point(aes(color = residuals)) +
  scale_color_gradient2(low = "blue", mid = "white", high = "red") +  
  guides(color = FALSE) +
  geom_point(aes(y = predicted), shape = 1) +
  theme_bw()
```

![]({{ site.baseurl }}/assets/images/unit05/ggplot1-3.png)<!-- -->



## Farbpaletten in R

Die Farbzuweisung in Karten und Plots sind ein eigenes und durchaus komplexes Kapitel in `R`. Das Grundkonzept ist einfach es werden sogenannte  R-Farbpaletten zum Ändern der Standardfarben genutzt. Dies gilt gleichermassen für Diagramme mit ggplot oder den R-Basis-Plotfunktionen oder auch Karten mit tmap

Die vielleicht wichtigsten Farbpalletten sind in verschiedenen R-Paketen verfügbar:

*    Viridis-Farbskalen [viridis-Paket].
*    Colorbrewer-Paletten [RColorBrewer-Paket].
*    Graue Farbpaletten [ggplot2-Paket]
*    Farbpaletten für wissenschaftliche Zeitschriften [ggsci-Paket]
*    R Basis-Farbpaletten: Rainbow,heat.colors, cm.colors


Die *viridis* Pallette zeichnet sich durch ihren großen Wahrnehmungsbereich aus. Sie nutzt den zur Verfügung stehenden Farbraum so weit wie möglich aus und ist sowohl für verschiedenen Formen der Farbenblindheit als auch für die ungebiaste Aufteilung der Farben am robustesten.


```r
library(RColorBrewer)
library(colorspace)
clrs_spec <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
clrs_hcl <- function(n) {
  hcl(h = seq(230, 0, length.out = n), 
      c = 60, l = seq(10, 90, length.out = n), 
      fixup = TRUE)
  }
### function to plot a color palette
pal <- function(col, border = "transparent", ...)
{
 n <- length(col)
 plot(0, 0, type="n", xlim = c(0, 1), ylim = c(0, 1),
      axes = FALSE, xlab = "", ylab = "", ...)
 rect(0:(n-1)/n, 0, 1:n/n, 1, col = col, border = border)
}
pal(clrs_spec(100))
```

![]({{ site.baseurl }}/assets/images/unit05/basics-1.png)<!-- -->

```r
pal(desaturate(clrs_spec(100)))
```

![]({{ site.baseurl }}/assets/images/unit05/basics-2.png)<!-- -->

```r
pal(rainbow(100))
```

![]({{ site.baseurl }}/assets/images/unit05/basics-3.png)<!-- -->



```r
library(RColorBrewer)
display.brewer.all()
```

![]({{ site.baseurl }}/assets/images/unit05/rcolorbrewer-1.png)<!-- -->



```r
# berechnung und plotten des Regressionsmodells lm_um
ggplot(nuts3_kreise, aes(x = Beschaeftigte, y = Universitaeten.Mittel)) + 
  geom_point(color = nuts3_kreise$Beschaeftigte) +
  scale_color_viridis(option = "D")+
  stat_smooth(method = "lm")
```

![]({{ site.baseurl }}/assets/images/unit05/ggplotcol-1.png)<!-- -->


```r
# Darstellung mit tmap Farbgebung nach em Methode mit 8 Klassen mit Hilfe der cartography::getBreaks() Funktion  
tm_shape(nuts3_kreise) + 
  tm_fill(col = "Beschaeftigte",breaks = getBreaks(nuts3_kreise$Beschaeftigte,nclass = 8,method = "em"), alpha = 0.3,palette = viridisLite::viridis(20, begin = 0, end = 0.56))
```

![]({{ site.baseurl }}/assets/images/unit05/tmap-1.png)<!-- -->

## Wo gibt's mehr Informationen?
Für mehr Informationen kann unter den folgenden Ressourcen nachgeschaut werden: 

* [Burkeys Acadamy](https://spatial.burkeyacademy.com/) 

* [Farben und Palletten in R](). 

## Download Skript
Das Skript kann unter [unit05-05_sitzung.R]({{ site.baseurl }}/assets/scripts/unit05-05_sitzung.R){:target="_blank"} heruntergeladen werden
  
