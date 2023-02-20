; This routine reads a ECMWF-AUX file specified by infile name plus
; the next one which is spliced at the end to avoid equatorial edge
; effects. 
;;;Created 12/01/2007 by ER following process_two_orbits.pro
;;;Modified 2/18/2008 by ER, removed 'round' in front of  p_avg =
;;;total(pslab,1)/float(maxx[i] - minx[i] + 1)
;;;but it doeesn't change the sounding by much at all, not a
;;;significant amount.

;;;;Initially save precip_and_convsf_fraction.sav with all -999. array
;;;;outside of this program. Then simply restore the arrays and fill
;;;;them in, then re-save for each call to this program.
;precip_frac_possible = fltarr(n_elements(minlats)) - 999.
;precip_frac_probable = fltarr(n_elements(minlats)) - 999.
;precip_frac_certain  = fltarr(n_elements(minlats)) - 999.

;conv_precip_frac    = fltarr(n_elements(minlats)) - 999.
;sf_precip_frac      = fltarr(n_elements(minlats)) - 999.
;shallow_precip_frac = fltarr(n_elements(minlats)) - 999.

;save, file='~/CLOUDSAT/cloud_lists/precip_and_convsf_fraction.sav', precip_frac_possible, precip_frac_probable, $
;      precip_frac_certain, conv_precip_frac, sf_precip_frac, shallow_precip_frac


pro process_PRECIP_COLUMN_orbit_pair, indir, infile, infile2

maxcloudwidth = 2000 ;;;how much a cloud may overhang from orbit 1 into orbit 2

shortname = strmid(infile,0,19)
swathname = '2C-PRECIP-COLUMN'
print, infile, ' shortname ', shortname
;spawn, 'mkdir ~/CLOUDSAT/cloud_precip_info_from_PRECIP-COLUMN/'+shortname
spawn, 'mkdir ~/CLOUDSAT/cloud_precip_info_from_PRECIP-COLUMN_minx_maxx_corrected/'+shortname
;----------------------------------------------- Read data

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile, /READ)
print,'file ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
print,'swath ',swathid

;;;; Read the data fields we want and name them sensibly
;;;; the  sounding data
status = EOS_SW_READFIELD(swathid, 'Data_quality', data_quality)
if( status lt 0) then print, 'Read Error'
;;;;I dont' think I should used cloud_flag since it determines
;;;;whether a significant cloud is present or not, where a cloud is
;;;;deemed significant if the 2B-GEOPROF cloud mask is 30 or 40 and
;;;;has a reflectivity corrected for gaseous attenuation of at least
;;;;-15 dBZ. We had used a cloud mask between 20-40 with the edges
;;;;(last 5 profiles) of the orbit were assigned a mask of 30 if the
;;;;geseous attenuated corrected dBZ was GE -25 (see
;;;;process_orbit_pair_Feb10.pro) 
status = EOS_SW_READFIELD(swathid, 'Cloud_flag', cloud_flag)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Precip_flag', precip_flag)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Precip_rate', precip_rate)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Conv_strat_flag', convsf_flag)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Rain_top_height', rain_topkm)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Status_flag', stat_flag)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Surface_type', sfc_type)
if( status lt 0) then print, 'Read Error'

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

;;;; Read the data fields we want and name them sensibly
;;;; the  sounding data
status = EOS_SW_READFIELD(swathid, 'Data_quality', data_quality2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Cloud_flag', cloud_flag2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Precip_flag', precip_flag2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Precip_rate', precip_rate2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Conv_strat_flag', convsf_flag2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Rain_top_height', rain_topkm2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Status_flag', stat_flag2)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Surface_type', sfc_type2)
if( status lt 0) then print, 'Read Error'

print, 'done reading in 2nd file'

;;;; OK, done getting what we neeed from file, close it
status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

;---------------------------------Append Files
data_quality = [data_quality, data_quality[0:maxcloudwidth-1]]
cloud_flag   = [cloud_flag, cloud_flag[0:maxcloudwidth-1]]
precip_flag  = [precip_flag, precip_flag[0:maxcloudwidth-1]]
precip_rate  = [precip_rate, precip_rate[0:maxcloudwidth-1]]
convsf_flag  = [convsf_flag, convsf_flag[0:maxcloudwidth-1]]
rain_topkm   = [rain_topkm, rain_topkm[0:maxcloudwidth-1]]
stat_flag    = [stat_flag, stat_flag[0:maxcloudwidth-1]]
sfc_type     = [sfc_type, sfc_type[0:maxcloudwidth-1]]

