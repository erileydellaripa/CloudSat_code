;;; Plot clouds on lat-lon grid, and display them on subsequent;;; postage stamp pages using the pixels
;;;Updated 4/08/08 by ER - removed halving of
;;;0 dBZ bin and truncaiton of filenames
pro plot_CFADs_midlats, FILENAMES = filenames, SORTBY = sortby, SAMPLE_NAME=sample_name, $
                ndays = ndays, nlats=nlats, nlons=nlons, bbwidths = bbwidths, $
		PATH = path

;PATH = '/Volumes/Seagate/CLOUDSAT_R04/cloud_pixels/'
;PATH = '/Volumes/Mini_me/cloud_pixels/'
;PATH = '/Volumes/silverbullet/new_cloud_pixels/'

tall
device, file=SAMPLE_NAME+'.overlappingstamps.ps'

;;;;set overlap to zero
overlap = 0

;;; Mean CFADs ffor each category
CFAD = fltarr(76, 85) ;; -50 to 25 in dbz, 0-20 in z by .24km
OCFAD = fltarr(76, 85) ;; -50 to 25 in dbz, 0-20 in z by .24km
TOTALCFAD = fltarr(76, 85) ;; -50 to 25 in dbz, 0-20 in z by .24km
dbz_cfad = -50 + (0.5+indgen(76))
z_cfad = (0.5+indgen(85))*240 
bot_vs_top = fltarr(105,105) ;;;Changed to 105 11/21/08
zaxis = indgen(105)*240      ;;;Changed to 105 11/21/08

order = sort( sortby ) ;;; Lowest to highest cloud order
filenames = filenames[order]
;;;;;Arrays to be filled later for histogram of profile by profile
;;;;;tops, bases, and thicknesses, layers
;tot_width   = total(bbwidths)
base_array   = fltarr(105)
top_array    = fltarr(105)
thick_array  = fltarr(105)
;have_layers  = 0 ;initialize how many profiles in EO have layers
;total_layers = 0 ;initialize how many profiles for all EO in the loop
;have layers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop over clouds
    for i = 0L, n_elements(filenames)-1 do begin
    if (i mod 10) eq 0 then print, 'cloud number ', i, '/', n_elements(filenames) 

        pixelfile = PATH + strmid(filenames[i], 0, 19) + $
          '/'+filenames[i] + '.sav'
        restore, pixelfile ;;; xcloud, zcloud, dbzcloud, xoverlapped, zoverlapped, dbzoverlapped

        if zoverlapped[0] gt -999 then $
          zoverlapped = zoverlapped/1000.

;;;;Keep track of how many clouds contain overlap
overlap = overlap + (zoverlapped[0] gt -999)

;;;;Make array for incloud and overlapped clouindess
        if zoverlapped[0] gt -999 then begin
            total_dbz = [dbzcloud, dbzoverlapped]
            total_z   = [zcloud, zoverlapped]
            total_x   = [xcloud, xoverlapped]
        endif else begin
            total_dbz = [dbzcloud]
            total_z   = [zcloud]
            total_x   = [xcloud]
        endelse 

;;;;Added 8/11/08
;       EOtop_profile  = total(EOtop, 1)
;       EObase_profile = total(EObase, 1) ;;z profile of cloud-base
;       density for this EO, not really what we want, as sometimes
;       there are multiple 1s in a vertical profile
;       (i.e. [0,0,1,1,1,2,3,...])

