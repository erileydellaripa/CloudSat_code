PRO GO

;year_name = '2007'

restore, '~/CLOUDSAT/cloud_lists/Masterlist_2013.sav'
;BBWIDTHS        INT       = Array[15181193]
;BIGGESTGT0S     LONG      = Array[15181193]
;BOTTOMS         FLOAT     = Array[15181193]
;DBZ_SEA_MAXS    FLOAT     = Array[15181193]
;DBZ_SEA_MINS    FLOAT     = Array[15181193]
;FILENAMES       STRING    = Array[15181193]
;LANDPIXELSS     LONG      = Array[15181193]
;MAXLATS         FLOAT     = Array[15181193]
;MAXLONS         FLOAT     = Array[15181193]
;MAXXS           LONG      = Array[15181193]
;MEANLATS        FLOAT     = Array[15181193]
;MEANLONS        FLOAT     = Array[15181193]
;MEANZS          FLOAT     = Array[15181193]
;MINLATS         FLOAT     = Array[15181193]
;MINLONS         FLOAT     = Array[15181193]
;MINXS           LONG      = Array[15181193]
;NCELLSGT0S      LONG      = Array[15181193]
;NPIXELSGE17S    LONG      = Array[15181193]
;NPIXELSGT0S     LONG      = Array[15181193]
;NPIXELSS        LONG      = Array[15181193]
;NPIXELS_ABOVES  LONG      = Array[15181193]
;SD_DBZ_SURFS    FLOAT     = Array[15181193]
;TODS            INT       = Array[15181193]
;TOPS            FLOAT     = Array[15181193]
;ZGMAXS          FLOAT     = Array[15181193]
;ZGMINS          FLOAT     = Array[15181193]

years    = fix(strmid(filenames, 0, 4))
days     = fix(strmid(filenames, 4, 3))
hours    = fix(strmid(filenames, 7, 2))
minutes  = fix(strmid(filenames, 9, 2))
seconds  = fix(strmid(filenames, 11, 2))
orbits   = float(strmid(filenames, 14, 5))
name_length = strlen(filenames)

EOnumbers = fltarr(n_elements(filenames))
FOR i = 0, n_elements(filenames)-1 DO EOnumbers[i] = float(strmid(filenames[i], 20, fix(name_length[i] - 20)))
  
yr_array = ['2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013']

FOR iyear = 0, n_elements(yr_array)-1 DO BEGIN 

w_year = where(years EQ fix(yr_array[iyear]), nEOs)
;w_year = where(years EQ '2007' and days EQ '001', nEOs)

BBWIDTHS_yr       = BBWIDTHS[w_year]
BIGGESTGT0S_yr    = BIGGESTGT0S[w_year]
BOTTOMS_yr        = BOTTOMS[w_year]
DBZ_SEA_MAXS_yr   = DBZ_SEA_MAXS[w_year]
DBZ_SEA_MINS_yr   = DBZ_SEA_MINS[w_year]
LANDPIXELSS_yr    = LANDPIXELSS[w_year]
MAXLATS_yr        = MAXLATS[w_year]
MAXLONS_yr        = MAXLONS[w_year]
MAXXS_yr          = MAXXS[w_year]
MEANLATS_yr       = MEANLATS[w_year]
MEANLONS_yr       = MEANLONS[w_year]
MEANZS_yr         = MEANZS[w_year]
MINLATS_yr        = MINLATS[w_year]
MINLONS_yr        = MINLONS[w_year]
MINXS_yr          = MINXS[w_year]
NCELLSGT0S_yr     = NCELLSGT0S[w_year]
NPIXELSGE17S_yr   = NPIXELSGE17S[w_year]
NPIXELSGT0S_yr    = NPIXELSGT0S[w_year]
NPIXELSS_yr       = NPIXELSS[w_year]
NPIXELS_ABOVES_yr = NPIXELS_ABOVES[w_year]
SD_DBZ_SURFS_yr   = SD_DBZ_SURFS[w_year]
TODS_yr           = TODS[w_year]
TOPS_yr           = TOPS[w_year]
ZGMAXS_yr         = ZGMAXS[w_year]
ZGMINS_yr         = ZGMINS[w_year]
days_yr           = days[w_year]
hours_yr          = hours[w_year]
minutes_yr        = minutes[w_year]
seconds_yr        = seconds[w_year]
orbits_yr         = orbits[w_year]
EOnumbers_yr      = EOnumbers[w_year]

