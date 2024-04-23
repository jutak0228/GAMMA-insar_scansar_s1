# GAMMA-insar_scansar_s1

GAMMA RS script for Interferometric SAR analysis for Sentinel-1 ScanSAR datasets

## Requirements

GAMMA Software Modules:

The GAMMA software is grouped into four main modules:
- Modular SAR Processor (MSP)
- Interferometry, Differential Interferometry and Geocoding (ISP/DIFF&GEO)
- Land Application Tools (LAT)
- Interferometric Point Target Analysis (IPTA)

The user need to install the GAMMA Remote Sensing software beforehand depending on your OS.

For more information: https://gamma-rs.ch/uploads/media/GAMMA_Software_information.pdf

## Process step

Pre-processing: make directory and input *.zip files into "input_files_orig"

Note: it should be processed orderly from the top (part_XX).

It needs to change the mark "off" to "on" when processing.
 
- part01a="off" # [1] make burst tabs to create BURST_tab for corresponding slc data.
- [2] edit burst_number_table
- part01b="off" # [3] generate BURST_tabs based on the zip files for each zip file.
- [4] define range and azimuth looks numbers...
- part02="off" # [5] mosaic slc burst
- part03="off" # [6] convert the GeoTIFF DEM into Gamma Software format
- part04="off" # [7] geocoding of S1 TOPS reference *Change the oversampling value from 1 to X if you need.
- part05="off" # [8] coregistration with a matching with offset_pwr and a spectral diversity using S1_coreg_overlap
- part06="off" # [9] differential interferogram
- part07="off" # [10] filtering with smoothing | high-pass filtering | bm3d | or whatever you want
- [11] YOU should select range and azimuth values like "1000 1200" as reference point
- part08="off" # [12] unwrapping with mcf method
- part09="off" # [13] make ortho and export output by creation of result directory
- demaux="off" # [option] dem support file export (ls_map, incidence angle, local resolution, offnadir angle)
- demgen="off" # [option] dem generation from interferometric analysis
