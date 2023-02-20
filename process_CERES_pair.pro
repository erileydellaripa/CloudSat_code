PRO process_CERES_pair, INFILE, INFILE2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Open and read INFILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PATH = '/Users/mapesgroup/CLOUDSAT/YOTC/YOTC_datasets/ceres/'
ceres_filename = infile
full_filepath = PATH + ceres_filename
shortname = strmid(ceres_filename, 6, 19)
spawn, 'mkdir /Users/mapesgroup/CLOUDSAT/YOTC/CERES_EOfiles/'+shortname
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

latitudes                                   = [data.latitude,  data_second.latitude[0:maxcloudwidths-1]]
longitudes                                  = [data.longitude, data_second.longitude[0:maxcloudwidths-1]]
CERES_LW_TOA_flux_upwardss                  = [data.CERES_LW_TOA_flux___upwards, data_second.CERES_LW_TOA_flux___upwards[0:maxcloudwidths-1]]
CERES_viewing_zenith_at_surfaces            = [data.CERES_viewing_zenith_at_surface, data_second.CERES_viewing_zenith_at_surface[0:maxcloudwidths-1]]
Radiance_and_Mode_flags                     = [data.Radiance_and_Mode_flags, data_second.Radiance_and_Mode_flags[0:maxcloudwidths-1]]
Altitude_of_surface_above_sea_levels        = [data.Altitude_of_surface_above_sea_level, data_second.Altitude_of_surface_above_sea_level[0:maxcloudwidths-1]]
CERES_SW_filtered_radiance_upwardss         = [data.CERES_SW_filtered_radiance___upwards, data_second.CERES_SW_filtered_radiance___upwards[0:maxcloudwidths-1]]
CERES_SW_ADM_type_for_inversion_processs    = [data.CERES_SW_ADM_type_for_inversion_process, data_second.CERES_SW_ADM_type_for_inversion_process[0:maxcloudwidths-1]]
CERES_solar_zenith_at_surfaces              = [data.CERES_solar_zenith_at_surface, data_second.CERES_solar_zenith_at_surface[0:maxcloudwidths-1]]
CERES_downward_WN_surface_flux_Model_As     = [data.CERES_downward_WN_surface_flux___Model_A, data_second.CERES_downward_WN_surface_flux___Model_A[0:maxcloudwidths-1]]
CERES_viewing_azimuth_at_surface_wrt_Norths = [data.CERES_viewing_azimuth_at_surface_wrt_North, data_second.CERES_viewing_azimuth_at_surface_wrt_North[0:maxcloudwidths-1]]
CERES_WN_radiance_upwardss                  = [data.CERES_WN_radiance___upwards, data_second.CERES_WN_radiance___upwards[0:maxcloudwidths-1]]
;Surface_type_indexs                         = [data.Surface_type_index, data_second.Surface_type_index[0:maxcloudwidths-1]]
CERES_TOT_filtered_radiance_upwardss        = [data.CERES_TOT_filtered_radiance___upwards, data_second.CERES_TOT_filtered_radiance___upwards[0:maxcloudwidths-1]]
CERES_relative_azimuth_at_surfaces          = [data.CERES_relative_azimuth_at_surface, data_second.CERES_relative_azimuth_at_surface[0:maxcloudwidths-1]]
CERES_net_SW_surface_flux_Model_Bs          = [data.CERES_net_SW_surface_flux___Model_B, data_second.CERES_net_SW_surface_flux___Model_B[0:maxcloudwidths-1]]
CERES_SW_TOA_flux_upwardss                  = [data.CERES_SW_TOA_flux___upwards, data_second.CERES_SW_TOA_flux___upwards[0:maxcloudwidths-1]]
CERES_downward_SW_surface_flux_Model_Bs     = [data.CERES_downward_SW_surface_flux___Model_B, data_second.CERES_downward_SW_surface_flux___Model_B[0:maxcloudwidths-1]]
CERES_downward_SW_surface_flux_Model_As     = [data.CERES_downward_SW_surface_flux___Model_A, data_second.CERES_downward_SW_surface_flux___Model_A[0:maxcloudwidths-1]]
CERES_WN_TOA_flux_upwardss                  = [data.CERES_WN_TOA_flux___upwards, data_second.CERES_WN_TOA_flux___upwards[0:maxcloudwidths-1]]
CERES_WN_surface_emissivitys                = [data.CERES_WN_surface_emissivity, data_second.CERES_WN_surface_emissivity[0:maxcloudwidths-1]]
CERES_WN_filtered_radiance_upwardss         = [data.CERES_WN_filtered_radiance___upwards, data_second.CERES_WN_filtered_radiance___upwards[0:maxcloudwidths-1]]
CERES_LW_ADM_type_for_inversion_processs    = [data.CERES_LW_ADM_type_for_inversion_process, data_second.CERES_LW_ADM_type_for_inversion_process[0:maxcloudwidths-1]]
CERES_LW_radiance_upwardss                  = [data.CERES_LW_radiance___upwards, data_second.CERES_LW_radiance___upwards[0:maxcloudwidths-1]]
;Surface_type_percent_coverages              = [data.Surface_type_percent_coverage, data_second.Surface_type_percent_coverage[0:maxcloudwidths-1]]
CERES_LW_surface_emissivitys                = [data.CERES_LW_surface_emissivity, data_second.CERES_LW_surface_emissivity[0:maxcloudwidths-1]]
CERES_net_LW_surface_flux_Model_As          = [data.CERES_net_LW_surface_flux___Model_A, data_second.CERES_net_LW_surface_flux___Model_A[0:maxcloudwidths-1]]
CERES_net_LW_surface_flux_Model_Bs          = [data.CERES_net_LW_surface_flux___Model_B, data_second.CERES_net_LW_surface_flux___Model_B[0:maxcloudwidths-1]]
CERES_net_SW_surface_flux_Model_As          = [data.CERES_net_SW_surface_flux___Model_A, data_second.CERES_net_SW_surface_flux___Model_A[0:maxcloudwidths-1]]
CERES_SW_radiance_upwardss                  = [data.CERES_SW_radiance___upwards, data_second.CERES_SW_radiance___upwards[0:maxcloudwidths-1]]
CERES_downward_LW_surface_flux_Model_Bs     = [data.CERES_downward_LW_surface_flux___Model_B, data_second.CERES_downward_LW_surface_flux___Model_B[0:maxcloudwidths-1]]
CERES_downward_LW_surface_flux_Model_As     = [data.CERES_downward_LW_surface_flux___Model_A, data_second.CERES_downward_LW_surface_flux___Model_A[0:maxcloudwidths-1]]
CERES_broadband_surface_albedos             = [data.CERES_broadband_surface_albedo, data_second.CERES_broadband_surface_albedo[0:maxcloudwidths-1]]

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