;FILENAMES_yr      = FILENAMES[w_year]

fid        = ncdf_create('EO_masterlist'+yr_array[iyear]+'.nc', /CLOBBER)
d          = indgen(1, /LONG)

;Set Dimensions
d[0] = ncdf_dimdef(fid, 'nEOs', nEOs)

;Define variables to be stored
BBWIDTHS_id = ncdf_vardef(fid, 'BBWIDTHS', d[0], /FLOAT)
BIGGESTGT0S_id = ncdf_vardef(fid, 'BIGGESTGT0S', d[0], /FLOAT)
BOTTOMS_id = ncdf_vardef(fid, 'BOTTOMS', d[0], /FLOAT)
DBZ_SEA_MAXS_id = ncdf_vardef(fid, 'DBZ_SEA_MAXS', d[0], /FLOAT)
DBZ_SEA_MINS_id = ncdf_vardef(fid, 'DBZ_SEA_MINS', d[0], /FLOAT)
;FILENAMES_id = ncdf_vardef(fid, 'FILENAMES', d1[0], /CHAR)
;;This doesn't work. See
;;http://www.idlcoyote.com/fileio_tips/rw_ncdfstr.html
;;But I dont' think coyote's work around will be sufficient for
;;sharing data with someone else since they might not be about to
;;convert from byte to string
MAXLATS_id = ncdf_vardef(fid, 'MAXLATS', d[0], /FLOAT)
MAXLONS_id = ncdf_vardef(fid, 'MAXLONS', d[0], /FLOAT)
MAXXS_id = ncdf_vardef(fid, 'MAXXS', d[0], /FLOAT)
MEANLATS_id = ncdf_vardef(fid, 'MEANLATS', d[0], /FLOAT)
MEANLONS_id = ncdf_vardef(fid, 'MEANLONS', d[0], /FLOAT)
MEANZS_id = ncdf_vardef(fid, 'MEANZS', d[0], /FLOAT)
MINLATS_id = ncdf_vardef(fid, 'MINLATS', d[0], /FLOAT)
MINLONS_id = ncdf_vardef(fid, 'MINLONS', d[0], /FLOAT)
MINXS_id = ncdf_vardef(fid, 'MINXS', d[0], /FLOAT)
NCELLSGT0s_id = ncdf_vardef(fid, 'NCELLSGT0S', d[0], /FLOAT)
NPIXELSGE17S_id = ncdf_vardef(fid, 'NPIXELSGE17S', d[0], /FLOAT)
NPIXELSGT0S_id = ncdf_vardef(fid, 'NPIXELSGT0S', d[0], /FLOAT)
NPIXELSS_id = ncdf_vardef(fid, 'NPIXELSS', d[0], /FLOAT)
NPIXELS_ABOVES_id = ncdf_vardef(fid, 'NPIXELS_ABOVES', d[0], /FLOAT)
SD_DBZ_SURFS_id = ncdf_vardef(fid, 'SD_DBZ_SURFS', d[0], /FLOAT)
TODS_id = ncdf_vardef(fid, 'TODS', d[0], /SHORT)
TOPS_id = ncdf_vardef(fid, 'TOPS', d[0], /FLOAT)
ZGMAXS_id = ncdf_vardef(fid, 'ZGMAXS', d[0], /FLOAT)
ZGMINS_id = ncdf_vardef(fid, 'ZGMINS', d[0], /FLOAT)
days_id   = ncdf_vardef(fid, 'DAYS', d[0], /SHORT)
hours_id  = ncdf_vardef(fid, 'HOURS', d[0], /SHORT)
MINS_id   = ncdf_vardef(fid, 'MINUTES', d[0], /SHORT)
SECS_id   = ncdf_vardef(fid, 'SECONDS', d[0], /SHORT)
ORBITS_id = ncdf_vardef(fid, 'ORBITS', d[0], /FLOAT)
EOnums_id = ncdf_vardef(fid, 'EONUMBERS', d[0], /FLOAT)
 
