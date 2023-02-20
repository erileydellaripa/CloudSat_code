PRO GO

land
device, file = 'plot_monthly_ITCZ_hists.eps'
device, xsize = 26, ysize = 19
!p.multi = [0, 3, 4]

month_name = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', $
              'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
label = ['(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', $
         '(i)', '(j)', '(k)', '(l)']

days = [31.*5+17-4-16., 5.*28.+1, 5.*31.-4., 5.*30.+13.-4., 5.*31.-6., 5.*30.+16., 31.*6., $
        31.*6., 30.*6. - 5., 31.*6.-3, 30.*6., 31.*6.-25.]

samples = 8.04*(360/233.)*3*[days]
PATH = '~/CLOUDSAT/combined_hists/'
hist_type = 'latlonhist'
FOR i = 0, n_elements(month_name) - 1 DO BEGIN

   restore, path+month_name[i]+'.ITCZ.'+hist_type+'.sav'

   contour, (total_hist/samples[i])*100., lonaxis, lataxis, /fill, levels = findgen(101), yrange = [-15, 15], xrange = [-150, -75], $
            title = label[i]+' '+month_name[i], xtitle = 'longitude', ytitle = 'latitude', charsize = 1.3
   map_world, /over, /cont, c_thick = 3

b = total_hist/samples[i]
hlp, b
hlp, total_hist
END 

levels = findgen(101)
colorbar, colors = levels*(!D.N_colors)/100., bottoms = 0, divisions = 4, $ ;format = '(f4.1)', $
          range = [levels[0], levels[100]], /vertical,  position = [.01, .35, .02, .65], title = 'cloud cover (%)', $
          charsize = 1.4


psout
END
