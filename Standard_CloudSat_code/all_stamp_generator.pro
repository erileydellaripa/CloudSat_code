pro all_stamp_generator,  FILENAMES=filenames, BBWIDTHS = bbwidths, TOPS=tops, BOTTOMS=bottoms, $
                          MEANLONS=meanlons, MEANLATS = meanlats, NAME = name, nlons = nlons, $
                          startlon = startlon
            
;smush_factor = (360.*40.)/nlons ;;Nlons: home many degrees of longitude the area of interest is

;startingx = round(min(meanlons))*smush_factor ;;; ~km                    
;Plotxsize = nlons*smush_factor + startingx ;;~km
startingx = 0
PLOTXSIZE = nlons * 111. ;;111 km = 1°longitude
PLOTZSIZE = 20 ;;; Km - 20km tropospheres stacked

plot, [0],[0], xra=[startingx,PLOTXSIZE], yra=[0,PLOTZSIZE], /nodata, $;/nodata, /noerase, $
      ytitle = 'height (km)', Xstyle = 9, Xtitle = 'km';'longitude*'+str(smush_factor) 
spacing = (plotxsize - startingx)/8.
axis, xaxis=1, xticks=9, xtickv=startingx + [0, spacing, spacing*2, spacing*3, spacing*4, spacing*5, $
                                             spacing*6, spacing*7, spacing*8], $
      Xtickn = ['50', '55', '60', '65', '70', '75', '80', '85', '90'], xtitle = 'longitude'
;Xyouts, 100, 18, 'seed = '

;;;Define cloudtypes
CLOUDTYPES = 0*TOPS
cloudtypes(where ( TOPS gt 10000 and bottoms lt 3000 and bbwidths ge 200)) = 0
cloudtypes(where ( TOPS gt 10000 and bottoms lt 3000 and bbwidths lt 200)) = 1
cloudtypes(where ( TOPS gt 10000 and bottoms ge 3000 and bottoms lt 7000)) = 2
cloudtypes(where ( TOPS gt 10000 and bottoms ge 7000)) = 3
cloudtypes(where ( TOPS le 10000 and tops gt 4500 and bottoms lt 3000)) = 4
cloudtypes(where ( TOPS le 10000 and tops gt 4500 and bottoms ge 3000)) = 5
cloudtypes(where ( TOPS le 4500 and bbwidths ge 10)) = 6
cloudtypes(where ( TOPS le 4500 and bbwidths lt 10)) = 7

list = filenames
EOsize = bbwidths
type = cloudtypes
meanlons_list = meanlons

;;;;Sort according to cloudtype, so will then be able to plot wcb a
;;;;different color.
sortby = sort(type)
type = type[sortby]
list = list[sortby]
EOsize = EOsize[sortby]
meanlons_list = meanlons_list[sortby]

;;;;Define the color scale: white->red for wcb, white->blue all others
steps = 106
scalefactor = findgen(steps)/(steps - 1)

For i = 0L, n_elements(type) - 1 do begin
   if type[i] eq 0 then begin
      r = replicate(255, steps)
      b = reverse(0 + (0+255)*scalefactor)
      g = reverse(0 + (0+255)*scalefactor)
   endif else begin
      r = reverse(0 + (0+255)*scalefactor)
      b = replicate(255, steps)
      g = reverse(0 + (0+255)*scalefactor)
   Endelse  

   plot_stamps_bylongitude, FILENAMES = list[i], meanlons = meanlons_list[i], nlons = nlons, $
                            R = r, G = g, B = b, NAME = name, startlon = startlon 

Endfor 

end 

