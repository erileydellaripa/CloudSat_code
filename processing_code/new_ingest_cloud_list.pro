;;updated ingest_cloud_list, no longer have formating issues 
;;;updated 9  July 2008 - ER: using latest masterlist_july08.txt
;;;updated 11 Nov  2008 - ER; Using latest masterlist_Nov08.txt
;;;updated 16 Mar  2010 - ER for latest masterlist_2010.txt
;;;updated 29 Mar  2013 - ER for latest masterlist_2013.txt
;;;Redone 10 May 2017   - ERD for new masterlist_overlap_corrected_06to09.txt
;;;To make masterlist.txt use more *200? > masterlist??.txt

pro go

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Read in the ASCII data slooow
filename='' ;;; a string                                                                                                                                  

;;;; Read in first line
;openr, 1, '/Volumes/silverbullet/cloud_lists/masterlist_july08.txt'
;openr, 1, '/Volumes/silverbullet/new_cloud_lists/masterlist_Nov08.txt'
;openr, 1, '/Volumes/silverbullet/masterlist_2010.txt'
;openr, 1, '/Volumes/User/eriley/CLOUDSAT/cloud_lists/GrandMasterlist.txt'
openr, 1, '/Users/eriley/CLOUDSAT/cloud_lists/masterlist_overlap_corrected_06to09.txt'
;n = file_lines('/Volumes/silverbullet/masterlist_july08.txt')
;n = 29047890
;NCLOUDS = 29047890L/6L 
;NCLOUDS = 33912036L/6L 
;I think use wc -l to get number of lines in file
;NCLOUDS = 59927112/6L ;9,987,852 EOs
;NCLOUDS = 91087158/6D
n = file_lines('/Users/eriley/CLOUDSAT/cloud_lists/masterlist_overlap_corrected_06to09.txt')
NCLOUDS = n/6D ;10,068,814   15,181,193

;;; Make plurals - collections of these variables
filenames = strarr(NCLOUDS)
tods = intarr(NCLOUDS)
minxs = lonarr(NCLOUDS)
maxxs = lonarr(NCLOUDS)
npixelss = lonarr(NCLOUDS)
npixelsge17s = lonarr(NCLOUDS)
npixelsgt0s = lonarr(NCLOUDS)
npixels_aboves = lonarr(NCLOUDS)
landpixelss = lonarr(NCLOUDS)
ncellsgt0s = lonarr(NCLOUDS)
biggestgt0s = lonarr(NCLOUDS)
bbwidths = intarr(NCLOUDS)
bottoms = fltarr(NCLOUDS)
meanzs = fltarr(NCLOUDS)
tops = fltarr(NCLOUDS)
minlats = fltarr(NCLOUDS)
meanlats = fltarr(NCLOUDS)
maxlats = fltarr(NCLOUDS)
minlons = fltarr(NCLOUDS)
meanlons = fltarr(NCLOUDS)
maxlons = fltarr(NCLOUDS)
zgmins = fltarr(NCLOUDS)
zgmaxs = fltarr(NCLOUDS)
dbz_sea_mins = fltarr(NCLOUDS)
dbz_sea_maxs = fltarr(NCLOUDS)
sd_dbz_surfs = fltarr(NCLOUDS)

;input variables
filename0 = ''
tod0 = 0
minx0 = 0L
maxx0 = 0L
npixels0 = 0L
npixelsge170 = 0L
npixelsgt00 = 0L
npixels_above0 = 0L
landpixels0 = 0L
ncellsgt00 = 0L
biggestgt00 = 0L
bbwidth0 = 0
bottom0 = 0
meanz0 = 0.
top0 = 0
minlat0 = 0.
meanlat0 = 0.
maxlat0 = 0.
minlon0 = 0.
meanlon0 = 0.
maxlon0 = 0.
zgmin0 = 0.
zgmax0 = 0.
dbz_sea_min0 = 0.
dbz_sea_max0 = 0.
sd_dbz_surf0 = 0.

