;;;ER 5/30/13
;;;Restores several histograms and combines them

pro combine_hists_EPac_ITCZ, HIST_TYPE=hist_type, GROUP_NAME=group_name, DIM1=dim1, DIM2=dim2

;latlonhist [234,61]
;bottomtopshist [102,102]
;topslathist [51, 102]
;widthtopshist [300, 102] ;;;Saved the normalized hist, hist2, & hist3 :(
;timetopshist [87, 102]
;timelathist [87, 51]

;total_hist = fltarr(dim1, dim2)

box1 = 'NEPac_ITCZ'
box2 = 'SEPac_ITCZ'

region_name = [box1, box2]
;region_name = [box2]

month_name = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', $
              'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

for imonth = 0, n_elements(month_name)-1 do begin
   total_hist = fltarr(dim1, dim2)

   for iregion = 0, n_elements(region_name)-1 do begin

      sample_name = region_name[iregion]+'.'+month_name[imonth]
      
      print, 'Sample_Name ', sample_name
      
      file = '~/CLOUDSAT/histograms_sav/'+ $    
             sample_name+'.'+hist_type+'.sav'
      
      command = 'restore, file'
      error   = execute(command)
      if (error eq 0) then goto, jump99 else $
         restore, file
      
      total_hist = hist2 + total_hist
      jump99:
   endfor 
   save, file= '~/CLOUDSAT/combined_hists/'+month_name[imonth]+'.ITCZ.'+ $
         hist_type + '.sav', total_hist, lataxis, lonaxis ; zaxis, zbaxis 
endfor 

;save, file= '~/CLOUDSAT/combined_hists/'+group_name+'.'+ $
;      hist_type+'.sav', total_CFAD, z_cfad, dbz_cfad ;zaxis, zbaxis ;lataxis, lonaxis
end 
