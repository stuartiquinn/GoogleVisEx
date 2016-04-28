
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

d <- read.csv("hpi_world.csv", header = T)

d$Year <- dmy(d$Year)

d_long <- melt(d, id.vars = "Year", variable.name = "Country",  value.name = "HPI_Value")

ggplot(d_long, aes(x = Year, y = HPI_Value, color = Country))+
  geom_line()

ggplot(d_long, aes(x = Year, y = HPI_Value))+
  geom_line()+
  facet_wrap(~Country, ncol = 5)
d_it <- subset(d_long, Country == "Italy")
ggplot(d_it, aes(x = Year, y = HPI_Value))+
  geom_line()
d_long$Year <- as.Date(d_long$Year) #View data

myState <- '{"uniColorForNonSelected":false,"yZoomedDataMin":0,"xAxisOption":"_TIME","time":"2015-09-30","duration":{"timeUnit":"D","multiplier":1},"orderedByY":false,"yLambda":1,"showTrails":false,"xZoomedDataMin":670377600000,"colorOption":"_UNIQUE_COLOR","nonSelectedAlpha":0.4,"playDuration":15088.88888888889,"iconKeySettings":[],"dimensions":{"iconDimensions":["dim0"]},"sizeOption":"_UNISIZE","xZoomedDataMax":1443571200000,"xLambda":1,"orderedByX":false,"yZoomedDataMax":800,"xZoomedIn":false,"iconType":"LINE","yAxisOption":"2","yZoomedIn":false}'
  
motion = gvisMotionChart(d_long,
                         idvar = "Country", 
                         timevar = "Year",
                         options = list(width = 650, height = 500, state=myState))

map <- gvisGeoChart(d_long, "Country", "HPI_Value",
             options = list(width = 300, height = 125))
List <- gvisTable (d_long, 
                   options = list(width = 300, height = 325))
mapList <- gvisMerge(map, List, horizontal = F)
mapListmotion <- gvisMerge(mapList, motion, horizontal = T,
                           tableOptions = "bgcolor = \"#000000\" cellspacing = 5.5")
plot(mapListmotion)



#Documentation of Data: http://www.bis.org/statistics/pp_long_documentation.pdf
#Source of Data: http://www.bis.org/statistics/pp/pp_long.xlsx
