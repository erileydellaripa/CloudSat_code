;;;ER 1/11/09
;;;Restores several histograms and combines them

pro combine_CFADs, CFAD_TYPE=cfad_type, GROUP_NAME=group_name, DIM1=dim1, DIM2=dim2, variable = variable

;Two options for cfad_type
;CFAD.sav
;withoverlaps.CFAD.sav, RESTORES THESE VARIABLE: totalCFAD, total_cloud_fraction,
;normocfad, normtotalcfad, ocfad, overlap_cloud_fraction,
;cloud_fraction, z_cfad, dBZ_cfad, bot_vs_top

;bot_vs_top [105,105]
;cloud_fraction = [85]
;CFADs = [76,85]

total_CFAD = fltarr(dim1, dim2)

box1 = 'NW_PAC'
box2 = 'NE_Atlantic'
box3 = 'Europe'
box4 = 'Russia'
box5 = 'NH_subtrop_EPAC'
box6 = 'GoM_Atlantic'
box7 = 'NE_Africa'
box8 = 'NW_Africa'
box9 = 'Tibetan_Plateau'
box10 = 'NH_CE_PAC'
box11 = 'trop_Epac'
box12 = 'trop_atlantic'
box13 = 'Af_monsoon'
box14 = 'W_Africa'
box15 = 'Indian_monsoon'
box16 = 'WPAC_warmpool'
box17 = 'NH_CW_PAC'
box18 = 'SH_CE_PAC'
box19 = 'SH_EPAC'
box20 = 'E_SAmerica'
box21 = 'Namibian_sc_region'
box22 = 'SE_Africa'
box23 = 'SH_trop_Indian'
box24 = 'PNG'
box25 = 'SH_CW_PAC'
box26 = 'SH_subtrop_EPAC'
box27 = 'SH_subtrop_Atlantic'
box28 = 'SH_Indian'
box29 = 'Australia'
box30 = 'SE_PAC'
box31 = 'S_Atlantic'
box32 = 'S_Indian'
box33 = 'S_WPAC'
box34 = 'Antarctica'
box35 = 'Arctic'

;region_name = [box10, box18]
;region_name = [box10, box11, box18, box19] ;& group_name = 'EPAC'
;region_name = [box12, box13, box20, box21] ;& group_name = 'Tropical_Atlantic'
;region_name = [box14, box15, box22, box23] ;& group_name = 'tropical_Indian'
;region_name = [box16, box17, box24, box25] ;& group_name = 'WPAC_warmpool'

;region_name = [box11, box12, box19, box20]; Amazon
;region_name = [box13, box14, box21, box22]; Congo
;region_name = [box15, box16, box23, box24]; Maritime continent

region_name = [box10, box11, box12, box13, box14, box15, box16, box17, $
               box18, box19, box20, box21, box22, box23, box24, box25] ;TROPICS

;region_name = [box1, box2, box3, box4, box5, box6, box7, box8, box9, $
;               box10, box11, box12, box13, box14, box15, box16, box17, $
;               box18, box19, box20, box21, box22, box23, box24, box25, $
;               box26, box27, box28, box29, box30, box31, box32, box33, $
;               box34, box35] ;All boxes

;region_name = [box5, box6, box7, box8, box9, box26, box27, box28, box29] ;subtropics
;region_name = [box1, box2, box3, box4, box30, box31, box32, box33] ;Mid-lats

;region_name = [box34, box35] ;High-lats
season_name = ['JJA06', 'SON06', 'DJF0607', 'MAM07', 'JJA07', 'SON07', $
               'DJF0708', 'MAM08'];, 'JJA08']

;season_name =['JJA07', 'SON07', 'DJF0708', 'MAM08']

typename = ['cb'];,'an','ci','cg','ac','sc','cu']

;geo_typename = ['ocean', 'low.land', 'high.land']
;geo_typename = ['coast'] All coastal EOs went into Land
;geo_typename = ['low.land', 'high.land']
geo_typename = ['ocean']

todname = ['am', 'pm']

for iregion = 0, n_elements(region_name)-1 do begin
    for iseason = 0, n_elements(season_name)-1 do begin
        for icloud = 0, n_elements(typename)-1 do begin
            for igeo = 0, n_elements(geo_typename)-1 do begin
                for itod = 0, n_elements(todname)-1 do begin 

                    sample_name = region_name[iregion]+'.'+season_name[iseason]+'.'+typename[icloud]+ $
                      '.'+geo_typename[igeo]+'.'+todname[itod]

                    print, 'Sample_Name ', sample_name
                    
                    file = '/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/CFADs.sav/'+ $    
                      sample_name+CFAD_type+'.sav'

                    command = 'restore, file'
                    error   = execute(command)
                    if (error eq 0) then goto, jump99 else $
                      restore, file
                    
;                    total_CFAD = bot_vs_top + total_CFAD
                    total_CFAD = CFAD + total_CFAD
                jump99:
                endfor 
            endfor 
        endfor 
    endfor
endfor

save, file= '/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/combined_CFADs/'+group_name+'.'+ $
  CFAD_type+'.sav', total_CFAD, z_cfad, dbz_cfad;zaxis, zbaxis ;lataxis, lonaxis

end 
