;;;PURPOSE - Assign each EO to a season either JJA, SON, DJF, MAM,
;;;
;;;- may need to alter PATH and Filename if updated
;;;Emily Riley - 06/01/2012 - original code found in
;;;              (monsoon_mosiacs.pro)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro assign_EO_seasons

PATH = '~/CLOUDSAT/cloud_lists/'
FILENAME = 'Masterlist_Dec2010.sav'

restore, PATH + filename

;;;Get the Julian day for each calendar year
year = float(strmid(filenames, 0, 4))
dayofyear = float(strmid(filenames, 4, 3))

;;;Make year 2008 have two jdays = 59, so Feb 28,29 both jday 59 and
;;;subtract one from days after Feb 29 so they have the same jday as
;;;non-leap years.
w       = where(year eq 2008 and dayofyear ge 60)
new08   =  dayofyear[w] - 1
newdays = [dayofyear[0:min(w)-1], new08, dayofyear[max(w)+1:*]]

;;;;;Seasons
nseasons = 4
SEASONS  = TOPS*0 - 999
SEASONS[where(newdays ge 152 and newdays le 243)] = 0 ;;JJA
SEASONS[where(newdays ge 244 and newdays le 334)] = 1 ;;SON
a = where(newdays ge 335 and newdays le 365)          ;;DJF
b = where(newdays ge 1 and newdays le 59)          
SEASONS[a] = 2 
SEASONS[b] = 2
SEASONS[where(newdays ge 60 and newdays le 151)]  = 3 ;;MAM

calendar_days = newdays

save, file = '~/CLOUDSAT/cloud_lists/EO_seasons.sav', calendar_days, SEASONS

END 