;---------------Find, profile by profile "cloud" base, top, and thickness
        h        = hist_2d(xcloud-min(xcloud), zcloud/240) ;;a cloud mask postage stamp in 240m z bins
        if max(h) gt 1 then h[where(h gt 1)] = 1
        ;;create array to be filled
        syze     = size(h)
        base_ind = fltarr(syze[1]) ;syze[1] = x-dimension, width of the cloud
        top_ind  = fltarr(syze[1]) ;syze[2] = z-dimension, height of the cloud*240 km

        for j=0L, n_elements(h[*,0])-1 do begin
            base_ind[j] =  min(uniq(h[j,*]))+1 ;find vert array loc of base, use min(uniq())+1 to find 1st index with a value = 1
        endfor                                      ;uniq returns the last index of each unique element, so last index of 1st set of 0s

        for j=0L, n_elements(h[*,0])-1 do begin
            top_ind[j] = max(uniq(h[j,*]))
        endfor

;;;Convert indicies into heights
        base_z = base_ind*240
        top_z  = top_ind*240
        thick = top_z - base_z + 240 ;;add one pixel thickness
        bad_thick = where(thick lt 0, count)
        if count gt 0 then print, '***THICKNESS IS NEGATIVE '+filenames[i]
        avg_thick= mean(thick)

;;;Total base, top, thick arrays for all EOs 
        base_array = histogram(base_z, input=base_array, binsize=240, min=0)
        top_array  = histogram(top_z,  input=top_array,  binsize=240, min=0)
        thick_array = histogram(thick,  input=thick_array,binsize=240, min=0)

;;;; GRAB PIXELS FOR TOTAL CATEGORY HISTOGRAM
;;;01/09/08 - Updated by ER.  Previously had all Results(1,2,3) just
;;;           as Result, thus making the CFADs incorrect!
        Result1 = HIST_2D( dbzcloud, zcloud, BIN1=1 ,BIN2=240, MAX1=25, MAX2=20160, MIN1=-50, MIN2=0) 
        CFAD[*,*] = CFAD[*,*] + Result1

        if zoverlapped[0] gt -999 then begin
            Result2 = HIST_2D( dbzoverlapped, zoverlapped, BIN1=1 ,BIN2=240, MAX1=25, MAX2=20160, MIN1=-50, MIN2=0) 
            OCFAD[*,*] = OCFAD[*,*] + Result2
        endif 

        Result3 = HIST_2D( total_dbz, total_z, BIN1=1 ,BIN2=240, MAX1=25, MAX2=20160, MIN1=-50, MIN2=0) 
        TOTALCFAD[*,*] = TOTALCFAD[*,*] + Result3

        Result4 = HIST_2D(base_z, top_z, BIN1=240, BIN2=240, MAX1 = 25000, MAX2=25000, MIN1=0, MIN2=0) 
        bot_vs_top[*,*] = bot_vs_top[*,*] + Result4
    end 
;;;;fraction of clouds that contain overlap
overlap_fraction = overlap/float(n_elements(filenames))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; correct for double binning at 0.5 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; added 12/28/07, ER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; removed 04/08/08, pixels recrated
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; shouldn't be a problem any more.
;cfad[50,*] = cfad[50,*]/2
;ocfad[50,*] = ocfad[50,*]/2
;totalcfad[50,*]= totalcfad[50,*]/2

;;;Compute Cloud Fraction
samples = 8.24 * ndays * nlats * nlons
cloud_fraction = total(CFAD, 1)/samples
overlap_cloud_fraction = total(OCFAD, 1)/samples
total_cloud_fraction = total(TOTALCFAD, 1)/samples
;;;Compute normalized CFAD, units are percent
normCFAD = (CFAD/total(CFAD))*100
normTOTALCFAD = (TOTALCFAD/total(TOTALCFAD))*100
normOCFAD = (OCFAD/total(OCFAD))*100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plots of the CFAD

;;;; CFAD plot
!p.multi=[0,1,2]
;;;; Fix the color scale by kluging an origin pixel

  contour, alog(CFAD>1), dbz_CFAD, z_CFAD/1000., /fill, nlev=33, $
  xtit='dbZ', ytit='z (km)', tit='CFAD' + sample_name

  contour, alog(OCFAD>1), dbz_CFAD, z_CFAD/1000., /fill, nlev=33, $
    xtit='dbZ', ytit='z (km)', tit='CFAD Overlapping Cloudiness ' + sample_name

  contour, alog(TOTALCFAD>1), dbz_CFAD, z_CFAD, /fill, nlev=33, $
    xtit='dbZ', ytit='z (km)', tit='CFAD Total Cloudiness ' + sample_name

  
