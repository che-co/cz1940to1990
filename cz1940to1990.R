#!/bin/R

options(stringsAsFactors=FALSE)

#  Read in data as character class
cz.codes <- read.csv("czlma903.csv", colClasses=rep("character", 11))
cities <- read.table("1940_cities_counties.csv", header=TRUE, colClasses=rep("character",3))
names(cz.codes) <- toupper(names(cz.codes))
names(cities) <- toupper(names(cities))

#  Split on "," to get state abbrv
cities$STATE <- toupper(do.call(rbind, strsplit(cities$CITY, ","))[,2])

