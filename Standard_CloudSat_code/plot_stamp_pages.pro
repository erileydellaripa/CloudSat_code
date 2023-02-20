;;;ER - 7/16/2012
;;;
;;;Original code from
;;;CLOUDSAT/new_MJO/plot_stamp_pages_for_publication.pro, which was
;;;used for Fig. 2 of Riley et al. (2011, JAS)
;;;
;;;USAGE: To plot ALL EOs for a given subset of EOs. 
;;;
;;;NOTES: The default is to sort the EOs by filename. As of now, if you want to sort
;;;by another criteria, you'd need to do that before calling
;;;the code, so sort the filenames how you want them first
;;;
;;;Set DO_ELEVATION to either 'ture' or 'false' True will plot the
;;;ground elevation underneath each EO's vertical profiles
;;;
;;;Default is for vertical and horizontal lines separating each EO
;;;black and the elevation underneath black. There is a note below
;;;about how I made vertical and horizontal lines in Fig 2 of
;;;Riley et al. (2001, JAS) colors is below.
;;;;
;;;;

pro plot_stamp_pages, FILENAMES = filenames, SAMPLE_NAME = sample_name, DO_ELEVATION = do_elevation

PATH = '/Volumes/silverbullet/cloud_pixels_Feb10/'

;land
tall
IF do_elevation eq 'true' THEN file = 'plot_stamp_pages_' + sample_name + '_welevation.ps' ELSE $
   file = 'plot_stamp_pages_' + sample_name + '.ps'
device, file = file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Postage stamp plots for each cloud
;;; Filled circle plots - 250m in z, 1km (?) in x

PLOTXSIZE = 400 ;800 ;;; km 4/13/2017 changed orginal value from 800 to 400 to match plot_1MJOstamp_drafts_marked.pro
PLOTZSIZE = 400 ;800 ;;; km - 20km tropospheres stacked
       DZ = 20  ;;; km between rows of clouds
       DX = 10   ;;; pixels between clouds

       llx = 0 ;;;; lower left corner's x value - start at LL of whole plot 
       llz = 0 ;;; lower left corner's z value - update as each cloud is added 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  MASTER PLOT: AXES ONL
       
!p.multi=0
plot, [0],[0], xra=[0,PLOTXSIZE], yra=[0,PLOTZSIZE], /nodata, $
      ystyle=4, xstyle=8, xtitle='x in pixels (~km)', $
      tit=str(n_elements(filenames))+' clouds', xticklen = 0.008

;;;; Use circular (or oval) pixel shapes
;A = FINDGEN(9) * (!PI*2/8.)  
;for USERSYM, 4*COS(A), SIN(A), /FILL
;Use square pixels
A = [1, -1, -1, 1, 1]*.5
B = [1, 1, -1, -1, 1]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop over clouds
for i = 0L, n_elements(filenames)-1 do begin
   if (i mod 10) eq 0 then print, 'cloud number ', i, '/', n_elements(filenames) 
   
   pixelfile = PATH + strmid(filenames[i], 0, 19) + $
               '/'+filenames[i] + '.sav'
   restore, pixelfile         ;;; xcloud, zcloud, dbzcloud, xoverlapped, zoverlapped, dbzoverlapped
   zcloud = zcloud/1000.      ;;; km
   
   total_dbz = [dbzcloud]
   total_z   = [zcloud]
   total_x   = [xcloud]
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Ready for postage stamp cloud plot
;; plot lowest dbz pixels on bottom, then higher values on top
   order = sort(total_dbz) 
   total_dbz = total_dbz(order)
   total_z = total_z(order)
   total_x = total_x(order)
   
;;; relative position in x
   total_x = total_x - min(total_x)
   
;;;;;; start at left edge of the row if it is full
   if (llx + max(total_x) gt PLOTXSIZE) then begin
      llx = 0 
      llz = llz + DZ
   endif
   
;;; loop over pixels and plot em        
   for ii = 0L, n_elements(total_x)-1 do begin

