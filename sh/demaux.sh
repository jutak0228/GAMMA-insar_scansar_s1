#!/bin/bash

###################################################
### create support files from dem data
# (layover and shadow, incidence angle, local resolution, offnadir angle)
# unit of look vector is radian:
# lv_theta  (output) SAR look vector "elevation angle" at each map pixel
#              lv_theta: PI/2 -> up  -PI/2 -> down
# lv_phi    (output) SAR look vector orientation angle at each map pixel
#              lv_phi: 0 -> East  PI/2 -> North

workdir="$1"
ref_date="$2"
python="$3"

cd ${workdir}

if [ -e ${workdir}/results/demaux ];then rm -r ${workdir}/results/demaux; fi

demdir=${workdir}/DEM
pwrdir=${workdir}/rmli
cd ${demdir}

if [ -e demaux ];then rm -r demaux; fi
mkdir demaux
cd demaux

# ls_map,local incidence
gc_map2 ${pwrdir}/${ref_date}.rmli.par ${demdir}/EQA.dem_par ${demdir}/EQA.dem - - - 1 1 ls_map - inc
data2geotiff ${demdir}/EQA.dem_par ls_map 5 ls_map.tif 0
rm -rf ls_map
# convert degree
python ${python}/rad2deg.py inc inc_deg
data2geotiff ${demdir}/EQA.dem_par inc_deg 1 local_inc.tif 0
rm -rf inc inc_deg

# slope
dem_gradient ${demdir}/EQA.dem_par ${demdir}/EQA.dem theta phi mag 1
python ${python}/deg_calc.py theta slope_grad
python ${python}/rad2deg.py phi slope_ori
data2geotiff ${demdir}/EQA.dem_par slope_grad 1 slope_grad.tif 0
data2geotiff ${demdir}/EQA.dem_par slope_ori 1 slope_ori.tif 0
rm -rf slope_grad slope_ori theta phi mag

# look vector
look_vector ${pwrdir}/${ref_date}.rmli.par - ${demdir}/EQA.dem_par ${demdir}/EQA.dem lv_theta lv_phi
data2geotiff ${demdir}/EQA.dem_par lv_theta 2 lv_theta.tif 0
data2geotiff ${demdir}/EQA.dem_par lv_phi 2 lv_phi.tif 0
rm -rf lv_theta lv_phi

# results dir create
if [ ! -e ${workdir}/results/demaux ];then mkdir -p ${workdir}/results/demaux; fi
cp -r ${demdir}/demaux/* ${workdir}/results/demaux/
rm -r ${demdir}/demaux/