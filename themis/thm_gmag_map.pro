; thm_gmag_map
;
; PURPOSE:
;     plot themis GMAG satation in North America
;
; HISTORY:
;     created by Asuka Hirai, 2018-09-11
;-
pro thm_gmag_map
  
  window, 0, xsize=800, ysize=800
  !p.position=[0.01,0.05,0.99,0.99]
  map2d_init
  map2d_coord, 'geo'
  ;  map2d_set,glat=55.,glonc=240.,scale=60e+6,/erase,/label   ;default
  map2d_set,glat=55.,glonc=250.,scale=40e+6,/erase,/label
  overlay_map_coast
  
  ;l-value
  get_lval_trace, 6.0, glat=glat_L6, glon=glon_L6, n=100, hemis='n'
  get_lval_trace, 5.0, glat=glat_L5, glon=glon_L5, n=100, hemis='n'
  get_lval_trace, 4.0, glat=glat_L4, glon=glon_L4, n=100, hemis='n'
  get_lval_trace, 3.0, glat=glat_L3, glon=glon_L3, n=100, hemis='n'
  get_lval_trace, 2.0, glat=glat_L2, glon=glon_L2, n=100, hemis='n'
  plots, glon_L6, glat_L6, color=cgcolor('blue')
  plots, glon_L5, glat_L5, color=cgcolor('blue')
  plots, glon_L4, glat_L4, color=cgcolor('blue')
  plots, glon_L3, glat_L3, color=cgcolor('blue')
  plots, glon_L2, glat_L2, color=cgcolor('blue')
  
  ;THEMIS GMAG station
  ;amer = [263.700, 38.500]
  atha = [246.36, 54.60]
  fsmi = [248.07, 60.03]
  gill = [265.34, 56.35]
  pgeo = [237.172, 53.815]
  pina = [263.96, 50.20]
  snkq = [280.77, 56.54]
  sit  = [244.67, 57.06]
  tpas = [259.059, 53.994]
  vldr = [-77.757, 48.190]
  whit = [224.78, 61.01]
  plots, [atha[0], fsmi[0]], [atha[1], fsmi[1]], psym = 7, color = 1
  xyouts, atha[0], atha[1], 'atha', ALIGNMENT=1, CHARSIZE=1.2
  xyouts, fsmi[0], fsmi[1], 'fsmi', ALIGNMENT=1, CHARSIZE=1.2
  plots, [gill[0], pgeo[0]], [gill[1], pgeo[1]], psym = 7, color = 1
  xyouts, gill[0], gill[1], 'gill', ALIGNMENT=1, CHARSIZE=1.2
  xyouts, pgeo[0], pgeo[1], 'pgeo', ALIGNMENT=1, CHARSIZE=1.2
  plots, [pina[0], snkq[0]], [pina[1], snkq[1]], psym = 7, color = 1
  xyouts, pina[0], pina[1], 'pina', ALIGNMENT=1, CHARSIZE=1.2
  xyouts, snkq[0], snkq[1], 'snkq', ALIGNMENT=1, CHARSIZE=1.2
  plots, [sit[0], tpas[0]], [sit[1], tpas[1]], psym = 7, color = 1
  xyouts, sit[0], sit[1], 'sit', ALIGNMENT=1, CHARSIZE=1.2
  xyouts, tpas[0], tpas[1], 'tpas', ALIGNMENT=1, CHARSIZE=1.2
  plots, [vldr[0], whit[0]], [vldr[1], whit[1]], psym = 7, color = 1
  xyouts, vldr[0], vldr[1], 'vldr', ALIGNMENT=1, CHARSIZE=1.2
  xyouts, whit[0], whit[1], 'whit', ALIGNMENT=1, CHARSIZE=1.2
  
  
end