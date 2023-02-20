pro go

land
device, file = 'red_blue_dbz-bars.ps'
!p.multi = 0

steps = 106
scalefactor = findgen(steps)/(steps - 1)

r = replicate(255, steps)
b = reverse(0 + (0+255)*scalefactor)
g = reverse(0 + (0+255)*scalefactor)

loadct, 0, ncolors = 150
tvlct, r, g, b, 150

array = lindgen(51) - 30
dbzcolors = (array + 50) * 3.5 > 0 < 250

map_world, /cont
make_key, colors = dbzcolors, labels = ['-30', '-5 dbz'], units = '20'


r = reverse(0 + (0+255)*scalefactor)
b = replicate(255, steps)
g = reverse(0 + (0+255)*scalefactor)

loadct, 0, ncolors = 150
tvlct, r, g, b, 150

map_world, /cont
make_key, colors = dbzcolors, labels = ['-30', '-5 dbz'], units = '20'

psout
end 
