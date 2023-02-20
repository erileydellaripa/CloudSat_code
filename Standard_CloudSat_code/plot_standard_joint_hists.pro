;;;Created by BEM
;;;;Updated by ER 1/17/08 to allow for max & min lat for binning
;;;;7/17/08 - Changed meanthickness, binz, binthk, be aware of that when looking at
;;;;          plots
pro plot_standard_joint_hists, $
BBWIDTHS=BBWIDTHS, $
NPIXELSS=NPIXELSS, $
BOTTOMS=BOTTOMS, $
TOPS=TOPS, $
MEANZS=MEANZS, $
MAXLATS=MAXLATS, $
MAXLONS=MAXLONS, $
MEANLATS=MEANLATS, $
MEANLONS=MEANLONS, $
MINLATS=MINLATS, $
MINLONS=MINLONS, $
SD_DBZ_SURFS=SD_DBZ_SURFS, $
ZGmins=ZGmins, $ 
ZGmaxs=ZGmaxs, $
JDAYs=JDAYs, $
MINBINLON = minbinlon, $
MINBINLAT = minbinlat, $
MAXBINLON = maxbinlon, $
MAXBINLAT = maxbinlat, $
BINLON = binlon, $
BINLAT = binlat, $
MINJDAY = minjday, $
MAXJDAY = maxjday, $
BINJDAY = binjday, $
SAMPLE_NAME= SAMPLE_NAME

thicknesses = (tops-bottoms)+240 ;; add 1 pixel thickness
;meanthicknesses = (npixelss/bbwidths)*250 ;; MEAN thickness
meanthicknesses = (npixelss/bbwidths)*240 ;; MEAN thickness

tall
device, file=SAMPLE_NAME+'.distributions.ps'
 
;;; Lonitude
;Minbinlon = 0;;;apparently the most recently used one (7/21/2009)
;Minbinlon = -180
;binlon = 360./233. ;;;apparently the most recently used one
;binlon = 2
;BINlon = 3
;BINlon = 10
;BINlon = 5
;Maxbinlon = 360;;;apparently the most recently used one
;Maxbinlon = 180
Minbinlon = minbinlon
Maxbinlon = maxbinlon
Binlon = binlon
LABlon = 'lon'

;;; Latitude
;Minbinlat = -90 ;;;apparently the most recently used one
;binlat = 2   ;;;apparently the most recently used one
;BINlat = 3.6
;BINlat = 5
;BINlat = 2.5
;Maxbinlat = 90  ;;;apparently the most recently used one
Minbinlat = minbinlat
Maxbinlat = maxbinlat
Binlat = binlat
LABlat = 'lat'

;;; JDAY
;MINjday = 166 ;;15 June 2006 ;;;apparently the most recently used one
;BINjday = 10  ;;;apparently the most recently used one
;MAXjday = 605 ;;28 August 2007 - end of old processed data
;MAXjday = 730 ;;31 December 2007 - end of second processed data
;MAXjday = 812 ;;22 March 2008
;MAXjday = 1035 ;;31 October 2008 ;;;apparently the most recently used one
Minjday = minjday
Maxjday = maxjday
Binjday = binjday
LABjday = 'jday06'

;;; Top, bottom Height
MINz  = 0
BINz  = 240 ;;; meters
MAXz  = 24240
LABz  = 'ztop'
LABzb = 'zbot'

;;; Centroid Height
MINzbar = 0
BINzbar = 240 ;;; meters
MAXzbar = 24240
LABzbar = 'z_centroid'

;;; Thickness
MINthk = 0
BINthk = 240 ;;; meters
MAXthk = 24240
LABthk = 'thk'

;;;BBwidth
MINwidth= 1
BINwidth= 10
MAXwidth= 3000
LABwidth= 'width'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; Lon-lat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Hist = HIST_2D( meanlons, meanlats, MIN1=Minbinlon, BIN1=BINlon ,MAX1 = Maxbinlon, $
                   MIN2=Minbinlat, BIN2=BINlat ,MAX2=Maxbinlat, INDICES = R)
