#!/bin/bash

workdir="$1"
master_date="$2"
slave_date="$3"
rglks="$4"
azlks="$5"
ref_range="$6"
ref_azimuth="$7"

cd ${workdir}/results

# results dir create
if [ -e demgen ];then rm -r demgen; fi
mkdir demgen

cd ${workdir}

if [ -e int ];then rm -r int; fi
mkdir int
cd int

cp ${workdir}/rslc/${master_date}.rslc .
cp ${workdir}/rslc/${master_date}.rslc.par .
cp ${workdir}/rslc/${slave_date}.rslc .
cp ${workdir}/rslc/${slave_date}.rslc.par .
cp ${workdir}/rmli/${master_date}.rmli .
cp ${workdir}/rmli/${master_date}.rmli.par .
cp ${workdir}/rmli/${slave_date}.rmli .
cp ${workdir}/rmli/${slave_date}.rmli.par .
cp ${workdir}/DEM/EQA.dem_par .
cp ${workdir}/DEM/${master_date}.hgt .

mliwidth=`cat ${master_date}.rmli.par | grep "range_samples" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
mliheight=`cat ${master_date}.rmli.par | grep "azimuth_lines" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
orthowidth=`cat EQA.dem_par | grep "width" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`

### Generation of the interferogram
# The first step is to generate an ISP offset parameter file in which the parameters describing 
# the interferogram will be stored (*.off).
create_offset ${master_date}.rslc.par ${slave_date}.rslc.par ${master_date}to${slave_date}.off 1 - - 0
offset_pwr ${master_date}.rslc ${slave_date}.rslc ${master_date}.rslc.par ${slave_date}.rslc.par ${master_date}to${slave_date}.off ${master_date}to${slave_date}.offs ${master_date}to${slave_date}.snr 64 64 ${master_date}to${slave_date}.offset 1 32 32 7.0
offset_fit ${master_date}to${slave_date}.offs ${master_date}to${slave_date}.snr ${master_date}to${slave_date}.off ${master_date}to${slave_date}.coff ${master_date}to${slave_date}.coffset 7.0 4

SLC_interp ${slave_date}.rslc ${master_date}.rslc.par ${slave_date}.rslc.par ${master_date}to${slave_date}.off R${slave_date}.rslc R${slave_date}.rslc.par

SLC_intf ${master_date}.rslc R${slave_date}.rslc ${master_date}.rslc.par R${slave_date}.rslc.par ${master_date}to${slave_date}.off ${master_date}to${slave_date}_${rglks}_${azlks}.int $rglks $azlks

#InSAR DEM
mliwidth=`cat ${master_date}.rmli.par | grep "range_samples" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
mliheight=`cat ${master_date}.rmli.par | grep "azimuth_lines" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`
orthowidth=`cat EQA.dem_par | grep "width" | awk -F":" '{print $2}' | tr -d [:space:] | sed -e "s/[^0-9]//g"`

#衛星間の距離計算
base_init ${master_date}.rslc.par ${slave_date}.rslc.par ${master_date}to${slave_date}.off ${master_date}to${slave_date}_${rglks}_${azlks}.int ${master_date}to${slave_date}.base 2

#軌道縞の削除
ph_slope_base ${master_date}to${slave_date}_${rglks}_${azlks}.int ${master_date}.rslc.par ${master_date}to${slave_date}.off ${master_date}to${slave_date}.base ${master_date}to${slave_date}_flt

#フィルタリング
adf ${master_date}to${slave_date}_flt ${master_date}to${slave_date}_flt_sm ${master_date}to${slave_date}.cc $mliwidth 1.0 32

#マスク処理 
rascc_mask ${master_date}to${slave_date}.cc ${master_date}.rmli $mliwidth - - - - - 0.3 - - - - - - ${master_date}to${slave_date}_mask.bmp

# #アンラップ処理
mcf ${master_date}to${slave_date}_flt_sm ${master_date}to${slave_date}.cc ${master_date}to${slave_date}_mask.bmp ${master_date}to${slave_date}_flt_sm_unw $mliwidth 0 0 0 - - 1 1 - $ref_range $ref_azimuth

#アンラップ結果の補完
interp_ad ${master_date}to${slave_date}_flt_sm_unw ${master_date}to${slave_date}_flt_sm_unw_ad $mliwidth

#アンラップモデルの作成
unw_model ${master_date}to${slave_date}_flt_sm ${master_date}to${slave_date}_flt_sm_unw_ad ${master_date}to${slave_date}_flt_sm_unw_ad_unw $mliwidth

#アンラップ画像と強度画像の重ね合わせ
rasdt_pwr ${master_date}to${slave_date}_flt_sm_unw_ad_unw ${master_date}.rmli $mliwidth - - - - - - - - ${master_date}to${slave_date}.bmp 

# GCP取得
##自動入力の場合
extract_gcp ${workdir}DEM/${master_date}.hgt ${master_date}to${slave_date}.off ${master_date}to${slave_date}.gcp

#取得したXYZと位相を関連付け
gcp_phase ${master_date}to${slave_date}_flt_sm_unw_ad_unw ${master_date}to${slave_date}.off ${master_date}to${slave_date}.gcp ${master_date}to${slave_date}.gcp_ph

#基線の再推定
base_ls ${master_date}.rslc.par ${master_date}to${slave_date}.off ${master_date}to${slave_date}.gcp_ph ${master_date}to${slave_date}.base 1 1 1 1 1 1 R${slave_date}.rslc.par

#DEM作成
hgt_map ${master_date}to${slave_date}_flt_sm_unw_ad_unw ${master_date}.rslc.par ${master_date}to${slave_date}.off ${master_date}to${slave_date}.base ${master_date}to${slave_date}.hgt ${master_date}to${slave_date}.gr 1 - - R${slave_date}.rslc.par

#オルソ化
geocode_back ${master_date}to${slave_date}.hgt $mliwidth ${workdir}/DEM/${master_date}.lt_fine ${master_date}to${slave_date}.hgt_ortho $orthowidth - 0 0

#TIFF化
data2geotiff EQA.dem_par ${master_date}to${slave_date}.hgt_ortho 2 ${workdir}/results/demgen/${master_date}to${slave_date}_hgt_ortho.tif

