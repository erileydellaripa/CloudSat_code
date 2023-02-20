pro plot_stamps_byTRUE_latitude, FILENAMES = filenames, meanlats = meanlats, minlats = minlats, maxlats = maxlats, nlats = nlats, $
                                 bbwidths = bbwidths, R = r, G = g, B = b, NAME = name, startlat = startlat, tods = tods, $
                                 DO_ELEVATION = do_elevation, DO_DBZCOLOR = do_dbzcolor

IF do_dbzcolor EQ 'true' THEN loadct, 39

IF do_dbzcolor EQ 'false' THEN BEGIN
   loadct, 0, ncolors=150
   tvlct, r, g, b, 150
ENDIF 
;steps = 106
;scalefactor = findgen(steps)/(steps - 1)
;;;make color table from red -> white
;r = replicate(255, steps)
;g = 0 + (0+255)*scalefactor ;;obviously dont need the 0s, but 0 would be another # if didn't want end to be white
;b = 0 + (0+255)*scalefactor
;;;Want it to go from white -> red, so reverse g & b
;g = reverse(g)
;b = reverse(b)


;PATH = '/Volumes/silverbullet/new_cloud_pixels/'
;PATH = '/Volumes/green/new_cloud_pixels/'
PATH = '/Volumes/silverbullet/cloud_pixels_Feb10/'
;PATH = '/Volumes/silverbullet/'

;meanlats = (meanlats * 111.) - (startlat*111.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Postage stamp plots for each cloud
;;; Filled circle plots - 250m in z, 1km (?) in x

;PLOTXSIZE = nlats*smush_factor ;;; km
PLOTXSIZE = nlats
PLOTZSIZE = 20 ;;; km - 20km tropospheres stacked

A = [1, -1, -1, 1, 1]
B = [1, 1, -1, -1, 1]*2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0L, n_elements(filenames)-1 do begin
   pixelfile = PATH + strmid(filenames[i], 0, 19) + $
               '/'+filenames[i] + '.sav'
   restore, pixelfile        ;;; xcloud, zcloud, dbzcloud, xoverlapped, zoverlapped, dbzoverlapped
   zcloud = zcloud/1000.     ;;; km
   
   total_dbz = [dbzcloud]
   total_z   = [zcloud]
   total_x   = [xcloud]
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Ready for postage stamp cloud plot
;; plot lowest dbz pixels on bottom, then higher values on top
   order = sort(total_dbz) 
   total_dbz = total_dbz(order)
   total_z = total_z(order)
   total_x = total_x(order)
;   total_lat = latcloud(order)

;;;relative position in x
   centerpt = (max(xcloud) + min(xcloud) + 1)/2.
;   total_x = (total_x - centerpt) + meanlats[i]
;   total_x = total_x - min(total_x) + 1;relative position in x
;   total_x = total_x + (minlats - startlat) *111.
;stop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;2) Find mean lat lon of each draft, first find lat, lon of each EO profile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   sorted_xcloud = xcloud[sort(xcloud)] ;xcloud is now in order from smallest x -> largest x
   uniq_xcloud   = unique(sorted_xcloud)
   
   width = bbwidths[i]
   
   temp_column_lats = minlats[i] + findgen(width)/(width-1) * (maxlats[i] - minlats[i])
   IF tods[i] EQ 0 THEN temp_column_lats = reverse(temp_column_lats)
   ;temp_column_lons = minlons[i] + findgen(width)/(width-1) * (maxlons[i] - minlons[i])

;;;make xlat array, needs to be same dimensions as xcloud
xlat = fltarr(n_elements(xcloud))
FOR ix = 0L, width - 1 DO BEGIN
   wtemp =  where(total_x eq uniq_xcloud[ix])
   xlat[wtemp] = temp_column_lats[ix]
ENDFOR 
;stop
;;; loop over pixels and plot em  
   for ii = 0L, n_elements(total_x)-1 do begin
      
;;; little oval pixel blobs: you just have to calibrate the size by
;;; eye "1.0 is about the size of a character"
      USERSYM, $
         A, B, $
         /FILL, color = (total_dbz(ii)+50)*3.5 >0 <254 
                                ;0.0dBZ is color 175, a dash above
                                ;pure white which 150 by definition
                                ;above--good enough to distinguish low
                                ;and high (dbz > 0) dBZ
      
      oPLOT, [xlat(ii)], [total_z(ii)], PSYM = 8, symsize = 0.1
   endfor  ;; ii pixel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Plot elevation undercloud;;;;;;;;;;;
;;;Find unique x's
   IF do_elevation eq 'true' THEN BEGIN
      relativex = xcloud - min(xcloud)
      uniq_x = unique(xcloud, /sort) - min(unique(xcloud, /sort))
;uniq_xindex = uniq(xcloud, sort(xcloud))
      zground = zground/1000.
      
      FOR iprofile = 0, n_elements(uniq_x)-1 DO BEGIN ;;;number of unique profiles in EO
         find_xprofile = where(relativex eq uniq_x[iprofile])
         
         IF zground[iprofile] gt 0 THEN BEGIN ;;check if cloud over land
            cgcolorfill, [min(total_x) + uniq_x[iprofile]- .5, min(total_x) + uniq_x[iprofile]+.5, min(total_x) + uniq_x[iprofile]+.5, $
                          min(total_x) + uniq_x[iprofile]-.5, min(total_x) + uniq_x[iprofile]-.5], $
                         [0, 0, zground[iprofile], zground[iprofile], 0], color = 0
         ENDIF ;;;over land
      ENDFOR   ;;;xprofiles
   ENDIF       ;;;elevation true or false
   
endfor                          ;i filenames
;psout
end 

