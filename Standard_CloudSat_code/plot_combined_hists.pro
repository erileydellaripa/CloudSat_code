;;;;ER - Modified 3/30/2011, original is in
;;;;     /Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/plot_combined_hists_latlon.pro 

pro plot_combined_hists, minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon, $
                         hist_type = hist_type, group_name = group_name, ndays = ndays

land
;device, file= group_name + '_' + hist_type +'.ps'
device, file = 'plot_combined_IOhists_wland.ps'

HIST_TYPE = ['latlonhist', 'bottomtopshist', 'topslathist', 'timetopshist', 'timelathist', $
             'lontopshist', 'timelonhist']

;GROUP_NAME = ['IO_JJA', 'IO_SON', 'IO_DJF', 'IO_MAM']
GROUP_NAME = ['IO_JJA_wland', 'IO_SON_wland', 'IO_DJF_wland', 'IO_MAM_wland']

for igroup_name = 0, n_elements(group_name) -1 do begin
   for ihisttype = 0, n_elements(HIST_TYPE) -1 do begin
      
      restore, '~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/combined_histograms/'+group_name[igroup_name]+'.'+$
               hist_type[ihisttype]+'.sav'
      
      if hist_type[ihisttype] eq 'latlonhist'     then  begin 
         bin1 = 3   & bin2 = 3.6  
         lowlim1 = min(where(lonaxis ge minlon)) & uplim1 = max(where(lonaxis le maxlon))  
         lowlim2 = min(where(lataxis ge minlat)) & uplim2 = max(where(lataxis le maxlat))  
         xaxis = lonaxis & yaxis = lataxis
         xname = 'longitude' & yname = 'latitude'
      endif 
      
      if hist_type[ihisttype] eq 'bottomtopshist' then begin 
         bin1 = 240 & bin2 = 240
         lowlim1 = 0 & uplim1 = 83 ;n_elements(zaxis)-1
         lowlim2 = 0 & uplim2 = 83 ;n_elements(zaxis)-1 
         xaxis = zbaxis & yaxis = zaxis
         xname = 'base height (m)' & yname = 'top height (m)'
      endif 
      
      if hist_type[ihisttype] eq 'topslathist'    then begin 
         bin1 = 3   & bin2 = 240  
         lowlim1 = min(where(lataxis ge minlat)) & uplim1 = max(where(lataxis le maxlat))  
         lowlim2 = 0 & uplim2 = 83 ;n_elements(zaxis)-1  
         xaxis = lataxis & yaxis = zaxis
         xname = 'latitude' & yname = 'top height (m)'
      endif 
      
      if hist_type[ihisttype] eq 'timetopshist'   then begin
         bin1 = 10  & bin2 = 240  
         lowlim1 = 0 & uplim1 = n_elements(jdayaxis)-1  
         lowlim2 = 0 & uplim2 = 83 ;n_elements(zaxis)-1   
         xaxis = jdayaxis & yaxis = zaxis
         xname = 'jday (since 2006)' & yname = 'top height (m)'
      endif 
      
      if hist_type[ihisttype] eq 'timelathist'    then begin 
         bin1 = 10  & bin2 = 3.6  
         lowlim1 = 0 & uplim1 = n_elements(jdayaxis)-1  
         lowlim2 = min(where(lataxis ge minlat)) & uplim2 = max(where(lataxis le maxlat))   
         xaxis = jdayaxis & yaxis = lataxis 
         xname = 'jday (since 2006)' & yname = 'latitude'
      endif 
      
      if hist_type[ihisttype] eq 'lontopshist'    then begin
         bin1 = 3   & bin2 = 240  
         lowlim1 = min(where(lonaxis ge minlon)) & uplim1 = max(where(lonaxis le maxlon))  
         lowlim2 = 0 & uplim2 = 83 ;n_elements(zaxis)-1   
         xaxis = lonaxis & yaxis = zaxis 
         xname = 'longitude' & yname = 'top height (m)'
      endif 
      
      if hist_type[ihisttype] eq 'timelonhist'    then begin
         bin1 = 10  & bin2 = 3  
         lowlim1 = 0 & uplim1 = n_elements(jdayaxis)-1  
         lowlim2 = min(where(lonaxis ge minlon)) & uplim2 = max(where(lonaxis le maxlon)) 
         xaxis = jdayaxis & yaxis = lonaxis
         xname = 'jday (since 2006)' & yname = 'longitude'
      endif 
;ndays = 351 ;31+31+30
;samples = 8.04 * nlons * nlats *ndays
      
      if hist_type[ihisttype] eq 'bottomtopshist' then begin
         levels = [10, 50, 100, 500, 1000, 3000, 5000, 10000, 50000, 100000]
         contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
                  title = group_name[igroup_name] + ' ' + hist_type[ihisttype], ythick = 6, xthick = 6, xtitle = xname, ytitle = yname
         contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /over, levels = levels, $
                  c_annotation = ['.01', '.05', '.1', '.5', '1', '3', '5', '10', '50', '100'], c_thick = 5

      endif else begin
         levels = min(total_hist[lowlim1:uplim1, lowlim2:uplim2]) + findgen(21)/20.* $
                  (max(total_hist[lowlim1:uplim1, lowlim2:uplim2]) - min(total_hist[lowlim1:uplim1, lowlim2:uplim2]))
         
         total_hist[where(total_hist eq 0)] = -999.
         contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
                  title = group_name[igroup_name] + ' ' + hist_type[ihisttype], ythick = 6, xthick = 6, xtitle = xname, ytitle = yname
         
         if hist_type[ihisttype] eq 'latlonhist' then begin
            map_world, /over, /cont,  c_thick = 10 ;limit = [minlat, minlon, maxlat, maxlon], c_thick = 4
         endif 
         
         MAKE_KEY, COLORS=findgen(n_elements(levels)) * !D.N_colors/n_elements(levels),  $
                   labels = round_any([min(levels),(min(levels)+max(levels))/4.,(min(levels)+max(levels))/2.,(min(levels)+max(levels))*3/4.],sig=2)
      endelse 
   endfor 
endfor       

psout
stop
end  