;;Not sure what the point of Landpixels are. From
;;process_orbit_pair_April17.pro:
;    zgmax = max( zsurf[minx:maxx], MIN = zgmin) 
;    landpixels = round(/L64, total( zsurf[minx:maxx] gt -999) )
;So landpixels looks like the total elevation underneath the EO
;LANDPIXELSS_id = ncdf_vardef(fid, 'LANDPIXELSS', d[0], /FLOAT)

;;;Define some attributes
ncdf_attput, fid, /Global, 'Title', 'Echo Object (EO) attributes for ' + yr_array[iyear]
ncdf_attput, fid, /Global, 'Description', 'Created by ERD from IDL Masterlist_2013.sav files. Battery failure 17 April 2011; after this only daytime EOs.'

ncdf_attput, fid, bbwidths_id, 'Long_name',  'bounding box width'
ncdf_attput, fid, bbwidths_id, 'Description', 'maxx - minx'
ncdf_attput, fid, bbwidths_id, 'units', 'pixels'
ncdf_attput, fid, biggestgt0s_id, 'Description', 'Number of pixels in biggest cell greater than 0 dBZ'
ncdf_attput, fid, bottoms_id, 'Description', 'base of the EO'
ncdf_attput, fid, bottoms_id, 'units', 'meters'
ncdf_attput, fid, dbz_sea_maxs_id, 'Description', 'If entirely ocean EO, max dBZ near sea surface'
ncdf_attput, fid, dbz_sea_maxs_id, 'units', 'dBZ'
ncdf_attput, fid, dbz_sea_mins_id, 'Description', 'If entirely ocean EO, min dBZ near sea surface'
ncdf_attput, fid, dbz_sea_mins_id, 'units', 'dBZ'
ncdf_attput, fid, maxlats_id, 'Description', 'Maximum EO latitude'
ncdf_attput, fid, maxlons_id, 'Description', 'Maximum EO longitude'
ncdf_attput, fid, maxxs_id, 'Description', 'Maximum location along CloudSat orbit track'
ncdf_attput, fid, meanlats_id, 'Description', 'Mean EO latitude'
ncdf_attput, fid, meanlons_id, 'Description', 'Mean EO longitude'
ncdf_attput, fid, meanzs_id, 'Description', 'Mean EO height'
ncdf_attput, fid, meanzs_id, 'units', 'meters'
ncdf_attput, fid, minlats_id, 'Description', 'Minimum EO latitude'
ncdf_attput, fid, minlons_id, 'Description', 'Minimum EO longitude'
ncdf_attput, fid, minxs_id, 'Description', 'Minimum location along CloudSat orbit track'
ncdf_attput, fid, ncellsgt0s_id, 'Description', 'Number of cells within EO with greater than 0 dBZ'
ncdf_attput, fid, npixelsge17s_id, 'Description', 'Number of pixels within EO with greather than -17 dBZ'
ncdf_attput, fid, npixelsge17s_id, 'units', 'pixels'
ncdf_attput, fid, npixelsgt0s_id, 'Description', 'Number of pixels within EO with greather than 0 dBZ'
ncdf_attput, fid, npixelsgt0s_id, 'units', 'pixels'
ncdf_attput, fid, npixelss_id, 'Description', 'Number of pixels with each EO'
ncdf_attput, fid, npixelss_id, 'units', 'pixels'
ncdf_attput, fid, npixels_aboves_id, 'Description', 'Number of pixels overlapping the EO. If zero then no overlapping EO pixels'
ncdf_attput, fid, npixels_aboves_id, 'units', 'pixels'
ncdf_attput, fid, sd_dbz_surfs_id, 'Description', 'standard deviation of sea surface dBZ. Only defined for ocean EOs'
ncdf_attput, fid, tods_id, 'Long_name', 'Time of Day'
ncdf_attput, fid, tods_id, 'Description', '0 is night overpass (0130 LT); 1 is day overpass (1330 LT)'
ncdf_attput, fid, tops_id, 'Description', 'top of the EO'
ncdf_attput, fid, tops_id, 'units', 'meters'
ncdf_attput, fid, zgmaxs_id, 'Description', 'Maximum ground altitude beneath the EO. -9999 is ocean'
ncdf_attput, fid, zgmaxs_id, 'units', 'meters'
ncdf_attput, fid, zgmins_id, 'Description', 'Minimum ground altitude beneath the EO. -9999 is ocean'
ncdf_attput, fid, zgmins_id, 'units', 'meters'
ncdf_attput, fid, EOnums_id, 'Description', 'EO number for corresponding orbit'
ncdf_attput, fid, orbits_id, 'Description', 'CloudSat orbit number'
;ncdf_attput, fid, filenames_id, 'Description', 'CloudSat filename. Format is YYYYDDDHHMMSS_orbitnumber.cloudnumber'

