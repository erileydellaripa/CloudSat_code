pro go

restore, '/Users/mapesgroup/CLOUDSAT/cloud_lists/Masterlist_Dec2010_filenames_meanlatslons.sav'
year =  fix( strmid(filenames,0, 4) )
year060708 = where(year le 2008)
year0910   = where(year gt 2008)
jdays060708 = fix( strmid(filenames[year060708], 4, 3) ) + 365*( fix( strmid(filenames[year060708],0, 4) ) -2006)
jdays0910   = (fix( strmid(filenames[year0910], 4, 3) )+1) + 365*( fix( strmid(filenames[year0910],0, 4) ) -2006)
jdays = [jdays060708, jdays0910]

save, file = 'cloudsat_jdays.sav', jdays

end 
