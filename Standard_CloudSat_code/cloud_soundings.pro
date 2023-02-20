pro cloud_soundings, FILENAMES=filenames, SAMPLE_NAME=sample_name, TOPS = tops, BOTTOMS = bottoms, PATH = path

;PATH ='/Volumes/Mini_me/cloud_soundings/' 
;PATH = '/Volumes/silverbullet/cloud_soundings/'
;Path = '/Volumes/Green/new_EO_soundings/'
;Path = '/Volumes/silverbullet/new_EO_soundings/'

;land
;device, file=SAMPLE_NAME+'.sounding.ps'


;;;;Make sum & num arrays to be filled
TSUM = fltarr(125)
TNUM = fltarr(125)

QSUM = fltarr(125)
QNUM = fltarr(125)

PSUM = fltarr(125)
PNUM = fltarr(125)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop over clouds
for i = 0L, n_elements(filenames)-1 do begin
    
    soundingfile = PATH + strmid(filenames[i], 0, 19) + $
      '/'+filenames[i] + '.sav'
    command = 'restore, file= soundingfile'
    errr = execute(command)

    If (errr eq 0) then goto, jump99

;    restore, soundingfile ;;; p_avg, T_avg, q_avg, zplot
    
    ;;;;Get only the bins we are interested in, bins[0:19] are below sfc
    T_avg = T_avg[20:124]
    q_avg = q_avg[20:124]
    p_avg = p_avg[20:124]

    TSUM = TSUM + (T_avg > 0)
    TNUM = TNUM + (T_avg ge 0)

    QSUM = QSUM + (q_avg > 0)
    QNUM = QNUM + (q_avg ge 0)

    PSUM = PSUM + (p_avg > 0)
    PNUM = PNUM + (p_avg ge 0)
;    !p.multi = [0,2,2]
;    plot, T_avg, reverse(zplot), yran=[0,25], xran=[0,310], tit='T cloud'+' '+str(i)+' jday '+str(jdays[i]), $
;      xtit='T(K)', ytit='z(km)'
;    plot, q_avg, reverse(zplot), yran=[0,25], xran=[-.5,20], tit='q cloud'+' '+str(i)+' jday '+str(jdays[i]), $
;      xtit='q(g/kg)', ytit='z(km)'
;    plot, p_avg, reverse(zplot), yran=[0,25], xran=[0,1020],tit='p cloud'+' '+str(i)+' jday '+str(jdays[i]), $
;      xtit='p(mb)', ytit='z(km)'

    print, T_avg[0], ' surface T cloud ', i
    print, q_avg[0], ' surface q cloud ', i
    print, p_avg[0], ' surface p cloud ', i
;    if T_avg[0] gt 310 then stop
jump99:
endfor 

avg_T = TSUM/(TNUM > 1)
avg_q = QSUM/(QNUM > 1)
avg_p = PSUM/(PNUM > 1)

;;;reverse zplot cause bin[0] ~ 24km & we want bin[0] = 0.0
z = reverse(zplot) 
z = z[20:124]

;;;;;;;;Compute -dT/dz;;;;;;;;;;;;
dT_dz = deriv(z, avg_T)*(0-1) ;;;units - degC/km

;;;;;;;;;Compute dtheta/dp;;;;;;;;
;;must put T in deg C first
T_degC = avg_T - 273.15
potentialT = theta(avg_p, T_degC)
dtheta_dp = deriv(avg_p, potentialT)*100 ;;;units - degC/100hPa

;;;;;;;;;;;Compute RH;;;;;;;;;;;;;
;;;mixing ratio first
w = mixrat(T_degC, avg_p)*1000 ;;;units - g/kg, since units of avg_q are g/kg
RH = (avg_q/w)*100.

;;;;;;Compute Brian's poor man's buoyancy;;;;;;;;;
avg_q_kg = avg_q/1000. ;;;must put q back in units of kg/kg to compute thetae & theta_esat
w_kg = w/1000.         ;;;must put q back in units of kg/kg to compute thetae & theta_esat
thetae = theta_e(T_degC, avg_p, avg_q_kg)
thetasat = theta_e(T_degC, avg_p, w_kg)

;;;Plot 'em up
;plot, avg_T, z, yran=[0,20], tit='Avg T Sounding'+' '+sample_name, xtit='T(K)', ytit='z(km)'
;plot, avg_q, z, yran=[0,20], tit='Avg q sounding'+' '+sample_name, xtit='q(g/kg)', ytit='z(km)'
;plot, avg_p, z, yran=[0,20], tit='Avg P sounding'+' '+sample_name, xtit='P(mb)', ytit='z(km)'
;plot, dT_dz, z, yran=[0,15], xran=[0,10],tit='Lapse rate (-dT/dz)'+' '+sample_name, xtit='degC/km', ytit='z(km)'
;plot, dtheta_dp, z, yran=[0,15], xran=[-10,0],tit='Lapse rate (dtheta/dp)'+' '+sample_name, xtit='degC/100hPa', ytit='z(km)'
;plot, RH, z, yran=[0,15], xran=[0,100],tit='Relative Humidity'+' '+sample_name, xtit='percent', ytit='z(km)'
;plot, thetae, z, yran=[0,18], xran=[330,400],tit='theta_e'+' '+sample_name, $
;  xtit='T(K)', ytit='z(km)', subtit='solid=theta_e, dashed=theta_esat'
;oplot, thetasat, z, linestyle = 2

save, file= '/Users/eriley/CLOUDSAT/CLOUDSAT_CODE/Soundings/' + sample_name + '.sav', $
  avg_T, avg_q, avg_p, z, dT_dz, dtheta_dp, RH, thetae, thetasat

;psout
end 
