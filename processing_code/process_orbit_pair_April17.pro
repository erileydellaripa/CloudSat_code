; This routine reads a 2B-GEOPROF file specified by infile name plus
; the next one which is spliced at the end to avoid equatorial edge
; effects. 

; Updated August 2007 by BEM at NCAR
; Added cloud profiles outputs, minx/maxx (for ascending/descending),
; latsampling output, better PIA, landpixels, and subcells > 0dBZ

;;; UPDATED AGAIN MIAMI JAN 2008
;;;; Round instead of fix, overlap problems, -17dbz stats, save ground
;;;; height

;;;UPDATED AGAIN MIAMI APRIL 2008
;;;end of orbit clouds should now be stiched together, ascending
;;;corrected, npixels_above_cloud added

;;;;UPDATED AGAIN NCAR AUGUST 2008
;;;was double counting end of orbit clouds, due to not correcting for
;;;both beginning and ending orbit profiles of each orbit. BLAST!

;;;;UPDATED AGAIN MIAMI NOV 2008
;;;;ADDED---
;w_is_cloud = where(is_cloud[0,*] eq 1)
;if w[0] gt 0-1 then cloudIDs[0,w] = 1
;;;;To correct for Data at edge of label_region being counted as zero
;;;;See IDL help page on LABEL_REGION

;;;;UPDATED AGAIN MIAMI 21 FEB 2010
;w_is_cloud = where(is_cloud[0,*] eq 1) 
;if w[0] gt 0-1 then cloudIDs[0,w] = 1 ----> if w_is_cloud[0] gt 0-1 
;then cloudIDs[0,w_is_cloud] = 1 ----> if w_is_cloud[0] gt 0-1                                                                                     
;then cloudIDs[0,w_is_cloud] = cloudIDs[1, w_is_cloud]
;;;;To correct for Data at edge of label_region being counted as zero
;;;;See IDL help page on LABEL_REGION

;;;;;;UPDATED AGAIN MIAMI 22 FEB 2010
;;;add column of zeros to beginning of data arrays, so LABEL_REGION
;;;will be correct
;;;;if ((minx gt NX1) or (minx eq 0)) then goto, jump99 ----> (minx eq 1)

;;;;;;UPDATED AGAIN APRIL 2017 IN COLORADO
;;;;;;Any variable that used minx:maxx was off by one since x2d
;;;;;;started at -1. So if the EO's min edge array index
;;;;;;position was 3, the minx would be 2. Thus any varialb that then
;;;;;;indexed using minx to maxx was actually off by 1. Corrected, by
;;;;;;making x2d start at 0 instead of -1. Was originally worried
;;;;;;about having two zeros on the edge since x = lindgen(NX), where
;;;;;;NX = n_elements(lat). Simply added a +1 to x.

; example usage 
; process_orbit_pair,'/Volumes/bluecloud/GEOPROF1B.R04/', $
;'2007001005141_03607_CS_2B-GEOPROF_GRANULE_P_R04_E02.hdf',$
;'2007001023034_03608_CS_2B-GEOPROF_GRANULE_P_R04_E02.hdf'

pro process_orbit_pair_April17, indir, infile, infile2

MAXCLOUDWIDTH = 2000 ;;; how much a cloud may overhang from orbit 1 into orbit 2

shortname = strmid(infile,0,19)
swathname = '2B-GEOPROF'
Print, infile, ' shortname ', shortname

;;;; Make directories for clouds  ***  INSIDE CURRENT DIR
;spawn, 'mkdir cloud_files/'+shortname
spawn, 'mkdir ~/CLOUDSAT/cloud_pixels_April17/'+shortname

;;; Open the list file for output
openw, 1, '~/CLOUDSAT/cloud_lists_April17/'+shortname+'.list'

SMALLEST_CLOUD = 3   ;;;; pixels
MIN_PIXELS_TO_ANALYZE = 999999L   ;;;; pixels
MIN_PIXELS_TO_SAV = 3  ;;; pixels

