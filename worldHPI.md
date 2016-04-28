---
title: "International Home Prices"
author: "Stuart_Quinn"
date: "April 25, 2016"
output: html_document
---

Recently I have exploring a number of alternative ways to produce data visualizations. Obviously, Excel is my bread and butter for designing simplistic graphs and it is particularly great for time-series data. Alternatively, I will use Tableau when I am trying to explore quite a bit of data, but ultimately, my preference has been R. With a growing number of packages and highly active participants, I can find 10 to 15 ways to explore data within R alone. 

We'll save the conversation of benefits and trade-offs of different tools for later. Let's first take advantage of the robust tools within R and my personal reason for using it -- quick web integration for posting to this blog!


First we will load the packages we will need: 

```{r echo = T, message = F, warning = F}
if(!require(reshape2)){
  install.packages("reshape2")
  library(reshape2)
}
if(!require(googleVis)){
  install.packages("googleVis")
  library(googleVis)
}

if(!require(lubridate)){
  install.packages("lubridate")
  library(lubridate)
}

if(!require(ggplot2)){
  install.packages("ggplot2")
  library(ggplot2)
}

if(!require(knitr)){
  install.packages("knitr")
  library(knitr)
}
```

For our analysis we will look at international home prices. There are a number of sources of data for home prices across the world. Within the United States, there are four core indices that are referenced: CoreLogic, CoreLogic Case-Shiller S&P/Case-Shiller and FHFA index. Recently, there have been a growing number of indices, such as the Zillow Home Value Index. 

Since we are looking for international figures, we will use the [Bank of International Settlements (BIS) data](http://www.bis.org/statistics/pp_long.htm). This organization is comprised of over 60 world banks and since the housing downturn has focused on aggregating large amounts of property data for purposes of measuring systemic risk. For additional information about the country specific measures, definitions and collection techniques, please [look here](Documentation of Data: http://www.bis.org/statistics/pp_long_documentation.pdf). 

I have downloaded, saved and cleaned some of data provided on their site and now we will load it in. The data is in wide format so we will convert the class of the date and use the helpful reshape2 package to make the data long. 

```{r, echo=T, message = F, warning = F}
d <- read.csv("hpi_world.csv", header = T)
head(d)

d$Year <- dmy(d$Year) #Convert date to day_month_year with lubridate package

d_long <- melt(d, id.vars = "Year", variable.name = "Country",  value.name = "HPI_Value") #Make data long 
head(d_long)
```

Now that we have our data in the proper format, we will visually explore the data in a couple of different ways to get trends by country. We will start with our favorite ggplot2 package, which has a ton of functionality. 


```{r echo = T, message = F, fig.align = "center", fig.height = 3, fig.width = 6}

ggplot(d_long, aes(x = Year, y = HPI_Value, color = Country))+
  geom_line()+
  theme(legend.position = "bottom")
```

This is a great first view, but the colors are all similar, but we can tell that there was a global run-up in the mid to late 2000's resulting in the financial crisis. Since this is an index, we can also observe that all of the values are indexed to 100 in 1999. We can think of prices relative to 1999. 

Let's use a face or small-multiples to see if we can find more distinct trends for our countries. 

```{r echo = T, message = F, fig.align = "center", fig.heaith = 4, fig.width = 8}

ggplot(d_long, aes(x = Year, y = HPI_Value))+
  geom_line()+
  facet_wrap(~Country, ncol = 5)+
  theme(axis.text.x = element_text(angle = 90))

```

We can certainly see some trends from the facet, particularly those that had stronger bubbles such as Spain, Ireland and the U.S. We also observe, that Canada did not experience a reset. O

Though this is better, due to the fixed y-axis, some of the figures are scaled in a way that can be deceiving. We can remedy this by using "free_y" in the facet function, but this can also make things further confusing if someone does not look closely at the axis. 

Below we see how different the slope of Italy home-prices look when viewing independent of the rest of the countries. 

```{r echo = T, message = F, warning = F}
d_it <- subset(d_long, Country == "Italy")
ggplot(d_it, aes(x = Year, y = HPI_Value))+
  geom_line()+
  ggtitle("Italian Home Price Index")  

```

To resolve this issue, we will build an interactive that allows us to view a number of different views over time through the [googleVis package](https://cran.r-project.org/web/packages/googleVis/vignettes/googleVis_examples.html). 

```{r setOptions, message = T}
library(googleVis)
op <- options(gvis.plot.tag = 'chart')
```

```{r results = 'asis'}
#first we have to convert the date since googleVis does not accept POSIX
d_long$Year <- as.Date(d_long$Year)
motion = gvisMotionChart(d_long,
                         idvar = "Country", 
                         timevar = "Year")
plot(motion)
```

There are a number of different charts that can be used with the googleVis package and these can be merged in a dashboard format to supply even more views to users. Below we creat a small world choropleth and an accompanying list for additional views of the data. 

```{r results = 'asis'}
map <- gvisGeoChart(d_long, "Country", "HPI_Value",
             options = list(width = 300, height = 125))
List <- gvisTable (d_long, 
                   options = list(width = 300, height = 325))
mapList <- gvisMerge(map, List, horizontal = F)
mapListmotion <- gvisMerge(mapList, motion, horizontal = T,
                           tableOptions = "bgcolor = \"#000000\" cellspacing = 5.5")
plot(mapListmotion)

```

```{r eho = F}
options(op)
```

