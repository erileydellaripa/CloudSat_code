;;;ER 1/11/09
;;;Restores several histograms and combines them

pro combine_CFADs_newTropicalBoxes, CFAD_TYPE=cfad_type, GROUP_NAME=group_name, DIM1=dim1, DIM2=dim2, SEASON = season

;Two options for cfad_type
;CFAD.sav
;withoverlaps.CFAD.sav, RESTORES THESE VARIABLE: totalCFAD, total_cloud_fraction,
;normocfad, normtotalcfad, ocfad, overlap_cloud_fraction,
;cloud_fraction, z_cfad, dBZ_cfad, bot_vs_top

;bot_vs_top [105,105]
;cloud_fraction = [85]
;CFADs = [76,85]

box1 = 'SWAfrica'
box2 = 'SWIO'
box3 = 'SEIO'
box4 = 'SWPac'
box5 = 'SEPac'
box6 = 'SAtl'
box7 = 'NWAfrica'
box8 = 'NWIO'
box9 = 'NEIO'
box10 = 'NWPac'
box11 = 'NEPac'
box12 = 'NEAtl'

region_name = [box2, box3, box8, box9]
;[box1, box2, box3, box4, box5, box6, box7, box8, box9, box10, box11, box12]
;[box5, box11]
;[box4, box10]
;
;[box1, box6, box7, box12] 
;

season_name = ['MAM'] ; ['JJA', 'SON', 'DJF', 'MAM'] ;

typename = ['cb','an','ci','cg','ac','sc','cu']

geo_typename = ['ocean'];, 'coast','low.land', 'high.land']

todname = ['am', 'pm']

total_CFAD = fltarr(dim1, dim2)

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
                    
                    ;total_CFAD = bot_vs_top + total_CFAD
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
