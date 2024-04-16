#!/bin/bash

workdir="$1"
ref_date="$2"
pythondir="$3"
rlks="$4"
azlks="$5"
flt_adf="$6"
flt_hp="$7"
flt_bm3d="$8"

demdir=${workdir}/DEM
slcdir=${workdir}/rslc
pwrdir=${workdir}/rmli
infdir=${workdir}/infero

# [FUNCTION] --------------------------------
func_filtering()
{
	cd ${slcdir}

	slc_master=$1
	slc_slave=$2
	adf=$3
	hp=$4
	bm3d=$5

	date_master=`echo ${master} | sed -e "s/[^0-9]//g"`
	date_slave=`echo ${slave} | sed -e "s/[^0-9]//g"`
	mas_to_slv="${date_master}_${date_slave}"
	dir_infero="${infdir}/${mas_to_slv}"

	slc_width=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	slc_height=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_azimuth_lines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	rspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_range_pixel_spacing"   | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
    aspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_azimuth_pixel_spacing" | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`

	# Filtering
	if [ ${adf} != "-" ]; then
		# Adaptive interferogram filtering
		adf ${dir_infero}/${mas_to_slv}.diff ${dir_infero}/${mas_to_slv}.diff.adf${adf} ${dir_infero}/${mas_to_slv}.diff.adf${adf}.cc ${slc_width} 1.0 ${adf}
		python ${pythondir}/highp_flt.py ${dir_infero}/${mas_to_slv}.diff.adf${adf} ${slc_width} ${slc_height} ${rspc} ${aspc} ${hp} ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}
	elif [ ${bm3d} != "-" ]; then
		# Block-Matching 3D filtering
		bm3d ${dir_infero}/${mas_to_slv}.diff $slc_width ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d} 1 6 ${bm3d}
		cc_wave ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d} - - ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.cc ${slc_width} - -
		python ${pythondir}/highp_flt.py ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d} ${slc_width} ${slc_height} ${rspc} ${aspc} ${hp} ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}
	fi
}

list_master=()
list_slave=()
counter=0
cd ${slcdir}

for rslc_file in `ls -f *.rslc`
do
	echo "SLC File = ${rslc_file}"
	list_master[${counter}]="${rslc_file}"
	counter=`expr ${counter} + 1`
done
list_slave=(${list_master[@]})

if [ ${flt_bm3d} != "-" ]; then
	range_samples=`cat ${pwrdir}/${ref_date}.rmli.par  | grep "range_samples" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	while read line; do 
		bm3d ${pwrdir}/$line.rmli $range_samples ${pwrdir}/${line}.bm3d${flt_bm3d}.rmli 0 0 ${flt_bm3d}
		cp ${pwrdir}/$line.rmli.par ${pwrdir}/${line}.bm3d${flt_bm3d}.rmli.par
		raspwr ${pwrdir}/${line}.bm3d${flt_bm3d}.rmli $range_samples - - - - - - - ${pwrdir}/${line}.bm3d${flt_bm3d}.rmli.bmp
	done < ${slcdir}/dates 
fi

# interferometry
for master in ${list_master[@]}
do
	for slave in ${list_slave[@]}
	do
		master_date=`echo ${master} | sed -e "s/[^0-9]//g"`
		slave_date=`echo ${slave} | sed -e "s/[^0-9]//g"`

		if [ ${master_date} -lt ${slave_date} ];then
			echo "master Date = ${master_date}"
			echo "slave Date = ${slave_date}"
			func_filtering ${master} ${slave} ${flt_adf} ${flt_hp} ${flt_bm3d}
		fi
	done
done


