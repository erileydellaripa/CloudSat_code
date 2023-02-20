PRO process_MODIS_cloud1km_pair, INFILE, INFILE2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PATH = '/Users/mapesgroup/CLOUDSAT/YOTC/YOTC_datasets/modis_cloud_1km/'
modis_cloud1km_filename = infile
full_filepath = PATH + modis_cloud1km_filename
shortname = strmid(modis_cloud1km_filename, 8, 19)
print, 'swath name: ', shortname
spawn, 'mkdir /Users/mapesgroup/CLOUDSAT/YOTC/MODIS_cloud1km_EOfiles/'+shortname
read_ncdf, full_filepath, data, /attrib ;returns data structure

openw, 1, '~/CLOUDSAT/YOTC/MLS_lists/'+shortname+'.list'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modis_cloud1km_filename2 = infile2
full_filepath2 = PATH + modis_cloud1km_filename2
read_ncdf, full_filepath2, data_second, /attrib ;returns data_second structure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;APPEND FILES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
maxcloudwidths = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2
;;;no need to read in latitude and longitude for every dataset
;latitudes   = [data.latitude,data_second.latitude[0:maxcloudwidths-1]] 
;longitudes  = [data.longitude, data_second.longitude[0:maxcloudwidths-1]]


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

wconv_bad   = where(convergence ge 2)    ;;must be less than 2
wstatus_bad = where(status mod 2 ne 0)   ;;must be an even number
wH2Oprecision_bad = where(H2Oprecision[6:39, *] lt 0) ;;must be a positive number, 0:5 pressure-1000 to 380mb and 40:* are always negative!
wquality_bad    = where(quality lt 1.3)  ;;must be greater than 1.3

;;;Compute average H2O mixing ratio if all the variables are valid
IF wconv_bad[0] lt 0 and wstatus_bad[0] lt 0 and wH2Oprecision_bad[0] lt 0 and wquality_bad[0] lt 0 THEN BEGIN   
   ;if iEO is wider than 1 pixel....
   IF maxx[iEO] - minx[iEO] gt 0 THEN BEGIN 
      mean_H2O = total(H2O[6:39, *], 2)/(maxx[iEO] - minx[iEO] + 1)
   ENDIF ELSE BEGIN ;;if iEO is only 1 pixel wide...
      mean_H2O = H2O[6:39]
   ENDELSE 
ENDIF ELSE BEGIN ;;write out each filename that doesnot have a saved mean_h2o profile, so will avoid fetching for statistics
   printf, 1, filenames[wfiles[iEO]]
ENDELSE 

save, file = '/Users/mapesgroup/CLOUDSAT/YOTC/MODIS_cloud1km_EOfiles/'+shortname+'/'+filenames[wfiles[iEO]]+'.sav', $
      pressure, convergence, status, H2O, H2Oprecision, quality, mean_H2O

ENDFOR 
close, 1
END 

