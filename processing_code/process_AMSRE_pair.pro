PRO process_AMSRE_pair, INFILE, INFILE2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PATH = '/Users/mapesgroup/CLOUDSAT/YOTC/YOTC_datasets/amsr/'
ceres_filename = infile
full_filepath = PATH + ceres_filename
shortname = strmid(ceres_filename, 6, 19)
spawn, 'mkdir /Users/mapesgroup/CLOUDSAT/YOTC/AMSRE_EOfiles/'+shortname
read_ncdf, full_filepath, data, /attrib ;returns data structure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ceres_filename2 = infile2
full_filepath2 = PATH + ceres_filename2
read_ncdf, full_filepath2, data_second, /attrib ;returns data_second structure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;APPEND FILES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
maxcloudwidths = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2

latitudes  = [data.latitude,  data_second.latitude[0:maxcloudwidths-1]]
longitudes = [data.longitude, data_second.longitude[0:maxcloudwidths-1]]
SSTs       = [data.SST, data_second.SST[0:maxcloudwidths-1]
vapors     = [data.vapor, data_second.vapor[0:maxcloudwidths-1]
WSPDs      = [data.WSPD, data_second.WSPD[0:maxcloudwidths-1]
clouds     = [data.cloud, data_second.cloud[0:maxcloudwidths-1]
rains      = [data.rain, data_second.rain[0:maxcloudwidths-1]
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

restore, '~/CLOUDSAT/YOTC/code/AMSRE_avgs.sav' ;;make blank arrays to be filled in initially in seperate code

;;;Loop over each EO in the swath
FOR iEO = 0, n_elements(wfiles) - 1 DO BEGIN

   latitude =  latitudes[minx[iEO]:maxx[iEO]]
   mean_latitude[wfiles[iEO]] = mean(latitude)

   longitude = longitudes[minx[iEO]:maxx[iEO]]
   mean_longitude[wfiles[iEO]] = mean(longitude)

   SST        = SSTs[minx[iEO]:max[iEO]]
   mean_SST   = mean(SST)

   vapor      = vapors[minx[iEO]:maxx[iEO]]
   mean_vapor = mean(vapor)
   
   WSPD      = WSPDs[minx[iEO]:maxx[iEO]]
   mean_WSPD = mean(WSPD)

   cloud     = clouds[minx[iEO]:maxx[iEO]]
   mean_cloud= mean(cloud)

   rain      = rains[minx[iEO]:maxx[iEO]]
   mean_rain = mean(rain)

save, file = '/Users/mapesgroup/CLOUDSAT/YOTC/AMSRE_EOfiles/'+shortname+'/'+filenames[wfiles[iEO]]+'.sav', $
      latitude, longitude, SST, vapor, WSPD, cloud, rain
ENDFOR 

save, file = 'AMSRE_avgs.sav', mean_latitude, mean_longitude, mean_SST, mean_vapor, mean_WSPD, mean_cloud, $
      mean_rain

END 

