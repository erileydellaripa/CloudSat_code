;;;;ER - Modified 3/30/2011, original is in
;;;;     /Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/plot_combined_hists_lonlon.pro 

pro plot_combined_lontopshists2, minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon

!p.multi = [0, 2, 2]
land
device, file = 'plot_combined_IOlontopshists.ps'

GROUP_NAME = ['IO_JJA', 'IO_SON', 'IO_DJF', 'IO_MAM']
title_name = ['JJA', 'SON', 'DJF', 'MAM']
;GROUP_NAME = ['IO_JJA_wland', 'IO_SON_wland', 'IO_DJF_wland',
;'IO_MAM_wland']
grand_hist = fltarr(121, 102)

for igroup_name = 0, n_elements(group_name) -1 do begin
   restore, '~/Indian_Ocean/'+group_name[igroup_name]+'.lontopshist.sav'

   hlp, total_hist
   grand_hist = total_hist + grand_hist

   bin1 = 3   & bin2 = 240  
   lowlim1 = min(where(lonaxis ge minlon)) & uplim1 = max(where(lonaxis le maxlon))  
   lowlim2 = 0 & uplim2 = 83    ;n_elements(zaxis)-1  
   xaxis = lonaxis & yaxis = zaxis
   xname = 'longitude' & yname = 'top height (m)'
   
   levels = findgen(21)*18000/20.
   levels10 = findgen(11)*18000/10.

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

grand_hist = grand_hist/total(grand_hist)

!p.multi = [0, 2, 2]
for igroup_name = 0, n_elements(group_name) -1 do begin
   restore, '~/Indian_Ocean/'+group_name[igroup_name]+'.lontopshist.sav'

   total_hist = total_hist/total(total_hist)
   hlp, total_hist
   
   bin1 = 3   & bin2 = 240  
   lowlim1 = min(where(lonaxis ge minlon)) & uplim1 = max(where(lonaxis le maxlon))  
   lowlim2 = 0 & uplim2 = 83    ;n_elements(zaxis)-1  
   xaxis = lonaxis & yaxis = zaxis
   xname = 'longitude' & yname = 'top height (m)'
   
   diff = total_hist - grand_hist

   print, 'diff'
   hlp, diff*1000

   levels = 3*findgen(21)/20. - 1.5
   levels10 = 3*findgen(11)/10. - 1.5

   total_hist[where(total_hist eq 0)] = -999.
   contour, diff[lowlim1:uplim1, lowlim2:uplim2]*1000, xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
            title = title_name[igroup_name], ythick = 3, xthick = 3, xtitle = xname, ytitle = yname
endfor        

!p.multi = 0
contour, diff[lowlim1:uplim1, lowlim2:uplim2]*1000, xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
         title = title_name[3], ythick = 3, xthick = 3, xtitle = xname, ytitle = yname

MAKE_KEY, COLORS=findgen(n_elements(levels)) * !D.N_colors/n_elements(levels),  $
          labels = round_any([-1.5, -1.5/2., 0, 1.5/2.],sig=2), $
          units = '10!U-1!N% '

psout
stop
end  





