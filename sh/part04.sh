#!/bin/bash

# 2) geocoding of S1 TOPS reference (20141003.mli.par)
 
# DEM available for use: SRTM (corrected so that heights are WGS84 heights) which is created in part03
# SRTM.dem
# SRTM.dem_par

workdir="$1"
ref_date="$2"
dem_name="$3"

cd ${workdir}
if [ -e "DEM" ];then rm -r DEM; fi
mkdir -p "DEM"
cd DEM

dem="../DEM_prep/${dem_name}.dem"
dem_par="../DEM_prep/${dem_name}.dem_par"

# copy master mli image to demdir
cp ../rmli/${ref_date}.mli ./
cp ../rmli/${ref_date}.mli.par ./

# set parameters
range_samples=`cat ${ref_date}.mli.par | grep "range_samples" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
azimuth_lines=`cat ${ref_date}.mli.par | grep "azimuth_lines" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
range_pixel_spacing=`cat ${ref_date}.mli.par | grep "range_pixel_spacing"   | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9\.]//g"`
azimuth_pixel_spacing=`cat ${ref_date}.mli.par | grep "azimuth_pixel_spacing" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9\.]//g"`

# DEM oversampling factors:  3 in lat 3 in lon (--> about 30m)

# calculate geocoding lookup table using gc_map
gc_map2 ${ref_date}.mli.par $dem_par $dem EQA.dem_par EQA.dem ${ref_date}.lt 1 1 ${ref_date}.ls_map - ${ref_date}.inc

# set parameters for EQA.dem
width=`cat EQA.dem_par | grep "width" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
nlines=`cat EQA.dem_par | grep "nlines" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`

# --> DEM segment width: 6169   lines: 2824

# do refinement of lookup table using a simulated backscatter image calculated using pixel_area program
pixel_area ${ref_date}.mli.par EQA.dem_par EQA.dem ${ref_date}.lt ${ref_date}.ls_map ${ref_date}.inc ${ref_date}.pix_sigma0 ${ref_date}.pix_gamma0 20 0.01
raspwr ${ref_date}.pix_gamma0 $range_samples - - - - - - - ${ref_date}.pix_gamma0.bmp
# dis2ras 20141003.pix_gamma0.bmp 20141003.mli.bmp &
# --> good match even without refinement; simulated backscatter well suited to determine a refinement

# determine geocoding refinement using offset_pwrm
create_diff_par ${ref_date}.mli.par - ${ref_date}.diff_par 1 0
offset_pwrm ${ref_date}.pix_gamma0 ${ref_date}.mli ${ref_date}.diff_par ${ref_date}.offs ${ref_date}.ccp 128 128 ${ref_date}.offsets 1 32 32 0.3
offset_fitm ${ref_date}.offs ${ref_date}.ccp ${ref_date}.diff_par ${ref_date}.coffs ${ref_date}.coffsets 0.3 1

# final solution: 597 offset estimates accepted out of 2048 samples
# final range offset poly. coeff.:                0.41985
# final azimuth offset poly. coeff.:             -0.20938
# final range offset poly. coeff. errors:     2.68286e-02
# final azimuth offset poly. coeff. errors:   2.18947e-02
# final model fit std. dev. (samples) range: 0.3332   azimuth: 0.2719

# --> correcting only an offset is sufficient (statistics do not get
#     significantly better if 3 parameters are estimated in offset_fitm
# --> estimated refinement offset is very small

# refine geocoding lookup table
gc_map_fine ${ref_date}.lt $width ${ref_date}.diff_par ${ref_date}.lt_fine 1

# apply again pixel_area using the refined lookup table to assure that the simulated image uses the refined geometry
pixel_area ${ref_date}.mli.par EQA.dem_par EQA.dem ${ref_date}.lt_fine ${ref_date}.ls_map ${ref_date}.inc ${ref_date}.pix_sigma0_fine ${ref_date}.pix_gamma0_fine
raspwr ${ref_date}.pix_gamma0_fine $range_samples - - - - - - - ${ref_date}.pix_gamma0_fine.bmp
# dis2ras 20141003.pix_gamma0_fine.bmp 20141003.mli.bmp &

# resample the MLI data from the slant range to the map geometry and visualize it
geocode_back ${ref_date}.mli $range_samples ${ref_date}.lt_fine EQA.${ref_date}.mli $width $nlines 5 0 - - 3
raspwr EQA.${ref_date}.mli ${width} - - - - - - - EQA.${ref_date}.mli.bmp
# eog EQA.20141003.mli.bmp &

# resample the DEM heights to the slant range MLI geometry
geocode ${ref_date}.lt_fine EQA.dem $width ${ref_date}.hgt $range_samples $azimuth_lines 2 0
rasdt_pwr ${ref_date}.hgt ${ref_date}.mli $range_samples - - - - 0 500 1 rmg.cm ${ref_date}.hgt.bmp
# eog 20141003.hgt.bmp &

# --> geocoding lookup table (20141003.lt_fine), geocoded backscatter image
    # and heights in slant range geoemtry