restore, '~/CLOUDSAT/YOTC/code/CERES_avgs.sav' ;;make blank arrays to be filled in initially in seperate code

;;;Loop over each EO in the swath
FOR iEO = 0, n_elements(wfiles) - 1 DO BEGIN

   latitude =  latitudes[minx[iEO]:maxx[iEO]]
   mean_latitude[wfiles[iEO]] = mean(latitude)
   longitude = longitudes[minx[iEO]:maxx[iEO]]
   mean_longitude[wfiles[iEO]] = mean(longitude)

   CERES_LW_TOA_flux_upwards =  CERES_LW_TOA_flux_upwardss[minx[iEO]:maxx[iEO]]
   CERES_LW_TOA_flux_upwards_avg[wfiles[iEO]] = mean(CERES_LW_TOA_flux_upwards)

   CERES_viewing_zenith_at_surface =  CERES_viewing_zenith_at_surfaces[minx[iEO]:maxx[iEO]]
   CERES_viewing_zenith_at_surface_avg[wfiles[iEO]] = mean(CERES_viewing_zenith_at_surface)

   Radiance_and_Mode_flag =  Radiance_and_Mode_flags[minx[iEO]:maxx[iEO]]

   Altitude_of_surface_above_sea_level =  Altitude_of_surface_above_sea_levels[minx[iEO]:maxx[iEO]]
   min_altitude = min( Altitude_of_surface_above_sea_levels[minx[iEO]:maxx[iEO]], MAX = max_altitude)
   
   CERES_SW_filtered_radiance_upwards =  CERES_SW_filtered_radiance_upwardss[minx[iEO]:maxx[iEO]]
   CERES_SW_filtered_radiance_upwards_avg[wfiles[iEO]] = mean(CERES_SW_filtered_radiance_upwards)

   CERES_SW_ADM_type_for_inversion_process =  CERES_SW_ADM_type_for_inversion_processs[minx[iEO]:maxx[iEO]]
   CERES_SW_ADM_type_for_inversion_process_avg[wfiles[iEO]] = mean(CERES_SW_ADM_type_for_inversion_process)

   CERES_solar_zenith_at_surface =  CERES_solar_zenith_at_surfaces[minx[iEO]:maxx[iEO]]
   CERES_solar_zenith_at_surface_avg[wfiles[iEO]] = mean(CERES_solar_zenith_at_surface)

   CERES_downward_WN_surface_flux_Model_A =  CERES_downward_WN_surface_flux_Model_As[minx[iEO]:maxx[iEO]]
   CERES_downward_WN_surface_flux_Model_A_avg[wfiles[iEO]] = mean(CERES_downward_WN_surface_flux_Model_A)

   CERES_viewing_azimuth_at_surface_wrt_North =  CERES_viewing_azimuth_at_surface_wrt_Norths[minx[iEO]:maxx[iEO]]
   CERES_viewing_azimuth_at_surface_wrt_North_avg[wfiles[iEO]] = mean(CERES_viewing_azimuth_at_surface_wrt_North)

   CERES_WN_radiance_upwards =  CERES_WN_radiance_upwardss[minx[iEO]:maxx[iEO]]
   CERES_WN_radiance_upwards_avg[wfiles[iEO]] = mean(CERES_WN_radiance_upwards)

