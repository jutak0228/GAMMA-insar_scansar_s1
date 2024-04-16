#!/bin/bash

# preparation of BURST_tabs that suited to generate consistent S1 SLC stacks (including corresponding burst)
# before select bursts and sub-swaths, you should check if you're going to cutting out the overlapped areas
# between the reference image and other images: overlapped areas (=burst numbers) can be different between them.

workdir="$1"
ref_date="$2"

cd ${workdir}
if [ -e "rslc" ];then rm -r rslc; fi
mkdir -p "rslc"
slcdir="${workdir}/rslc"

cd ${workdir}/input_prep

rm -f dates
rm -f tmp0

cd ${workdir}/input_files_orig
for zip_file in `ls -F *.zip`
do
	file_tm=`echo $zip_file | awk -F"T" '{print $1}'`
	fileID=`echo $file_tm | awk -F"_" '{print $1$2$3"_"$6}'`
	date=`echo $fileID | awk -F"_" '{print $2}'`
	echo ${date} >> ${workdir}/input_prep/tmp_dates
	echo ${ref_date} >> ${workdir}/input_prep/tmp0
done
cd ${workdir}/input_prep
sort tmp_dates | uniq >> dates
rm tmp_dates

# create OPOD directory and donwload orbit aux data from ESA website
# sentineleof: Tool to download Sentinel 1 precise/restituted orbit files (.EOF files) for processing SLCs
if [ -e "../input_files_orig/OPOD" ];then rm -r ../input_files_orig/OPOD; fi
mkdir -p "../input_files_orig/OPOD"
run_all.pl dates 'eof -p ../input_files_orig --save-dir ../input_files_orig/OPOD'

#for i in `cat dates | wc -l`; do echo ${ref_date} >> tmp0; done
paste dates tmp0 > dates_tmp0

# import selected bursts from each acquisition
run_all.pl dates 'ls ../input_files_orig/*$1*.zip > $1.zipfile_list'
run_all.pl dates_tmp0 'S1_import_SLC_from_zipfiles $1.zipfile_list $2.burst_number_table vv 0 0 ../input_files_orig/OPOD 1 1'

rm -f dates_tmp0 tmp0
rm -rf tmp_data_dir

# copy dates file
cp dates $slcdir
cp *.vv.slc.iw? $slcdir
cp *.vv.slc.iw?.par $slcdir
cp *.vv.slc.iw?.tops_par $slcdir
cp *.SLC_tab $slcdir

cd ../

