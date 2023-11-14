#!/bin/bash 


###loop over the different sites
var="tas"
scen="hist-1950"
real="r2i1p2f1"
input_path="./cat"
f=$input_path/${var}_Amon_EC-Earth3P-HR_${scen}_${real}.nc
for loc in `cat site.lst`;do
	lon=`echo $loc|awk '{print $2}'`
	lat=`echo $loc|awk '{print $3}'`
	site=`echo $loc|awk '{print $1}'`
	output_path="./stat/$site"
	seas=$output_path/${site}_EC-Earth3P-HR_${scen}_${real}_${var}_seas.nc
	p95=$output_path/${site}_EC-Earth3P-HR_${scen}_${real}_${var}_p95.nc
	trenda=$output_path/${site}_EC-Earth3P-HR_${scen}_${real}_${var}_trend_a.nc
	trendb=$output_path/${site}_EC-Earth3P-HR_${scen}_${real}_${var}_trend_b.nc
	mkdir stat/$site/
	echo "Computing stat $site $var $lon $lat"

	##get the seasonal cycle of the historical period 
	cdo -s ymonmean $f $seas	
	
	##get the trend of the historical period
	cdo -s trend -yearmean $f $trenda $trendb 

	rm $trenda
	
	##P95
	cdo -s -timpctl,95 $f -timmin $f -timmax $f $p95


	###get era5 stat for the site 

	for y in `seq 1980 2014`;do
		echo "cat era5 $y"
		era5_site=./era5/era5.$site.nc
		era5=/archive/data/era5/da/$var/era5.$var.$y.da.ab.grb
		cdo -s -r -f nc -remapnn,lon=$lon/lat=$lat $era5 $era5_site

	seas_era5=$output_path/${site}_era5_${var}_seas.nc
	trenda_era5=$output_path/${site}_era5_${var}_trend_a.nc
	trendb_era5=$output_path/${site}_era5_${var}_trend_b.nc
	p95_era5=$output_path/${site}_era5_${var}_p95.nc
	echo "Computing stat ERA5 $site $var $lon $lat"

	##get the seasonal cycle of the historical period 
    cdo -s ymonmean $era5_site $seas_era5    
    
    ##get the trend of the historical period
    cdo -s trend -yearmean $era5_site $trenda_era5 $trendb_era5 

    rm $trenda_era5
    
    ##P95
    cdo -s -timpctl,95 $era5_site -timmin $era5_site -timmax $era5_site $p95_era5

done
