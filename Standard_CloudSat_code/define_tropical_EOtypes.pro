;;;;PURPOSE - Assigns each EO a type
;;;;Definitions valid for EOs between 35°S - 35°N according to
;;;;                                         E. Riley (2009, MS thesis)
;;;;
;;;; - May need to change PATH name
;;;; - filename (.sav file) may need changed if more EOs are added to
;;;;dataset
;;;;
;;;;Emily Riley 06/01/2012 - original code in
;;;;                         (get_barplot_info_WHphases_18lonboxes_Dec2010masterlist_pinwheelphases.pro)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro go

PATH = '/Users/mapesgroup/CLOUDSAT/cloud_lists/'
filename = 'Masterlist_Dec2010.sav'
restore, PATH + filename

;w = where(abs(meanlats) le 35)

CLOUDTYPES = 0*TOPS - 9999
cloudtypes(where ( TOPS gt 10000 and BOTTOMS lt 3000 and BBWIDTHS ge 200)) = 0  ;;;wide deep precipitating (wdp)
cloudtypes(where ( TOPS gt 10000 and BOTTOMS lt 3000 and BBWIDTHS lt 200)) = 1  ;;;narrow deep precipitating (ndp)
cloudtypes(where ( TOPS gt 10000 and BOTTOMS ge 3000 and BOTTOMS  lt 7000)) = 2 ;;;(detached) anvil (an)
cloudtypes(where ( TOPS gt 10000 and BOTTOMS ge 7000)) = 3                         ;;;cirrus (ci)
cloudtypes(where ( TOPS le 10000 and TOPS gt 4500 and BOTTOMS lt 3000)) = 4     ;;;cumulus congestus (cg)
cloudtypes(where ( TOPS le 10000 and TOPS gt 4500 and BOTTOMS ge 3000)) = 5     ;;;altocumulus (ac)
cloudtypes(where ( TOPS le 4500  and BBWIDTHS ge 10)) = 6                          ;;;startocumulus (sc)
cloudtypes(where ( TOPS le 4500  and BBWIDTHS lt 10)) = 7                          ;;;cumulus (cu)

save, file = '~/CLOUDSAT/cloud_lists/tropical_cloudtypes.sav', cloudtypes

End 
