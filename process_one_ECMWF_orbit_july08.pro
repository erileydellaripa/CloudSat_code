; This routine reads a ECMWF-AUX file specified by infile name plus
; the next one which is spliced at the end to avoid equatorial edge
; effects. 
;;;Created 12/01/2007 by ER following process_two_orbits.pro
;;;Modified 2/18/2008 by ER, removed 'round' in front of  p_avg =
;;;total(pslab,1)/float(maxx[i] - minx[i] + 1)
;;;but it doeesn't change the sounding by much at all, not a
;;;significant amount.
; example usage 
; process_one_ECMWF_orbit,'./', '2006193061810_01091_CS_ECMWF-AUX_GRANULE_P_R04_E00.hdf' 

pro process_one_ECMWF_orbit_july08, indir, infile

shortname = strmid(infile,0,19)
swathname = 'ECMWF-AUX'
print, infile, ' shortname ', shortname
spawn, 'mkdir /Volumes/silverbullet/new_EO_soundings/'+shortname
;----------------------------------------------- Read data

;;;; Open the file and "attach" to it
fid = eos_sw_open(indir+infile, /READ)
print,'file ',fid
swathid = EOS_SW_ATTACH(fid, swathname)
print,'swath ',swathid

;;;; Read the data fields we want and name them sensibly
;;;; the  sounding data
status = EOS_SW_READFIELD(swathid, 'EC_height', z)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Pressure', p)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Temperature', T)
if( status lt 0) then print, 'Read Error'
status = EOS_SW_READFIELD(swathid, 'Specific_humidity', q)
if( status lt 0) then print, 'Read Error'

;stop
;;;;  rotate as necessary & put in correct units
p = rotate(p,3)/100. ;;put in mb/hPa
T = rotate(T,3)
q = rotate(q,3)*1000 ;;put in g/kg
zplot = z/1000. 

;;;; OK, done getting what we neeed from file, close it
status = EOS_SW_DETACH(swathid)
status = EOS_SW_CLOSE(fid)

print, '***done reading in file***'

;;;;Restore MASTERLIST_R04 to get maxxs & minxxs, no need to recreate
;;;;them. 
;restore, '/Users/mapesgroup/CLOUDSAT/cloud_lists/New_Masterlist_july08.sav'
;restore,'/Users/mapesgroup/CLOUDSAT/cloud_lists/Dec08_sounding_minmaxxs.sav' ;Days 182 to 546
restore, '/Users/mapesgroup/CLOUDSAT/cloud_lists/July07Oct08_minxmaxxs.sav';Days 545 to 1035 
   files = strmid(filenames, 0,19)
    wfiles = where(files eq shortname) 

    minx = minxs[wfiles]
    maxx = maxxs[wfiles]

print, '***done restoring masterlist and finding files***'
;;;loop over clouds and create a slab of data, then avg over the slab
for i=0L, n_elements(wfiles)-1 do begin

    pslab = p[minx[i]:maxx[i],*]
    Tslab = T[minx[i]:maxx[i],*]
    qslab = q[minx[i]:maxx[i],*]

    p_avg = total(pslab,1)/float(maxx[i] - minx[i] + 1)
    T_avg = total(Tslab,1)/float(maxx[i] - minx[i] + 1)
    q_avg = total(qslab,1)/float(maxx[i] - minx[i] + 1)
;stop
;window,0
;plot, reverse(p_avg), zplot, yran=[0,25], xtit='mb', ytit='km'
;window,1
;plot, reverse(T_avg), zplot, xran=[180,315],yran=[0,25], xtit='T(K)', ytit='km'
;window,2
;plot, reverse(q_avg), zplot, xran=[0,20],yran=[0,25], xtit='q(g/kg)', ytit='km'

;print, shortname 
;print, filenames[wfiles[i]]
;hlp, p_avg, T_avg, q_avg
save, file='/Volumes/silverbullet/new_EO_soundings/'+shortname+'/'+filenames[wfiles[i]]+'.sav', $
  p_avg, T_avg, q_avg, zplot
;stop
endfor   ;; end i loop over clouds
end

