;ERD 6/14/208
;Follows process_PRECIP_COLUMN_orbit_pair_minx_maxx_corrected.pro

pro process_MOD_AUX1km_orbit_pair, indir, infile, infile2

maxcloudwidth = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2

shortname = strmid(infile,0,19)
swathname = 'MOD06-1KM-AUX'
print, infile, ' shortname ', shortname
spawn, 'mkdir ~/CLOUDSAT/cloud_precip_info_from_PRECIP-COLUMN_GEOPROF_reprocessed/'+shortname
;----------------------------------------------- Read data

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile, /READ)
print,'file ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
print,'swath ',swathid

;;;;Read the data fields we want and name them sensibly
;;;;The variables of intereset have dimensions [15, nray], where the
;;;;15 is the 3x5 MODIS pixels nearest the CloudSat track. vector 8
;;;;(or in IDL world, 7) is the pixel closest to the CPR footprint, so
;;;;maybe I should just use that pixel.
;;;;See
;;;;http://www.cloudsat.cira.colostate.edu/sites/default/files/products/files/MOD06-AUX_PDICD.P1_R05.rev0_.pdf
;;;;for more information
status = EOS_SW_READFIELD(swathid, 'Cloud_top_pressure_1km', Cloud_top_pressure)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_pressure_1km_scale_factor', Cloud_top_pressure_scale_factor)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_pressure_1km_add_offset', Cloud_top_pressure_offset)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_height_1km', Cloud_top_height)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_height_1km_scale_factor', Cloud_top_height_scale_factor)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_height_1km_add_offset', Cloud_top_height_offset)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_temperature_1km', Cloud_top_temp)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_temperature_1km_scale_factor', Cloud_top_temp_scale_factor)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_temperature_1km_add_offset', Cloud_top_temp_offset)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_Optical_Thickness', Cloud_tau)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_Optical_Thickness_scale_factor', Cloud_tau_scale_factor)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_Optical_Thickness_add_offset', Cloud_tau_offset)
if( status lt 0) then print, 'Read Error'

;;;The cloud_top_temp_scale_factor and/or cloud_top_temp_offset do not
;;;seem to be correct. They give unphysical cloud_top_temp values. I
;;;checked several files and the temps all have values on the order of
;;;5000 to 15000 with a scale factor or 0.009999 and offset of -15000.

print, 'done reading in 1st file'

;;;; OK, done getting what we neeed from file, close it
status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

;---------------Read data - 2 (to append)
;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile2, /READ)
print,'file2 ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
print,'swath2 ',swathid

if fid lt 0 then stop

status = EOS_SW_READFIELD(swathid, 'Cloud_top_pressure_1km', Cloud_top_pressure2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_pressure_1km_scale_factor', Cloud_top_pressure_scale_factor2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_pressure_1km_add_offset', Cloud_top_pressure_offset2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_height_1km', Cloud_top_height2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_height_1km_scale_factor', Cloud_top_height_scale_factor2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_height_1km_add_offset', Cloud_top_height_offset2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_temperature_1km', Cloud_top_temp2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_temperature_1km_scale_factor', Cloud_top_temp_scale_factor2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_top_temperature_1km_add_offset', Cloud_top_temp_offset2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_Optical_Thickness', Cloud_tau2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_Optical_Thickness_scale_factor', Cloud_tau_scale_factor2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_Optical_Thickness_add_offset', Cloud_tau_offset2)
if( status lt 0) then print, 'Read Error'

print, 'done reading in 2nd file'

;;;; OK, done getting what we neeed from file, close it
status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

;;;;Padd appended files with 0 to start since GEOPROF varialbes were
;padded with a 0 to correct for label_region issue. This insures that
;minx and maxx are in the same array location for the GEOPROF data and
;these new varialbes.
;---------------------------------Append Files
cloud_flag   = [0, cloud_flag, cloud_flag2[0:maxcloudwidth-1]]
precip_flag  = [0, precip_flag, precip_flag2[0:maxcloudwidth-1]]
precip_rate  = [0, precip_rate, precip_rate2[0:maxcloudwidth-1]]
convsf_flag  = [0, convsf_flag, convsf_flag2[0:maxcloudwidth-1]]
rain_topkm   = [0, rain_topkm, rain_topkm2[0:maxcloudwidth-1]]
stat_flag    = [0, stat_flag, stat_flag2[0:maxcloudwidth-1]]
sfc_type     = [0, sfc_type, sfc_type2[0:maxcloudwidth-1]]
