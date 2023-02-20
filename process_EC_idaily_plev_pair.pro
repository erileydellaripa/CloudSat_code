PRO process_EC_idaily_plev_pair, INFILE, INFILE2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PATH = '/Volumes/User/eriley/CLOUDSAT/YOTC/YOTC_datasets/ecmwf_plevels/'
ecmwf_filename = infile
full_filepath = PATH + ecmwf_filename
shortname = strmid(ecmwf_filename, 26, 19)
spawn, 'mkdir /Volumes/User/eriley/CLOUDSAT/YOTC/ecmwf_plev_EOfiles/'+shortname
read_ncdf, full_filepath, data, /attrib ;returns data structure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ecmwf_filename2 = infile2
full_filepath2 = PATH + ecmwf_filename2
read_ncdf, full_filepath2, data_second, /attrib ;returns data_second structure

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;APPEND FILES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
maxcloudwidths = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2

;;;;;;;;;;!!!!!MAY HAVE TO TRANSPOSE DATA!!!!;;;;;;;;;;;;;;;
latitudes  = [data.latitude,  data_second.latitude[0:maxcloudwidths-1]]
longitudes = [data.longitude, data_second.longitude[0:maxcloudwidths-1]]
pres_levels = data.lv_ISBL0
ciwcs = [transpose(data.CIWC_GDS4_ISBL), transpose(data_second.CIWC_GDS4_ISBL[*, 0:maxcloudwidths-1])]
RHs   = [transpose(data.R_GDS4_ISBL),    transpose(data_second.R_GDS4_ISBL[*, 0:maxcloudwidths-1])]
qs    = [transpose(data.Q_GDS4_ISBL),    transpose(data_second.Q_GDS4_ISBL[*, 0:maxcloudwidths-1])]
ws    = [transpose(data.W_GDS4_ISBL),    transpose(data_second.W_GDS4_ISBL[*, 0:maxcloudwidths-1])]
clwcs = [transpose(data.CLWC_GDS4_ISBL), transpose(data_second.CLWC_GDS4_ISBL[*, 0:maxcloudwidths-1])]
ccs   = [transpose(data.CC_GDS4_ISBL),   transpose(data_second.CC_GDS4_ISBL[*, 0:maxcloudwidths-1])]
pvs   = [transpose(data.PV_GDS4_ISBL),   transpose(data_second.PV_GDS4_ISBL[*, 0:maxcloudwidths-1])]
vs    = [transpose(data.V_GDS4_ISBL),    transpose(data_second.V_GDS4_ISBL[*, 0:maxcloudwidths-1])]
us    = [transpose(data.U_GDS4_ISBL),    transpose(data_second.U_GDS4_ISBL[*, 0:maxcloudwidths-1])]
Vorts = [transpose(data.VO_GDS4_ISBL),   transpose(data_second.VO_GDS4_ISBL[*, 0:maxcloudwidths-1])]
geops = [transpose(data.Z_GDS4_ISBL),    transpose(data_second.Z_GDS4_ISBL[*, 0:maxcloudwidths-1])]
temps = [transpose(data.T_GDS4_ISBL),    transpose(data_second.T_GDS4_ISBL[*, 0:maxcloudwidths-1])]
divs  = [transpose(data.D_GDS4_ISBL),    transpose(data_second.D_GDS4_ISBL[*, 0:maxcloudwidths-1])]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Restore EO filenames, minxs, maxxs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; minlats, maxlats, minlons, maxlons, bbwidths
;restore, '/Users/mapesgroup/CLOUDSAT/cloud_lists/Masterlist_Dec2010_filenames_minmaxlatlons.sav'
restore, '/Volumes/User/eriley/CLOUDSAT/cloud_lists/Masterlist_Dec2010_filenames_minmaxxs.sav'
files = strmid(filenames, 0, 19)
wfiles = where(files eq shortname) ;;;Match swath names

;;;create minx, maxx sub-set
minx = minxs[wfiles]
maxx = maxxs[wfiles]

;restore, '~/CLOUDSAT/YOTC/code/ECMWF_avgs.sav' ;;make blank arrays to be filled in initially in seperate code
;stop
;;;Loop over each EO in the swath
FOR iEO = 0, n_elements(wfiles) - 1 DO BEGIN

   ciwc        = CIWCs[minx[iEO]:maxx[iEO], *]
   mean_ciwc   = total(ciwc, 1)/(maxx[iEO] - minx[iEO] + 1)

   RH = RHs[minx[iEO]:maxx[iEO], *]
   mean_RH = total(RH, 1)/(maxx[iEO] - minx[iEO] + 1)

   q = qs[minx[iEO]:maxx[iEO], *]
   mean_q = total(q, 1)/(maxx[iEO] - minx[iEO] + 1)

   w = ws[minx[iEO]:maxx[iEO], *]
   mean_w = total(w, 1)/(maxx[iEO] - minx[iEO] + 1)

   clwc = clwcs[minx[iEO]:maxx[iEO], *]
   mean_clwc = total(clwc, 1)/(maxx[iEO] - minx[iEO] + 1)

   cc = ccs[minx[iEO]:maxx[iEO], *]
   mean_cc = total(cc, 1)/(maxx[iEO] - minx[iEO] + 1)

   pv = pvs[minx[iEO]:maxx[iEO], *]
   mean_pv = total(pv, 1)/(maxx[iEO] - minx[iEO] + 1)

   v = vs[minx[iEO]:maxx[iEO], *]
   mean_v = total(v, 1)/(maxx[iEO] - minx[iEO] + 1)

   u = us[minx[iEO]:maxx[iEO], *]
   mean_u = total(u, 1)/(maxx[iEO] - minx[iEO] + 1)

   vort = vorts[minx[iEO]:maxx[iEO], *]
   mean_vort = total(vort, 1)/(maxx[iEO] - minx[iEO] + 1)

   geop = geops[minx[iEO]:maxx[iEO], *]
   mean_geop = total(geop, 1)/(maxx[iEO] - minx[iEO] + 1)

   temp = temps[minx[iEO]:maxx[iEO], *]
   mean_temp = total(temp, 1)/(maxx[iEO] - minx[iEO] + 1)

   div = divs[minx[iEO]:maxx[iEO], *]
   mean_div = total(div, 1)/(maxx[iEO] - minx[iEO] + 1)

   save, file = '/Volumes/User/eriley/CLOUDSAT/YOTC/ecmwf_plev_EOfiles/'+shortname+'/'+filenames[wfiles[iEO]]+'.sav', $
         mean_ciwc, mean_RH, mean_q, mean_w, mean_clwc, mean_cc, mean_pv, mean_u, mean_v, mean_vort, mean_geop, mean_temp, $
         mean_div, pres_levels
ENDFOR 

;save, file = 'ECMWF_avgs.sav', mean_SST, mean_vapor, mean_WSPD, mean_cloud,  mean_rain

END 

