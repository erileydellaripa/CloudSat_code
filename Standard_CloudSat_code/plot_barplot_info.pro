;;;;PURPOSE - plot up barplot infor saved from get_barplot_info.sav
;;;;NOTE - if you want to overplot the mean line for each bin,
;;;;       you'll just have to fuss with the specifics, I haven't
;;;;figured out how to automate it yet : (
;;;;Emily Riley - 6/6/12, modified from
;;;;              (plot_barplot_info_WHphases_18lonboxes_just_area_bars_newmasterlist.pro)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro plot_barplot_info, NBINS = nbins, BINWIDTH = binwidth, MAX_LAT = max_lat, MIN_LAT = min_lat, $
                       MIN_LON = min_lon, MAX_LON = max_lon, MIN_JDAY = min_jday, MAX_JDAY = max_jday, $
                       SUBSET_NAME = subset_name, PATH = path, DO_LINEPLOT = do_lineplot, $
                       MEAN_COVERAGE = mean_coverage, ndays = ndays

tall
device, file = PATH + subset_name + 'barplots.ps'
!p.multi = [0,1,4]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
restore, '~/CLOUDSAT/bar_plot_info/'+subset_name+'_NAVarray.sav'

barnames = ['wcb', 'ncb', 'an', 'ci', 'cg', 'ac', 'sc', 'cu']
plotme = A

;;;;Make bar plot with cloud type area stacked one on top of
;;;;eachother for each longitude bin
area_cloudtype = fltarr(nbins, 8)
bin_total      = fltarr(nbins)

for ibin = 0, nbins-1 do begin
    cloud_type_value        = total(plotme(ibin, *, *), 2)
    area_cloudtype[ibin, *] = cloud_type_value
endfor 

nlats = max_lat  - min_lat  + 1
;ndays = max_jday - min_jday + 1

area_coverage = area_cloudtype/(binwidth*nlats*8.04*ndays)*100D ;compute % coverage

all_bins = fltarr(nbins, 8)
for ibin = 0, nbins-1 do begin
    a = total(area_coverage[ibin, *])
    b = a - area_coverage[ibin, 1]
    c = b - area_coverage[ibin, 0]
    d = c - area_coverage[ibin, 2]
    e = d - area_coverage[ibin, 3]
    f = e - area_coverage[ibin, 4]
    g = f - area_coverage[ibin, 5]
    h = g - area_coverage[ibin, 6]
    array = [h, g, f, e, d, c, b, a]
    array = rotate(array, 4) ;;make vertical

    all_bins[ibin, *] = array

    bin_total[ibin] = a
endfor 

base = intarr(nbins)

if binwidth mod 2 eq 0 then begin
   barnames = str(lindgen(nbins)*binwidth+min_lon+(binwidth/2))
endif else begin ;;;;At most want only 1 number after the decimal place labele
   barnames = str(round_any(lindgen(nbins)*binwidth+min_lon+(binwidth/2.), sig = 4))
endelse 

colors = intarr(nbins, 8)
for i = 0, 7 do colors[*, i]= i*(250/7)
colors[*,5] = 190

for i = 0, 7 do begin
    bar_plot, all_bins[*, i], colors = colors[*,i], baselines=base, $
      barwidth = 0.6, barspace = 0.38, over=(i gt 0), yrange = [0, 85], $
      barnames = barnames, xtitle = 'longitude bin', ytitle='hp cover (%)', $
      title = subset_name, ycharsize = .5;;, length = 1
    base = all_bins[*,i]
endfor 

;;;;;;used to make average line plot across all MJO phases for Fig. 10
;;;Riley et al. (2011, JAS)
;;;x_location = findgen(nbins)*((16.4-.65)/17.) + .65
;;;oplot, x_location, total_array_mean, psym = -2, symsize = .4

if do_lineplot eq 'yes' then begin
   x_location = findgen(nbins)*((17.4-.65)/(nbins-1.)) + .65
   oplot, x_location, mean_coverage, psym = -2, symsize = .4
endif 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Bar plots percent of each EO type out of 100%
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
percent_coverage = fltarr(nbins, 8)
for ibin = 0, nbins - 1 do begin
   percent_coverage[ibin, *] = area_cloudtype[ibin, *]/total(area_cloudtype[ibin, *])*100 ;compute % coverage
endfor 

all_bins = fltarr(nbins, 8)
for ibin = 0, nbins-1 do begin
    a = 100
    b = a - percent_coverage[ibin, 1]
    c = b - percent_coverage[ibin, 0]
    d = c - percent_coverage[ibin, 2]
    e = d - percent_coverage[ibin, 3]
    f = e - percent_coverage[ibin, 4]
    g = f - percent_coverage[ibin, 5]
    h = g - percent_coverage[ibin, 6]
    array = [h, g, f, e, d, c, b, a]
    array = rotate(array, 4) ;;make vertical

    all_bins[ibin, *] = array

    bin_total[ibin] = a
endfor 

base = intarr(nbins)

if binwidth mod 2 eq 0 then begin
   barnames = str(lindgen(nbins)*binwidth+min_lon+(binwidth/2))
endif else begin ;;;;At most want only 1 number after the decimal place labeled
   barnames = str(round_any(lindgen(nbins)*binwidth+min_lon+(binwidth/2.), sig = 4))
endelse 

colors = intarr(nbins, 8)
for i = 0, 7 do colors[*, i]= i*(250/7)
colors[*,5] = 190

for i = 0, 7 do begin
    bar_plot, all_bins[*, i], colors = colors[*,i], baselines=base, $
              barwidth = 0.6, barspace = 0.38, over=(i gt 0), yrange = [0, 100], $
      barnames = barnames, xtitle = 'longitude bin', ytitle='hp cover (%)', $
      title = subset_name, ycharsize = .5;;, length = 1
    base = all_bins[*,i]
endfor 


psout
;stop
end 