;Change modes
ncdf_control, fid, /ENDEF

;Write the data
ncdf_varput, fid, 'BBWIDTHS', BBWIDTHS_yr
ncdf_varput, fid, 'BIGGESTGT0S', BIGGESTGT0S_yr
ncdf_varput, fid, 'BOTTOMS', BOTTOMS_yr
ncdf_varput, fid, 'DBZ_SEA_MAXS', DBZ_SEA_MAXS_yr
ncdf_varput, fid, 'DBZ_SEA_MINS', DBZ_SEA_MINS_yr
ncdf_varput, fid, 'MAXLATS', MAXLATS_yr
ncdf_varput, fid, 'MAXLONS', MAXLONS_yr
ncdf_varput, fid, 'MAXXS', MAXXS_yr
ncdf_varput, fid, 'MEANLATS', MEANLATS_yr
ncdf_varput, fid, 'MEANLONS', MEANLONS_yr
ncdf_varput, fid, 'MEANZS', MEANZS_yr
ncdf_varput, fid, 'MINLATS', MINLATS_yr
ncdf_varput, fid, 'MINLONS', MINLONS_yr
ncdf_varput, fid, 'MINXS', MINXS_yr
ncdf_varput, fid, 'NCELLSGT0S', NCELLSGT0S_yr
ncdf_varput, fid, 'NPIXELSGE17S', NPIXELSGE17S_yr
ncdf_varput, fid, 'NPIXELSGT0S', NPIXELSGT0S_yr
ncdf_varput, fid, 'NPIXELSS', NPIXELSS_yr
ncdf_varput, fid, 'NPIXELS_ABOVES', NPIXELS_ABOVES_yr
ncdf_varput, fid, 'SD_DBZ_SURFS', SD_DBZ_SURFS_yr
ncdf_varput, fid, 'TODS', TODS_yr
ncdf_varput, fid, 'TOPS', TOPS_yr
ncdf_varput, fid, 'ZGMAXS', ZGMAXS_yr
ncdf_varput, fid, 'ZGMINS', ZGMINS_yr
ncdf_varput, fid, 'DAYS', DAYS_yr
ncdf_varput, fid, 'HOURS', HOURS_yr
ncdf_varput, fid, 'SECONDS', SECONDS_yr
ncdf_varput, fid, 'MINUTES', MINUTES_yr
ncdf_varput, fid, 'ORBITS', ORBITS_yr
ncdf_varput, fid, 'EONUMBERS', EOnumbers_yr

;ncdf_varput, fid, 'FILENAMES', FILENAMES_yr

;Close the file & release the handler
ncdf_close, fid

ENDFOR 

stop
END 