print, '**done concatinating  files***'
;---------------------------------Find clouds, make sounding
;;;;Restore MASTERLIST_R04 to get maxxs & minxxs, no need to recreate
;;;;them. 
restore, '~/CLOUDSAT/cloud_lists/Masterlist_2013.sav'

files     = strmid(filenames, 0,19)
wfiles    = where(files eq shortname)
file      = files[wfiles]
minx      = minxs[wfiles]
maxx      = maxxs[wfiles]
bbwidth   = bbwidths[wfiles]
filename = filenames[wfiles]

print, '***done restoring list and finding files***'

;PATH = '/Volumes/silverbullet/cloud_pixels_Feb10/'
PATH = '~/CLOUDSAT/cloud_pixels_April17/'

;restore, '~/CLOUDSAT/cloud_lists/precip_and_convsf_fraction.sav'
restore, '~/CLOUDSAT/cloud_lists/precip_and_convsf_fraction_minx_maxx_corrected.sav'

;;;loop over clouds and determine fraction of cloud that is raining
;;;bbwidth = maxx-minx+1 ;;; units: pixels
for i=0L, n_elements(wfiles)-1 do begin
   
   data_quality_slab = data_quality[minx[i]:maxx[i]]
   precip_flag_slab  = precip_flag[minx[i]:maxx[i]]
   precip_rate_slab  = precip_rate[minx[i]:maxx[i]]
   convsf_flag_slab  = convsf_flag[minx[i]:maxx[i]]
   stat_flag_slab    = stat_flag[minx[i]:maxx[i]]
   sfc_type_slab     = sfc_type[minx[i]:maxx[i]]

   w_precip_possible                 = where(precip_flag_slab GT 0 AND precip_flag_slab LT 9, count_possible)

   w_rain_probable_snw_mixed_certain = where(precip_flag_slab EQ 2 OR $
                                             precip_flag_slab EQ 5 OR $
                                             precip_flag_slab EQ 7, count_probable)

   w_precip_certain                  = where(precip_flag_slab EQ 3 OR $
                                             precip_flag_slab EQ 5 OR $
                                             precip_flag_slab EQ 7, count_certain)

   w_conv_precip    = where(convsf_flag_slab EQ 1, count_conv)
   w_strat_precip   = where(convsf_flag_slab EQ 2, count_sf)
   w_shallow_precip = where(convsf_flag_slab EQ 3, count_shallow)
   
   print, filename[i]
   print, 'count_possible =', count_possible
   print, 'count_probable =', count_probable
   print, 'count_certain =', count_certain

   ;;;;Check to see if there is an EO underneath the current EO. IF
   ;;;;so, it should be assinged the precipitation of the column and
   ;;;;not the current EO.
   IF count_possible GT 0 THEN BEGIN
      restore, PATH + file[i] + '/'+filename[i] + '.sav'

      unique_xcloud    = unique(xcloud, /sort)      ;basically creating a 1D array of x-positions
      unique_xover     = unique(xoverlapped, /sort) ;basically creating a 1D array of x-positions

      ;*********************POSSIBLE PRECIP PROFILES*********************************;
      ;;;Can just do a histogram of unique_xover and
      ;;;unique_xcloud[w_precip_possible] since that would say where
      ;;;there is both EO overlap AND precipitation all in one step
      ;;;instead of the two step i originally was using
      h_xover_with_precip_poss = histogram([unique_xover, unique_xcloud[w_precip_possible]], binsize = 1, min = min(unique_xcloud), $
                                            max = max(unique_xcloud), locations = xlocation)
      w_overlap_and_precip_poss= where(h_xover_with_precip_poss GT 1, count_over_and_precip_poss) 
      ;using unique_xcloud (above) for min and max bin positions, since it's
      ;overlap with the current EO that we're interested in. Note,
      ;unique_xcloud and unique_xover may not have the exact same min and
      ;max x positons for reasons that are not clear to me.

      IF count_over_and_precip_poss GT 0 THEN BEGIN
         ;;;loop through each x_profile/column that has overlap to
         ;;;determine if current cloud is lowest. If current cloud is
         ;;;the lowest in the column, then assign precip to it,
         ;;;otherwise skip it and precip will be assigned when looking
         ;;;at overlapped EO
         xvalue_wover_precip_poss = unique_xcloud[w_overlap_and_precip_poss]
         
         FOR iprofile = 0, count_over_and_precip_poss - 1 DO BEGIN
            wx_poss           = where(xcloud EQ xvalue_wover_precip_poss[iprofile])
            zmax_xcloud_poss  = max(zcloud[wx_poss])

            wx_over_poss      = where(xoverlapped EQ xvalue_wover_precip_poss[iprofile])
            ;looking at just the max height of the overlapped cloud may not work as
            ;there could be overlapping cloud both under and over the current EO cloud.
            ;Need to look at entire column of overlapped cloud and see if there is
            ;at least a cloud underneath the EO of interest.
            ;zmax_xover_precip_poss = max(zoverlapped[wx_over_poss]) 
            w_cloud_underneath= where(zoverlapped[wx_over_poss] LT zmax_xcloud_poss, count_underneath)
               
            IF count_underneath GT 0 THEN BEGIN
               w_rain_under = where(w_precip_possible EQ w_overlap_and_precip_poss[iprofile])
               w_precip_possible[w_rain_under] = -999.
            ENDIF 
         ENDFOR ;;;iprofile loop

         ;;;eliminate -999s from w_precip_possible array
         wgood = where(w_precip_possible GT -99, count_good)
         IF count_good GT 0 THEN BEGIN
            w_precip_possible = w_precip_possible[wgood]

            ;;redefine count possible given some precip profiles may
            ;;have been eliminated from original count
            count_possible = count_good
         ENDIF ELSE BEGIN;count_good GT 0
            count_possible = 0  ;if get here means there were raining profiles from original where statement above, but all came from cloud underneath current EO
         ENDELSE
      ENDIF ;count_over_and_precip_poss GT 0

      ;*********************PROBABLE PRECIP & CERTAIN SNW & MIXED PROFILES*********************************;
      ;***Need to also check count_probable and count_certain but stay within
      ;count_probalbe IF statement so won't have to restore pixel file again
      IF count_probable GT 0 THEN BEGIN
         h_xover_with_precip_prob = histogram([unique_xover, unique_xcloud[w_rain_probable_snw_mixed_certain]], binsize = 1, min = min(unique_xcloud), $
                                              max = max(unique_xcloud), locations = xlocation)
         w_overlap_and_precip_prob= where(h_xover_with_precip_prob GT 1, count_over_and_precip_prob) 

         IF count_over_and_precip_prob GT 0 THEN BEGIN
       
            xvalue_wover_precip_prob = unique_xcloud[w_overlap_and_precip_prob]
            
            FOR iprofile = 0, count_over_and_precip_prob - 1 DO BEGIN
               wx_prob           = where(xcloud EQ xvalue_wover_precip_prob[iprofile])
               zmax_xcloud_prob  = max(zcloud[wx_prob])
               
               wx_over_prob      = where(xoverlapped EQ xvalue_wover_precip_prob[iprofile])
               w_cloud_underneath= where(zoverlapped[wx_over_prob] LT zmax_xcloud_prob, count_underneath)
               
               IF count_underneath GT 0 THEN BEGIN
                  w_rain_under = where(w_rain_probable_snw_mixed_certain EQ w_overlap_and_precip_prob[iprofile])
                   w_rain_probable_snw_mixed_certain[w_rain_under] = -999.
               ENDIF 
            ENDFOR ;;;iprofile loop
            
            ;;;eliminate -999s from w_rain_probable_snw_mixed_certain array
            wgood = where(w_rain_probable_snw_mixed_certain GT -99, count_good)
            IF count_good GT 0 THEN BEGIN
               w_rain_probable_snw_mixed_certain = w_rain_probable_snw_mixed_certain[wgood]
               
               ;;redefine count probable given some precip profiles may
               ;;have been eliminated from original count
               count_probable = count_good
            ENDIF ELSE BEGIN            ;count_good GT 0
               count_probable = 0  ;if get here means there were raining profiles from original where statement above, but all came from cloud underneath current EO
            ENDELSE 

         ENDIF ;;count_over_and_precip_prob GT 0
      ENDIF    ;;count_probable IF statement 
      
      ;*********************CERTAIN PRECIP PROFILES*********************************;
      ;***Need to also check count_probable and count_certain but stay within
      ;count_probalbe IF statement so won't have to restore pixel file again
      IF count_certain GT 0 THEN BEGIN
         h_xover_with_precip_certain = histogram([unique_xover, unique_xcloud[w_precip_certain]], binsize = 1, min = min(unique_xcloud), $
                                              max = max(unique_xcloud), locations = xlocation)
         w_overlap_and_precip_certain= where(h_xover_with_precip_certain GT 1, count_over_and_precip_certain) 

         IF count_over_and_precip_certain GT 0 THEN BEGIN
       
            xvalue_wover_precip_certain = unique_xcloud[w_overlap_and_precip_certain]
            
            FOR iprofile = 0, count_over_and_precip_certain - 1 DO BEGIN
               wx_certain           = where(xcloud EQ xvalue_wover_precip_certain[iprofile])
               zmax_xcloud_certain  = max(zcloud[wx_certain])
               
               wx_over_certain      = where(xoverlapped EQ xvalue_wover_precip_certain[iprofile])
               w_cloud_underneath= where(zoverlapped[wx_over_certain] LT zmax_xcloud_certain, count_underneath)
               
               IF count_underneath GT 0 THEN BEGIN
                  w_rain_under = where(w_precip_certain EQ w_overlap_and_precip_certain[iprofile])
                  w_precip_certain[w_rain_under] = -999.
               ENDIF 
            ENDFOR ;;;iprofile loop
            
            ;;;eliminate -999s from w_rain_certain_snw_mixed_certain array
            wgood = where(w_precip_certain GT -99, count_good)
            IF count_good GT 0 THEN BEGIN
               w_precip_certain = w_precip_certain[wgood]
               
               ;;redefine count certain given some precip profiles may
               ;;have been eliminated from original count
               count_certain = count_good
            ENDIF ELSE BEGIN            ;count_good GT 0
               count_certain = 0  ;if get here means there were raining profiles from original where statement above, but all came from cloud underneath current EO
            ENDELSE 

         ENDIF  ;;count_over_and_precip_certain GT 0
      ENDIF     ;;count_certain IF statement 

      ;*********************CONVECTIVE PROFILES*********************************;
      ;***Need to also check conv, sf, shallow distinction but stay within
      ;count_probalbe IF statement so won't have to restore pixel file again

      ;;;Do I have to do the above for w_conv_precip, w_strat_precip
      ;;;and w_shallow_precip? Or can I just ajdust the conv, sf,
      ;;;shallow as I adjust the precip profiles? Only need to do
      ;;;conv, sf, shallow separately if it's possible to have
      ;;;a profiel assigned conv, sf, shallow and not have possible or
      ;;;certain precip. To be safe, just go through above code for
      ;;;each type of rain.
      IF count_conv GT 0 THEN BEGIN
         h_xover_with_precip_conv = histogram([unique_xover, unique_xcloud[w_conv_precip]], binsize = 1, min = min(unique_xcloud), $
                                              max = max(unique_xcloud), locations = xlocation)
         w_overlap_and_precip_conv= where(h_xover_with_precip_conv GT 1, count_over_and_precip_conv) 

         IF count_over_and_precip_conv GT 0 THEN BEGIN
       
            xvalue_wover_precip_conv = unique_xcloud[w_overlap_and_precip_conv]
            
            FOR iprofile = 0, count_over_and_precip_conv - 1 DO BEGIN
               wx_conv           = where(xcloud EQ xvalue_wover_precip_conv[iprofile])
               zmax_xcloud_conv  = max(zcloud[wx_conv])
               
               wx_over_conv      = where(xoverlapped EQ xvalue_wover_precip_conv[iprofile])
               w_cloud_underneath= where(zoverlapped[wx_over_conv] LT zmax_xcloud_conv, count_underneath)
               
               IF count_underneath GT 0 THEN BEGIN
                  w_rain_under = where(w_conv_precip EQ w_overlap_and_precip_conv[iprofile])
                  w_conv_precip[w_rain_under] = -999.
               ENDIF 
            ENDFOR ;;;iprofile loop
            
            ;;;eliminate -999s from w_rain_certain_snw_mixed_certain array
            wgood = where(w_conv_precip GT -99, count_good)
            IF count_good GT 0 THEN BEGIN
               w_conv_precip = w_conv_precip[wgood]
               
               ;;redefine count certain given some precip profiles may
               ;;have been eliminated from original count
               count_conv = count_good
            ENDIF ELSE BEGIN            ;count_good GT 0
               count_conv = 0  ;if get here means there were raining profiles from original where statement above, but all came from cloud underneath current EO
            ENDELSE 

         ENDIF  ;;count_over_and_precip_conv GT 0
      ENDIF     ;;count_conv IF statement 

      ;********************STRATIFORM PROFILES*********************************;
      ;***Need to also check conv, sf, shallow distinction but stay within
      ;count_probalbe IF statement so won't have to restore pixel file again
      IF count_sf GT 0 THEN BEGIN
         h_xover_with_precip_sf = histogram([unique_xover, unique_xcloud[w_strat_precip]], binsize = 1, min = min(unique_xcloud), $
                                              max = max(unique_xcloud), locations = xlocation)
         w_overlap_and_precip_sf= where(h_xover_with_precip_sf GT 1, count_over_and_precip_sf) 

         IF count_over_and_precip_sf GT 0 THEN BEGIN
       
            xvalue_wover_precip_sf = unique_xcloud[w_overlap_and_precip_sf]
            
            FOR iprofile = 0, count_over_and_precip_sf - 1 DO BEGIN
               wx_sf           = where(xcloud EQ xvalue_wover_precip_sf[iprofile])
               zmax_xcloud_sf  = max(zcloud[wx_sf])
               
               wx_over_sf      = where(xoverlapped EQ xvalue_wover_precip_sf[iprofile])
               w_cloud_underneath= where(zoverlapped[wx_over_sf] LT zmax_xcloud_sf, count_underneath)
               
               IF count_underneath GT 0 THEN BEGIN
                  w_rain_under = where(w_strat_precip EQ w_overlap_and_precip_sf[iprofile])
                  w_strat_precip[w_rain_under] = -999.
               ENDIF 
            ENDFOR ;;;iprofile loop
            
            ;;;eliminate -999s from w_rain_certain_snw_mixed_certain array
            wgood = where(w_strat_precip GT -99, count_good)
            IF count_good GT 0 THEN BEGIN
               w_strat_precip = w_strat_precip[wgood]
               
               ;;redefine count certain given some precip profiles may
               ;;have been eliminated from original count
               count_sf = count_good
            ENDIF ELSE BEGIN            ;count_good GT 0
               count_sf = 0  ;if get here means there were raining profiles from original where statement above, but all came from cloud underneath current EO
            ENDELSE 

         ENDIF  ;;count_over_and_precip_sf GT 0
      ENDIF     ;;count_sf IF statement 

      ;********************SHALLOW PROFILES*********************************;
      ;***Need to also check conv, sf, shallow distinction but stay within
      ;count_probalbe IF statement so won't have to restore pixel file again
      IF count_shallow GT 0 THEN BEGIN
         h_xover_with_precip_shallow = histogram([unique_xover, unique_xcloud[w_shallow_precip]], binsize = 1, min = min(unique_xcloud), $
                                              max = max(unique_xcloud), locations = xlocation)
         w_overlap_and_precip_shallow= where(h_xover_with_precip_shallow GT 1, count_over_and_precip_shallow) 

         IF count_over_and_precip_shallow GT 0 THEN BEGIN
       
            xvalue_wover_precip_shallow = unique_xcloud[w_overlap_and_precip_shallow]
            
            FOR iprofile = 0, count_over_and_precip_shallow - 1 DO BEGIN
               wx_shallow           = where(xcloud EQ xvalue_wover_precip_shallow[iprofile])
               zmax_xcloud_shallow  = max(zcloud[wx_shallow])
               
               wx_over_shallow      = where(xoverlapped EQ xvalue_wover_precip_shallow[iprofile])
               w_cloud_underneath= where(zoverlapped[wx_over_shallow] LT zmax_xcloud_shallow, count_underneath)
               
               IF count_underneath GT 0 THEN BEGIN
                  w_rain_under = where(w_shallow_precip EQ w_overlap_and_precip_shallow[iprofile])
                  w_shallow_precip[w_rain_under] = -999.
               ENDIF 
            ENDFOR ;;;iprofile loop
            
            ;;;eliminate -999s from w_rain_certain_snw_mixed_certain array
            wgood = where(w_shallow_precip GT -99, count_good)
            IF count_good GT 0 THEN BEGIN
               w_shallow_precip = w_shallow_precip[wgood]
               
               ;;redefine count certain given some precip profiles may
               ;;have been eliminated from original count
               count_shallow = count_good
            ENDIF ELSE BEGIN            ;count_good GT 0
               count_shallow = 0  ;if get here means there were raining profiles from original where statement above, but all came from cloud underneath current EO
            ENDELSE 

         ENDIF  ;;count_over_and_precip_shallow GT 0
      ENDIF     ;;count_shallow IF statement 


   ENDIF ;;;count_possible if statment
      
   print, 'count_possible =', count_possible
   print, 'count_probable =', count_probable
   print, 'count_certain =', count_certain

   ;;;;compute precip fraction
