
;;; Plot clouds on lat-lon grid, and display them on subsequent
;;; postage stamp pages using the pixels
;;;Updated 4/08/08 by ER - removed halving of
;;;0 dBZ bin and truncaiton of filenames
pro plot_CFADs_trops, FILENAMES = filenames, SORTBY = sortby, SAMPLE_NAME=sample_name, $
                ndays = ndays, nlats=nlats, nlons=nlons, bbwidths=bbwidths, $
		PATH = path

;PATH = '/Volumes/Seagate/CLOUDSAT_R04/cloud_pixels/'
;PATH = '/Volumes/Mini_me/cloud_pixels/'
;PATH = '/Volumes/silverbullet/new_cloud_pixels/'
;PATH = '/Volumes/SMURF/new_cloud_pixels/'
;PATH = '/Volumes/Silverbullet/new_cloud_pixels/'

tall
device, file=SAMPLE_NAME+'.CFADs.ps'

;;;;set overlap to zero
overlap = 0
;up_pop_overlap = 0
low_pop_underlap = 0
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
base_array   = fltarr(105) ;increased to 105, when changed vert binsize to 240m 11/21/08
top_array    = fltarr(105)
thick_array  = fltarr(105)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop over clouds*********************
    for i = 0L, n_elements(filenames)-1 do begin ;***********
    if (i mod 10) eq 0 then print, 'cloud number ', i, '/', n_elements(filenames) 
    
        pixelfile = PATH + strmid(filenames[i], 0, 19) + $
          '/'+filenames[i] + '.sav'
        restore, pixelfile ;;; xcloud, zcloud, dbzcloud, xoverlapped, zoverlapped, dbzoverlapped
         
;;;;Keep track of how many clouds contain overlap
        overlap = overlap + (zoverlapped[0] gt -999)
;;;;Keep track of how many cloud contain overlap between 6.5 and 8.5 km, check for peaks co-occuring
   ;this will give us the at most fraction that the EOs could be co-occuring.        
;        if total((zoverlapped gt 6.5 and zoverlapped lt 8.5)) gt 0 then true = 1 else true = 0
;        up_pop_overlap = up_pop_overlap + true

;;;;Keep track of how many cloud contain underlap between 4.5 and 6.5 km, check for peaks co-occuring
   ;this will give us the at most fraction that the EOs could be co-occuring.        
;        if total((zoverlapped gt 4500 and zoverlapped lt 6500)) gt 0 then true = 1 else true = 0
;        low_pop_underlap = low_pop_underlap + true
        
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
 
;--------------------------------------------------------------------;
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

;;;Compute Cloud Fraction
samples = 8.04 * ndays * nlats * nlons
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

  contour, alog(TOTALCFAD>1), dbz_CFAD, z_CFAD/1000., /fill, nlev=33, $
    xtit='dbZ', ytit='z (km)', tit='CFAD Total Cloudiness ' + sample_name
    
  contour, alog(bot_vs_top>1), zaxis/1000., zaxis/1000., /fill, nlev=33, $
    xtit='bottom height (km)', ytitle='top height (km)', title='Bottom vs. Top ' + sample_name

  
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

;;;;
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

save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'CFAD.sav', CFAD, z_cfad, $
  dbz_cfad, cloud_fraction, normCFAD, ndays, nlons, nlats
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'withoverlaps.CFAD.sav', TOTALCFAD, OCFAD, $
  z_cfad, dbz_cfad, overlap_fraction, total_cloud_fraction, normOCFAD, normTOTALCFAD, bot_vs_top, overlap_cloud_fraction,$
  cloud_fraction ;, low_pop_underlap_fraction ;up_pop_overlap_fraction
save, file='~/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/histogram_profile_top_base_thk/'+sample_name+'profile_hist.sav', $
  base_array, top_array, thick_array

;;;Save also to seagate
;save, file='/Volumes/Seagate/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'CFAD.sav', CFAD, z_cfad, $
;  dbz_cfad, cloud_fraction, normCFAD
;save, file='/Volumes/Seagate/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/CFADS.sav/'+sample_name+'withoverlaps.CFAD.sav', $
;  TOTALCFAD, OCFAD, z_cfad, dbz_cfad, overlap_fraction, total_cloud_fraction, normOCFAD, normTOTALCFAD, bot_vs_top, overlap_cloud_fraction,$
;  cloud_fraction ;, low_pop_underlap_fraction ;up_pop_overlap_fraction
;save, file='/Volumes/Seagate/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_code/global_loops/histogram_profile_top_base_thk/'+sample_name+'profile_hist.sav', $
;  base_array, top_array, thick_array

;/Volumes/Seagate/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/CFADS.sav/ 

psout
;stop 
end 

;;;;Find how many layers per profile
;        layers = intarr(syze[1])
;        for j=0L, n_elements(h[*,0])-1 do begin
;            h = histogram(hcum_base[j,*])
;            w = where(h gt 1, count)
;            last_index = n_elements(h)-1

;            if count eq 0 then layers[j] = 1 ;there is only one layer if none of the numbers in hcum_base repeate

;            if count gt 0 then begin
;                if h[last_index] gt 1 then begin
;                    layers[j] = n_elements(w) - 1
;                endif else begin
;                    layers[j] = n_elements(w)
;                endelse 
;            endif 
            
;            if layers[j] gt 1 then amount = 1 else amount = 0
;            have_layers = amount + have_layers ;keep track of how many profiles contain multiple layers

;       endfor 

;       total_layers = have_layers + total_layers

;        saveplot_stampswithoverlap_and_histograms_trops.pro, file='/Volumes/silverbullet/global_loops/profile_top_base_thk/'+filenames[i]+'.sav', $
;          base_z, top_z, thick, avg_thick
;        stop
