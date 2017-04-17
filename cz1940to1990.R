#!/bin/R

options(stringsAsFactors=FALSE)

#  Read in data as character class
cz.codes <- read.csv("czlma903.csv", colClasses=rep("character", 11))
cities <- read.table("1940_cities_counties.csv", header=TRUE, colClasses=rep("character",3))
st.fips <- read.csv("ST_FIPS.csv", colClasses=rep("character", 3))
cities.to.match <- read.csv("1940_cities_to_match_to_1990_CZs.csv")

names(cz.codes) <- toupper(names(cz.codes))
names(cities) <- toupper(names(cities))

#  Split on "," to get state postal abbrv
cities$ST <- toupper(do.call(rbind, strsplit(cities$CITY, ", "))[,2])

#  Merge ST FIPS
cities <- data.frame(cities, STATEFP=st.fips[match(cities$ST, st.fips$ST), "FIPS"])

#  Add leading 0s to COUNTY var and drop last digit for historical changes 
cities$COUNTY <- unlist(lapply(cities$COUNTY, function(x) paste(c(rep("0", 4-nchar(x)), x), collapse="")))
if(any(substr(cities$COUNTY, 4, 4) != "0")) { # Check changed county codes
	changed.counties <- cities[which(substr(cities$COUNTY,4,4) != "0"), ]
	write.csv(changed.counties, file="cities-in-changed-counties.csv", row.names=FALSE)
}

#  Make unique state-county identifier
cities$GEOID <- paste0(cities$STATEFP, substr(cities$COUNTY, 1, 3))

#  Match CZ90 based on county FIPS codes
cities <- data.frame(cities, CZ90=cz.codes[match(cities$GEOID, cz.codes$COUNTY.FIPS.CODE), "CZ90"])

#  Match cities and add CZ90 and cz name
cities.to.match$cz <- cities[match(cities.to.match$city, cities$CITY), "CZ90"]
cities.to.match$czname <- cz.codes[match(cities.to.match$cz, cz.codes$CZ90), "NAME.OF.LARGEST.PLACE.IN.COMMUTING.ZONE"]

#  Add Oak Park Villiage and Kensington by hand.
cities.to.match[which(cities.to.match$city == "oak park village"), c("cz", "czname")] <- c("24300", "Chicago city, IL")
cities.to.match[which(cities.to.match$city == "kensington"), c("cz", "czname")] <- c("19700", "Philadelphia city, PA")

#  Save file
write.csv(cities.to.match, "1940_cities_matched_to_1990_CZs.csv", row.names=FALSE)
