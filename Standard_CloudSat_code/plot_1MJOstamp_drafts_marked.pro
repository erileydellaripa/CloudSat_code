pro plot_1MJOstamp_drafts_marked, FILENAMES = filenames, XCLOUD_VALUE_ARRAY = xcloud_value_array

;loadct, 0, ncolors=150
;steps = 106
;scalefactor = findgen(steps)/(steps - 1)
;;;make color table from red -> white
;r = replicate(255, steps)
;g = 0 + (0+255)*scalefactor ;;obviously dont need the 0s, but 0 would be another # if didn't want end to be white
;b = 0 + (0+255)*scalefactor
;;;Want it to go from white -> red, so reverse g & b
;g = reverse(g)
;b = reverse(b)
;tvlct, r, g, b, 150

;PATH = '/Volumes/silverbullet/new_cloud_pixels/'
;PATH = '/Volumes/green/new_cloud_pixels/'
PATH = '/Volumes/silverbullet/cloud_pixels_Feb10/'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Postage stamp plots for each cloud
;;; Filled circle plots - 250m in z, 1km (?) in x

PLOTXSIZE = 1000     ;;; km
PLOTZSIZE = 1000     ;;; km - 20km tropospheres stacked
DZ = 20              ;;; km between rows of clouds
DX = 5               ;;; pixels between clouds

llx = 0     ;;;; lower left corner's x value - start at LL of whole plot 
llz = 0     ;;; lower left corner's z value - update as each cloud is added 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  MASTER PLOT: AXES ONL

!p.multi=0
plot, [0],[0], xra=[0,PLOTXSIZE], yra=[0,PLOTZSIZE], /nodata, $
      ystyle=4, xstyle=8, xtitle='x in pixels (~km)', $
      tit=str(n_elements(filenames))+' clouds'

;;;; Use circular (or oval) pixel shapes
A = FINDGEN(16) * (!PI*2/15.)  

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
   new_x   = total_x(order)
;;;relative position in 
   new_draft_values = xcloud_value_array - min(total_x)
   total_x = total_x - min(total_x)

;;;;;; start at left edge of the row if it is full
        if (llx + max(total_x) gt PLOTXSIZE) then begin
            llx = 0 
            llz = llz + DZ
         endif
;stop
;;; loop over pixels and plot em  
   for ii = 0L, n_elements(total_x)-1 do begin
;      wii = where(xcloud_value_array eq new_x(ii)) ;if true then this xcloud position is a draft column
;      wii = where(new_x(ii) eq 36826)                             ;if true then this xcloud position is a draft column
;      if new_x(ii) eq  36826 then color = 0 else color = (total_dbz(ii)+50)*3.5 >0 <254 ;plot draft columns black

;;; little oval pixel blobs: you just have to calibrate the size by
;;; eye "1.0 is about the size of a character"
      USERSYM, $
         3*4*COS(A), $
         3*  SIN(A), $
         /FILL, color = (total_dbz(ii)+50)*3.5 >0 <254 
                                ;0.0dBZ is color 175, a dash above
                                ;pure white which 150 by definition
                                ;above--good enough to distinguish low
                                ;and high (dbz > 0) dBZ
      
      oPLOT, [total_x(ii)], [total_z(ii)], PSYM = 8, symsize = 0.005
;        plots,  [total_x(ii)], [j], [total_z(ii)], PSYM = 8, symsize = 0.3, /T3D
   endfor  ;; ii pixel
   if ((max(xcloud)-min(xcloud)) gt 50) then xyouts, llx, llz+17, filenames[i], charsize=0.1
   
   for idraft = 0, n_elements(xcloud_value_array) - 1 do begin
      USERSYM, $
         3*4*COS(A), $
         3*  SIN(A), $
         /FILL, color = 0 ;;;mark drafts black
      oplot, [total_x[where(total_x eq new_draft_values[idraft])]], [total_z[where(total_x eq new_draft_values[idraft])]], $
             psym=8, symsize = 0.005
   endfor 
   
;;; Draw a line and move on to next cloud position
   llx = llx + max(total_x) +DX ;;; space of DX until next cloud
   oplot, [llx-DX/2, llx-DX/2], [llz, llz+DZ], thick=0.25
   oplot, [0,llx-DX], [llz,llz], thick=0.25
   
  ;;; Quit plotting if off page
   if (llz gt PLOTZSIZE) then begin
      timestamp, 'page full at cloud '+str(i)+' file '+filenames[i], charsize=0.5
      plot, [0],[0], xra=[0,PLOTXSIZE], yra=[0,PLOTZSIZE], /nodata, $
            ystyle=4, xstyle=8, xtitle='x in pixels (~km)', $
            tit=str(n_elements(filenames))+' clouds past '+str(i)
      
      llz = 0
      ;i = n_elements(filenames)-1 ;;; quit
   endif
   
endfor                          ;i filenames
;psout
end 

