#!/bin/bash

workdir="$1"
ref_date="$2"
rlks="$3"
azlks="$4"

demdir=${workdir}/DEM
slcdir=${workdir}/rslc
pwrdir=${workdir}/rmli
infdir=${workdir}/infero

func_interferometry()
{
	cd ${slcdir}

	slc_master=$1
	slc_slave=$2
	rlks=$3
	azlks=$4

	master_dt=`echo $slc_master | awk -F"." '{print $1}'`
	slave_dt=`echo $slc_slave | awk -F"." '{print $1}'`
	master_rslc="${slcdir}/${master_dt}.rslc"
	master_rslc_par="${slcdir}/${master_dt}.rslc.par"
	master_rmli="${pwrdir}/${master_dt}.rmli"
	master_rmli_par="${pwrdir}/${master_dt}.rmli.par"
	slave_rmli_par="${pwrdir}/${slave_dt}.rmli.par"
	slave_rslc="${slcdir}/${slave_dt}.rslc"
	slave_rslc_par="${slcdir}/${slave_dt}.rslc.par"

	mas_to_slv="${master_dt}_${slave_dt}"
	off_file="${infdir}/${mas_to_slv}/${mas_to_slv}.off"
	sim_unw_file="${infdir}/${mas_to_slv}/${mas_to_slv}.sim_unw"
	diff_file="${infdir}/${mas_to_slv}/${mas_to_slv}.diff"
	range_samples=`cat ${master_rmli_par} | grep "range_samples" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`

	counter=`expr ${counter} + 1`
	cd ${infdir}/${mas_to_slv}
	# topographic phase simulation 
	phase_sim_orb $master_rslc_par $slave_rslc_par $off_file ${workdir/}DEM/${ref_date}.hgt $sim_unw_file $master_rslc_par - - 1 1

	# calculate differential interferogram (azimuth common band filtering
	# is not activated, to apply it the two SLCs need to be first deramped for
	# the azimuth phase ramp relating to the doppler centroid variation within each burst)

	SLC_diff_intf $master_rslc $slave_rslc $master_rslc_par $slave_rslc_par $off_file $sim_unw_file $diff_file $rlks $azlks 1 0 0.2
	rasmph_pwr $diff_file $master_rmli $range_samples 1 0 1 1 rmg.cm ${diff_file}.bmp 1. .35 24

}

list_master=()
list_slave=()
counter=0
cd ${slcdir}

for rslc_file in `ls -f *.rslc`
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
		master_date=`echo ${master} | sed -e "s/[^0-9]//g"`
		slave_date=`echo ${slave} | sed -e "s/[^0-9]//g"`

		if [ ${master_date} -lt ${slave_date} ];then
			echo "master date = ${master_date}"
			echo "slave date = ${slave_date}"
			func_interferometry ${master} ${slave} ${rlks} ${azlks}
		fi
	done
done