;;; little oval pixel blobs: you just have to calibrate the size by
;;; eye "1.0 is about the size of a character"
      
      USERSYM, $
         A, B, /FILL, color = (total_dbz(ii)+50)*3.5 >0 <254

      oPLOT, [llx + total_x(ii)], [llz + total_z(ii)], PSYM = 8, symsize = 0.08
   endfor ;; ii pixel

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
      minz_at_xprofile = min(zcloud[find_xprofile])
      
      IF zground[iprofile] gt 0 THEN BEGIN ;;check if cloud over land
         cgcolorfill, [llx + uniq_x[iprofile]- .5, llx + uniq_x[iprofile]+.5, llx + uniq_x[iprofile]+.5, llx + uniq_x[iprofile]-.5, llx + uniq_x[iprofile]-.5], $
                      [llz + 0, llz + 0, llz + zground[iprofile], llz + zground[iprofile], llz + 0], color = 0
      ENDIF ;;;over land
   ENDFOR ;;;xprofiles
ENDIF ;;;elevation true or false


;;; Draw a line and move on to next cloud position
   llx = llx + max(total_x) +DX ;;; space of DX until next cloud
   oplot, [llx-DX/2, llx-DX/2], [llz, llz+DZ], thick=0.25
   oplot, [0,llx-DX], [llz,llz], thick=0.25

;********************************************************************
;;;To make vertical and horizontal lines colors match the EO
;;;type. Would have to FIRST SORT Filenames BY TYPE and then adjust
;;;the i amounts to correspond to each EO type
;;;FOR EXAMPE: Fig 2 Riley et al. (2011, JAS) had 149 cu; 75 sc; 40
;;;ac; 30 cg; 20 ci; 15 an; and 10 cb
;********************************************************************
;colors = intarr(8)
;for icolor = 0, 7 do colors[icolor]= icolor*(250/7)
;colors[5] = 190
;
;   if i le 149 then begin
;      oplot, [llx, llx+max(total_x) + DX], [llz, llz], thick = 2
;   endif 
;
;   if i gt 149 and i le 149+75 then begin
;      oplot, [llx, llx+max(total_x)+ DX], [llz,llz], thick=3, color = colors[1]
;   endif
;
;   if i gt 149+75 and i le 149+75+40 then begin
;      oplot, [llx, llx+max(total_x) + DX], [llz,llz], thick=3, color = colors[2]
;   endif
;
;   if i gt 149+75+40 and i le 149+75+40+30 then begin
;      oplot, [llx, llx+max(total_x) + DX], [llz,llz], thick=3, color = colors[3]
;   endif
;
;   if i gt 149+75+40+30 and i le 149+75+40+30+20 then begin
;      oplot, [llx, llx+max(total_x) + DX], [llz,llz], thick=3, color = colors[4]
;   endif
;
;   if i gt 149+75+40+30+20 and i le 149+75+40+30+20+15 then begin
;      oplot, [llx, llx+max(total_x) + DX], [llz,llz], thick=3, color = colors[5]
;   endif
;
;   if i gt 149+75+40+30+20+15 and i le 149+75+40+30+20+15+10 then begin
;      oplot, [llx, llx+max(total_x) + DX], [llz,llz], thick=3, color = colors[6]
;   endif
;
;   if i gt 149+75+40+30+20+15+10 then begin
;      oplot, [llx, llx+max(total_x) + DX], [llz,llz], thick=3, color = colors[7]
;   endif
;
;llx = llx + max(total_x) + DX

;;; Quit plotting if off page
   if (llz gt PLOTZSIZE) then begin
;      print, timestamp(), 'page full at cloud '+str(i)+' file '+filenames[i], charsize=0.5
      plot, [0],[0], xra=[0,PLOTXSIZE], yra=[0,PLOTZSIZE], /nodata, $
            ystyle=4, xstyle=8, xtitle='x in pixels (~km)', $
            tit=str(n_elements(filenames))+' clouds past '+str(i)
      
      llz = 0
;            i = n_elements(filenames)-1 ;;; quit
   endif
   
endfor                          ; i cloud

psout
;stop 
end 

