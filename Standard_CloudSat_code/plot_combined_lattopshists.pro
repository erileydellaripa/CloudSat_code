;;;;ER - Modified 3/30/2011, original is in
;;;;     /Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/plot_combined_hists_latlon.pro 

pro plot_combined_lattopshists, minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon

!p.multi = [0, 2, 2]
land
device, file = 'plot_combined_IOlattopshists.ps'

GROUP_NAME = ['IO_JJA', 'IO_SON', 'IO_DJF', 'IO_MAM']
title_name = ['JJA', 'SON', 'DJF', 'MAM']
;GROUP_NAME = ['IO_JJA_wland', 'IO_SON_wland', 'IO_DJF_wland',
;'IO_MAM_wland']
grand_hist = fltarr(51, 102)

for igroup_name = 0, n_elements(group_name) -1 do begin
   restore, '~/Indian_Ocean/'+group_name[igroup_name]+'.topslathist.sav'

   hlp, total_hist
   grand_hist = total_hist + grand_hist

   bin1 = 3   & bin2 = 240  
   lowlim1 = min(where(lataxis ge minlat)) & uplim1 = max(where(lataxis le maxlat))  
   lowlim2 = 0 & uplim2 = 83    ;n_elements(zaxis)-1  
   xaxis = lataxis & yaxis = zaxis
   xname = 'latitude' & yname = 'top height (m)'
   
   levels = findgen(21)*67000/20.
   levels10 = findgen(11)*67000/10.

   total_hist[where(total_hist eq 0)] = -999.
   contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
            title = title_name[igroup_name], ythick = 3, xthick = 3, xtitle = xname, ytitle = yname
endfor        
!p.multi = 0
contour, total_hist[lowlim1:uplim1, lowlim2:uplim2], xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
         title = title_name[3], ythick = 6, xthick = 6, xtitle = xname, ytitle = yname

MAKE_KEY, COLORS=findgen(n_elements(levels)) * !D.N_colors/n_elements(levels),  $
          labels = round_any([min(levels),(min(levels)+max(levels))/4.,(min(levels)+max(levels))/2.,(min(levels)+max(levels))*3/4.]/1000,sig=2), $
          units = '10!U3!N hor pix'

Grand_hist = grand_hist/total(grand_hist)

!p.multi = [0, 2, 2]
for igroup_name = 0, n_elements(group_name) -1 do begin
   restore, '~/Indian_Ocean/'+group_name[igroup_name]+'.topslathist.sav'

   total_hist = total_hist/total(total_hist)
   hlp, total_hist
   
   bin1 = 3   & bin2 = 240  
   lowlim1 = min(where(lataxis ge minlat)) & uplim1 = max(where(lataxis le maxlat))  
   lowlim2 = 0 & uplim2 = 83    ;n_elements(zaxis)-1  
   xaxis = lataxis & yaxis = zaxis
   xname = 'latitude' & yname = 'top height (m)'
   
   diff = total_hist - grand_hist

   print, 'diff'
   hlp, diff*1000

   levels = 5*findgen(21)/20. - 2.5
   levels10 = 5*findgen(11)/10. - 2.5

   total_hist[where(total_hist eq 0)] = -999.
   contour, diff[lowlim1:uplim1, lowlim2:uplim2]*1000, xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
            title = title_name[igroup_name], ythick = 3, xthick = 3, xtitle = xname, ytitle = yname
endfor        

!p.multi = 0
contour, diff[lowlim1:uplim1, lowlim2:uplim2]*1000, xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
         title = title_name[3], ythick = 3, xthick = 3, xtitle = xname, ytitle = yname

MAKE_KEY, COLORS=findgen(n_elements(levels)) * !D.N_colors/n_elements(levels),  $
          labels = round_any([-2.5, -2.5/2., 0, 2.5/2.],sig=2), $
          units = '10!U-1!N% '

psout
end  