;;;;Surface_type_index[8,37081]
;   Surface_type_index =  Surface_type_index[minx[iEO]:maxx[iEO]]
;   Surface_type_index_avg[wfiles[iEO]] = mean(Surface_type_index)

   CERES_TOT_filtered_radiance_upwards =  CERES_TOT_filtered_radiance_upwardss[minx[iEO]:maxx[iEO]]
   CERES_TOT_filtered_radiance_upwards_avg[wfiles[iEO]] = mean(CERES_TOT_filtered_radiance_upwards)

   CERES_relative_azimuth_at_surface =  CERES_relative_azimuth_at_surfaces[minx[iEO]:maxx[iEO]]
   CERES_relative_azimuth_at_surface_avg[wfiles[iEO]] = mean(CERES_relative_azimuth_at_surface)

   CERES_net_SW_surface_flux_Model_B =  CERES_net_SW_surface_flux_Model_Bs[minx[iEO]:maxx[iEO]]
   CERES_net_SW_surface_flux_Model_B_avg[wfiles[iEO]] = mean(CERES_net_SW_surface_flux_Model_B)

   CERES_SW_TOA_flux_upwards =  CERES_SW_TOA_flux_upwardss[minx[iEO]:maxx[iEO]]
   CERES_SW_TOA_flux_upwards_avg[wfiles[iEO]] = mean(CERES_SW_TOA_flux_upwards)

   CERES_downward_SW_surface_flux_Model_B =  CERES_downward_SW_surface_flux_Model_Bs[minx[iEO]:maxx[iEO]]
   CERES_downward_SW_surface_flux_Model_B_avg[wfiles[iEO]] = mean(CERES_downward_SW_surface_flux_Model_B)

   CERES_downward_SW_surface_flux_Model_A =  CERES_downward_SW_surface_flux_Model_As[minx[iEO]:maxx[iEO]]
   CERES_downward_SW_surface_flux_Model_A_avg[wfiles[iEO]] = mean(CERES_downward_SW_surface_flux_Model_A)

   CERES_WN_TOA_flux_upwards =  CERES_WN_TOA_flux_upwardss[minx[iEO]:maxx[iEO]]
   CERES_WN_TOA_flux_upwards_avg[wfiles[iEO]] = mean(CERES_WN_TOA_flux_upwards)

   CERES_WN_surface_emissivity =  CERES_WN_surface_emissivitys[minx[iEO]:maxx[iEO]]
   CERES_WN_surface_emissivity_avg[wfiles[iEO]] = mean(CERES_WN_surface_emissivity)

   CERES_WN_filtered_radiance_upwards =  CERES_WN_filtered_radiance_upwardss[minx[iEO]:maxx[iEO]]
   CERES_WN_filtered_radiance_upwards_avg[wfiles[iEO]] = mean(CERES_WN_filtered_radiance_upwards)

   CERES_LW_ADM_type_for_inversion_process =  CERES_LW_ADM_type_for_inversion_processs[minx[iEO]:maxx[iEO]]
   CERES_LW_ADM_type_for_inversion_process_avg[wfiles[iEO]] = mean(CERES_LW_ADM_type_for_inversion_process)

   CERES_LW_radiance_upwards =  CERES_LW_radiance_upwardss[minx[iEO]:maxx[iEO]]
   CERES_LW_radiance_upwards_avg[wfiles[iEO]] = mean(CERES_LW_radiance_upwards)