;;;;;2/24/08 Trying to figure out issue with contouring and binning.
;;;;;The problem is that when the midlevel clouds are plotted with
;;;;;zgmaxs lt 1000 there is a peak in distribution right over the
;;;;;mountain!  How can that be, the binning does it!  Must fix for this!
s = size(hist)
nbins = s( n_elements(s)-1 )

lonaxis = Minbinlon + BINlon*(0.5 + findgen(s(1)))
lataxis = Minbinlat + BINlat*(0.5 + findgen(s(2)) < 90)

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
Hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

!p.multi=[0,1,3]
contour, hist, lonaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABlat+' cloud count dist', $
         xtitle = 'longitude', ytitle = 'latitude'
map_world, limit=[-90,0, 90, 360],/over,/cont, c_thick = 5
contour, hist2, lonaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABlat+' cloud area dist', $
                  xtitle = 'longitude', ytitle = 'latitude'
map_world, limit=[-90,0, 90, 360],/over,/cont, c_thick = 5
contour, hist3, lonaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABlat+' cloud volume dist', $
                  xtitle = 'longitude', ytitle = 'latitude'
map_world, limit=[-90,0, 90, 360],/over,/cont, c_thick = 5

!p.multi=[0,1,3]
contour, hist, lonaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABlat+' cloud count dist',/nodata, $
         xtitle = 'longitude', ytitle = 'latitude'
fit_in_window, 1, hist, MN = min(hist), MX = max(hist)-1
map_world, limit=[-90, 0, 90, 360],/over,/cont, c_thick = 5
contour, hist2, lonaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABlat+' cloud area dist',/nodata, $
                  xtitle = 'longitude', ytitle = 'latitude'
fit_in_window, 1, hist2, MN = min(hist2), MX = max(hist2)-1
map_world, limit=[-90, 0, 90, 360],/over,/cont, c_thick = 5
contour, hist3, lonaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABlat+' cloud volume dist',/nodata, $
                  xtitle = 'longitude', ytitle = 'latitude'
fit_in_window, 1, hist3, MN = min(hist3), MX = max(hist3)-1
map_world, limit=[-90, 0, 90, 360],/over,/cont, c_thick = 5

;;;Save Histograms
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/'+ $
 SAMPLE_NAME + '.latlonhist.sav', hist, hist2, hist3, lataxis, lonaxis

;Save, file ='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/'+ $
;  SAMPLE_NAME + '.latlonhist.sav', hist, hist2, hist3, lataxis, lonaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; tops-lat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( meanlats, tops, MIN1=Minbinlat, BIN1=BINlat ,MAX1 = Maxbinlat, $
                   MIN2=MINz, BIN2=BINz ,MAX2=MAXz, INDICES = R)
s = size(hist)
nbins = s( n_elements(s)-1 )

Zaxis = (MINz + BINz*(0.5 + findgen(s(2))))/1000.

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

!p.multi=[0,1,3]
contour, hist, lataxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlat+'-'+LABz+' cloud number dist', $
         xtitle = 'latitude', ytitle ='height (km)'
;hor, [5,12]
contour, hist2, lataxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlat+'-'+LABz+' cloud area dist', $
                  xtitle = 'latitude', ytitle ='height (km)'
;hor, [5,12]
contour, hist3, lataxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlat+'-'+LABz+' cloud volume dist', $
                  xtitle = 'latitude', ytitle ='height (km)'
;hor, [5,12]

;;;Save Histograms
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.topslathist.sav', hist, hist2, hist3, lataxis, zaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.topslathist.sav', hist, hist2, hist3, lataxis, zaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; z_centroid -lat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( meanlats, meanzs, MIN1=Minbinlat, BIN1=BINlat ,MAX1 = Maxbinlat, $
                   MIN2=MINzbar, BIN2=BINzbar ,MAX2=MAXzbar, INDICES = R)
s = size(hist)
nbins = s( n_elements(s)-1 )

zaxis = (MINzbar + BINzbar*(0.5 + findgen(s(2))))/1000.
;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

!p.multi=[0,1,3]
contour, hist, lataxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlat+'-'+LABzbar+' cloud number dist', $
         xtitle = 'latitude', ytitle ='height (km)'
contour, hist2, lataxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlat+'-'+LABzbar+' cloud area dist', $
                  xtitle = 'latitude', ytitle ='height (km)'
