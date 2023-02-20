;;;PURPOSE - compute the mean for two or more barplot subsets
;;;The mean total EO coverage for each longitude bin can then be
;;;plotted over the unique barplot subsets that were used to make the
;;;mean. 
;;;
;;;INPUTS - path and filename to restore barplot subset information,
;;;         nbins and binwidth
;;;
;;;NOTE - default path is ~/CLOUDSAT/bar_plot_info/, can specify
;;;       another path if needed
;;;
;;;Emily M Riley - 6 June 2012
;;;
;;;Example use:
;;;Filenames = ['ENSO_coolphase_2007', 'ENSO_warmphase_2006'],
;;;mean_name = ENSO0608, other values the same as used in make_barplot.pro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



PRO mean_barplot_subsets, FILENAMES = filenames, BARPLOT_INFO_PATH = path, NBINS = nbins, $
                          BINWIDTH = binwidth, MIN_JDAY = min_jday, MAX_JDAY = max_jday, $
                          MIN_LAT = min_lat, MAX_LAT = max_lat, MEAN_NAME = mean_name

barplot_info_PATH = '~/CLOUDSAT/bar_plot_info/'
;total_area_perbin = fltarr(nbins)
total_coverage_perbin = fltarr(nbins)
grand_total = fltarr(nbins)

FOR i = 0, n_elements(filenames)-1 DO BEGIN
   restore, barplot_info_PATH + FILENAMES[i] + '_NAVarray.sav'
   
   ndays = max_jday - min_jday + 1
   nlats = max_lat  - min_lat  + 1

   FOR ibin = 0, nbins - 1 DO BEGIN
      total_area_perbin = total(A[ibin, *, *])
      total_coverage_perbin[ibin] = total_area_perbin/(binwidth*nlats*8.04*ndays)*100D ;compute % coverage
   ENDFOR  
   
   grand_total = grand_total + total_coverage_perbin

ENDFOR 

   mean_coverage = grand_total/n_elements(filenames)

   save, file = '~/CLOUDSAT/bar_plot_info/'+mean_name+'_mean_coverage.sav', mean_coverage
END 
