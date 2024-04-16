#!/bin/bash

# in this script, we determine burst numbers available in the first zip file
# before select bursts and sub-swaths, you should check if you're going to cutting out the overlapped areas
# between the reference image and other images: overlapped areas (=burst numbers) can be different between them.

workdir="$1"
ref_date="$2"

cd ${workdir}
if [ -e "input_prep" ];then rm -r input_prep; fi
mkdir -p "input_prep"
cd input_prep

ref_zip=`ls ../input_files_orig | grep "${ref_date}"`
S1_extract_png ../input_files_orig/${ref_zip}

S1_BURST_tab_from_zipfile - ../input_files_orig/${ref_zip}
ref_header=`echo ${ref_zip} | sed 's/\.[^\.]*$//'`
cp ${ref_header}.burst_number_table ${ref_date}.burst_number_table

echo "please edit your reference busrt file as below...
zipfile:              S1A_IW_SLC__1SDV_20190809T053522_20190809T053549_028488_033855_23C3.zip
iw2_number_of_bursts: 6
iw2_first_burst:      796.808209
iw2_last_burst:       801.808209"

nedit ${ref_date}.burst_number_table &
eog ${ref_header}.png

cd ../
