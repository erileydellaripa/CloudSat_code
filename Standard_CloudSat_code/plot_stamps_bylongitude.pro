pro plot_stamps_bylongitude, FILENAMES = filenames, meanlons = meanlons, nlons = nlons, $
                             R = r, G = g, B = b, NAME = name, startlon = startlon, $
                             DO_ELEVATION = do_elevation, DO_DBZCOLOR = do_dbzcolor, tods = tods

IF do_dbzcolor EQ 'true' THEN loadct, 39

IF do_dbzcolor EQ 'false' THEN BEGIN
   loadct, 0, ncolors=150
   tvlct, r, g, b, 150
ENDIF 

;PATH = '/Volumes/silverbullet/new_cloud_pixels/'
;PATH = '/Volumes/green/new_cloud_pixels/'
PATH = '/Volumes/silverbullet/cloud_pixels_Feb10/'

;smush_factor = (360*40)/nlons ;;nlons - how many degrees of longitude the area interest is so 50° - 90° = nlons = 40
;meanlons = meanlons*smush_factor
meanlons = (meanlons * 111.) - (startlon*111.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Postage stamp plots for each cloud
;;; Filled circle plots - 250m in z, 1km (?) in x

;PLOTXSIZE = nlons*smush_factor ;;; km
PLOTXSIZE = nlons * 111.
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

;;;relative position in x
   centerpt = (max(xcloud) - min(xcloud) + 1)/2.
   total_x = (total_x - centerpt) + meanlons[i]

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
      
      oPLOT, [total_x(ii)], [total_z(ii)], PSYM = 8, symsize = 0.1
   endfor  ;; ii pixel
endfor ;i filenames
;psout
end 

