;;;ER 3/30/11
;;;Restores several histograms and combines them

pro combine_hists_NewTropicalBoxes, HIST_TYPE=hist_type, GROUP_NAME=group_name, DIM1=dim1, DIM2=dim2, $
                                    SEASON = season, TYPENAME = typename

;latlonhist [121,51]
;bottomtopshist [102,102]
;topslathist [51, 102]
;widthtopshist [300, 102] ;;;Saved the normalized hist, hist2, & hist3 :(
;timetopshist [87, 102]
;timelathist [87, 51]

total_hist = fltarr(dim1, dim2)

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
box12 = 'NAtl'

region_name = [box2, box3, box8, box9]

season_name = season

typename = ['cb','an','ci','cg','ac','sc','cu']

geo_typename = ['ocean', 'coast','low.land', 'high.land']

todname = ['am', 'pm']

for iregion = 0, n_elements(region_name)-1 do begin
    for iseason = 0, n_elements(season_name)-1 do begin
        for icloud = 0, n_elements(typename)-1 do begin
            for igeo = 0, n_elements(geo_typename)-1 do begin
                for itod = 0, n_elements(todname)-1 do begin 

                    sample_name = region_name[iregion]+'.'+season_name[iseason]+'.'+typename[icloud]+ $
                      '.'+geo_typename[igeo]+'.'+todname[itod]

                    print, 'Sample_Name ', sample_name
                    
                    file = '/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/histograms/'+ $                                     
                      sample_name+'.'+hist_type+'.sav'

                    command = 'restore, file'
                    error   = execute(command)
                    if (error eq 0) then goto, jump99 else $
                      restore, file
                    
                    total_hist = hist2 + total_hist

                jump99:
                endfor 
            endfor 
        endfor 
    endfor
endfor

save, file= '/Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/combined_histograms/'+group_name+'.'+ $
  hist_type+'.sav', total_hist, lataxis, lonaxis,  zaxis, zbaxis, jdayaxis

end 