contour, hist3, lataxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlat+'-'+LABzbar+' cloud volume dist', $
         xtitle = 'latitude', ytitle ='height (km)'

;;;Save Histograms
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.z_centroidlathist.sav', hist, hist2, hist3, lataxis, zaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.z_centroidlathist.sav', hist, hist2, hist3, lataxis, zaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; lon- tops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( meanlons, tops, MIN1=Minbinlon, BIN1=BINlon ,MAX1 = Maxbinlon, $
                   MIN2=MINz, BIN2=BINz ,MAX2=MAXz, INDICES = R)
s = size(hist)
nbins = s( n_elements(s)-1 )

zaxis = (MINz + BINz*(0.5 + findgen(s(2))))/1000.

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

!p.multi=[0,1,3]
contour, hist, lonaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABz+' cloud number dist', $
         xtitle = 'longitude', ytitle='height (km)'
;hor, [5,12]
contour, hist2, lonaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABz+' cloud area dist', $
         xtitle = 'longitude', ytitle='height (km)'
;hor, [5,12]
contour, hist3, lonaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABlon+'-'+LABz+' cloud volume dist', $
         xtitle = 'longitude', ytitle='height (km)'
;hor, [5,12]

;;;Save Histograms
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.lontopshist.sav', hist, hist2, hist3, lonaxis, zaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.lontopshist.sav', hist, hist2, hist3, lonaxis, zaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; time-lon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( jdays, meanlons,  MIN1=MINjday, BIN1=BINjday ,MAX1 = MAXjday, $
                   MIN2=Minbinlon, BIN2=BINlon ,MAX2=Maxbinlon, INDICES = R)

s = size(hist)
nbins = s( n_elements(s)-1 )

JDAYaxis = MINjday + BINjday*(0.5 + findgen(s(1)))

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

!p.multi=[0,1,3]
contour, rotate(hist,4), lonaxis, jdayaxis, /fill, nlev=230, $
  tit=SAMPLE_NAME+' '+LABjday+'-'+LABlon+' cloud number dist', xtitle = 'longitude', ytitle = 'jday'
hor, [268,275]
contour, rotate(hist2,4), lonaxis, jdayaxis,  /fill, $
  nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlon+' cloud area dist', xtitle = 'longitude', ytitle = 'jday'
hor, [268,275]
contour, rotate(hist3,4), lonaxis, jdayaxis,  /fill, $
  nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlon+' cloud volume dist', xtitle = 'longitude', ytitle = 'jday'
hor, [268,275]

;;;Save Histograms
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.timelonhist.sav', hist, hist2, hist3, jdayaxis, lonaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.timelonhist.sav', hist, hist2, hist3, jdayaxis, lonaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; time-lat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( jdays, meanlats,  MIN1=MINjday, BIN1=BINjday ,MAX1 = MAXjday, $
                   MIN2=Minbinlat, BIN2=BINlat ,MAX2=Maxbinlat, INDICES = R)
s = size(hist)
nbins = s( n_elements(s)-1 )

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

!p.multi=[0,1,3]
contour, hist, jdayaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlat+' cloud number dist', $
         xtitle = 'jday', ytitle = 'latitude'
ver, [269,276]
contour, hist2, jdayaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlat+' cloud area dist', $
         xtitle = 'jday', ytitle = 'latitude'
ver, [269,276]
contour, hist3, jdayaxis, lataxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlat+' cloud volume dist', $
         xtitle = 'jday', ytitle = 'latitude'
ver, [269,276]

save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.timelathist.sav', hist, hist2, hist3, jdayaxis, lataxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.timelathist.sav', hist, hist2, hist3, jdayaxis, lataxis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; time-tops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( jdays, tops,  MIN1=MINjday, BIN1=BINjday ,MAX1 = MAXjday, $
                   MIN2=MINz, BIN2=BINz ,MAX2=MAXz, INDICES = R)
s = size(hist)
nbins = s( n_elements(s)-1 )

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

!p.multi=[0,1,3]
contour, hist, jdayaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABz+' cloud number dist', $
         xtitle = 'jday', ytitle = 'height (km)'