;;;;Surface_type_percent_coverage[8, 37081]
;   Surface_type_percent_coverage =  Surface_type_percent_coverage[minx[iEO]:maxx[iEO]]
;   Surface_type_percent_coverage_avg[wfiles[iEO]] = mean(Surface_type_percent_coverage)

   CERES_LW_surface_emissivity =  CERES_LW_surface_emissivitys[minx[iEO]:maxx[iEO]]
   CERES_LW_surface_emissivity_avg[wfiles[iEO]] = mean(CERES_LW_surface_emissivity)

   CERES_net_LW_surface_flux_Model_A =  CERES_net_LW_surface_flux_Model_As[minx[iEO]:maxx[iEO]]
   CERES_net_LW_surface_flux_Model_A_avg[wfiles[iEO]] = mean(CERES_net_LW_surface_flux_Model_A)

   CERES_net_LW_surface_flux_Model_B =  CERES_net_LW_surface_flux_Model_Bs[minx[iEO]:maxx[iEO]]
   CERES_net_LW_surface_flux_Model_B_avg[wfiles[iEO]] = mean(CERES_net_LW_surface_flux_Model_B)

   CERES_net_SW_surface_flux_Model_A =  CERES_net_SW_surface_flux_Model_As[minx[iEO]:maxx[iEO]]
   CERES_net_SW_surface_flux_Model_A_avg[wfiles[iEO]] = mean(CERES_net_SW_surface_flux_Model_A)

   CERES_SW_radiance_upwards =  CERES_SW_radiance_upwardss[minx[iEO]:maxx[iEO]]
   CERES_SW_radiance_upwards_avg[wfiles[iEO]] = mean(CERES_SW_radiance_upwards)

   CERES_downward_LW_surface_flux_Model_B =  CERES_downward_LW_surface_flux_Model_Bs[minx[iEO]:maxx[iEO]]
   CERES_downward_LW_surface_flux_Model_B_avg[wfiles[iEO]] = mean(CERES_downward_LW_surface_flux_Model_B)

   CERES_downward_LW_surface_flux_Model_A =  CERES_downward_LW_surface_flux_Model_As[minx[iEO]:maxx[iEO]]
   CERES_downward_LW_surface_flux_Model_A_avg[wfiles[iEO]] = mean(CERES_downward_LW_surface_flux_Model_A)

   CERES_broadband_surface_albedo =  CERES_broadband_surface_albedos[minx[iEO]:maxx[iEO]]
   CERES_broadband_surface_albedo_avg[wfiles[iEO]] = mean(CERES_broadband_surface_albedo)


