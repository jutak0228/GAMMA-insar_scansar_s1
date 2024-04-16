#!/bin/bash

workdir="$1"
ref_date="$2"
pythondir="$3"
rlks="$4"
azlks="$5"
flt_adf="$6"
flt_bm3d="$7"
flt_hp="$8"
mask="$9"

# results dir create
if [ ! -e ${workdir}/results ];then mkdir -p ${workdir}/results; fi
if [ ! -e ${workdir}/results/diff ];then mkdir -p ${workdir}/results/diff; fi
if [ ! -e ${workdir}/results/unw ];then mkdir -p ${workdir}/results/unw; fi
if [ ! -e ${workdir}/results/cc ];then mkdir -p ${workdir}/results/cc; fi
if [ ! -e ${workdir}/results/pwr ];then mkdir -p ${workdir}/results/pwr; fi

demdir=${workdir}/DEM
slcdir=${workdir}/rslc
pwrdir=${workdir}/rmli
infdir=${workdir}/infero
out_diff_dir=${workdir}/results/diff
out_unw_dir=${workdir}/results/unw
out_cc_dir=${workdir}/results/cc
out_pwr_dir=${workdir}/results/pwr

func_Ortho_UNW()
{
	cd ${slcdir}

	slc_master=$1
	slc_slave=$2
	adf=$3
	bm3d=$4
	hp=$5

	date_master=`echo ${master} | sed -e "s/[^0-9]//g"`
	date_slave=`echo ${slave} | sed -e "s/[^0-9]//g"`
	mas_to_slv="${date_master}_${date_slave}"
	dir_infero="${infdir}/${mas_to_slv}"

	if [ -e "${demdir}/${ref_date}.lt_fine" ];then
		lut="${demdir}/${ref_date}.lt_fine"
    else
		lut="${demdir}/${ref_date}.lt"
    fi

	slc_width=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	slc_height=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_azimuth_lines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	rspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_range_pixel_spacing"   | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
    aspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_azimuth_pixel_spacing" | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
	dem_width=`cat ${demdir}/EQA.dem_par  | grep "width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	dem_height=`cat ${demdir}/EQA.dem_par  | grep "nlines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`

	# Ortho(UNW)
	if [ ${adf} != "-" ]; then
		dispmap ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw ${demdir}/${ref_date}.hgt ${slc_master}.par ${dir_infero}/${mas_to_slv}.off ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw.disp
		geocode_back ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw.disp ${slc_width} ${lut} ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw.disp.ortho ${dem_width} - 2 0 
		data2geotiff ${demdir}/EQA.dem_par ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw.disp.ortho 2 ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw.disp.tif
		cd ${dir_infero}
		rm -rf *.disp *.ortho
		out_file=${mas_to_slv}.diff.adf${adf}.hp${hp}_mcf.unw.disp.tif
	elif [ ${bm3d} != "-" ]; then
		dispmap ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw ${demdir}/${ref_date}.hgt ${slc_master}.par ${dir_infero}/${mas_to_slv}.off ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw.disp
		geocode_back ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw.disp ${slc_width} ${lut} ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw.disp.ortho ${dem_width} - 2 0 
		data2geotiff ${demdir}/EQA.dem_par ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw.disp.ortho 2 ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw.disp.tif
		cd ${dir_infero}
		rm -rf *.disp *.ortho
		out_file=${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}_mcf.unw.disp.tif
	fi

	mv ${dir_infero}/${out_file} ${out_unw_dir}/${out_file}
}