ver, [269,276]
contour, hist2, jdayaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABz+' cloud area dist', $
         xtitle = 'jday', ytitle = 'height (km)'
ver, [269,276]
contour, hist3, jdayaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABz+' cloud volume dist', $
         xtitle = 'jday', ytitle = 'height (km)'
ver, [269,276]

save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.timetopshist.sav', hist, hist2, hist3, jdayaxis, zaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.timetopshist.sav', hist, hist2, hist3, jdayaxis, zaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; thk- tops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( meanthicknesses, tops, MIN1=MINthk, BIN1=BINthk ,MAX1 = MAXthk, $
                MIN2=MINz, BIN2=BINz ,MAX2=MAXz, INDICES = R)

s = size(hist)
nbins = s( n_elements(s)-1 )
thkaxis = (MINthk + BINthk*(0.5 + findgen(s(1))))/1000.
zaxis = (MINz + BINz*(0.5 + findgen(s(2))))/1000.

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

;;;;;;;;;;;;NUMBER DISTRIBUTION PLOT
contour, alog(hist>1), thkaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABthk+'-'+LABz+' # dist.', $
  xtit=LABthk+' (km)', ytit=LABz+' (km)'

;;;;;;;;;;AREA PLOT
contour, alog(hist2>1), thkaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABthk+'-'+LABz+' a dist.', xtit=LABthk, ytit=LABz

;;;;;;;;;;;VOLUME PLOT
contour, alog(hist3>1), thkaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABthk+'-'+LABz+' v dist.',  xtit=LABthk, ytit=LABz

save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.thknstopshist.sav', hist, hist2, hist3, thkaxis, zaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.thknstopshist.sav', hist, hist2, hist3, thkaxis, zaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; tops-bottoms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D(bottoms, tops, MIN1=MINz, BIN1=BINz ,MAX1 = MAXz, $
                MIN2=MINz, BIN2=BINz ,MAX2=MAXz, INDICES = R)

s = size(hist)
nbins = s( n_elements(s)-1 )
zbaxis = (MINz + BINz*(0.5 + findgen(s(1))))/1000.
zaxis = (MINz + BINz*(0.5 + findgen(s(2))))/1000.

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

;;;;;;;;;;;;NUMBER DISTRIBUTION PLOT
contour, alog(hist>1), zbaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABzb+'-'+LABz+' # dist.', $
  xtit=LABzb+' (km)', ytit=LABz+' (km)'

;;;;;;;;;;AREA PLOT
contour, alog(hist2>1), zbaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABzb+'-'+LABz+' a dist.', xtit=LABzb, ytit=LABz

;;;;;;;;;;;VOLUME PLOT
contour, alog(hist3>1), zbaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABzb+'-'+LABz+' v dist.',  xtit=LABzb, ytit=LABz

save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.bottomtopshist.sav', hist, hist2, hist3, zbaxis, zaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.bottomtopshist.sav', hist, hist2, hist3, thkaxis, zaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; thk- tops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hist = HIST_2D( thicknesses, tops, MIN1=MINthk, BIN1=BINthk ,MAX1 = MAXthk, $
                MIN2=MINz, BIN2=BINz ,MAX2=MAXz, INDICES = R)

s = size(hist)
nbins = s( n_elements(s)-1 )
thkaxis = (MINthk + BINthk*(0.5 + findgen(s(1))))/1000.
zaxis = (MINz + BINz*(0.5 + findgen(s(2))))/1000.

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

;;;;;;;;;;;;NUMBER DISTRIBUTION PLOT
contour, alog(hist>1), thkaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABthk+'-'+LABz+' # dist.', $
  xtit=LABthk+' (km)', ytit=LABz+' (km)'

;;;;;;;;;;AREA PLOT
contour, alog(hist2>1), thkaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABthk+'-'+LABz+' a dist.', xtit=LABthk, ytit=LABz

;;;;;;;;;;;VOLUME PLOT
contour, alog(hist3>1), thkaxis, zaxis, /fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABthk+'-'+LABz+' v dist.',  xtit=LABthk, ytit=LABz

save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.truethknstopshist.sav', hist, hist2, hist3, thkaxis, zaxis

