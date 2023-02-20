; This routine reads a FLXHR file specified by infile name plus
; the next one which is spliced at the end to avoid equatorial edge
; effects. It restores a masterlist with minx, maxx bounds and
; filenames for the set of EOs. That masterlist also has a set of new
; attributes defined here: heating rates, CREs at TOA and BOA, OLR,
; OSR, INSOLATION -- several. 

;; BEM made this from ER's process_ECMWF_orbit_pair.pro 4/17/09

pro process_FLXHR_orbit_pair, indir, infile, infile2

maxcloudwidth = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2

;;;;;;;;; Create directory for EO profiles
shortname = strmid(infile,0,19)
print, infile, ' shortname ', shortname
spawn, 'mkdir FLXHR_PROFILES_2/'+shortname

;;;;----------------------------------------------- Read data
productname = '2B-FLXHR'

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile, /READ)
print,'file ',fid
swathid = EOS_SW_ATTACH(fid, productname)
print,'swath ',swathid

;;;; Read the data fields we want and name them sensibly

err = EOS_SW_READFIELD(swathid, 'Profile_time', time)
if( err lt 0) then print, 'Read Error'
if( err lt 0) then stop

err = EOS_SW_READFIELD(swathid, 'Latitude', lat)
err = EOS_SW_READFIELD(swathid, 'Longitude', lon)
err = EOS_SW_READFIELD(swathid, 'Height', z)
err = EOS_SW_READFIELD(swathid, 'DEM_elevation', zsurf)

NX = n_elements(lat) ;;; Array size in horizontal
x = lindgen(NX)
x2d = x#( 1+fltarr(125) ) ;;; 2D array of x cordinate

;;;; Mean height profile
z = rotate(z,3) ;;;; CAREFUL: Z is a 2D array not a single value
meanz = total(z,1)/1000. /NX ;; km
zflux = [meanz[0],meanz+0.120] ;; 126 element array, offset by 1/2 bin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Now the data - fluxes

err = EOS_SW_READFIELD(swathid, 'FD', FD)
FD = transpose(FD,[1,0,2])
FD = reverse(FD,2)
err = EOS_SW_READFIELD(swathid, 'FDclr', FDclr)
FDclr = transpose(FDclr,[1,0,2])
FDclr = reverse(FDclr,2)
err = EOS_SW_READFIELD(swathid, 'FU', FU)
FU = transpose(FU,[1,0,2])
FU = reverse(FU,2)
err = EOS_SW_READFIELD(swathid, 'FUclr', FUclr)
FUclr = transpose(FUclr,[1,0,2])
FUclr = reverse(FUclr,2)
err = EOS_SW_READFIELD(swathid, 'QR', QR)
QR = transpose(QR,[1,0,2])
QR = reverse(QR,2)
QR = QR/100.
err = EOS_SW_READFIELD(swathid, 'TOACRE', TOACRE)
err = EOS_SW_READFIELD(swathid, 'BOACRE', BOACRE)
err = EOS_SW_READFIELD(swathid, 'RH', RH)
err = EOS_SW_READFIELD(swathid, 'Status', status) ;;; status le 8 should be good data

;;; Close file
err = EOS_SW_DETACH(swathid)
err = EOS_SW_CLOSE(fid)
print, 'done reading in 1st file'


;;;; Rename data 1 for appending
time1 = time
zsurf1 = zsurf
FD1 = FD
FDclr1 = FDclr
FU1 = FU
FUclr1 = FUclr
QR1 = QR
RH1 = RH
TOACRE1 = TOACRE
BOACRE1 = BOACRE
status1 = status

;;;;----------------------------------------------- Read data 2
productname = '2B-FLXHR'

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile2, /READ)
print,'file ',fid
swathid = EOS_SW_ATTACH(fid, productname)
print,'swath ',swathid

;;;; Read the data fields we want and name them sensibly

err = EOS_SW_READFIELD(swathid, 'Profile_time', time)
if( err lt 0) then print, 'Read Error'
if( err lt 0) then stop

err = EOS_SW_READFIELD(swathid, 'DEM_elevation', zsurf)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Now the data - fluxes