func_Ortho_DIFF()
{
	cd ${slcdir}

	slc_master=$1
	slc_slave=$2
	adf=$3
	bm3d=$4
	hp=$5

	date_master=`echo ${master} | sed -e "s/[^0-9]//g"`
	date_slave=`echo ${slave} | sed -e "s/[^0-9]//g"`
	mas_to_slv="${date_master}_${date_slave}"
	dir_infero="${infdir}/${mas_to_slv}"

	if [ -e "${demdir}/${ref_date}.lt_fine" ];then
		lut="${demdir}/${ref_date}.lt_fine"
    else
		lut="${demdir}/${ref_date}.lt"
    fi

	slc_width=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	slc_height=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_azimuth_lines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	rspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_range_pixel_spacing"   | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
    aspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_azimuth_pixel_spacing" | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
	dem_width=`cat ${demdir}/EQA.dem_par  | grep "width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	dem_height=`cat ${demdir}/EQA.dem_par  | grep "nlines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`

	# Ortho(DIFF)
	if [ ${adf} != "-" ]; then
		cpx_to_real ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp} ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}.phase ${slc_width} 4
		python ${pythondir}/convert_16step.py ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}.phase ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}.stp
		geocode_back ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}.stp ${slc_width} ${lut} ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}.ortho ${dem_width} - 0 3
		data2geotiff ${demdir}/EQA.dem_par ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}.ortho 5 ${dir_infero}/${mas_to_slv}.diff.adf${adf}.hp${hp}.tif 0
		cd ${dir_infero}
		rm -rf *.stp *.ortho
		out_file=${mas_to_slv}.diff.adf${adf}.hp${hp}.tif
	elif [ ${bm3d} != "-" ]; then
		cpx_to_real ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp} ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.phase ${slc_width} 4
		python ${pythondir}/convert_16step.py ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.phase ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.stp
		geocode_back ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.stp ${slc_width} ${lut} ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.ortho ${dem_width} - 0 3
		data2geotiff ${demdir}/EQA.dem_par ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.ortho 5 ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.tif 0
		cd ${dir_infero}
		rm -rf *.stp *.ortho
		out_file=${mas_to_slv}.diff.bm3d${bm3d}.hp${hp}.tif
	fi

	mv ${dir_infero}/${out_file} ${out_diff_dir}/${out_file}
}

func_Ortho_CC()
{
	cd ${slcdir}

	slc_master=$1
	slc_slave=$2
	adf=$3
	bm3d=$4

	date_master=`echo ${master} | sed -e "s/[^0-9]//g"`
	date_slave=`echo ${slave} | sed -e "s/[^0-9]//g"`
	mas_to_slv="${date_master}_${date_slave}"
	dir_infero="${infdir}/${mas_to_slv}"

	if [ -e "${demdir}/${ref_date}.lt_fine" ];then
		lut="${demdir}/${ref_date}.lt_fine"
	else
		lut="${demdir}/${ref_date}.lt"
	fi

	slc_width=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	slc_height=`cat ${dir_infero}/${mas_to_slv}.off  | grep "interferogram_azimuth_lines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	rspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_range_pixel_spacing"   | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
    aspc=`cat ${dir_infero}/${mas_to_slv}.off   | grep "interferogram_azimuth_pixel_spacing" | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
	dem_width=`cat ${demdir}/EQA.dem_par  | grep "width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	dem_height=`cat ${demdir}/EQA.dem_par  | grep "nlines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`

	# Ortho(CC)
	if [ ${adf} != "-" ]; then
		geocode_back ${dir_infero}/${mas_to_slv}.diff.adf${adf}.cc ${slc_width} ${lut} ${dir_infero}/${mas_to_slv}.diff.adf${adf}.ortho ${dem_width} - 0 0
		data2geotiff ${demdir}/EQA.dem_par ${dir_infero}/${mas_to_slv}.diff.adf${adf}.ortho 2 ${dir_infero}/${mas_to_slv}.diff.adf${adf}_cc.tif 0
		rm -rf ${dir_infero}/${mas_to_slv}.diff.adf${adf}.ortho
		out_file=${mas_to_slv}.diff.adf${adf}_cc.tif
	elif [ ${bm3d} != "-" ];then
		geocode_back ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.cc ${slc_width} ${lut} ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.ortho ${dem_width} - 0 0
		data2geotiff ${demdir}/EQA.dem_par ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.ortho 2 ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}_cc.tif 0
		rm -rf ${dir_infero}/${mas_to_slv}.diff.bm3d${bm3d}.ortho
		out_file=${mas_to_slv}.diff.bm3d${bm3d}_cc.tif
	fi
	mv ${dir_infero}/${out_file} ${out_cc_dir}/${out_file}
}