;save, file='/Volumes/Seagate~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
;  SAMPLE_NAME + '.truethknstopshist.sav', hist, hist2, hist3, thkaxis, zaxis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; bbwidths vs Tops ***MODIFIED 2/21/08 ER TO BE WIDTH VS
;;;;;;;;;;; TOPS INSTEAD OF WIDTH VS THICKNESSES***
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Hist = HIST_2D(bbwidths, tops ,MIN2=MINz, BIN2=BINz, MAX2 = MAXz, $
               MIN1=MINwidth, BIN1=BINwidth ,MAX1=MAXwidth, INDICES = R)

s = size(hist)
nbins = s( n_elements(s)-1 )
widthaxis = (MINwidth + BINwidth*(0.5 + findgen(s(1))))
zaxis = (MINz + BINz*(0.5 + findgen(s(2))))/1000.

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist2=hist2/total(hist2)

hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 
hist3=hist3/total(hist3)

contour, hist, widthaxis, zaxis,/fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABwidth+'-'+LABz+' # dist.', $
  xtit=LABwidth+'(km)', ytit=LABz+'cloud top height (km)'

contour, hist2, widthaxis, zaxis,/fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABwidth+'-'+LABz+' area dist.', $
  xtit=LABwidth+'(km)', ytit=LABz+' cloud top height (km)'

contour, hist3, widthaxis, zaxis,/fill, nlev=33, $
  tit=SAMPLE_NAME+' '+LABwidth+'-'+LABz+' vol dist.', $
  xtit=LABwidth+'(km)', ytit=LABz+' cloud top height(km)'

;;;Save Histograms
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/' + $
  SAMPLE_NAME + '.widthtopshist.sav', hist, hist2, hist3, widthaxis, zaxis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;; PIA - tops                                                                                       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hist = HIST_2D( PIAs, tops, MIN1=MINthk, BIN1=BINthk ,MAX1 = MAXthk, $
;                   MIN2=MINz, BIN2=BINz ,MAX2=MAXz, INDICES = R)
;s = size(hist)
;nbins = s( n_elements(s)-1 )

;piaaxis = MINpia + BINpia*(0.5 + findgen(s(1)))
;zaxis = (MINz + BINz*(0.5 + findgen(s(2))))/1000.

;;;; Weight by # of pixels per cloud -- see below code for
;;;;                                    documentation                                                
;;; area and volume                                                   
;hist2 = hist*0.
;for i=0,NBINS-1 do $
;    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] )
;hist3 = hist*0.
;for i=0,NBINS-1 do $
;  IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] )
;;; PIA weighting                                                                 
;hist4 = hist*0.
;for i=0,NBINS-1 do $
;    IF R[i] NE R[i+1] THEN Hist4[i] = total(PIAs [R[R[I] : R[i+1]-1]] )

;!p.multi=[0,2,2]
;contour, hist, piaaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABpia+'-'+LABz+' #dist.'
;contour, hist2, piaaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABpia+'-'+LABz+' a dist.'
;contour, hist3, piaaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABpia+'-'+LABz+' v dist.'
;contour, hist4, piaaxis, zaxis, /fill, nlev=230, tit=SAMPLE_NAME+' '+LABpia+'-'+LABz+' maxPIA dist.'

psout
end


;REVERSE_INDICES
;When possible, this list is returned as a 32-bit integer vector whose number of elements 
;is the sum of the number of elements in the histogram, N, and the number of 
;array elements included in the histogram, plus one. 
;
;The subscripts of the original array elements falling in the ith bin, 
;0 <= i < N, are given by the expression: R(R[i] : R[i+1]-1), 
;where R is the reverse index list. If R[i] is equal to R[i+1], 
;no elements are present in the ith bin.
;
;For example, make the histogram of array A:
;H = HISTOGRAM(A, REVERSE_INDICES = R) 
; 
;;Set all elements of A that are in the ith bin of H to 0. 
;IF R[i] NE R[i+1] THEN A[R[R[I] : R[i+1]-1]] = 0 

;;;;;;;;NOTE:24 Oct 2007, can't define a loglevel since each plot is
;;;;;;;;over a different defined region