;----------------------------------------------- Read data -

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile, /READ)
Print,'file ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
Print,'swath ',swathid

;;;; Read the data fields we want and name them sensibly

;;;; Time
status = EOS_SW_READFIELD(swathid, 'TAI_start', tai)
if( status lt 0) then print, 'Read Error'
Status = EOS_SW_READFIELD(swathid, 'Profile_time', time)
if( status lt 0) then print, 'Read Error'
;;;; Lat
status = EOS_SW_READFIELD(swathid, 'Latitude', lat)
if( status lt 0) then print, 'Read Error'
;;;; Lon
status = EOS_SW_READFIELD(swathid, 'Longitude', lon)
if( status lt 0) then print, 'Read Error'
;;;; Height
status = EOS_SW_READFIELD(swathid, 'Height', z)
if( status lt 0) then print, 'Read Error'
;;;; Ground Height
status = EOS_SW_READFIELD(swathid, 'DEM_elevation', zsurf)
if( status lt 0) then print, 'Read Error'

;;;; Update THE LAT-LON SAMPLING ARRAY
;norbits=0
;latlonsamplinghist=0
;restore,'latlonsampling.sav'
;Result = HIST_2D( lon, lat, MAX1= 180, MAX2=90, MIN1= -180, MIN2= -90) 
;latlonsamplinghist = latlonsamplinghist + result
;norbits = norbits+1
;save,file='latlonsampling.sav', latlonsamplinghist, norbits

;;;; Now the data - mask radar reflectivity by cloud mask
;;;; after dividing by factor of 100 to make dbZ units

status = EOS_SW_READFIELD(swathid, 'Radar_Reflectivity', rawdata)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'CPR_Cloud_mask', mask)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Gaseous_Attenuation', atten)
if( status lt 0) then print, 'Read Error'
;print, 'stop after read in fist file'
;stop

rawdbZ = rotate(rawdata+atten, 3) / 100.
dBZ = rawdBZ
mask = rotate(mask, 3) 
z = rotate(z,3) ;;;; CAREFUL: Z is a 2D array not a single value
;;;;Try fixing for masks at edges being set to zero. Set last 5
;;;;profiles or 1st orbit where dbz gt -25 to mask = 30, this way the dbz will be
;;;;retained in these profiles.
nlats = n_elements(lat)
s = size(z)

;;;correct for last 5, an easier way
last_profiles = mask[s[1]-5:*,*]
w = where( z[s[1]-5:*, *] gt 0 and z[s[1]-5:*, *] le 18000 and $
             dbz[s[1]-5:*, *] ge 0-25 and dbz[s[1]-5:*, *] le 30)
if w[0] ne 0-1 then last_profiles[w] = 30 ;;;sometimes the above criteria is not met
mask[s[1]-5:*,*] = last_profiles
;;;correct for first 5, an easier way
first_profiles = mask[0:4, *]
w = where( z[0:4, *] gt 0 and z[0:4, *] le 18000 and $
             dbz[0:4, *] ge 0-25 and dbz[0:4, *] le 30)
if w[0] ne 0-1 then first_profiles[w] = 30
mask[0:4,*] = first_profiles

;;;correct last 5, the hard way
;for i = nlats-5, nlats-1 do begin
;    for j=0, 125-1 do begin
;        if z[i,j] gt 0 and z[i,j] le 18000 then begin ;avoid anything below surface and above tropo
;            if dbz[i,j] ge 0-25 and dbz[i,j] le 30 then mask[i,j] = 30
;        endif 
;    endfor 
;endfor
;;;correct for first 5, the hard way
;for i = 0, 4 do begin ;first 15 profile
;    for j=0, 125-1 do begin ;loop over all height bins
;        if z[i,j] gt 0 and z2[i,j] le 18000 then begin
;            if dbz[i,j] ge 0-25 and dbz[i,j] le 30 then mask[i,j] = 30
;        endif 
;    endfor 
;endfor 
dBZ[ where(mask lt 20 or mask gt 40) ] = -88.88 ;;; MASK has values 20-40 for clouds
;print, 'stop after dbz'
;stop
;;;; OK, done getting what ewe neeed from file, close it