save, file = '/Users/mapesgroup/CLOUDSAT/YOTC/CERES_EOfiles/'+shortname+'/'+filenames[wfiles[iEO]]+'.sav', CERES_LW_TOA_flux_upwards, CERES_viewing_zenith_at_surface, max_altitude, min_altitude, $
      CERES_SW_filtered_radiance_upwards, CERES_SW_ADM_type_for_inversion_process, CERES_solar_zenith_at_surface, CERES_downward_WN_surface_flux_Model_A, $
      CERES_viewing_azimuth_at_surface_wrt_North, CERES_WN_radiance_upwards, CERES_TOT_filtered_radiance_upwards, $
      CERES_relative_azimuth_at_surface, CERES_net_SW_surface_flux_Model_B, CERES_SW_TOA_flux_upwards, CERES_downward_SW_surface_flux_Model_B, $
      CERES_downward_SW_surface_flux_Model_A, CERES_WN_TOA_flux_upwards, CERES_WN_surface_emissivity, CERES_WN_filtered_radiance_upwards, $
      CERES_LW_ADM_type_for_inversion_process, CERES_LW_radiance_upwards, CERES_LW_surface_emissivity, $
      CERES_net_LW_surface_flux_Model_A, CERES_net_LW_surface_flux_Model_B, CERES_net_SW_surface_flux_Model_A, CERES_SW_radiance_upwards, $
      CERES_downward_LW_surface_flux_Model_B, CERES_downward_LW_surface_flux_Model_A, CERES_broadband_surface_albedo, Radiance_and_Mode_flag 

ENDFOR 

save, file = 'CERES_avgs.sav', CERES_LW_TOA_flux_upwards_avg, CERES_viewing_zenith_at_surface_avg, max_altitude, min_altitude, $
      CERES_SW_filtered_radiance_upwards_avg, CERES_SW_ADM_type_for_inversion_process_avg, CERES_solar_zenith_at_surface_avg, CERES_downward_WN_surface_flux_Model_A_avg, $
      CERES_viewing_azimuth_at_surface_wrt_North_avg, CERES_WN_radiance_upwards_avg, CERES_TOT_filtered_radiance_upwards_avg, $
      CERES_relative_azimuth_at_surface_avg, CERES_net_SW_surface_flux_Model_B_avg, CERES_SW_TOA_flux_upwards_avg, CERES_downward_SW_surface_flux_Model_B_avg, $
      CERES_downward_SW_surface_flux_Model_A_avg, CERES_WN_TOA_flux_upwards_avg, CERES_WN_surface_emissivity_avg, CERES_WN_filtered_radiance_upwards_avg, $
      CERES_LW_ADM_type_for_inversion_process_avg, CERES_LW_radiance_upwards_avg, CERES_LW_surface_emissivity_avg, $
      CERES_net_LW_surface_flux_Model_A_avg, CERES_net_LW_surface_flux_Model_B_avg, CERES_net_SW_surface_flux_Model_A_avg, CERES_SW_radiance_upwards_avg, $
      CERES_downward_LW_surface_flux_Model_B_avg, CERES_downward_LW_surface_flux_Model_A_avg, CERES_broadband_surface_albedo_avg, mean_latitude, mean_longitude

END 

;;;match ceres data to EO indices 
;dummy = min(abs(data.latitude - minlats[w_swath[iEO]]), index)
;dummy = min(abs(data.latitude - maxlats[w_swath[iEO]]), index2)
;indices = [index, index2]

;;;check width
;ceres_width = abs(index - mindex2 + 1)
;if ceres_width - bbwidths[w_swath[iEO]] ne 0 then STOP
;a = read_netcdf_gui(filename, variable_list = [var_list[0:13]])
;b = read_netcdf_gui(filename, variable_list = [var_list[14:25]])
;c = read_netcdf_gui(filename, variable_list = [var_list[26:33]])

