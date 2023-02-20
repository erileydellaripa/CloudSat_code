;;;Emily Riley 1 October 2012
;;;
;;;Pupose - make average vertical profiles of ECMWF variables for a
;;;         subset of filenames.
;;;
;;;Each ECMWFfile contains -  mean_temp, mean_q, mean_cc, mean_ciwc, mean_clwc, mean_div,
;mean_geop, mean_pv, mean_rh, mean_u, mean_v, mean_vort, mean_w.
;INVALiD values  = -909090
;
;;;Code made following cloud_soundings.pro

pro ECMWF_plev_composite, FILENAMES=filenames, SAMPLE_NAME=sample_name, RAIN = rain, $
                          SST = sst, PW = pw, PATH = path, EOnumbers = EOnumbers

PATH = '/Volumes/User/eriley/CLOUDSAT/YOTC/ecmwf_plev_EOfiles/'

;land
;device, file=SAMPLE_NAME+'_YOTC_ECMWFprofiles.ps'

restore, '/Volumes/User/eriley/CLOUDSAT/YOTC/code/ec_idaily_pres_levels.sav' ;restores pres_levels
;;;;Make sum & num arrays to be filled
TSUM    = fltarr(37)
TNUM    = fltarr(37)
QSUM    = fltarr(37)
QNUM    = fltarr(37)
CCSUM   = fltarr(37)
CCNUM   = fltarr(37) 
CIWCSUM = fltarr(37)
CIWCNUM = fltarr(37)
CLWCSUM = fltarr(37)
CLWCNUM = fltarr(37)
DIVSUM  = fltarr(37)
DIVNUM  = fltarr(37)
GEOSUM  = fltarr(37)
GEONUM  = fltarr(37)
PVSUM   = fltarr(37)
PVNUM   = fltarr(37)
RHSUM   = fltarr(37)
RHNUM   = fltarr(37)
USUM    = fltarr(37)
UNUM    = fltarr(37)
VSUM    = fltarr(37)
VNUM    = fltarr(37)
VORSUM  = fltarr(37)
VORNUM  = fltarr(37)
WSUM    = fltarr(37)
WNUM    = fltarr(37)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop over clouds
for i = 0L, n_elements(filenames)-1 do begin
    
   ECMWFfile = PATH + strmid(filenames[i], 0, 19) + $
      '/'+filenames[i] + '.sav'
 
    command = 'restore, ECMWFfile'
    errr = execute(command)
    If (errr eq 0) then goto, jump99

;restores: mean_temp, mean_q, mean_cc, mean_ciwc, mean_clwc, mean_div,
;mean_geop, mean_pv, mean_rh, mean_u, mean_v, mean_vort, mean_w
;;;INVALID VALUE = -909090
;;;FillValue = 1.e+20f 

    TSUM = TSUM + (mean_temp > 0)
    TNUM = TNUM + (mean_temp ge 0 and mean_temp lt 1e18)

    QSUM = QSUM + (mean_q > 0)
    QNUM = QNUM + (mean_q ge 0 and mean_q lt 1e18)

    CCSUM = CCSUM + (mean_cc > 0)
    CCNUM = CCNUM + (mean_cc ge 0 and mean_cc lt 1e18)

    CIWCSUM = CIWCSUM + (mean_ciwc > 0)
    CIWCNUM = CIWCNUM + (mean_ciwc ge 0 and mean_ciwc lt 1e18)

    CLWCSUM = CLWCSUM + (mean_clwc > 0)
    CLWCNUM = CLWCNUM + (mean_clwc ge 0 and mean_clwc lt 1e18)

    DIVSUM = DIVSUM + mean_div[where(mean_div gt -909090)]
    DIVNUM = DIVNUM + (mean_div gt 0-909090 and mean_div lt 1e18)

    GEOSUM = GEOSUM + (mean_geop > 0)
    GEONUM = GEONUM + (mean_geop ge 0 and mean_geop lt 1e18)

    PVSUM = PVSUM + mean_pv[where(mean_pv gt -909090)]
    PVNUM = PVNUM + (mean_pv gt 0-909090 and mean_pv lt 1e18)

    RHSUM = RHSUM + (mean_rh > 0)
    RHNUM = RHNUM + (mean_rh ge 0 and mean_rh lt 1e18)

    USUM = USUM + mean_u[where(mean_u gt -909090)]
    UNUM = UNUM + (mean_u gt -909090 and mean_u lt 1e18)

    VSUM = VSUM + mean_v[where(mean_v gt -909090)]
    VNUM = VNUM + (mean_v gt 0-909090 and mean_v lt 1e18)

    VORSUM = VORSUM + mean_vort[where(mean_vort gt -909090)]
    VORNUM = VORNUM + (mean_vort gt 0-909090 and mean_vort lt 1e18)

    WSUM = WSUM + mean_w[where(mean_w gt -909090)]
    WNUM = WNUM + (mean_w gt 0-909090 and mean_w lt 1e18)

jump99:
endfor 

