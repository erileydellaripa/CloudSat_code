PRO GO

restore, '~/CLOUDSAT/cloud_lists/Masterlist_2013.sav'

PATH = '/Volumes/silverbullet/EO_soundings_thru2009/'

year_name = '2006'

years       = fix(strmid(filenames, 0, 4))
days        = fix(strmid(filenames, 4, 3))
hours       = fix(strmid(filenames, 7, 2))
minutes     = fix(strmid(filenames, 9, 2))
seconds     = fix(strmid(filenames, 11, 2))
orbits      = float(strmid(filenames, 14, 5))
name_length = strlen(filenames)

EOnumbers = fltarr(n_elements(filenames))
FOR i = 0, n_elements(filenames)-1 DO EOnumbers[i] = float(strmid(filenames[i], 20, fix(name_length[i] - 20)))

orbits      = strmid(filenames, 14, 5)
start_names = strmid(filenames, 0, 19)

w_year = where(years EQ fix(year_name), nEOs)

uniq_orbits   = unique(orbits[w_year], /sort)
uniq_st_names = unique(start_names[w_year], /sort)

;;;Arrays to be filled later
all_p_avg = fltarr(nEOs, 125)
all_q_avg = fltarr(nEOs, 125)
all_T_avg = fltarr(nEOs, 125)

i_tot_EO = 0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Loop through each EO to restore it's ECMWF sounding information
FOR iorbit = 0, n_elements(uniq_orbits)-1 DO BEGIN
   print, uniq_orbits[iorbit]

   w_orbit = where(orbits EQ uniq_orbits[iorbit], nOrbEO)
;   w_st_name = where(start_names EQ uniq_st_names[iorbit], n2)

   FOR iEO = 0, nOrbEO - 1 DO BEGIN

      restore, path + uniq_st_names[iorbit] + '/' + filenames[w_orbit[iEO]] + '.sav'
      
      all_p_avg[i_tot_EO, *] = p_avg
      all_q_avg[i_tot_EO, *] = q_avg
      all_T_avg[i_tot_EO, *] = T_avg
      
      i_tot_EO = i_tot_EO + 1

   ENDFOR 
ENDFOR 

;;;;
days_yr      = days[w_year]
hours_yr     = hours[w_year]
minutes_yr   = minutes[w_year]
seconds_yr   = seconds[w_year]
orbits_yr    = orbits[w_year]
EOnumbers_yr = EOnumbers[w_year]

;;;Create netcdf file
fid = ncdf_create('ECMWF_sounding_info_2006.nc', /CLOBBER)
d   = indgen(2, /LONG)

;Set Dimensions
d[0] = ncdf_dimdef(fid, 'nEOs', nEOs)
d[1] = ncdf_dimdef(fid, 'levels', 125)

;Define variables to be stored
days_id   = ncdf_vardef(fid, 'DAYS', d[0], /SHORT)
hours_id  = ncdf_vardef(fid, 'HOURS', d[0], /SHORT)
MINS_id   = ncdf_vardef(fid, 'MINUTES', d[0], /SHORT)
SECS_id   = ncdf_vardef(fid, 'SECONDS', d[0], /SHORT)
ORBITS_id = ncdf_vardef(fid, 'ORBITS', d[0], /FLOAT)
EOnums_id = ncdf_vardef(fid, 'EONUMBERS', d[0], /FLOAT)
P_id      = ncdf_vardef(fid, 'ALL_P_AVGS', [d[0], d[1]], /FLOAT)
Q_id      = ncdf_vardef(fid, 'ALL_Q_AVGS', [d[0], d[1]], /FLOAT)
T_id      = ncdf_vardef(fid, 'ALL_T_AVGS', [d[0], d[1]], /FLOAT)

;;;Define some attributes
ncdf_attput, fid, /Global, 'Title', 'ECMWF soundings for each Echo Object (EO) in '+ year_name
ncdf_attput, fid, /Global, 'Description', 'Created by ERD from individual EO IDL save files on storage drive sillverbullet. Soundings created by averaging ECMWF info over each EO bbwidth'

ncdf_attput, fid, EOnums_id, 'Description', 'EO number for corresponding orbit'
ncdf_attput, fid, orbits_id, 'Description', 'CloudSat orbit number'
ncdf_attput, fid, P_id, 'Long_name',  'Pressure'
ncdf_attput, fid, P_id, 'units', 'mb' 
ncdf_attput, fid, Q_id, 'Long_name',  'Specific Humidity'
ncdf_attput, fid, Q_id, 'units', 'g/kg' 
ncdf_attput, fid, T_id, 'Long_name',  'Temperature'
ncdf_attput, fid, T_id, 'units', 'Kelvin' 

;Change modes
ncdf_control, fid, /ENDEF

;Write the data
ncdf_varput, fid, 'DAYS', DAYS_yr
ncdf_varput, fid, 'HOURS', HOURS_yr
ncdf_varput, fid, 'SECONDS', SECONDS_yr
ncdf_varput, fid, 'MINUTES', MINUTES_yr
ncdf_varput, fid, 'ORBITS', ORBITS_yr
ncdf_varput, fid, 'EONUMBERS', EOnumbers_yr
ncdf_varput, fid, 'ALL_P_AVGS', all_p_avg 
ncdf_varput, fid, 'ALL_Q_AVGS', all_Q_avg 
ncdf_varput, fid, 'ALL_T_AVGS', all_T_avg 

;Close the file & release the handler
ncdf_close, fid

stop
END