;;;Loop to read in all the variables
for i=0L, NCLOUDS-1 do begin
   if i mod 100000 eq 0 then print, 'cloud number =  ', i, '/', nclouds

  readf, 1, filename0, tod0, minx0, maxx0, npixels0, npixelsge170, $
  npixelsgt00, npixels_above0, landpixels0, ncellsgt00, biggestgt00, bbwidth0, $
  bottom0, meanz0, top0, minlat0, meanlat0, maxlat0, minlon0, meanlon0, $
  maxlon0, zgmin0, zgmax0, dbz_sea_min0, dbz_sea_max0, sd_dbz_surf0 
  
  if(npixelsgt00 gt npixels0) then print, filename0 + ' has npixelsgt0 gt npixels ',npixelsgt00, npixels0
  ;if(strlen(filename) gt 28) then print, filename, 'too long filename'
  if(npixels0 lt 0) then print, 'negative pixels ', npixels0
  if(npixelsgt00 lt 0) then print, filename0 + ' has negative npixelsgt0 ',npixelsgt00
  if(npixelsge170 lt 0) then print, filename0 + ' has negative npixelsge17 ',npixelsge170
  if (i mod 100000L eq 0) then print, i, $
      filename0, tod0, minx0, maxx0, npixels0, npixelsge170, $
      npixelsgt00, npixels_above0, landpixels0, ncellsgt00, biggestgt00, bbwidth0, $
      bottom0, meanz0, top0, minlat0, meanlat0, maxlat0, minlon0, meanlon0, $
      maxlon0, zgmin0, zgmax0, dbz_sea_min0, dbz_sea_max0, sd_dbz_surf0 
      
;;; Make plurals - collections of these variables
filenames[i] = filename0
tods[i] = tod0
minxs[i] = minx0
maxxs[i] = maxx0
npixelss[i] = npixels0
npixelsge17s[i] = npixelsge170
npixelsgt0s[i] = npixelsgt00
npixels_aboves[i] = npixels_above0
landpixelss[i] = landpixels0
ncellsgt0s[i] = ncellsgt00
biggestgt0s[i] = biggestgt00
bbwidths[i] = bbwidth0
bottoms[i] = bottom0
meanzs[i] = meanz0
tops[i] = top0
minlats[i] = minlat0
meanlats[i] = meanlat0
maxlats[i] = maxlat0
minlons[i] = minlon0
meanlons[i] = meanlon0
maxlons[i] = maxlon0
zgmins[i] = zgmin0
zgmaxs[i] = zgmax0
dbz_sea_mins[i] = dbz_sea_min0
dbz_sea_maxs[i] = dbz_sea_max0
sd_dbz_surfs[i] = sd_dbz_surf0

endfor
close, 1

;save, file='Masterlist_2010.sav', filenames, tods, minxs, maxxs, npixelss, $
;  npixelsge17s, npixelsgt0s, npixels_aboves, landpixelss, ncellsgt0s, biggestgt0s, bbwidths, $
;  bottoms, meanzs, tops, minlats, meanlats, maxlats, minlons, meanlons, maxlons, $
;  zgmins, zgmaxs, dbz_sea_mins, dbz_sea_maxs, sd_dbz_surfs

;save, file='Masterlist_2013.sav', filenames, tods, minxs, maxxs, npixelss, $

save, file='Masterlist_overlap_corrected_06to09.sav', filenames, tods, minxs, maxxs, npixelss, $
  npixelsge17s, npixelsgt0s, npixels_aboves, landpixelss, ncellsgt0s, biggestgt0s, bbwidths, $
  bottoms, meanzs, tops, minlats, meanlats, maxlats, minlons, meanlons, maxlons, $
  zgmins, zgmaxs, dbz_sea_mins, dbz_sea_maxs, sd_dbz_surfs
  
;save, file='New_Masterlist_08.sav'

stop
end 
