;;;PURPOSE - generator random set of EOs to be plots as stamps
;;;
;;;USES - tropical_cloudtypes.sav, which was generated with
;;;       define_tropical_EOtypes.pro
;;;
;;;CALLS - plot_stamps_bylongitude.pro
;;;
;;;NOTES - Plotting convention is to make bottom horizontal axis
;;;        kilometers (i.e. nlons * 111, since 111 km = 1 degrees) and
;;;top axis the corresponding longitude or latitude.
;;;ORIENTATION = 'lat' or 'lon' depending on if you want to plot the
;;;stamps by latitude or longitude
;;;;
;;;;DO_DBZCOLOR = 'true' will plot EO by dbz color, if 'false' will
;;;plot wDps grey to red and all other EOs grey to blue.
;;;;
;;;;DO_ELEVATION = 'true' will plot zground undneath each EO's
;;;profiles, 'false' will not plot elevation underneath
;;;;
;;;nlons = maxlon - minlon, nlats = maxlat - minlat
;;;;ntick and increment used to make the top horizontal axis
;;;correspond to longitude; increment = how many degrees between each
;;;tick mark; nticks = how many tick marks
;;;
;;;EXAMPLE given in ENSO_mosiacs.pro - I wanted to plot a random set of
;;;                                   stamps between 100 and 290 with
;;;20 degree spacing.  So I used increment = 20 and ntick = 9
;;;
;;;Total_cloudiness is how much total bbwidth you want on the figure,
;;;can play with values to get pretty picture.
;;;
;;;THIS HAS NOT BE TESTED EXHAUSTIVELY!
;;;


pro random_stamp_generator, FILENAMES=filenames, BBWIDTHS = bbwidths, CLOUDTYPES = cloudtypes, SEED = seed, $
                            MEANLONS=meanlons, MEANLATS = meanlats, NAME = name, nlons = nlons, nlats = nlats, $
                            startlon = startlon, startlat = startlat, INCREMENT = increment, NTICKS = nticks, $
                            TOTAL_CLOUDINESS = total_cloudiness, ORIENTATION = orientation, DO_ELEVATION = do_elevation, $
                            DO_DBZCOLOR = do_dbzcolor, MINLATS = minlats, MINLONS = minlons, TODS = tods
            
;smush_factor = (360.*40.)/nlons ;;Nlons: home many degrees of longitude the area of interest is

;startingx = round(min(meanlons))*smush_factor ;;; ~km                    
;Plotxsize = nlons*smush_factor + startingx ;;~km
startingx = 0
IF orientation EQ 'lon' THEN PLOTXSIZE = nlons * 111. ;;111 km = 1°longitude near equator & 1 degree latitude ~everywhere
IF orientation EQ 'lat' THEN PLOTXSIZE = nlats * 111.
PLOTZSIZE = 20 ;;; Km - 20km tropospheres stacked

plot, [0],[0], xra=[startingx,PLOTXSIZE], yra=[0,PLOTZSIZE], /nodata, $;/nodata, /noerase, $
      ytitle = 'height (km)', Xstyle = 9, Xtitle = 'km';'longitude*'+str(smush_factor) 
;spacing = (plotxsize - startingx)/8.
spacing = increment * 111
IF orientation EQ 'lon' THEN BEGIN
   print, 'made it past orientation if for setting plot region'
   axis, xaxis=1, xticks=nticks, xtickv = lindgen(nticks+1)*spacing, $
         xtickn = Str(lindgen(nticks+1)*increment + startlon), $
         xtitle = 'longitude'
ENDIF 

IF orientation EQ 'lat' THEN BEGIN
   axis, xaxis=1, xticks=nticks, xtickv = lindgen(nticks+1)*spacing, $
         xtickn = Str(round_any(lindgen(nticks+1)*increment + startlat, 2)), $
         xtitle = 'latitude'
ENDIF 
;      Xtickn = ['50', '55', '60', '65', '70', '75', '80', '85', '90'], xtitle = 'longitude'
;Xyouts, 100, 18, 'seed = '

;;;restore cloudtypes ;;0-7 wcb, ncb, an, ci, cg, ac, sc, cu
;;;restore, '~/CLOUDSAT/cloud_lists/tropical_cloudtypes.sav'
;;;--changed, should be done in code where EO set is defined.

;meanlons = (meanlons + 360) mod 360

RandomNumbers = randomu(seed, n_elements(filenames), /double)
sorted_random_numbers = sort(randomnumbers)
width_array = bbwidths[sorted_random_numbers]
total_width = total(width_array, /cum)
desired_total_cloudiness = total_cloudiness ;default was 2000
dummy = min(abs(desired_total_cloudiness - total_width), index)

list = filenames[sorted_random_numbers[0:index]]
EOsize = bbwidths[sorted_random_numbers[0:index]]
type = cloudtypes[sorted_random_numbers[0:index]]
;stop
IF orientation EQ 'lon' THEN BEGIN
   meanlons_list = meanlons[sorted_random_numbers[0:index]]
   minlons_list  = minlons[sorted_random_numbers[0:index]]
   tods_list     = tods[sorted_random_numbers[0:index]]
ENDIF 

IF orientation EQ 'lat' THEN BEGIN
   meanlats_list = meanlats[sorted_random_numbers[0:index]]
   minlats_list  = minlats[sorted_random_numbers[0:index]]
   tods_list     = tods[sorted_random_numbers[0:index]]
ENDIF 

;;;;Sort according to cloudtype, so will then be able to plot wcb a
;;;;different color.
sortby = sort(type)
type = type[sortby]
list = list[sortby]
EOsize = EOsize[sortby]
IF orientation EQ 'lon' THEN meanlons_list = meanlons_list[sortby]
IF orientation EQ 'lat' THEN meanlats_list = meanlats_list[sortby]

;stop
;;;;Define the color scale: white->red for wcb, white->blue all others
steps = 106
scalefactor = findgen(steps)/(steps - 1)

FOR i = 0L, n_elements(type) - 1 DO BEGIN
   IF type[i] EQ 0 THEN BEGIN
      r = replicate(255, steps)
      b = reverse(0 + (0+255)*scalefactor)
      g = reverse(0 + (0+255)*scalefactor)
   ENDIF ELSE BEGIN
      r = reverse(0 + (0+255)*scalefactor)
      b = replicate(255, steps)
      g = reverse(0 + (0+255)*scalefactor)
   ENDELSE   

   IF orientation EQ 'lon' THEN BEGIN ;and type[i] ne 0 THEN BEGIN
      print, 'made it to plot_stamps_bylongitude'

      plot_stamps_bylongitude, FILENAMES = list[i], meanlons = meanlons_list[i], minlons = minlons_list[i], nlons = nlons, $
                               R = r, G = g, B = b, NAME = name, startlon = startlon, $
                               DO_ELEVATION = do_elevation, DO_DBZCOLOR = do_dbzcolor, tods = tods_list[i]
   ENDIF 
   
   IF orientation EQ 'lat' THEN BEGIN
      plot_stamps_bylatitude, FILENAMES = list[i], meanlats = meanlats_list[i], minlats = minlats_list[i], nlats = nlats, $
                              R = r, G = g, B = b, NAME = name, startlat = startlat, $
                              DO_ELEVATION = do_elevation, DO_DBZCOLOR = do_dbzcolor, tods = tods_list[i]
   ENDIF 
   
ENDFOR  

END 