err = EOS_SW_READFIELD(swathid, 'FD', FD)
FD = transpose(FD,[1,0,2])
FD = reverse(FD,2)
err = EOS_SW_READFIELD(swathid, 'FDclr', FDclr)
FDclr = transpose(FDclr,[1,0,2])
FDclr = reverse(FDclr,2)
err = EOS_SW_READFIELD(swathid, 'FU', FU)
FU = transpose(FU,[1,0,2])
FU = reverse(FU,2)
err = EOS_SW_READFIELD(swathid, 'FUclr', FUclr)
FUclr = transpose(FUclr,[1,0,2])
FUclr = reverse(FUclr,2)
err = EOS_SW_READFIELD(swathid, 'QR', QR)
QR = transpose(QR,[1,0,2])
QR = reverse(QR,2)
QR = QR/100.
err = EOS_SW_READFIELD(swathid, 'TOACRE', TOACRE)
err = EOS_SW_READFIELD(swathid, 'BOACRE', BOACRE)
err = EOS_SW_READFIELD(swathid, 'RH', RH)
err = EOS_SW_READFIELD(swathid, 'Status', status) ;;; status le 8 should be good data

;;; Close file
err = EOS_SW_DETACH(swathid)
err = EOS_SW_CLOSE(fid)
print, 'done reading in 2nd file'

;---------------------------------Append Files
;;;2D arrays
;p = [p, p2[0:maxcloudwidth-1,*]]

;;; 1d files (x only)
time = [time1, time[0:maxcloudwidth-1]]
zsurf = [zsurf1, zsurf[0:maxcloudwidth-1]]

;;; 3d files (x, z, band) SW is band 0, LW band 1
bandFD = [FD1, FD[0:maxcloudwidth-1,*,*]]
FU = [FU1, FU[0:maxcloudwidth-1,*,*]]
FUclr = [FUclr1, FUclr[0:maxcloudwidth-1,*,*]]
FD = [FD1, FD[0:maxcloudwidth-1,*,*]]
FDclr = [FDclr1, FDclr[0:maxcloudwidth-1,*,*]]
QR = [QR1, QR[0:maxcloudwidth-1,*,*]]

;;; 2D files (x, band)
RH = [RH1, RH[0:maxcloudwidth-1,*]]
TOACRE = [TOACRE1, TOACRE[0:maxcloudwidth-1,*]]
BOACRE = [BOACRE1, BOACRE[0:maxcloudwidth-1,*]]
status = [status1, status[0:maxcloudwidth-1,*]]


;;;;;;;;;;;;; Compute CURD, CDRD, albedo_clr, albedo

CUR = FU - FUclr ;;; INTEGER
CURD = CUR*1.0 ;;; floating point
for iband = 0,1 do $
   for ix=0L, NX+maxcloudwidth-1 do $
      CURD[ix,*,iband] = (status[ix] le 8)* deriv(CURD[ix,*,iband]) /240. ; Wm-3 units

CDR = FD - FDclr ;;; INTEGER
CDRD = CDR*1.0 ;;; floating point
for iband = 0,1 do $
   for ix=0L, NX+maxcloudwidth-1 do $
      CDRD[ix,*,iband] = (status[ix] le 8)* deriv(CDRD[ix,*,iband]) /240. ; Wm-3 units

;;;; Albedo assessed at 18km altitude
alb     = 1.0* (FU[*,96,0]>0)    / (FD[*,96,0] >1) ;;; avoid 0/0 troubles at night
alb_clr = 1.0* (FUclr[*,96,0]>0) / (FDclr[*,96,0] >1) ;;; avoid 0/0 troubles at night

print, '**done reading and concatinating orbit files***'

;---------------------------------Find clouds, make sounding
;;;;Restore MASTERLIST subset to get maxxs & minxxs -- prepared earlier

;restore, 'Masterlist_Dec08_nonrepeated_noxoutliers.sav' ;;; too huge
;w = where (strmid(filenames,0,4) eq '2007')
;filenames = filenames[w]
;minxs = minxs[w]
;maxxs = maxxs[w]
;save, file='Masterlist_2007_CRFstuff.sav', filenames, minxs, maxxs ;;; done once

