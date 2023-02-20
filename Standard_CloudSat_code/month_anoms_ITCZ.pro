PRO GO

land
;device, file = 'month_anoms_NEPac_ITCZ.eps'
;device, file = 'month_anoms_SEPac_ITCZ.eps'
device, file = 'month_anoms_EPac_ITCZ.eps'
device, xsize = 26, ysize = 18
!p.multi = [0, 4, 3]
;restore, '~/CLOUDSAT/combined_CFADs/all_NEPac_ITCZ.CFAD.sav'
;restore, '~/CLOUDSAT/combined_CFADs/all_SEPac_ITCZ.CFAD.sav'
restore, '~/CLOUDSAT/combined_CFADs/all_EPac_ITCZ.CFAD.sav'
all_year_CFAD = total_cfad
norm_tot_CFAD = all_year_cfad/total(all_year_cfad)

month_name = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', $
              'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
label = ['(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', $
         '(i)', '(j)', '(k)', '(l)']

box1 = 'NEPac_ITCZ'
box2 = 'SEPac_ITCZ'

region_name = [box1, box2]
;region_name = [box1]

levels = -5 + findgen(21)/2.
;levels = -20 + findgen(21)*2
Load_ctbl, '~/IDL_PROGRAMS/PK_blueredanom.tbl'

;for iregion = 0, n_elements(region_name)-1 do begin
   for imonth = 0, n_elements(month_name)-1 do begin
      
;      sample_name = region_name[iregion]+'.'+month_name[imonth]
      sample_name =month_name[imonth]+'.ITCZ.'
      
      print, 'Sample_Name ', sample_name
      
      file = '~/CLOUDSAT/combined_CFADs/'+ $    
             sample_name+'CFAD.sav'

;      file = '~/CLOUDSAT/CFADs_sav/'+ $    
;             sample_name+'CFAD.sav'
      
      command = 'restore, file'
      error   = execute(command)
      if (error eq 0) then goto, jump99 else $
         restore, file
      
      anom_CFAD = total_cfad/total(total_cfad) - all_year_CFAD/total(all_year_CFAD)
;      anom_CFAD = cfad/total(cfad) - all_year_CFAD/total(all_year_CFAD)
      
      contour, anom_CFAD*10000., dbz_cfad, z_cfad/1000., /fill, levels = levels, $
               title = label[imonth] + ' '+ month_name[imonth], $
               xtitle = 'dBz', ytitle = 'height (km)', xthick = 3, ythick = 3, charsize = 1.2, $
               yrange = [0, 18], xrange = [-35, 20]
      contour, norm_tot_cfad*10000, dbz_cfad, z_cfad/1000., levels = findgen(12), /over, c_thick = 3

jump99:
      
   endfor 
;endfor 

colorbar, colors = levels*(!D.N_colors)/20., bottoms = 0, divisions = 4, $ ;format = '(f4.1)', $
          range = [levels[0], levels[20]], /vertical,  position = [.01, .35, .02, .65], title = '10!U-4!N%', $
          charsize = 1.4

psout
;stop
end

