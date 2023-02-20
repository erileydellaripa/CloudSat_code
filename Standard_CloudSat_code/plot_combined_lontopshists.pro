;;;;ER - Modified 3/30/2011, original is in
;;;;     /Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/plot_combined_hists_latlon.pro 

pro plot_combined_lontopshists, minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon

land
device, file = 'plot_combined_IOlontopshists.ps'

GROUP_NAME = ['IO_JJA', 'IO_SON', 'IO_DJF', 'IO_MAM']
;GROUP_NAME = ['IO_JJA_wland', 'IO_SON_wland', 'IO_DJF_wland', 'IO_MAM_wland']

for igroup_name = 0, n_elements(group_name) -1 do begin
   restore, '~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/combined_histograms/'+group_name[igroup_name]+'.lontopshist.sav'
   hlp, total_hist

   bin1 = 3   & bin2 = 240  
   lowlim1 = min(where(lonaxis ge minlon)) & uplim1 = max(where(lonaxis le maxlon))  
   lowlim2 = 0 & uplim2 = 83    ;n_elements(zaxis)-1   
   xaxis = lonaxis & yaxis = zaxis 
   xname = 'longitude' & yname = 'top height (m)'
   
;   levels = findgen(21)*25000/20.
   levels = findgen(21)*18000/20.

   total_hist[where(total_hist eq 0)] = -999.
   contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
            title = group_name[igroup_name] + ' lon-tops hist', ythick = 6, xthick = 6, xtitle = xname, ytitle = yname
   
   MAKE_KEY, COLORS=findgen(n_elements(levels)) * !D.N_colors/n_elements(levels),  $
             labels = round_any([min(levels),(min(levels)+max(levels))/4.,(min(levels)+max(levels))/2.,(min(levels)+max(levels))*3/4.]/1000.,sig=2), $
             units = '10!U3! hor pix'
   
endfor       

psout
end  