;   IF w_precip_possible[0] GE 0 THEN precip_fraction_possible = count_possible/float(bbwidth[i]) ELSE precip_fraction_possible = -777.
   IF count_possible GT 0 THEN precip_fraction_possible = count_possible/float(bbwidth[i]) ELSE precip_fraction_possible = -777.
   IF count_probable GT 0 THEN precip_fraction_probable = count_probable/float(bbwidth[i]) ELSE precip_fraction_probable = -777.
   IF count_certain  GT 0 THEN precip_fraction_certain  = count_certain /float(bbwidth[i]) ELSE precip_fraction_certain = -777.

   IF count_conv    GT 0 THEN conv_precip_fraction     = count_conv/float(bbwidth[i])    ELSE conv_precip_fraction  = -777.
   IF count_sf      GT 0 THEN strat_precip_fraction    = count_sf  /float(bbwidth[i])    ELSE strat_precip_fraction = -777.
   IF count_shallow GT 0 THEN shallow_precip_fraction  = count_shallow/float(bbwidth[i]) ELSE shallow_precip_fraction = -777.

   precip_frac_possible[wfiles[i]] = precip_fraction_possible
   precip_frac_probable[wfiles[i]] = precip_fraction_probable
   precip_frac_certain[wfiles[i]]  = precip_fraction_certain

   conv_precip_frac[wfiles[i]]     = conv_precip_fraction
   sf_precip_frac[wfiles[i]]       = strat_precip_fraction
   shallow_precip_frac[wfiles[i]]  = shallow_precip_fraction

