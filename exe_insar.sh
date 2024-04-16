#!/bin/bash

#####################################################################################################################
# 	GAMMA SAR Script for Differencial SAR Interferometry (DInSAR) with Sentinel-1
#####################################################################################################################

### [PROC FLAGs] ###
                         # [0] make directory and input *.zip files into "input_files_orig"
part01a="off"            # [1] make burst tabs to create BURST_tab for corresponding slc data.
                         # [2] edit burst_number_table
part01b="off"            # [3] generate BURST_tabs based on the zip files for each zip file.
                         # [4] define range and azimuth looks numbers...
part02="off"             # [5] mosaic slc burst
part03="off"             # [6] convert the GeoTIFF DEM into Gamma Software format
part04="off"             # [7] geocoding of S1 TOPS reference *Change the oversampling value from 1 to X if you need.
part05="off"              # [8] coregistration with a matching with offset_pwr and a spectral diversity using S1_coreg_overlap
part06="off"              # [9] differential interferogram 
part07="off"             # [10] filtering with smoothing | high-pass filtering | bm3d | or whatever you want
                         # [11] YOU should select range and azimuth values like "1000 1200" as reference point 
part08="off"             # [12] unwrapping with mcf method
part09="off"             # [13] make ortho and export output by creation of result directory
demaux="off"             # [option] dem support file export (ls_map, incidence angle, local resolution, offnadir angle)
demgen="on"              # [option] dem generation from interferometric analysis

### directory path ###
workdir="/home/takataka_ju/gamma/gamma_demo/insar_scansar_s1/"
python="${workdir}/python"
shell="${workdir}/sh"
dem_name="SRTM"
# dem_tiff="${workdir}/input_files_orig/XXXX.tif"
dem_tiff="-" #if you do not have precise or higher resolution DEM data, please select this.

### parameters ###
rlks="5" # range look number
azlks="1" # azimuth look number
ref_date="20240131" # first date of all dataset
# *You can choose filtering method >>> adf or bm3d
# if you do not select either one, you should set that parameter as "-"
    flt_adf="32" # Adaptive interferogram filtering: 8, 16, 32, 64, 128, 256
    flt_bm3d="-" # Block-Matching 3D filtering: 10, 20, 30, 40, 50
flt_hp="3000" # high-pass filtering1000, 3000, 5000, 10000
ccthres="0.3"
refpos_x="2779"
refpos_y="1334"
mask_ortho="0x0F" # [DIFF:0x08][UNW:0x04][CC:0x02][PWR:0x01] - ex) DIFF+UNW : MASK_ORTHO="0x0C" | ALL products : "0x0F"
# definition of numbers for mask_ortho is hexadecimal

### dem generation pair parameters
slave_date="20240212"

### execution (you do not need to change below) ###
if [ "${part01a}" = "on" ];then bash ${shell}/part01a.sh ${workdir} ${ref_date}; fi
if [ "${part01b}" = "on" ];then bash ${shell}/part01b.sh ${workdir} ${ref_date}; fi
if [ "${part02}" = "on" ];then bash ${shell}/part02.sh ${workdir} ${ref_date} ${rlks} ${azlks}; fi
if [ "${part03}" = "on" ];then bash ${shell}/part03.sh ${workdir} ${ref_date} ${dem_name} ${dem_tiff}; fi
if [ "${part04}" = "on" ];then bash ${shell}/part04.sh ${workdir} ${ref_date} ${dem_name}; fi
if [ "${part05}" = "on" ];then bash ${shell}/part05.sh ${workdir} ${ref_date} ${rlks} ${azlks}; fi
if [ "${part06}" = "on" ];then bash ${shell}/part06.sh ${workdir} ${ref_date} ${rlks} ${azlks}; fi
if [ "${part07}" = "on" ];then bash ${shell}/part07.sh ${workdir} ${ref_date} ${python} ${rlks} ${azlks} ${flt_adf} ${flt_hp} ${flt_bm3d}; fi
if [ "${part08}" = "on" ];then bash ${shell}/part08.sh ${workdir} ${rlks} ${azlks} ${flt_adf} ${flt_hp} ${flt_bm3d} ${ccthres} ${refpos_x} ${refpos_y}; fi
if [ "${part09}" = "on" ];then bash ${shell}/part09.sh ${workdir} ${ref_date} ${python} ${rlks} ${azlks} ${flt_adf} ${flt_bm3d} ${flt_hp} ${mask_ortho}; fi
if [ "${demaux}" = "on" ];then bash ${shell}/demaux.sh ${workdir} ${ref_date} ${python}; fi
if [ "${demgen}" = "on" ];then bash ${shell}/demgen.sh ${workdir} ${ref_date} ${slave_date} ${rlks} ${azlks} ${refpos_x} ${refpos_y}; fi

