#!/bin/sh
#
# set variables
# prj=M15c # projection. 
# prj=S0/90/16c # projection.
prj=S10/90/11c # projection.
region=-18/74/30/82r 

# set variables for grids and cpt's
grd_in=/Users/yliu/Data/paper/3/map/IBCAO_framstrait.grd #input grid file
int_in=/Users/yliu/Data/paper/3/map/IBCAO_framstrait.int #input intensity file
cpt_wet=/Users/yliu/Data/paper/3/map/framstrait_wet.cpt
cpt_dry=/Users/yliu/Data/paper/3/map/framstrait_dry.cpt

# output file
out=map_framstrait.ps

# check default parameters: gmt gmtdefaults -D in the terminal

# change some postscript proporties
gmt gmtset PS_MEDIA=a4	PS_PAGE_ORIENTATION=portrait FORMAT_GEO_MAP=ddd:mm:ssF FONT_ANNOT_PRIMARY=10p,Helvetica,black

# change map appearance
gmt gmtset MAP_FRAME_TYPE=plain MAP_FRAME_AXES=wesn MAP_TICK_LENGTH_PRIMARY=0p/0p MAP_GRID_CROSS_SIZE_PRIMARY=0p

# change character encoding
gmt gmtset PS_CHAR_ENCODING=ISOLatin1+

# create color palette table
makecpt -Cibcso -T-5000/0/100 -D -Z >$cpt_wet #-C color,abyss; -T color value range (refer to grid range);-Z:continuous color gradient
makecpt -Cdem2 -T0/1500/250 -D -Z >$cpt_dry #-C color,abyss; -T color value range (refer to grid range)

# create a clipped image of the wet areas
gmt pscoast -J$prj -R$region -Sc -Df -V -K >$out # -S clip the wet areas
grdimage $grd_in -J$prj -R$region -C$cpt_wet -I$int_in -K -O >>$out #-I:specify intensity file
gmt pscoast -J$prj -R$region -Q -V -K -O >>$out #-Q terminate the clipping

# create a clipped image of the dry areas
gmt pscoast -J$prj -R$region -Gc -Df -V -K -O>>$out # -G clip the wet areas
grdimage $grd_in -J$prj -R$region -C$cpt_dry -I$int_in -K -O >>$out #-I:specify intensity file
gmt pscoast -J$prj -R$region -Q -V -K -O >>$out #-Q terminate the clipping

# creat coastline
gmt pscoast -J$prj -R$region -W0.2p,black -N1/0.5p,red -Ir/0.5p,blue -Df -V -K -O >>$out #red to RGB code 255/0/0, -E specifies the region, DE is Germany;+g fill the color of the region, and red is red.

# create contours on the map
#gmt grdcontour $grd_in -J$prj -R$region -C3000 -W0.2p,black -V -K -O >>$out

# plot stations on the map
gmt psxy latlon_ps992.txt -i7,6 -J$prj -R$region -Sc0.26c -Ggreen -W0.3p,black -V -K -O >>$out #by default, gmt plot lon-lat instead of lat-lon, so i7,6 (i6,7 does not work!)
gmt psxy latlon_ps107.txt -i7,6 -J$prj -R$region -St0.32c -Gred -W0.3p,black -V -K -O >>$out #by default, gmt plot lon-lat instead of lat-lon, so i7,6 (i6,7 does not work!)
gmt psxy latlon_ps121.txt -i7,6 -J$prj -R$region -Sd0.18c -Gorange -W0.3p,black -V -K -O >>$out #by default, gmt plot lon-lat instead of lat-lon, so i7,6 (i6,7 does not work!)


# plot legend of the cruises
gmt pslegend -J$prj -R$region -Dx0c/5.5c+w0.8i/0.7i+jBL+l1 \
-C0.1i/0.4i -V -K -O << EOF >>$out
# G is vertical gap, V is vertical line, N sets # of columns, D draws horizontal line.
# H is header, L is label, S is symbol, T is paragraph text, M is map scale.
G -0.7c
#D 1p
N 1
V 1p
S 0.01i c 0.095i green 0.2p 0.1i PS99.2
S 0.01i t 0.095i red 0.2p 0.1i PS107
S 0.01i d 0.095i orange 0.2p 0.1i PS121
V 1p
#D 1p
N 1
EOF

# Add text
gmt pstext text.txt -: -J$prj -R$region -F+f12p,Helvetica-Bold,black+a -V -K -O >>$out 

# create basemap
gmt psbasemap -J$prj -R$region -Bxa10g10 -Bya4g2 -V -K -O >>$out #last layer -O
#measuring scale
gmt psbasemap -J$prj -R$region -Lx9.6c/0.5c+c76+w200+f+ukm --FONT_ANNOT_PRIMARY=6p,Helvetica-Bold,black -V -K -O >>$out #last layer -O
#gmt psbasemap -J$prj -R$region -Lx2c/2c+c50+w200+f -V -O >>$out #+f use "fancy" measuring scale

#create inlet for overview of Arctic
prj=S10/90/2c # projection.
region=-180/180/58/90 
#gmt pscoast -J$prj -R$region -Gblack -Swhite -Dl -V -K -O >>$out 
gmt pscoast -J$prj -R$region -X0.1c -Y0.2c -W0.265p,black -Gwhite -Swhite -Dl -V -K -O >>$out 
#gmt psxy fram_box.xy -J$prj -R$region -W1p,red -V -K -O >>$out 
gmt psbasemap -J$prj -R$region -Bxa0g0 -Bya0g0 --MAP_FRAME_PEN=1p -V -O >>$out


# convert PostScript to other formats
gmt psconvert $out -Tj -A0.2c -V #-T:format, g-png, f-PDF, e-eps,j-jpeg; -A cut off edge 0.2 centimeter; -E, resolution,720 for PDF, 300 for others
gmt psconvert $out -Tf -A0.2c -V