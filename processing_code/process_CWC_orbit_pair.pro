; This routine reads a 2B-CWC-RVOD file specified by infile name plus
; the next one which is spliced at the end to avoid equatorial edge
; effects. 
;;;Created 07/12/2010 by ER following process_two_orbits.pro
;;;
;;;Realized on 5/14/2018 that this code was written
;;;incorrectly. Luckilyy I dont' think I ever used these
;;;variable for anything.
;;;Issue - Used [minx:maxx, *] to define IWC & LWC of each EO, but
;;;        that includes overlapping pixels. Need to only do IWC and
;;;        LWC indices that are IN each EO.

pro process_CWC_orbit_pair, indir, infile, infile2

maxcloudwidth = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2

shortname = strmid(infile,0,19)
swathname = '2B-CWC-RVOD'
print, infile, ' shortname ', shortname
;spawn, 'mkdir /Volumes/silverbullet/CWC/'+shortname
spawn, 'mkdir ~/CLOUDSAT/CWC/'+shortname
;----------------------------------------------- Read data

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile, /READ)
print,'file ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
print,'swath ',swathid

;;;; Read the data fields we want and name them sensibly
;;;; the  sounding data
status = EOS_SW_READFIELD(swathid, 'Latitude', lat)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Longitude', lon)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Height', z)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_liq_water_content', LWC)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_liq_water_content_uncertainty', LWC_uncertainty)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_ice_water_content', IWC)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_ice_water_content_uncertainty', IWC_uncertainty)
if( status lt 0) then print, 'Read Error'

print, 'done reading in 1st file'
stop
;;;;  rotate as necessary & put in correct unit
z = rotate(z,3) ;;;; CAREFUL: Z is a 2D array not a single value
LWC = rotate(LWC, 3) 
LWC_uncertainty = rotate(LWC_uncertainty, 3) 
IWC = rotate(IWC, 3)
IWC_uncertainty = rotate(IWC_uncertainty, 3)

;;;; OK, done getting what we neeed from file, close it
status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

;---------------Read data - 2 (to append)
;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile2, /READ)
print,'file2 ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
print,'swath2 ',swathid

;;;; Read the data fields we want and name them sensibly
;;;; the  sounding data

