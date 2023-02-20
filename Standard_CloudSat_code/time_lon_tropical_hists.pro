PRO time_lon_tropical_hist, type = type, minlon = minlon, maxlon = maxlon, $
                            minlat = minlat, maxlat = maxlat, sample_name = sample_name


tall
;device, file='time_lon_tropical0608_hists.ps'
;device, file='time_lon_tropical0608_PAConly10NS_hists.ps'
;device, file='time_lon_tropical0608_PAC_wcb_only10NS_hists.ps'
device, file = 'time_lon_tropical0608_PAC_'+ sample_name + '_hists.ps'
!p.multi=0

restore, '~/CLOUDSAT/cloud_lists/Masterlist_Dec2010.sav'
restore, '~/CLOUDSAT/cloud_lists/cloudsat_jdays.sav'
restore, '~/CLOUDSAT/cloud_lists/tropical_cloudtypes.sav'

meanlons = (meanlons + 360) mod 360

maxlon = maxlon ;360
minlon = minlon ;0
minday = 166
maxday = 365*3 + 1;max(jdays)
minlat = minlat;-10;-20 ;-30 
maxlat = maxlat ;10 ;20  ;30
BINLON = 360./233.*13.
MINBINLON = minlon
MAXBINLON = maxlon
MINJDAY = minday
MAXJDAY = maxday
BINJDAY = 1 ;;;initially do binjday = 1, so that can exclude missing days from average
LABjday = 'jday'
LABlon = 'longitude'
SAMPLE_NAME = 'tropics0608_time_lon'

w = where(meanlats le maxlat and meanlats ge minlat and $
          meanlons ge minlon and meanlons lt maxlon and $
          jdays ge minday and jdays le maxday and $
          cloudtypes eq type)

Hist = HIST_2D( jdays[w], meanlons[w],  MIN1=MINjday, BIN1=BINjday ,MAX1 = MAXjday, $
                   MIN2=Minbinlon, BIN2=BINlon ,MAX2=Maxbinlon, INDICES = R)

s = size(hist)
nbins = s( n_elements(s)-1 )

JDAYaxis = MINjday + BINjday*(0.5 + findgen(s(1)))
lonaxis = Minbinlon + BINlon*(0.5 + findgen(s(2)))

;;;; Weight by # of pixels per cloud -- see below code for documentation
;;; area and volume
hist2 = hist*0 - 999

for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist2[i] = total(bbwidths [R[R[I] : R[i+1]-1]] ) 
hist3 = hist*0.
for i=0L,NBINS-1 do $
    IF R[i] NE R[i+1] THEN Hist3[i] = total(npixelss [R[R[I] : R[i+1]-1]] ) 

;;hist is [jday, meanlons]
;;;Calculate total for each longitude bin over all days
wgood = where(hist2 gt 0)
good_index = array_indices(hist2, wgood)
good_dayindex = reform(good_index[0, *])
good_lonindex = reform(good_index[1, *])
where_ngood_days = unique(good_dayindex, /sort)
;print, where_ngood_days

wbad = where(hist2 lt 0)
bad_index = array_indices(hist2, wbad)
bad_dayindex = reform(bad_index[0, *])
where_nbad_days = unique(bad_dayindex, /sort)
;print, where_nbad_days

a = hist2[0:102, *]
b = hist2[111:275, *]
c = hist2[280:300, *]
d = hist2[306:534, *]
e = hist2[536:537, *]
f = hist2[539:582, *]
g = hist2[587:707, *]
h = hist2[714:*, *]

hist2_missing_removed = [a, b, c, d, e, f, g, h]

;total_lonbin = total(hist2[good_dayindex, good_lonindex], 1)/s(1)
anom_hist = fltarr(s(1), s(2))

;;;29 missing days
total_lonbin = total(hist2_missing_removed, 1)/(s[1] - 29) ;(s[1] - n_elements(where_nbad_days)) - works for +-30


;FOR ibin = 0, s(2)-1 DO BEGIN
;   anom_hist[*, ibin] = hist2_missing_removed[*, ibin] - total_lonbin[ibin]
;ENDFOR 

FOR ibin = 0, s(2)-1 DO BEGIN
   anom_hist[0:102,   ibin] = a[*, ibin] - total_lonbin[ibin]
   anom_hist[111:275, ibin] = b[*, ibin] - total_lonbin[ibin]
   anom_hist[280:300, ibin] = c[*, ibin] - total_lonbin[ibin]
   anom_hist[306:534, ibin] = d[*, ibin] - total_lonbin[ibin]
   anom_hist[536:537, ibin] = e[*, ibin] - total_lonbin[ibin]
   anom_hist[539:582, ibin] = f[*, ibin] - total_lonbin[ibin]
   anom_hist[587:707, ibin] = g[*, ibin] - total_lonbin[ibin]
   anom_hist[714:*,   ibin] = h[*, ibin] - total_lonbin[ibin]
ENDFOR 
;stop
;levels = -8 + findgen(17) ;for entire globe 0-360
;levels = -6 + findgen(13)
contour, rotate(anom_hist,4)/1000, lonaxis, jdayaxis,  /fill, $
  nlevels = 100, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlon+' cloud anom dist', xtitle = 'longitude', ytitle = 'jday'
hor, [268,275]

contour, rotate(anom_hist,4), lonaxis, jdayaxis,  /over, levels = 0, thick = 5

rebined_anom_hist = rebin(anom_hist[0:929, *], 93, s[2])
newJDAYaxis = MINjday + 10*(0.5 + findgen(93))

restore, '~/IDL_PROGRAMS/Stefan_colortable_warmcold.sav'
tvlct, r, g, b
;levels = -3 + findgen(7)
levels = -2 + findgen(9)/2
contour, rotate(rebined_anom_hist,4)/1000, lonaxis, newjdayaxis,  /fill, $
  nlevels = 200, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlon+' cloud anom dist', xtitle = 'longitude', ytitle = 'jday'
hor, [268,275]

contour, rotate(rebined_anom_hist,4), lonaxis, newjdayaxis,  /over, levels = 0, thick = 5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;after rebinning
loadct, 39
contour, rotate(hist2,4), lonaxis, jdayaxis,  /fill, $
  nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlon+' cloud area dist', xtitle = 'longitude', ytitle = 'jday'
hor, [268,275]
contour, rotate(hist3,4), lonaxis, jdayaxis,  /fill, $
  nlev=230, tit=SAMPLE_NAME+' '+LABjday+'-'+LABlon+' cloud volume dist', xtitle = 'longitude', ytitle = 'jday'
hor, [268,275]

psout
stop
END 
