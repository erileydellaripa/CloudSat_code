pro go

;;;Find Julday for cloudsat EOs

listname = '2013' ;'Dec2010', 'Dec08_nonrepeated_noxoutliers'

restore, '~/CLOUDSAT/cloud_lists/Masterlist_'+listname+'.sav'
restore, '~/CLOUDSAT/cloud_lists/cloudsat_jdays_since2006_end'+listname+'.sav'

Hours    = fix( strmid(filenames, 7, 2))
minutes  = fix( strmid(filenames, 9, 2))

;;;Arrays to be filled later
cldsat_day = dblarr(n_elements(jdays))
juliandays = dblarr(n_elements(jdays))

;;;Round to the nearest hour
w = where(minutes ge 30)
hours[w] = hours[w] + 1

start_day  = julday(12, 31, 2005, 00, 00, 00)
for iday = 0L, n_elements(jdays) - 1 do begin
   cldsat_day[iday] = start_day + jdays[iday] 

   caldat, cldsat_day[iday], month, day, year
   juliandays[iday] = julday(month, day, year, hours[iday])
endfor 

save, file='EO_juliandays_'+listname+'Masterlist.sav', juliandays

end 
