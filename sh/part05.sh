#!/bin/bash

workdir="$1"
ref_date="$2"
rlks="$3"
azlks="$4"

cd ${workdir}
slcdir=${workdir}/rslc
pwrdir=${workdir}/rmli
infdir=${workdir}/infero

if [ -e ${infdir} ]; then rm -r ${infdir}; fi
mkdir -p ${infdir}

# coregistration with ScanSAR_coreg.py

func_coregistration()
{
	slc_master=$1
	slc_slave=$2
	rlks=$3
	azlks=$4
	# parameter setting
	master_dt=`echo $slc_master | awk -F"." '{print $1}'`
	slave_dt=`echo $slc_slave | awk -F"." '{print $1}'`
	mas_to_slv="${master_dt}_${slave_dt}"
	if [ ! -e "${infdir}/${mas_to_slv}" ];then mkdir -p ${infdir}/${mas_to_slv}; fi

	cd ${slcdir}

	master_tab="${slcdir}/${master_dt}.vv.SLC_tab"
	slave_tab="${slcdir}/${slave_dt}.vv.SLC_tab"
	sed -e 's/slc/rslc/g' ${slave_dt}.vv.SLC_tab > ${slave_dt}.vv.RSLC_tab
	slave_rtab="${slcdir}/${slave_dt}.vv.RSLC_tab"

	# ScanSAR_coreg.py
	if [ ${master_dt} = ${ref_date} ]; then
		ScanSAR_coreg.py $master_tab $master_dt $slave_tab $slave_dt $slave_rtab ${workdir}/DEM/${ref_date}.hgt $rlks $azlks
	elif [ ${master_dt} != ${ref_date} ]; then
		ScanSAR_coreg.py ${ref_date}.vv.SLC_tab $ref_date $slave_tab $slave_dt $slave_rtab ${workdir}/DEM/${ref_date}.hgt $rlks $azlks --RSLC3_tab ${master_dt}.vv.RSLC_tab --RSLC3_ID $master_dt
		create_offset ${master_dt}.rslc.par ${slave_dt}.rslc.par ${mas_to_slv}.off 1 $rlks $azlks 0
		phase_sim_orb ${master_dt}.rslc.par ${slave_dt}.rslc.par ${mas_to_slv}.off ${workdir}/DEM/${ref_date}.hgt $s${mas_to_slv}.sim_unw ${master_dt}.rslc.par - - 1 1
	fi

	mv *.coreg_quality *.diff *.diff.bmp *.off *.results *.sim_unw ${infdir}/${mas_to_slv}/

}

list_master=()
list_slave=()
counter=0
cd ${slcdir}

for slc_file in `ls -f *.slc`
do
	list_master[${counter}]="${slc_file}"
	counter=`expr ${counter} + 1`
done
list_slave=(${list_master[@]})

# coregistration
counter=0
for master in ${list_master[@]}
do
	for slave in ${list_slave[@]}
	do
		master_date=`echo ${master} | sed -e "s/[^0-9]//g"`
		slave_date=`echo ${slave} | sed -e "s/[^0-9]//g"`

		if [ ${master_date} -lt ${slave_date} ];then
			echo "master date = ${master_date}"
			echo "slave date = ${slave_date}"
			func_coregistration ${master} ${slave} ${rlks} ${azlks}
		fi
	done
done

cp ${slcdir}/${ref_date}.slc.par ${slcdir}/${ref_date}.rslc.par
cp ${slcdir}/${ref_date}.slc ${slcdir}/${ref_date}.rslc

# multi_look for coregistered slc files
cd ${slcdir}
for rslc_file in `ls -f *.rslc`
do
	base_name=`echo ${rslc_file} | awk -F"." '{print $1}'`
	rslc=${base_name}.rslc
	rslc_par=${base_name}.rslc.par
	rmli=${base_name}.rmli
	rmli_par=${base_name}.rmli.par
	multi_look ${rslc} ${rslc_par} ${workdir}/rmli/${rmli} ${workdir}/rmli/${rmli_par} ${rlks} ${azlks}
done