;;; Profile of cloud fraction
plot, total(CFAD,1), z_cfad/1000., tit='Cloud Cover '+ sample_name, $
  xtit='# of obs', ytit='z (km)'

plot, total(OCFAD,1), z_cfad/1000., tit='Overlapping Cloud Cover ' + sample_name, $
  xtit='# of obs', ytit='z (km)'

plot, total(TOTALCFAD,1), z_cfad/1000., tit='Total Cloud Cover '+ sample_name, $
  xtit='# of obs', ytit='z (km)'

;;;;;;;;;;;
plot, total(CFAD,1), z_cfad/1000., tit='Cloud Cover ' + sample_name, $
  xtit='# of obs', ytit='z (km)'
oplot, total(OCFAD,1), z_cfad/1000., linestyle=3
oplot, total(TOTALCFAD,1), z_cfad/1000., linestyle=2

;;;;;;;;;;;
plot, total(CFAD,1), z_cfad/1000., tit='Cloud Cover ' + sample_name, $
  xtit='# of obs', ytit='z (km)'
oplot, total(TOTALCFAD,1), z_cfad/1000., linestyle=2

;;;;;;;;;;;
plot, top_array, zaxis/1000., title = 'tops profile '+sample_name, $
  xtit= '# samples', ytit='height (km)'
plot, base_array, zaxis/1000., title = 'bases profile ' +sample_name, $
  xtit= '# samples', ytit='height (km)'
plot, thick_array, zaxis/1000., title = 'thick profile '+sample_name, $
  xtit= '# samples', ytit='height (km)'


;;;Save it all off
;save, file='/Volumes/silverbullet/global_loops/CFADS.sav/'+sample_name+'CFAD.sav', CFAD, z_cfad, dbz_cfad, cloud_fraction, normCFAD
;save, file='/Volumes/silverbullet/global_loops/CFADS.sav/'+sample_name+'withoverlaps.CFAD.sav', TOTALCFAD, OCFAD, $
;  z_cfad, dbz_cfad, overlap_fraction, total_cloud_fraction, normOCFAD, normTOTALCFAD
;save, file='/Volumes/silverbullet/global_loops/histogram_profile_top_base_thk/'+sample_name+'profile_hist.sav', base_array, $
;  top_array, thick_array

save, file='/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'CFAD.sav', CFAD, z_cfad, dbz_cfad, cloud_fraction, normCFAD
save, file='/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'withoverlaps.CFAD.sav', TOTALCFAD, OCFAD, $
  z_cfad, dbz_cfad, overlap_fraction, total_cloud_fraction, normOCFAD, normTOTALCFAD, bot_vs_top, overlap_cloud_fraction, cloud_fraction
save, file='/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/histogram_profile_top_base_thk/'+sample_name+'profile_hist.sav', base_array, $
  top_array, thick_array

;;;Save also to seagate
save, file='/Volumes/Seagate/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'CFAD.sav', CFAD, z_cfad, $
  dbz_cfad, cloud_fraction, normCFAD
save, file='/Volumes/Seagate/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'withoverlaps.CFAD.sav', $
  TOTALCFAD, OCFAD, z_cfad, dbz_cfad, overlap_fraction, total_cloud_fraction, normOCFAD, normTOTALCFAD, bot_vs_top, overlap_cloud_fraction,$
  cloud_fraction ;, low_pop_underlap_fraction ;up_pop_overlap_fraction
save, file='/Volumes/Seagate/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/histogram_profile_top_base_thk/'+sample_name+'profile_hist.sav', $
  base_array, top_array, thick_array

psout
end 
