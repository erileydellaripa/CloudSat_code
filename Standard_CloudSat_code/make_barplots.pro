;;;PURPOSE - Defines constraints to make barplots for
;;;          uniquely defined set of EOs
;;;
;;;CALLS - get_barplot_info.pro & plot_barplot_info.pro
;;;
;;;INPUT -  DAY_TYPE, either jdays from cloudsat_jdays.sav or
;;;        calendar_days from EO_season.sav
;;;The DAY_TYPE input will affect the range of your min_day and
;;;Range is (166-1793) for jdays and (1-365) for calendar days
;;;Use calendar days if you want to look at same seasons across
;;;more than one CloudSat year
;;;
;;;Do_lineplot - first run with do_linplot = 'no' for different
;;;              desired EO sets. Then use mean_barplots_subsets.pro
;;;              to find average of combined EO sets. A mean_coverge
;;;              array will be saved in mean_barplots_subsets.pro,
;;;              that can then be recalled here to overplot the
;;;              average mean line. After using
;;;              mean_barplot_subsets.pro can have do_lineplot = 'yes'
;;;              and uncomment restore, '~/..........'
;;;
;;;SAMPLE_NAME - whatever unique name you gave to mean_coverage.sav 
;;;example - sample_name = 'ENSO0608'
;;;
;;;Emily M Riley - 6 June 2012
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PRO make_barplots, DAY_TYPE = day_type, sample_name = sample_name

;restore, '~/CLOUDSAT/bar_plot_info/'+sample_name+'_mean_coverage.sav'

;;;;ENSO_warmphase_2006
;days     = day_type
;min_jday  = 244
;max_jday  = 424
;min_lon  = 100
;max_lon  = 290
;min_lat  = -10
;max_lat  = 10
;nbins    = 19
;binwidth = 10
;Path     = '~/CLOUDSAT/ENSO/'
;subset_name = 'ENSO_warmphase_2006'
;ndays = max_jday - min_jday + 1
;do_lineplot = 'yes'
;;mean_coverage = mean_coverage

;;;;ENSO_coolphase_2007
;days     = day_type
;min_jday  = 609
;max_jday  = 790
;min_lon  = 100
;max_lon  = 290
;min_lat  = -10
;max_lat  = 10
;nbins    = 19
;binwidth = 10
;Path     = '~/CLOUDSAT/ENSO/'
;subset_name = 'ENSO_coolphase_2007'
;ndays = max_jday - min_jday + 1
;do_lineplot = 'yes'
;;mean_coverage = mean_coverage

;;;;;Indian Monsoon
days = day_type
min_jday = 152
max_jday = 243
min_lon = 50
max_lon = 90
min_lat = 5
max_lat = 20
nbins = 8
binwidth = 5
Path = '~/CLOUDSAT/Indian_Monsoon/'
subset_name = 'Indian_Monsoon_JJA'
ndays = ((243-152+1) * 4) + 62 + 16 ;JJA07, 08, 09, 10 all of Jul, Aug06 part June06
;ndays = max_jday - min_jday + 1
do_lineplot = 'no'

get_barplot_info, NBINS = nbins, BINWIDTH = binwidth, MIN_LON = min_lon, MAX_LON = max_lon,$
                  MIN_LAT = min_lat, MAX_LAT = max_lat, MIN_JDAY = min_jday, $
                  MAX_JDAY = max_jday, DAYS = days, SUBSET_NAME = subset_name

plot_barplot_info, NBINS = nbins, BINWIDTH = binwidth, MIN_LON = max_lon, MAX_LON = min_lon, $
                   MIN_LAT = min_lat, MAX_LAT = max_lat, MIN_JDAY = min_jday, $
                   MAX_JDAY = max_jday, SUBSET_NAME = subset_name, PATH = path, $
                   DO_LINEPLOT = do_lineplot, MEAN_COVERAGE = mean_coverage, ndays = ndays


END 
