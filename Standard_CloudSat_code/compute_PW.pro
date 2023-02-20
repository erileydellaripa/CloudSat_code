;;ERiley 08/08/2012
;;Compute precipitable water
;;
;;USES - mixrat.pro
;;
;;INPUTS - z_array - array of heights, must be in meters and going
;;         from surface to top level, so for ECMWF soundings do
;;z_array = reverse(zplot)*1000.
;;         q_array - specific humidity, must be in kg/kg
;;                   as computed in process_ECMWF_orbit_pair.pro,
;;units are in g/kg, so do q_array = q_avg/1000.
;;
;;         T_array - units Kelvin
;;
;;         p_array - units mb/hpa, if have p_array, then just set
;;                   input p_array to -999
;;
;;Assumptions - surface pressure = 1000 hpa/mb
;;            - scale height is 8 km

FUNCTION compute_PW, q_array, z_array, T_array, p_array

;print, 'Make sure z_array is in m and goes from surface to top level'
;print, 'Make sure q_array is in kg/kg '

;;only use heights above ground z > 0 m, or pressure above 0 or
;;q_array ge 0
w1 = where(p_array ge 0)
w2 = where(z_array ge 0)
w3 = where(q_array ge 0)
;;Find the largest minimum index value
dummy = max([min(w1), min(w2), min(w3)])
if dummy eq min(w1) then w = w1
if dummy eq min(w2) then w = w2
if dummy eq min(w3) then w = w3
;stop
z_array = z_array[w]
p_array = p_array[w]
T_array = t_array[w]
q_array = q_array[w]

;Define some constants
rho     = 10^3                 ;;; kg/m^3 density of water
g       = 9.806                ;;;m/s^2 gravity
epsilon = 0.621970585          ;;;ratio of the molecular weights of water and dry ai
Rd      = 286.9968933          ;;;J/K/kg gas constant for dry air
H       = 8000                 ;;;m approx. scale height 
psurf   = 1000*100.    ;;;put in Pascals

;;;;;;;;;IF ONLY HAVE Z_ARRAY WILL NEED TO SOLVE FOR pressure
;;;;;;;;;differences
IF p_array[0] LT -99 THEN BEGIN
;;;use hypsometric equation to convert height to pressure
;;p1/ exp(g*del(z)/(Rd*Tv)) = p2, or p1/exp(del(z)/H) = p2
;;;TV = T*(1 + ((1-epsilon)/epsilon )*w) - w is mixing ratio, mv/md,
;;;            specific humidit is mv/(md + mv), so they're
;;;            nearly the same
;;;TV = T(1 + 0.61w)
;;;
;;;compute mixing ratio - units must be degC and mb
   T_degC = T_array - 272.15
   w = mixrat(T_degC, p_array)  ;units kg/kg in mixrat.pro ;;WOULDN"T HAVE p_array, so I guess you can't compute w, would just have to use specific humidity as an approximation 
;;;compute virtual temperature
   Tv = T_array*(1 + (0.61*w))
;;;convert z to p
   zground = min(z_array)
   delz = z_array - zground
;p = psurf/exp(delz/H)
   denom = exp((g*delz)/(Rd*Tv))>1
   p_array = psurf/denom
   p_array = psurf/exp(delz/H)
  
ENDIF ELSE p_array = p_array*100 ;put in pascals
p_diff = fltarr(n_elements(p_array)) 
avg_q = fltarr(n_elements(p_array))

for i = 0, n_elements(p_array)-2 do p_diff[i] = p_array[i] - p_array[i+1]
for i = 0, n_elements(p_array)-2 do avg_q[i] = mean(q_array[i:i+1])

pw = 1/(rho*g) * total(avg_q*p_diff) ;;units are meters

pw = pw*1000. ;units are mm

return, pw

END