status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

;;;;; Define x dimension (along track) 
Nx1 = n_elements(lat) ;;; Array size in horizontal for orbit 1 only

;----------------------------------------------- Read data -2 (to append)

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile2, /READ)
print,'file2 ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
print,'swath2 ',swathid

;;;; Read the data fields we want and name them sensibly

;;;; Time
status = EOS_SW_READFIELD(swathid, 'TAI_start', tai2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Profile_time', time2)
if( status lt 0) then print, 'Read Error'
;;;; Lat
status = EOS_SW_READFIELD(swathid, 'Latitude', lat2)
if( status lt 0) then print, 'Read Error'
;;;; Lon
status = EOS_SW_READFIELD(swathid, 'Longitude', lon2)
if( status lt 0) then print, 'Read Error'
;;;; Height
status = EOS_SW_READFIELD(swathid, 'Height', z2)
if( status lt 0) then print, 'Read Error'
;;;; Ground Height
status = EOS_SW_READFIELD(swathid, 'DEM_elevation', zsurf2)
if( status lt 0) then print, 'Read Error'

;;;; Now the data - mask radar reflectivity by cloud mask
;;;; after dividing by factor of 100 to make dbZ units

status = EOS_SW_READFIELD(swathid, 'Radar_Reflectivity', rawdata2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'CPR_Cloud_mask', mask2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Gaseous_Attenuation', atten2)
if( status lt 0) then print, 'Read Error'
;print, 'stop after read in 2nd file'
;stop
;;;; OK, done getting what ewe neeed from fole, close it

status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

;;;;  rotate as necessary
rawdBZ2 = rotate(rawdata2+atten2, 3) / 100.
dBZ2 = rawdBZ2
mask2 = rotate(mask2, 3)
z2 = rotate(z2,3) ;;;; CAREFUL: Z is a 2D array not a single value

;;;;Try fixing for masks at edges being set to zero. Set first 5
;;;;profiles or 2nd orbit where dbz gt -25 to mask = 30, this way the dbz will be
;;;;retained in these profiles.
;mask2[where(dbz2[0:14, *] ge -30.)] = 30
nlats2 = n_elements(lat2)
s2 = size(z2)

;;;correct for last 5, an easier way
last_profiles2 = mask2[s2[1]-5:*,*]
w = where( z2[s2[1]-5:*, *] gt 0 and z2[s2[1]-5:*, *] le 18000 and $
           dbz2[s2[1]-5:*, *] ge 0-25 and dbz2[s2[1]-5:*, *] le 30)
if w[0] ne 0-1 then last_profiles2[w] = 30
mask2[s2[1]-5:*,*] = last_profiles2
;;;correct for first 5, an easier way
first_profiles2 = mask2[0:4, *]
w = where( z2[0:4, *] gt 0 and z2[0:4, *] le 18000 and $
           dbz2[0:4, *] ge 0-25 and dbz2[0:4, *] le 30)
if w[0] ne 0-1 then first_profiles2[w] = 30
mask2[0:4, *] = first_profiles2
;;;correct for last 5
;for i = nlats2-5, nlats2-1 do begin
;    for j=0, 125-1 do begin
;        if z2[i,j] gt 0 and z2[i,j] le 18000 then begin ;avoid anything below surface and above tropo
;            if dbz2[i,j] ge 0-25 and dbz2[i,j] le 30 then mask2[i,j] = 30
;        endif 
;    endfor 
;endfor
;;;correct for first 5
;for i = 0, 4 do begin ;first 15 profile
;    for j=0, 125-1 do begin ;loop over all height bins
;        if z2[i,j] gt 0 and z2[i,j] le 18000 then begin
;            if dbz2[i,j] ge 0-25 and dbz2[i,j] le 30 then mask2[i,j] = 30
;        endif 
;    endfor 
;endfor 

dBZ2[ where(mask2 lt 20 or mask2 gt 40) ] = -88.88 ;;; MASK has values 20-40 for clouds
;print, 'stop after dbz2'
;stop
;;;; ORB2 is mismatched? This can happen if there is missing data. 
;;; Check TAI time arrays (atomic time). 
;;; If there is even 1 second (or say 60 seconds or more) offset, the orbits 
;;; are mismatched. 

if( TAI2-(TAI+max(time)) gt 60 ) then $
    dBZ2( *,* ) = -88.88 ;;; disable any false connections betw clouds in one orbit 
; and next if there is missing data in between
if( TAI2-(TAI+max(time)) gt 60 ) then print, 'orbits are mismatched'

;----------------------------------------------- APPEND files

;;; 2D arrays
z = [z, z2[0:MAXCLOUDWIDTH-1,*] ]
dBZ = [dbz, dbz2[0:MAXCLOUDWIDTH-1,*] ]
rawdBZ = [rawdbz, rawdbz2[0:MAXCLOUDWIDTH-1,*] ]
mask = [mask, mask2[0:MAXCLOUDWIDTH-1,*] ]

;;; 1D arrays
lat = [lat, lat2[ 0:MAXCLOUDWIDTH-1] ]
lon = [lon, lon2[ 0:MAXCLOUDWIDTH-1] ]
zsurf = [zsurf, zsurf2[0:MAXCLOUDWIDTH-1] ]

;;;;; Define x dimension (along track) 
Nx = n_elements(lat) ;;; Array size in horizontal
x = lindgen(NX)+1

;;;; 2D coordinate arrays, for convenience
lon2d = lon#( 1+fltarr(125) ) ;;; 2D array of longitudes, -180 to 180
lat2d = lat#( 1+fltarr(125) ) ;;; 2D array of latitudes
x2d = x#( 1+fltarr(125) ) ;;; 2D array of x cordinate

;----------------- Add a column of zeros to beginning of data arrays
;                  to correct for LABEL_REGION snag! 22 Feb 2010

z      = [rotate(intarr(125), 4), z]
dbz    = [rotate(intarr(125)-88., 4), dbz]    ;;-88 is dummy value
rawdbz = [rotate(intarr(125)-88., 4), rawdbz]
mask   = [rotate(intarr(125), 4), mask]

zsurf = [0, zsurf]

lon2d  = [rotate(intarr(125), 4), lon2d]
lat2d  = [rotate(intarr(125), 4), lat2d]
x2d    = [rotate(intarr(125), 4), x2d] 
;;-1 since array starts at zero and padding with an additional column
;;of zeros would make the array have two columns of zeros
;;March 2017 changed it so x2d array starts at 0, instead of -1. Made
;;x above start at 1 instead of 0. x = lindgen(NX) + 1 

;;;22 Feb 2010 changed NX -> (NX + 1) b/c have added column of zeros,
;;;wait...just leave as NX, b/c that first column is all ZEROS,
;;;therefore it should not be included in the average, so leave it as NX.
zplot = total(z, 1)/NX /1000. ;;; Average height profile over sample, convert m to km

;print, 'stop after NX and x2d'
;stop
;------------------------------------------------ Find clouds

;;;; Have dBZ array, with -88.88 where it is not cloud. 
;;; Let's define is_cloud as dbz greater than -80 (bad is -88.88)

is_cloud = (dBZ gt -80)

;stop
;;;; Now LABEL_REGION
;;;; It is useful to rotate and rotate back so numbering increases
;;;; left to right rather than top to bottom (for display purposes)

cloudIDs = rotate( $
                   label_region(rotate(is_cloud,4), /ulong), $
                   4) ;;; long int in case of more than 32767

;stop
;;;;Correct for label_region counting pixels at edges of Data as ZERO!
;;;;(Note added 2/19/10) I dont' remember if I've actually processed
;;;;the data with this correction added :(
;;eliminated below 2 lines 22 Feb 2010 b/c corrected for label_region
;;snag above by adding column of zeros to data arrays.
;w_is_cloud = where(is_cloud[0,*] eq 1)
;if w_is_cloud[0] gt 0-1 then cloudIDs[0,w_is_cloud] = cloudIDS[1, w_is_cloud]

;;; HOW MANY CLOUDS
NCLOUDS = max(cloudIDs)  ;;; The 0 value seems to be the background - all clouds are numbers >0
print, 'Number of clouds in this orbit: ', NCLOUDS

;stop
;------------------------------------------------ Now lets process
;                                                 clouds and grab stats
for icld = 1, NCLOUDS do begin

;;; Define region in cloud, and make a mask (0-1) array, and a masked
;;; dbZ array containing only the present cloud
    mask = ( cloudIDs eq icld )     ;;; 1 in cloud, 0 outside
    npixels = round(/L64,total(mask))

;;;; Skip clouds of too few pixels
    if( npixels lt SMALLEST_CLOUD ) then goto, jump99

;;;; Define cloud region in 2D array space
    incloud = where( mask )         ;;; array addresses of cloud's points
    masked = dbz*0-88.88            ;;; masked dbZ array : -88.88 initially
    masked(incloud) = dbz(incloud)  ;;; fill part containing cloud
;print, 'stop before maxx, minx'
;stop
;;;;;; X coordinates
    maxx = round(/L64,max( x2d(incloud), MIN=minx )) ;; get max and min in one call
    minx = round(/L64,minx)

;;; If this is entirely in orbit 2, (minx gt NX1+1) chuck it - will catch it next
;;; call of the program. IF minx in current call equals NX+1 then it
;;; abuts the left edge of the appended orbit. Count it in the current
;;; call, so can avoid double counted EOs in next call (or EOs that
;;; span the appended files). For next call, an EO with minx=1 (abuts
;;; left edge), it was counted at NX1+1 in last orbit. 
;;; So, discard those at minx=1.
;stop
;;Changed from minx eq 0 to minx eq 1: 2/22/10.....wait, wait, wait,
;;keep it at minx eq 0, since added array will be -1, else we'd
;;have two columns of zeros!
;;;4/18/207: Now since x2d goes from 0 to NX1+2000, instead of -1 to
;;;NX1+2000-1, changed (minx eq 0) to minx EQ 1.
;;;4/11/2017 add the following note: minx EQ 0 avoids double counting of clouds. As of 4/18/17 this is minx EQ 1, since I changed x to start at 1 istead of 0.
    if( (minx gt NX1+1) or (minx eq 1) ) then goto, jump99  
    if( maxx ge NX  ) then print, '*********************** MINCLOUDWIDTH IS TOO SMALL ****************'

;;; OK, we are counting this one: grab some stats

;STOP
;;;;;; Define slab (of data) and maskedslab (of data) containing the
;;;;;; cloud in question (AUG07)
    slab = dbz[minx:maxx,*]
    maskedslab = masked[minx:maxx,*]
;    totalcloudprofile = total( slab gt -80, 1) ;; Total column
;    cloudiness not used - saved overlapped pixels instead
;    cloudcloudprofile = total( maskedslab gt -80, 1) ;; cloud's cloudiness profile

;;;; SUBCELLS with dbz > 0. May be impossible if slab is too narrow.,
;;;; so make dummy values first then overwrite if slab is wide
;;;; enough. 
    npixelsgt0= round(/L64,total(maskedslab gt 0))
    npixelsge17= round(/L64,total(maskedslab ge -17))

    ncellsgt0 = (npixelsgt0 gt 0) ;;; 0 or 1 if too isolated for label_rtegion
    biggestgt0 = npixelsgt0  ;;;; if too isolated for label_region

    if (maxx-minx gt 2 and max(maskedslab) gt 0) then begin ;;; if label_region is possible
        subcells = label_region(maskedslab gt 0) 
;;; Sometimes the >0 pixels are all at the edge so that 
;;; subells is zero even though it has some ones going into 
;;; the label_region thing, so fixes are necessary
        ncellsgt0 = max([subcells,maskedslab gt 0])
;;;; Histogram says how many pixels in each cloud label
;;;; 0 is non>0 so don't count it!
        if( max(subcells gt 0) ) then $
          biggestgt0 = max( (histogram(subcells))(1:*) )
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Bounding box and centroid
;;; Top and bottom ;; get max and min in one call
    top = max( z(incloud), wtop, MIN=bottom, subscript_min = wbot ) 
    index_of_top = incloud[wtop]
    index_of_bot = incloud[wbot]

;;; min and max lat-lon : if lon crosses dateline, fixed below
    maxlat = max( lat2d(incloud), MIN=minlat ) ;; get max and min in one call
    maxlon = max( lon2d(incloud), MIN=minlon ) ;; get max and min in one call

;;; If longitude is folded across 180 dateline, unfold and recompute min, max, mean
    if( (maxlon-minlon) gt 180 ) then begin
        maxlon = max(   ((lon2d+360) mod 360) (incloud), MIN=minlon ) 
        meanlon = mean( ((lon2d+360) mod 360) (incloud) ) 
    endif

;;; Ascending or descending (asc = day, desc = night)
;;;Changed from lat to lat2d, so indexing will be done properly (ER
;;;April 26 2008)
    ascending = (deriv(lat2d) gt 0)

;;; Mean height, lat, lon
    meanz = mean( z(incloud) ) 
    meanlat = mean( lat2d(incloud) ) 
    meanlon = mean( lon2d(incloud) ) 
    meanx = mean( x2d(incloud) ) 

;;; Max and min surface elevation. Ocean is -9999.
    zgmax = max( zsurf[minx:maxx], MIN = zgmin) 
    landpixels = round(/L64, total( zsurf[minx:maxx] gt -999) )

;;;number of pixels overlapping the top of the cloud(ER, April 26
;;;2008)
;;;tried to use wtop, but that is a 1D array for incloud, we need the
;;;location of the top of the cloud in the height bin of 2D array
    zmax_2Dlocation = array_indices(z, index_of_top)
    zmax_heightbin = zmax_2Dlocation[1] ;z is a 2D array so zmax_2Dlocation[1] is height bin location
    above_cloud_in_slab = slab[*, zmax_heightbin+1:*]
    npixels_above_cloud = total(total(above_cloud_in_slab gt -80, 2))
;print, 'number of pixels above cloud ', npixels_above_cloud

;;;; Assuming this cloud is is puely over ocean, grab the PIA as a precip indicator
;;;; Min and max dbZ of sea surface - sort of Haynes and Stephens' PIA
;;;; Of course will be meaningless for clouds over land so careful

    dbz_sea_max = 0 ;;; this will stand uless the cloud is over water
    dbz_sea_min = 0 ;;; i.e. use zero for clouds over land
    sd_dbz_surf = 0 ;; dummy, will be overwritten if possible

;;; IF ocean clouds, grab stats 
    if( zgmax lt -999 ) then begin
        zprofile = total(z[MINX:MAXX,*], 1)/(maxx-minx+1) ;;; Average height profile of bins,
                                ;;; in local region over cloud (m)
        dummy = min(abs(zprofile), MSL_zindex) ;;; bin 20 usually
        if( MSL_zindex ne 20 ) then print, '******* MSL in bin ', MSL_zindex
        
        dbz_sea_max = max( rawdbz[minx:maxx, MSL_zindex], MIN=dbz_sea_min )
;;; Only if there are more than 2 values is stdev defined
        if(maxx-minx gt 0) then sd_dbz_surf = stdev(rawdbz[minx:maxx, MSL_zindex]) 

    endif

;;; Make little thumbnail contour plots ... just to check sanity? 
    center_x = mean(incloud mod NX)
    left_x = (center_x - 100)  >0
    right_x = (center_x + 100) <(NX-1)

;;; plot only tropical clouds
;    dbzlevels = -50 + indgen(80)
;    if( abs(meanlat) lt 30 and NPIXELS gt 50 ) then begin
;        dog = masked(left_x:right_x,*)
;        contour, dog, $
;          x(left_x:right_x) - min(x(left_x:right_x)), zplot, xtitle = 'km', /fill, $
;          ytit='z', title='cloud '+string(icld),levels=dbzlevels
;;; data
;        dog = dog[*,in_trop]
;        fit_in_window, 0, dog + 999*(dog lt -80), MN=-55, MX=25
;        axis, xaxis=0
;        axis, yaxis=0
;    endif


;    if( npixels gt MIN_PIXELS_TO_ANALYZE ) then begin
;;;;; PROCESSING cloud in detail - excluded for now, see old versions
;    endif ;    if( npixels gt MIN_PIXELS_TO_PROCESS ) then begin        


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Done with vertical loop -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; cloud digested, ready to
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; regurgitate stats into
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; files
        
;;;; Write a line in the master list: all the variables one might want to
;;;; sort on. bottom, top, size (area, width), lat, lon, land-sea mask
;;;; and PIA

    bbwidth = maxx-minx+1 ;;; units: pixels

;;; Filename on separate line - only string - then all the rest are just numbers
;;;                             (easier to read unformatted)
    printf, 1,     shortname+'.'+strtrim(string(icld),2)

;UNFORMATTED output - NEW ORDERING
    printf, 1, $
;    print, $
      round(mean(ascending(incloud))), $ ;;; zero or 1, 1=day=ascending, 0 = night = descending
      minx, maxx, npixels, npixelsge17, npixelsgt0, npixels_above_cloud, landpixels, $
      ncellsgt0, biggestgt0, $
      bbwidth, bottom, meanz, top, minlat, meanlat, maxlat, minlon, meanlon, maxlon, $
      zgmin, zgmax, dbz_sea_min, dbz_sea_max, sd_dbz_surf

;;;; Write an output file with the cloud points: x, z, and dBZ. 
;;;; From this, one could rebuild the picture and then measure
;;;; anything more about it (ellipticity, fractality, etc etc. 
        
        xcloud = round(/L64,x2d[ incloud ])
        zcloud = round(z  [ incloud ]) ;;; A short integer will suffice
        dbzcloud = round(dbz [ incloud ]) ;;; short int is enough
        zground = round( zsurf[minx:maxx] ) ;;; a short integer will suffice (meters)

;;;;;; Define slab (of data) and maskedslab (of data) containing the
;;;;;; cloud in question (AUG07)
;    slab = dbz[minx:maxx,*]  !!! DONE ABOVE - here as reminder only
;    maskedslab = masked[minx:maxx,*]

        xslab = x2d[minx:maxx,*]
        zslab =   z[minx:maxx,*]
;;; Find the places where slab has nonbad dbZ but maskedslab has
;;; -88.88
        overlapped = where(slab gt -80 and maskedslab lt -80); in slab but not part of this cloud
;;; Set dummy values, in case these dont exist - then overwrite if
;;;                                              they do
        zoverlapped = -999 ;; dummy
        xoverlapped = -999 ;; dummy
        dbzoverlapped = -999 
;;; If overlapped cloud exists, save its pixels
        if( max(overlapped) gt 0 ) then begin
            xoverlapped = round(/L64,xslab[overlapped])
            zoverlapped = round(zslab[overlapped]) ;; short int
            dbzoverlapped=round(slab[overlapped])  ;; short int
        endif

        if( npixels ge MIN_PIXELS_TO_SAV) then $
        save, file='~/CLOUDSAT/cloud_pixels_April17/'+shortname+'/'+shortname+'.'+strtrim(string(icld),2)+'.sav', $
          xcloud, zcloud, dbzcloud, xoverlapped, zoverlapped, dbzoverlapped, zground

;;; If cloud was too small, do none of the above (skip it)
jump99:
        
    endfor ;; end icld loop over clouds
    close,1
; stop   
end