status = EOS_SW_READFIELD(swathid, 'Latitude', lat2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Longitude', lon2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Height', z2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_liq_water_content', LWC2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_liq_water_content_uncertainty', LWC_uncertainty2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_ice_water_content', IWC2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'RVOD_ice_water_content_uncertainty', IWC_uncertainty2)
if( status lt 0) then print, 'Read Error'
if fid lt 0 then stop

print, 'done reading in 2nd file'
stop

;;;;  rotate as necessary & put in correct units
z2 = rotate(z2, 3)
LWC2 = rotate(LWC2, 3) 
LWC_uncertainty2 = rotate(LWC_uncertainty2, 3) 
IWC2 = rotate(IWC2, 3)
IWC_uncertainty2 = rotate(IWC_uncertainty2, 3)

;;;; OK, done getting what we neeed from file, close it
status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

;---------------------------------Append Files
;;; 2D arrays
z = [z, z2[0:MAXCLOUDWIDTH-1,*] ]
LWC = [LWC, LWC2[0:MAXCLOUDWIDTH-1,*] ]
LWC_uncertainty = [LWC_uncertainty, LWC_uncertainty2[0:MAXCLOUDWIDTH-1,*] ]
IWC = [IWC, IWC2[0:MAXCLOUDWIDTH-1,*] ]
IWC_uncertainty = [IWC_uncertainty, IWC_uncertainty2[0:MAXCLOUDWIDTH-1,*] ]

;;; 1D arrays
lat = [lat, lat2[ 0:MAXCLOUDWIDTH-1] ]
lon = [lon, lon2[ 0:MAXCLOUDWIDTH-1] ]

;;;;; Define x dimension (along track) 
NX = n_elements(lat) ;;; Array size in horizontal
x = lindgen(NX)

;;;; 2D coordinate arrays, for convenience
lon2d = lon#( 1+fltarr(125) ) ;;; 2D array of longitudes, -180 to 180
lat2d = lat#( 1+fltarr(125) ) ;;; 2D array of latitudes
x2d = x#( 1+fltarr(125) ) ;;; 2D array of x cordinate

print, '**done concatinating  files***'
;---------------------------------Find clouds, 
;;;;Restore MASTERLIST_R04 to get maxxs & minxxs, no need to recreate
;;;;them. 
;restore, '/Volumes/silverbullet/Masterlist_2010.sav'
;restore, '/Volumes/Desktop\ Backup/Backups.backupdb/Emily\ Riley’s\ Power\ Mac\ G5/2010-06-04-174313/Macintosh\ HD/Users/mapesgroup/CLOUDSAT/cloud_lists/Masterlist_2010.sav'
restore, '/Users/emily/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/masterlist_2010_filenaems_minxs_maxxs.sav'


files = strmid(filenames, 0,19)
wfiles = where(files eq shortname)
minx = minxs[wfiles]
maxx = maxxs[wfiles]

print, '***done restoring list and finding files***'

stop
;;;Find where ECMWF data does not match GEOPROF data
;    syze = size(p)
;    syze_1st_element = syze[1]
;    w_bad = where(maxx gt syze_1st_element+1, count)
;;;loop over clouds and create a slab of data, then avg over the slab
for i=0L, n_elements(wfiles)-1 do begin
;    if maxx[i] gt syze_1st_element then begin


   LWC_slab = LWC[minx[i]:maxx[i], *]
   LWC_uncertainty_slab = LWC_uncertainty[minx[i]:maxx[i], *]
   IWC_slab = IWC[minx[i]:maxx[i], *]
   IWC_uncertainty_slab = IWC_uncertainty[minx[i]:maxx[i], *]
   zslab    = z[minx[i]:maxx[i], *]
   xslab    = x2d[minx[i]:maxx[i], *]
   lat2d_slab = lat2d[minx[i]:maxx[i], *]
   lon2d_slab = lon2d[minx[i]:maxx[i], *]
   
;;;Find where LWC values are zero even though GEOPROF values are
;;;not. CWC product uses cloud mask > 30, while we used cloud mask >
;;;20, so some EO bins will not exist in CWC data.
   LWC_good = where(LWC_slab gt 0)
   if LWC_good[0] ne 0-1 then begin
      LWC_slab = LWC_slab[LWC_good]
      LWC_xslab =xslab[LWC_good]
      LWC_zslab =zslab[LWC_good]
      LWC_lat_slab = lat2d_slab[LWC_good]
      LWC_lon_slab = lon2d_slab[LWC_good]
      LWC_uncertainty_slab = LWC_uncertainty_slab[LWC_good]

      save, file='/Volumes/silverbullet/LWC/'+shortname+'/'+filenames[wfiles[i]]+'.sav', $
            LWC_slab, LWC_lat_slab, LWC_lon_slab, LWC_xslab, LWC_zslab, LWC_uncertainty_slab
   endif 

   IWC_good = where(IWC_slab gt 0)
   if IWC_good[0] ne 0-1 then begin
      IWC_slab = IWC_slab[IWC_good]
      IWC_xslab =xslab[IWC_good]
      IWC_zslab =zslab[IWC_good]
      IWC_lat_slab = lat2d_slab[IWC_good]
      IWC_lon_slab = lon2d_slab[IWC_good]
      IWC_uncertainty_slab = IWC_uncertainty_slab[IWC_good]

      save, file='/Volumes/silverbullet/IWC/'+shortname+'/'+filenames[wfiles[i]]+'.sav', $
            IWC_slab, IWC_lat_slab, IWC_lon_slab, IWC_xslab, IWC_zslab, IWC_uncertainty_slab
   endif 

;stop
;window,0
;plot, reverse(p_avg), zplot, yran=[0,25], xtit='mb', ytit='km'
;window,1
;plot, reverse(T_avg), zplot, xran=[180,315],yran=[0,25], xtit='T(K)', ytit='km'
;window,2
;plot, reverse(q_avg), zplot, xran=[0,20],yran=[0,25], xtit='q(g/kg)', ytit='km'

;print, shortname 
;print, filenames[wfiles[i]]
;hlp, p_avg, T_avg, q_avg

;save, file='/Users/emily/CLOUDSAT/CWC/'+shortname+'/'+filenames[wfiles[i]]+'.sav', $
;      LWC_slab, IWC_slab, lat2d_slab, lon2d_slab, xslab, zslab, LWC_uncertainty_slab, $
;      IWC_uncertainty_slab
   
;;see if saving just the 'good' parts saves memory, cuts it by ~6 to 7
;;times 52 KB -> 8 KB
;save, file='/Users/emily/CLOUDSAT/CWC/'+shortname+'/'+filenames[wfiles[i]]+'.2.sav', $
;      LWC_slab, IWC_slab, LWC_lat2d_slab, LWC_lon2d_slab, IWC_lat2d_slab, IWC_lon2d_slab, LWC_xslab, $
;      IWC_xslab, LWC_zslab, IWC_zslab, LWC_uncertainty_slab, IWC_uncertainty_slab


endfor    ;; end i loop over clouds
end

