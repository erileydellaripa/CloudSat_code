;;;;ER - Modified 3/30/2011, original is in
;;;;     /Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/plot_combined_hists_latlon.pro 

pro plot_combined_bottomtopshists, minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon, $
                         hist_type = hist_type, group_name = group_name, ndays = ndays

!p.multi = [0, 2, 2]

land
device, file = 'plot_combined_IObottomtopshists.ps'

GROUP_NAME = ['IO_JJA', 'IO_SON', 'IO_DJF', 'IO_MAM']
title_name = ['JJA', 'SON', 'DJF', 'MAM']

;GROUP_NAME = ['IO_JJA_wland', 'IO_SON_wland', 'IO_DJF_wland', 'IO_MAM_wland']

for igroup_name = 0, n_elements(group_name) -1 do begin
   restore, '~/Indian_Ocean/'+group_name[igroup_name]+'.bottomtopshist.sav'
   
   bin1 = 240 & bin2 = 240
   lowlim1 = 0 & uplim1 = 83       ;n_elements(zaxis)-1
   lowlim2 = 0 & uplim2 = 83       ;n_elements(zaxis)-1 
   xaxis = zbaxis & yaxis = zaxis
   xname = 'base height (m)' & yname = 'top height (m)'
   
   levels = [10, 50, 100, 500, 1000, 3000, 5000, 10000, 50000, 100000]
   contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
            title = title_name[igroup_name] , ythick = 3, xthick = 3, xtitle = xname, ytitle = yname
   contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /over, levels = levels, $
            c_annotation = ['.01', '.05', '.1', '.5', '1', '3', '5', '10', '50', '100'], c_thick = 4, c_charsize = .7
endfor       

psout
end  