;;;If want to keep track of profile positions of each EO that have
;;;rain, need to save where information for each EO
;   IF count_possible GT 0 OR $
;      count_probable GT 0 OR $
;      count_certain  GT 0 OR $
;      count_conv     GT 0 OR $
;      count_sf       GT 0 OR $
;      count_shallow  GT 0 THEN BEGIN 

;   save, file='~/CLOUDSAT/cloud_precip_info_from_PRECIP-COLUMN/'+shortname+'/'+filenames[wfiles[i]]+'_where_in_xcloud_array_is_precip.sav', $
;         w_precip_possible, w_rain_probable_snw_mixed_certain, w_precip_certain, w_conv_precip, $
;         w_strat_precip, w_shallow_precip


   save, file='~/CLOUDSAT/cloud_precip_info_from_PRECIP-COLUMN_minx_maxx_corrected/'+shortname+'/'+filenames[wfiles[i]]+'_where_in_xcloud_array_is_precip.sav', $
         w_precip_possible, w_rain_probable_snw_mixed_certain, w_precip_certain, w_conv_precip, $
         w_strat_precip, w_shallow_precip
   
endfor   ;; end i loop over clouds

;save, file='~/CLOUDSAT/cloud_lists/precip_and_convsf_fraction.sav', precip_frac_possible, precip_frac_probable, $
;      precip_frac_certain, conv_precip_frac, sf_precip_frac, shallow_precip_frac

save, file='~/CLOUDSAT/cloud_lists/precip_and_convsf_fraction_minx_maxx_corrected.sav', precip_frac_possible, precip_frac_probable, $
      precip_frac_certain, conv_precip_frac, sf_precip_frac, shallow_precip_frac

stop

end

;      h_xcloud_xover   = histogram([unique_xcloud, unique_xover], binsize = 1, min = min(unique_xcloud), max = max(unique_xcloud), $
;                                   locations = xlocation)
;
;find where there is overlap and surface precipitation, but first
;check to make sure the arrays are the same size
;      diff_check       = n_elements(h_xcloud_xover) - n_elements(precip_flag_slab)
;
;      IF diff_check EQ 0 THEN BEGIN
;         w_xpos_overlap   = where(h_xcloud_xover GT 1, count) 
;
            ;;Find where EOs are both overlapped and there is rain in
            ;;the column
;            h_xpos_overlap_and_possible_rain = histogram([w_xpos_overlap, w_precip_possible], binsize = 1)
;            w_two_raining_clouds             = where(h_xpos_overlap_and_possible_rain GT 1)
;            
;   ENDIF ELSE BEGIN ;;diff_check EQ 0
;         print, 'Array elements not the same size'
;         STOP
;      ENDELSE 
