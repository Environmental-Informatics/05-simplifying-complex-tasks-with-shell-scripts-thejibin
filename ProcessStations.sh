#!/bin/bash
## Assignment05 - Simplifying complex tasks with shell scripts
## Jibin Joseph
## 2020-02-25

## Revision04

### Part I

## Check and create a directory named "HigherElevation" using if statement
if [ ! -d HigherElevation ]
then
	mkdir HigherElevation
fi

## Search through the contents of station file using loop
## And identify staions at altitudes above 200 ft using grep or awk
## Copy the stations above 200 ft elevation to the new directory

for file in StationData/*.txt
do
	filepath=$(awk '/Altitude/ && $NF >=200 {print FILENAME}' $file)
	
	if [ -n "$filepath" ]
	then
		cp $filepath ./HigherElevation/$(basename $file)
	fi
done

### Part II

## Extract Latitude and Longitude for each file
## Perform on StationData

awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list #Multiply by -1 to make it West
awk '/Latitude/ {print 1 * $NF}' StationData/Station_*.txt > Lat.list
paste Long.list Lat.list > AllStation.xy

## Remove Long.list and Lat.list from the directory
rm *.list

## Perform on HigherElevation data

awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > Long.list #Multiply by -1 to make it West
awk '/Latitude/ {print 1 * $NF}' HigherElevation/Station_*.txt > Lat.list
paste Long.list Lat.list > HEStation.xy

## Remove Long.list and Lat.list from the directory
rm *.list


## Load gmt module
module load gmt

## Add block
## First Line - Draws rivers, coastlines and political boundaries
## Second Line - Adds small black circles for all station locations
## Third Line - Adds red circles  for all higher elevation locations
gmt pscoast -JU16/4i -R-93/-86/36/43 -Dh -B2f0.5 -Cl/Blue -Ia/blue -Na/orange -P -K -V > SoilMoistureStations.ps
# -Dh Selects the resolution of data to use high(h)
# -Cl/Blue - Fill lakes with color blue

gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
gmt psxy HEStation.xy -J -R -Sc0.05 -Gred -O -V >> SoilMoistureStations.ps
# 0.05 instead of 0.15 (given) will reduce the size

## View figure
gv SoilMoistureStations.ps &

### Part III

## Convert postscript file created by GMT into a standard conforming encapsulated postcript file
## Cropped to its bounding box
ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi
gv SoilMoistureStations.epsi &


## Convert to tif using ImageMagic convert command of density 150 dots per inch
convert SoilMoistureStations.epsi -density 150 SoilMoistureStations.tif
