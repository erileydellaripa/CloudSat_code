;;;Emily Riley 7 November 2012
;;;
;;;Pupose - make average vertical profiles of ECMWF vorticity for a
;;;         subset of filenames.
;;;
;;;Each ECMWFfile contains -  mean_temp, mean_q, mean_cc, mean_ciwc, mean_clwc, mean_div,
;mean_geop, mean_pv, mean_rh, mean_u, mean_v, mean_vort, mean_w.
;INVALiD values  = -909090
;
;;;Code made following cloud_soundings.pro

pro ECMWF_plev_vorticity, FILENAMES=filenames, SAMPLE_NAME=sample_name, PATH = path

PATH = '/Volumes/User/eriley/CLOUDSAT/YOTC/ecmwf_plev_EOfiles/'

land
device, file=SAMPLE_NAME+'_YOTC_ECMWFprofiles.ps'
!p.multi = [0, 2, 2]

restore, '/Volumes/User/eriley/CLOUDSAT/YOTC/code/ec_idaily_pres_levels.sav' ;restores pres_levels

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop over clouds
for i = 0L, n_elements(filenames)-1 do begin
    
   ECMWFfile = PATH + strmid(filenames[i], 0, 19) + $
      '/'+filenames[i] + '.sav'
 
    command = 'restore, ECMWFfile'
    errr = execute(command)
    If (errr eq 0) then goto, jump99

    plot, mean_vort*100000, pres_levels, yrange=[1000, 50] , tit='Avg Vorticity'+' '+sample_name, xtit='relative vorticity(10!U-5!Ns!U-1!N)', ytit='p (hPa)', thick = 5
    ver, 0

jump99:
endfor 

psout
end 