print, 'restoring EOs'
Restore, '~/CLOUDSAT/cloud_lists/Masterlist_Dec2010_filenames_minmaxxs.sav'
;restore, 'Masterlist_2007_CRFstuff.sav' ;;; manageable: minx, maxx, filenames, and whatever we create here
print, 'done restoring EOs'

;;;;;;;;;;;;;;;ONCE ONLY: DEFINE NEW ATTRIBUTES FOR THE EOs (-9999.9
;;;;;;;;;;;;;;;initially

if( n_elements(meanOLRs) lt 1 ) then meanOLRs = maxxs*0.0-9999
if( n_elements(meanOSRs) lt 1 ) then meanOSRs = maxxs*0.0-9999
if( n_elements(meanSWheatings) lt 1 ) then meanSWheatings = maxxs*0.0-9999
if( n_elements(meanLWheatings) lt 1 ) then meanLWheatings = maxxs*0.0-9999
if( n_elements(meanCRE_SW_TOAs) lt 1 ) then meanCRE_SW_TOAs = maxxs*0.0-9999
if( n_elements(meanCRE_LW_TOAs) lt 1 ) then meanCRE_LW_TOAs = maxxs*0.0-9999
if( n_elements(meanCRE_SW_BOAs) lt 1 ) then meanCRE_SW_BOAs = maxxs*0.0-9999
if( n_elements(meanCRE_LW_BOAs) lt 1 ) then meanCRE_LW_BOAs = maxxs*0.0-9999
if( n_elements(albedo_clrs ) lt 1 ) then albedo_clrs  = maxxs*0.0-9999
if( n_elements(albedos ) lt 1 ) then albedos  = maxxs*0.0-9999
if( n_elements(status_le8isgoods ) lt 1 ) then status_le8isgoods = maxxs*0.0-9999
;;;;;;;;;;;;;;;ONCE ONLY: DEFINE NEW ATTRIBUTES FOR THE EOs 



;;;;; Find the EOs who are in this FLXHR file
files = strmid(filenames, 0,19)
wfiles = where(files eq shortname)

;;; Subset to just those for looping
minx = minxs[wfiles]
maxx = maxxs[wfiles]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LOOP OVER EOs in this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; orbit file pair
for i=0L, n_elements(wfiles)-1 do begin

;;;;;;;;;;;;;;;;;;;; FOR EACH EO, make its *** RAD. ATTRIBUTES ***
;;;;;;;;;;;;;;;;;;;; (level 96 = TOA, really it is 18km)

   meanOSR = total( FU[minx[i]:maxx[i],96,0] ,1)/(maxx[i] - minx[i] + 1)
   meanOLR = total( FU[minx[i]:maxx[i],96,1] ,1)/(maxx[i] - minx[i] + 1)

   meanSWheating = total( RH[minx[i]:maxx[i], 0] ,1)/(maxx[i] - minx[i] + 1)
   meanLWheating = total( RH[minx[i]:maxx[i], 1] ,1)/(maxx[i] - minx[i] + 1)

   meanCRE_SW_TOA = total( TOACRE[minx[i]:maxx[i], 0] ,1)/(maxx[i] - minx[i] + 1)
   meanCRE_LW_TOA = total( TOACRE[minx[i]:maxx[i], 1] ,1)/(maxx[i] - minx[i] + 1)

   meanCRE_SW_BOA = total( BOACRE[minx[i]:maxx[i], 0] ,1)/(maxx[i] - minx[i] + 1)
   meanCRE_LW_BOA = total( BOACRE[minx[i]:maxx[i], 1] ,1)/(maxx[i] - minx[i] + 1)

   albedo_clr = total( alb_clr [minx[i]:maxx[i],0] ,1)/(maxx[i] - minx[i] + 1)
   albedo = total( alb [minx[i]:maxx[i],0] ,1)/(maxx[i] - minx[i] + 1)

   status_le8isgood = max( status[minx[i]:maxx[i]] )

;;; capture them
   meanOSRs[ wfiles[i] ] = meanOSR
   meanOLRs[ wfiles[i] ] = meanOLR
   meanSWheatings[ wfiles[i] ] = meanSWheating
   meanLWheatings[ wfiles[i] ] = meanLWheating
   meanCRE_SW_TOAs[ wfiles[i] ] = meanCRE_SW_TOA
   meanCRE_LW_TOAs[ wfiles[i] ] = meanCRE_LW_TOA
   meanCRE_SW_BOAs[ wfiles[i] ] = meanCRE_SW_BOA
   meanCRE_LW_BOAs[ wfiles[i] ] = meanCRE_SW_BOA
   albedo_clrs [ wfiles[i] ] = albedo_clr
   albedos [ wfiles[i] ] = albedo
   status_le8isgoods[ wfiles[i] ] = status_le8isgood

;;;;;;;;;;;;;;;;;;;; FOR EACH EO, make its *** PROFILES ***

   QR_SW = total( QR[minx[i]:maxx[i],*,0] ,1)/(maxx[i] - minx[i] + 1)
   QR_LW = total( QR[minx[i]:maxx[i],*,1] ,1)/(maxx[i] - minx[i] + 1)

   CURD_SW = total( CURD[minx[i]:maxx[i],*,0] ,1)/(maxx[i] - minx[i] + 1)
   CURD_LW = total( CURD[minx[i]:maxx[i],*,1] ,1)/(maxx[i] - minx[i] + 1)

   CDRD_SW = total( CDRD[minx[i]:maxx[i],*,0] ,1)/(maxx[i] - minx[i] + 1)
   CDRD_LW = total( CDRD[minx[i]:maxx[i],*,1] ,1)/(maxx[i] - minx[i] + 1)

   TOACRE_SW = TOACRE[minx[i]:maxx[i],0]
   BOACRE_SW = BOACRE[minx[i]:maxx[i],0]
   TOACRE_LW = TOACRE[minx[i]:maxx[i],1]
   BOACRE_LW = BOACRE[minx[i]:maxx[i],1]

   DEMZ = zsurf[minx[i]:maxx[i]]
   status_segment_le8isgood = status[minx[i]:maxx[i]]

;hlp,   QR_SW, QR_LW, CURD_SW, CURD_LW, CDRD_SW, CDRD_LW, TOACRE_SW, TOACRE_LW
;hlp,         BOACRE_SW, BOACRE_LW, DEMZ, meanOLR, meanOSR, meanSWheating, meanLWheating
;hlp,         meanCRE_SW_TOA, meanCRE_LW_TOA, meanCRE_SW_BOA, meanCRE_LW_BOA, albedo_clr, albedo
;hlp,         status_segment_le8isgood

   save, file='FLXHR_PROFILES_2/'+shortname+'/'+filenames[wfiles[i]]+'.sav', $
         QR_SW, QR_LW, CURD_SW, CURD_LW, CDRD_SW, CDRD_LW, TOACRE_SW, TOACRE_LW, $
         BOACRE_SW, BOACRE_LW, DEMZ, meanOLR, meanOSR, meanSWheating, meanLWheating, $
         meanCRE_SW_TOA, meanCRE_LW_TOA, meanCRE_SW_BOA, meanCRE_LW_BOA, albedo_clr, albedo, $
         status_segment_le8isgood, meanz

endfor   ;; end i loop over EOs

stop
;;; Re-save EO attribute arrays (with the numbers we added for all the
;;; EOs in this orbit)

;print, 'saving EO list'
save, file='Masterlist_Dec2007_CRFstuff.sav', minxs, maxxs, filenames, meanOLRs, meanOSRs, $      
      meanSWheatings, meanLWheatings, meanCRE_SW_TOAs, meanCRE_LW_TOAs, meanCRE_SW_BOAs, $
      meanCRE_LW_BOAs, albedo_clrs, albedos, status_le8isgoods

;wok = where(meanOLRs gt 0)
;hlp, meanOLRs(wok), meanOSRs(wok)
;hlp,  meanSWheatings(wok), meanLWheatings(wok), meanCRE_SW_TOAs(wok), meanCRE_LW_TOAs(wok), meanCRE_SW_BOAs(wok)
;hlp,  meanCRE_LW_BOAs(wok), albedo_clrs(wok), albedos(wok), status_le8isgoods(wok)

$date
;print, 'done saving EO list'
end