avg_T = TSUM/(TNUM > 1)
avg_q = QSUM/(QNUM > 1)
avg_cc = CCSUM/(CCNUM > 1)
avg_ciwc = CIWCSUM/(CIWCNUM > 1)
avg_clwc = CLWCSUM/(CLWCNUM > 1)
avg_div = DIVSUM/(DIVNUM > 1)
avg_geo = GEOSUM/(GEONUM > 1)
avg_pv = PVSUM/(PVNUM > 1)
avg_rh = RHSUM/(RHNUM > 1)
avg_u = USUM/(UNUM > 1)
avg_v = vSUM/(VNUM > 1)
avg_vor = VORSUM/(VORNUM > 1)
avg_w = WSUM/(WNUM > 1)

;;;;;;Compute Brian's poor man's buoyancy;;;;;;;;;
avg_q_kg = avg_q/1000. ;;;must put q back in units of kg/kg to compute thetae & theta_esat
;w_kg = w/1000.         ;;;must put q back in units of kg/kg to compute thetae & theta_esat
;thetae = theta_e(T_degC, avg_p, avg_q_kg)
;thetasat = theta_e(T_degC, avg_p, w_kg)

!p.multi = [0, 2, 2]
;;;Plot 'em up
;plot, avg_T, pres_levels, yrange=[1000, 50], tit='Avg T Sounding'+' '+sample_name, xtit='T(K)', ytit='p (hPa)', thick = 5
;plot, avg_q*100., pres_levels, yrange=[1000, 50] , tit='Avg q sounding'+' '+sample_name, xtit='q(g/kg)', ytit='p (hPa)', thick = 5
;plot, avg_RH, pres_levels, yran=[1000,50], xran=[0,100],tit='Relative Humidity'+' '+sample_name, xtit='percent', ytit='p (hPa)', thick = 5
;plot, thetae, pres_levels, yran=[1000,50], xran=[330,400],tit='theta_e'+' '+sample_name, thick = 5, $
;  xtit='T(K)', ytit='p (hPa)', subtit='solid=theta_e, dashed=theta_esat'
;oplot, thetasat, pres_levels, linestyle = 2, thick = 5
;plot, avg_cc*100, pres_levels, yrange=[1000, 50], xrange = [0, 100], tit='Avg CC'+' '+sample_name, xtit='percent', ytit='p (hPa)', thick = 5
;plot, avg_ciwc*100000, pres_levels, yrange=[1000, 50] , tit='Avg CIWC'+' '+sample_name, xtit='CIWC (10!U-2!Ng/kg)', ytit='p (hPa)', thick = 5
;plot, avg_clwc*100000, pres_levels, yrange=[1000, 50] , tit='Avg CLWC'+' '+sample_name, xtit='CLWC (10!U-2!Ng/kg)', ytit='p (hPa)', thick = 5
;plot, avg_div*100000, pres_levels, yrange=[1000, 50] , tit='Avg DIV'+' '+sample_name, xtit='divergence(10!U-5!Ns!U-1!N)', ytit='p (hPa)', thick = 5
;ver, 0
;plot, avg_geo/1e5, pres_levels, yrange=[1000, 50] , tit='Avg GEOP'+' '+sample_name, xtit='geopotential(10!U5!Nm!U2!Ns!U-2!N)', ytit='p (hPa)', thick = 5
;plot, avg_pv*10000, pres_levels, yrange=[1000, 50] , tit='Avg PV'+' '+sample_name, xtit='PV(10!U-4!N K m!U2!Nkg!U-1!Ns!U-1!N)', ytit='p (hPa)', thick = 5
;ver, 0
;plot, avg_u, pres_levels, yrange=[1000, 50] , tit='Avg u-wind'+' '+sample_name, xtit='u(ms!U-1!N)', ytit='p (hPa)', thick = 5
;ver, 0
;plot, avg_v, pres_levels, yrange=[1000, 50] , tit='Avg v-wind'+' '+sample_name, xtit='v(ms!U-1!N)', ytit='p (hPa)', thick = 5
;ver, 0
;plot, avg_w*100, pres_levels, yrange=[1000, 50] , tit='Avg w'+' '+sample_name, xtit='w(10!U-2!Nms!U-1!N)', ytit='p (hPa)', thick = 5
;ver, 0
;plot, avg_vor*100000, pres_levels, yrange=[1000, 50] , tit='Avg Vorticity'+' '+sample_name, xtit='relative vorticity(10!U-5!Ns!U-1!N)', ytit='p (hPa)', thick = 5
;ver, 0

save, file= '/Volumes/User/eriley/CLOUDSAT/CLOUDSAT_CODE/ECMWF_plev_composites/' + sample_name + '.sav', $
      avg_T, avg_q, avg_cc, avg_ciwc, avg_clwc, avg_div, avg_geo, avg_pv, avg_rh, avg_u, avg_v, avg_vor, avg_w, $
      rain, sst, pw, EOnumbers

;psout
end 
