PRO process_MLS_H2O_pair, INFILE, INFILE2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PATH = '/Users/mapesgroup/CLOUDSAT/YOTC/YOTC_datasets/mls/H2O/'
msl_H2O_filename = infile
full_filepath = PATH + msl_H2O_filename
shortname = strmid(msl_H2O_filename, 8, 19)
spawn, 'mkdir /Users/mapesgroup/CLOUDSAT/YOTC/MLS_H2O_EOfiles/'+shortname
read_ncdf, full_filepath, data, /attrib ;returns data structure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
msl_H2O_filename2 = infile2
full_filepath2 = PATH + msl_H2O_filename2
read_ncdf, full_filepath2, data_second, /attrib ;returns data_second structure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;APPEND FILES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
maxcloudwidths = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2
;;;no need to read in latitude and longitude for every dataset
;latitudes   = [data.latitude,data_second.latitude[0:maxcloudwidths-1]] 
;longitudes  = [data.longitude, data_second.longitude[0:maxcloudwidths-1]]
convergences= [data.convergence, data_second.convergence[0:maxcloudwidths-1]]
statuss     = [data.status, data_second.status[0:maxcloudwidths-1]]
H2Os        = [[data.H2O], [data_second.H2O[*, 0:maxcloudwidths-1]]]
H2Oprecisions = [[data.H2Oprecision], [data_second.H2Oprecision[*, 0:maxcloudwidths-1]]]
qualitys    = [data.quality, data_second.quality[0:maxcloudwidths-1]]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Restore EO filenames, minxs, maxxs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; minlats, maxlats, minlons, maxlons, bbwidths
;restore, '/Users/mapesgroup/CLOUDSAT/cloud_lists/Masterlist_Dec2010_filenames_minmaxlatlons.sav'
restore, '/Users/mapesgroup/CLOUDSAT/cloud_lists/Masterlist_Dec2010_filenames_minmaxxs.sav'
files = strmid(filenames, 0, 19)
wfiles = where(files eq shortname) ;;;Match swath names

;;;create minx, maxx sub-set
minx = minxs[wfiles]
maxx = maxxs[wfiles]

;;;Loop over each EO in the swath
;;;No mean profiles saved b/c need to check conv, status, H2Oprecision,
;;;and quality before making 
FOR iEO = 0, n_elements(wfiles) - 1 DO BEGIN

   convergence = convergences[minx[iEO]:maxx[iEO]]
   
   status      = statuss[minx[iEO]:maxx[iEO]]

   H2O         = H2Os[*, minx[iEO]:maxx[iEO]] ;[pressure, time]

   H2Oprecision  = H2Oprecisions[*, minx[iEO]:maxx[iEO]]; [pressure, time]

   quality     = qualitys[minx[iEO]:maxx[iEO]]

stop

wconv_bad   = where(convergence ge 2)    ;;must be less than 2
wstatus_bad = where(status mod 2 ne 0)   ;;must be an even number
wH2Oprecision_bad = where(H2Oprecision lt 0) ;;must be a positive number
wquality_bad    = where(quality lt 1.3)  ;;must be greater than 1.3

;;;Compute average H2O mixing ratio
IF wconv_bad[0] lt 0 and wstatus_bad[0] lt 0 and wprecision_bad[0] lt 0 and wquality_bad[0] lt 0 THEN BEGIN
   mean_H2O = total(H2O, 2)/(maxx[iEO] - minx[iEO] + 1)
ENDIF 

stop

save, file = '/Users/mapesgroup/CLOUDSAT/YOTC/MLS_H2O_EOfiles/'+shortname+'/'+filenames[wfiles[iEO]]+'.sav', $
      data.pressure, convergence, status, H2O, H2Oprecision, quality, mean_H2O

ENDFOR 

END 