func_Ortho_PWR()
{
	dem_width=`cat ${demdir}/EQA.dem_par  | grep "width" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
	dem_height=`cat ${demdir}/EQA.dem_par  | grep "nlines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`

	if [ -e "${demdir}/${ref_date}.lt_fine" ];then
		lut="${demdir}/${ref_date}.lt_fine"
    else
		lut="${demdir}/${ref_date}.lt"
    fi

	cd ${pwrdir}
	for rmli_file in `ls -f *.rmli`
	do
		echo "rmli_file=${rmli_file}"
		rmli_width=`cat ${rmli_file}.par  | grep "range_samples" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
		rmli_height=`cat ${rmli_file}.par  | grep "azimuth_lines" | awk -F":" '{print $2}' | sed -e "s/[^0-9]//g"`
		rspc=`cat ${rmli_file}.par   | grep "range_pixel_spacing"   | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`
	    aspc=`cat ${rmli_file}.par   | grep "azimuth_pixel_spacing" | awk '{print $2}'    | sed -e "s/[^0-9,\.]//g"`

		# Ortho(PWR)
		# raspwr ${rmli_file} ${rmli_width} - - - - - - - ${rmli_file%.*}_ras.tif
		# geocode_back ${rmli_file%.*}_ras.tif ${rmli_width} ${lut} ${rmli_file%.*}_ortho.tif ${dem_width} - 0 2
		# data2geotiff ${demdir}/EQA.dem_par ${rmli_file%.*}_ortho.tif 0 ${rmli_file%.*}_tmp.tif
		# gdal_translate -a_nodata 0 ${rmli_file%.*}_tmp.tif ${rmli_file%.*}.tif

	    python ${pythondir}/makeBSImage.py ${rmli_file} ${rmli_width} ${rmli_height} 0 ${rmli_file%.rmli}_db
        geocode_back ${rmli_file%.rmli}_db ${rmli_width} ${lut} ${rmli_file%.*}_db_ortho ${dem_width} - - 0
        data2geotiff ${demdir}/EQA.dem_par ${rmli_file%.*}_db_ortho 2 ${rmli_file%.*}_tmp.tif
        gdal_translate -a_nodata 0 ${rmli_file%.*}_tmp.tif ${rmli_file%.*}_db.tif
        rm -rf ${file%.rmli}_db ${file%.*}_db_ortho ${file%.*}_tmp.tif

		# rm -rf ${rmli_file%.*}_ras.tif ${rmli_file%.*}_ortho.tif ${rmli_file%.*}_tmp.tif

		out_file=${rmli_file%.*}_db.tif
		mv ${out_file} ${out_pwr_dir}/${out_file}
	done
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

for master in ${list_master[@]}
do
	for slave in ${list_slave[@]}
	do
		masdate=`echo ${master} | sed -e "s/[^0-9]//g"`
		slvdate=`echo ${slave} | sed -e "s/[^0-9]//g"`

		if [ ${masdate} -lt ${slvdate} ];then
			echo "Master Date = ${masdate}"
			echo "Slave Date = ${slvdate}"

			# CC
			if [ $((${mask} & 0x02)) -gt 0 ];then
				echo "func_Ortho_CC...start"
				func_Ortho_CC ${master} ${slave} ${flt_adf} ${flt_bm3d}
			fi
			# UNW
			if [ $((${mask} & 0x04)) -gt 0 ];then
				echo "func_Ortho_UNW...start"
				func_Ortho_UNW ${master} ${slave} ${flt_adf} ${flt_bm3d} ${flt_hp}
			fi
			# DIFF
			if [ $((${mask} & 0x08)) -gt 0 ];then
				echo "func_Ortho_DIFF...start"
				func_Ortho_DIFF ${master} ${slave} ${flt_adf} ${flt_bm3d} ${flt_hp}
			fi
		fi
	done
done

# intensity image 
if [ $((${mask} & 0x01)) -gt 0 ];then
	func_Ortho_PWR
fi


