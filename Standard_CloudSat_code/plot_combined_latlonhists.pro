;;;;ER - Modified 3/30/2011, original is in
;;;;     /Users/mapesgroup/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/plot_combined_hists_latlon.pro 

pro plot_combined_latlonhists, minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon, $
                         hist_type = hist_type, group_name = group_name, ndays = ndays

land
!p.multi = [0, 2, 2]
device, file = 'plot_combined_IOlatlonhists_wland.ps'
;device, file = 'plot_combined_IOlatlonhists.ps'

;GROUP_NAME = ['IO_JJA', 'IO_SON', 'IO_DJF', 'IO_MAM']
ndays = [441, 447, 353, 356]

grand_hist = fltarr(121, 51)

GROUP_NAME = ['IO_JJA_wland', 'IO_SON_wland', 'IO_DJF_wland', 'IO_MAM_wland']
title_name = ['JJA', 'SON', 'DJF', 'MAM']

for igroup_name = 0, n_elements(group_name) -1 do begin
      
   restore, '~/CLOUDSAT/CLOUDSAT_CODE/Standard_Code/global_loops/combined_histograms/'+group_name[igroup_name]+'.latlonhist.sav'
   
   grand_hist = total_hist + grand_hist
   
   bin1 = 3   & bin2 = 3.6  
   lowlim1 = min(where(lonaxis ge minlon)) & uplim1 = max(where(lonaxis le maxlon))  
   lowlim2 = min(where(lataxis ge minlat)) & uplim2 = max(where(lataxis le maxlat))  
   xaxis = lonaxis & yaxis = lataxis
   xname = 'longitude' & yname = 'latitude'

   nboxes = n_elements(where(total_hist[lowlim1:uplim1, lowlim2:uplim2] gt 0))
   
   samples = 8.04 * 3.6 * 3 * ndays[igroup_name]
      
;   levels = findgen(21)*35000/20.
   levels = findgen(21) * 5

   EO_cover = (total_hist[lowlim1:uplim1, lowlim2:uplim2]/samples)*100
   
   hlp, EO_cover
   
   total_hist[where(total_hist eq 0)] = -999.
   contour, total_hist[lowlim1:uplim1, lowlim2:uplim2]/samples*100, xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
            title = title_name[igroup_name] , ythick = 6, xthick = 6, xtitle = xname, ytitle = yname
         
   map_world, /over, /cont,  c_thick = 10 ;limit = [minlat, minlon, maxlat, maxlon], c_thick = 4
      
endfor       

!p.multi = 0

samples = 8.04*3*3.6*total(ndays)
grand_hist[where(grand_hist eq 0)] = -999.

contour, grand_hist[lowlim1:uplim1, lowlim2:uplim2]/samples*100, xaxis[lowlim1:uplim1], yaxis[lowlim2:uplim2], /fill, levels = levels, $
         title = 'Yearly Avg' , ythick = 6, xthick = 6, xtitle = xname, ytitle = yname

map_world, /over, /cont,  c_thick = 10 ;limit = [minlat, minlon, maxlat, maxlon], c_thick = 4

MAKE_KEY, COLORS=findgen(n_elements(levels)) * !D.N_colors/n_elements(levels),  $
          labels = round_any([min(levels),(min(levels)+max(levels))/4.,(min(levels)+max(levels))/2.,(min(levels)+max(levels))*3/4.],sig=2), $
          units = '%'

psout
stop
end  





