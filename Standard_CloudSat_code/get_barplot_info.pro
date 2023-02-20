;;;The code catorgorizes EOs into arrays by [longitude bin, time of
;;;day, EO type] to be used in another code "plot_barplot_info.pro" to
;;;produce barplots of EOs by type and longitude bin
;;;
;;;- Specify number of longitude bins and bin widths and lat/lon
;;;constraints
;;;
;;;- Input DAYS: may be either jdays from start of CloudSat (in that
;;;  case input jdays from cloudsat_jdays.sav (jdays 166 - 1793)) OR
;;;  jdays for each year to get seasonal barplot info, (in that case input
;;;  calendar_jdays from EO_seasons.sav (calendar_jdays 1 - 365)
;;;
;;;Emily Riley - 06/01/2012 (modified from
;;;              get_barplot_info_WHphases_18lonboxes_Dec2010masterlist_pinwheelphases.pro)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro get_barplot_info, NBINS = nbins, BINWIDTH = binwidth, MIN_LON = min_lon, MAX_LON = max_lon,$
                      MIN_LAT = min_lat, MAX_LAT = max_lat, MIN_JDAY = min_jday, $
                      MAX_JDAY = max_jday, DAYS = days, SUBSET_NAME = subset_name

;;;restore master list
restore, '~/CLOUDSAT/cloud_lists/Masterlist_Dec2010.sav'
;;;make meanlons 0 - 360°
meanlons = (meanlons + 360) mod 360
;;;restore cloudtypes 0-7
restore, '~/CLOUDSAT/cloud_lists/tropical_cloudtypes.sav'
print, 'Done restoring masterlist and cloudtypes'

;;;cloudtype abbriviations
typename=['wcb','ncb','an','ci','cg','ac','sc','cu']
todname = ['pm', 'am']

minlon = findgen(nbins)*binwidth + min_lon
maxlon = [minlon[1:*], max_lon]

nbox = float(nbins)
ntod = 2
ntype = 8

N = fltarr(NBOX, NTOD, NTYPE) ;;; Pixel ;histograms of each cloud type.
A = fltarr(NBOX, NTOD, NTYPE) ;;; Pixel ;histograms of each cloud type.
V = fltarr(NBOX, NTOD, NTYPE) ;;; Pixel ;histograms of each cloud type.

for ibox=0, n_elements(minlon)-1 do begin
   for itod=0, ntod-1 do begin
      for itype=0, ntype-1 do begin
         
         w = where(meanlats le max_lat and meanlats ge min_lat and meanlons gt minlon[ibox] and meanlons le maxlon[ibox] $
                   and cloudtypes eq itype and tods eq itod and days ge min_jday and days le max_jday)
         
         sample_name = subset_name+'_'+str(ibox)+'.'+todname[itod]+'.'+typename[itype]

         
         if w[0] gt 0 then begin
            N[ibox, itod, itype] = n_elements(w)
            A[ibox, itod, itype] = total(BBwidths[w])
            V[ibox, itod, itype] = total(NPixelss[w])
         endif 

         EOs_index = w
         save, file = '~/CLOUDSAT/bar_plot_info/'+sample_name+'.sav', EOs_index
         
      endfor                    ;type 
   endfor                       ;tod
endfor                          ;box
  
save, file='~/CLOUDSAT/bar_plot_info/'+ subset_name + '_NAVarray.sav', N, A, V, min_jday, max_jday, min_lat, max_lat, $
      min_lon, max_lon

end 
