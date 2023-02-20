;;;ER 1/11/09
;;;Restores several histograms and combines them

pro combine_CFADs_EPac_ITCZ, CFAD_TYPE=cfad_type, GROUP_NAME=group_name, DIM1=dim1, DIM2=dim2, variable = variable

;Two options for cfad_type
;CFAD.sav
;withoverlaps.CFAD.sav, RESTORES THESE VARIABLE: totalCFAD, total_cloud_fraction,
;normocfad, normtotalcfad, ocfad, overlap_cloud_fraction,
;cloud_fraction, z_cfad, dBZ_cfad, bot_vs_top

;bot_vs_top [105,105]
;cloud_fraction = [85]
;CFADs = [76,85]

total_CFAD = fltarr(dim1, dim2)

box1 = 'NEPac_ITCZ'
box2 = 'SEPac_ITCZ'

region_name = [box1, box2]
;region_name = [box2]

month_name = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', $
              'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

for imonth = 0, n_elements(month_name)-1 do begin
   total_CFAD = fltarr(dim1, dim2)

   for iregion = 0, n_elements(region_name)-1 do begin

      sample_name = region_name[iregion]+'.'+month_name[imonth]
      
      print, 'Sample_Name ', sample_name
      
      file = '~/CLOUDSAT/CFADs_sav/'+ $    
             sample_name+'CFAD.sav'
      
      command = 'restore, file'
      error   = execute(command)
      if (error eq 0) then goto, jump99 else $
         restore, file
      
;                    total_CFAD = bot_vs_top + total_CFAD
      total_CFAD = CFAD + total_CFAD
      jump99:
   endfor 
   save, file= '~/CLOUDSAT/combined_CFADs/'+month_name[imonth]+'.ITCZ.'+ $
         'CFAD.sav', total_CFAD, z_cfad, dbz_cfad ;zaxis, zbaxis ;lataxis, lonaxis
endfor 

;save, file= '~/CLOUDSAT/combined_CFADs/'+group_name+'.'+ $
;      'CFAD.sav', total_CFAD, z_cfad, dbz_cfad ;zaxis, zbaxis ;lataxis, lonaxis
end 
