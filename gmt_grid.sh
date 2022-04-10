#!/bin/sh

# gmt grdinfo IBCAO.nc (in terminal) # check the grid information of the grid file GEBCO.nc

# input variables
grd_in=/Users/yliu/Data/paper/3/map/IBCAO_V3_30arcsec_RR #input grid file
grd_out=/Users/yliu/Data/paper/3/map/IBCAO_framstrait.grd #output grid file
int_out=/Users/yliu/Data/paper/3/map/IBCAO_framstrait.int #output internsity grid file

# create sub-region Fram Strait from IBCAO Arctic grids
gmt grdcut $grd_in -R-40/30/72/84   -V -G$grd_out #-G defines output file; -V verbose

# create the intensity file (grid)
gmt grdgradient $grd_out -G$int_out -Nt0.5 -A135 -V #-N:Normalization of gradients. -A:illumination angle

