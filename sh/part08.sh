#!/bin/bash

workdir="$1"
rlks="$2"
azlks="$3"
flt_adf="$4"
flt_hp="$5"
flt_bm3d="$6"
cc_thres="$7"
ref_range="$8"
ref_azimuth="$9"

demdir=${workdir}/DEM
slcdir=${workdir}/rslc
pwrdir=${workdir}/rmli
infdir=${workdir}/infero

func_unwrapping()
{
	cd ${slcdir}

	slc_master=$1
	slc_slave=$2
	adf=$3
	hp=$4
	bm3d=$5
	cc=$6
	refX=$7
	refY=$8

	date_master=`echo ${master} | sed -e "s/[^0-9]//g"`
	date_slave=`echo ${slave} | sed -e "s/[^0-9]//g"`
	mas_to_slv="${date_master}_${date_slave}"
	dir_infero="${infdir}/${mas_to_slv}"

	slc_width=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	slc_height=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_azimuth_lines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	rspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_range_pixel_spacing"   | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
    aspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_azimuth_pixel_spacing" | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`

	# Unwrapping
	if [ ${adf} != "-" ]; then
		# rascc_mask - Generate phase unwrapping validity mask using correlation and intensity
		rascc_mask ${dir_infero}/${mas_to_slv}.diff.adf${adf}.cc - ${slc_width} - - - - - ${cc} - - - - - - ${dir_infero}/${mas_to_slv}.diff.adf${adf}.bmp
		# mcf - Phase unwrapping algorithm using Minimum Cost Flow (MCF) and triangulation
		mcf ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp} ${dir_infero}/${mas_to_slv}.diff.adf${adf}.cc ${dir_infero}/${mas_to_slv}.diff.adf${adf}.bmp ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw ${slc_width} 0 0 0 - - 1 1 - ${refX} ${refY}
	elif [ ${flt_bm3d} != "-" ]; then 
		# cc_wave - coherence estimation from normalized interferogram and co-registered intensity images.
		cc_wave ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d} - - ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.cc $slc_width - -
		# rascc_mask - Generate phase unwrapping validity mask using correlation and intensity
		rascc_mask ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.cc - ${slc_width} - - - - - ${cc} - - - - - - ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.bmp
		# mcf - Phase unwrapping algorithm using Minimum Cost Flow (MCF) and triangulation
		mcf ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp} ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.cc ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.bmp ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw $slc_width 0 0 0 - - 1 1 - ${refX} ${refY}
	fi
}

# --- main process ---

list_master=()
list_slave=()
counter=0
cd ${slcdir}

for rslc_file in `ls -F *.rslc`
do
	list_master[${counter}]="${rslc_file}"
	counter=`expr ${counter} + 1`
done

list_slave=(${list_master[@]})

# interferometry
for master in ${list_master[@]}
do
	for slave in ${list_slave[@]}
	do
		masdate=`echo ${master} | sed -e "s/[^0-9]//g"`
		slvdate=`echo ${slave} | sed -e "s/[^0-9]//g"`

		if [ ${masdate} -lt ${slvdate} ];then
			func_unwrapping ${master} ${slave} ${flt_adf} ${flt_hp} ${flt_bm3d} ${cc_thres} ${ref_range} ${ref_azimuth}
		fi
	done
done



