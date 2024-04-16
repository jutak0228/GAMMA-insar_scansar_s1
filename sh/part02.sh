#!/bin/bash

workdir="$1"
ref_date="$2"
rglks="$3"
azlks="$4"

cd ${workdir}
if [ -e "rmli" ];then rm -r rmli; fi
mkdir -p "rmli"
pwrdir="${workdir}/rmli"
cd rslc

while read line
do 
	
	SLC_mosaic_S1_TOPS ${line}.vv.SLC_tab ${line}.slc ${line}.slc.par $rglks $azlks 1
	# (error) multi_look ${line}.slc ${line}.slc.par ${pwrdir}/${line}.mli ${pwrdir}/${line}.mli.par $rglks $azlks 1 - 0.000001
	# multi_look ${line}.slc ${line}.slc.par ${pwrdir}/${line}.mli ${pwrdir}/${line}.mli.par $rglks $azlks
	multi_look_ScanSAR ${line}.vv.SLC_tab ${pwrdir}/${line}.mli ${pwrdir}/${line}.mli.par ${rglks} ${azlks} 1
	# set parameters
	range_samples=`cat ${pwrdir}/${line}.mli.par | grep "range_samples" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
	raspwr ${pwrdir}/${line}.mli $range_samples - - - - - - - ${pwrdir}/${line}.mli.bmp

done < dates

