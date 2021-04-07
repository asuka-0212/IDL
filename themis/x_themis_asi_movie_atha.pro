pro x_themis_asi_movie_atha, start_date=start_date, stop_date=stop_date, interval_sec = interval_sec

  if not keyword_set(start_date) or not keyword_set(stop_date) then begin
    print, 'Usage : THEMIS> x_themis_asi_movie_atha, start_date=start_date, stop_date=stop_date, interval_min = interval_min'
    print, "    ex) THEMIS> x_themis_asi_movie_atha, start_date='2017-03-27/07:00:00', stop_date='2017-03-27/07:30:00', interval_sec = 3"
    print, "    ex) THEMIS> x_themis_asi_movie_atha, start_date='2017-03-27/07:00:00', stop_date='2017-03-27/07:00:03', interval_sec = 3"
    print, "    ex) THEMIS> x_themis_asi_movie_atha, start_date='2017-03-27/10:00:00', stop_date='2017-03-27/11:20:00', interval_sec = 3"
    stop
  endif

  trg_ath = [246.7  ,54.7  ]
  trg_pkr = [212.512  ,65.125]
  ndk  = [261.467,46.367] ; 25.2kHz
  wwvb = [254.950,40.667] ; 60.0kHz
  nlk  = [238.083,48.200] ; 24.8kHz
  lf_get_gcp, src=ndk,   trg=trg_ath, gcp_lon=lon1, gcp_lat=lat1
  lf_get_gcp, src=ndk,   trg=trg_pkr, gcp_lon=lon2, gcp_lat=lat2
  lf_get_gcp, src=wwvb,  trg=trg_ath, gcp_lon=lon3, gcp_lat=lat3
  lf_get_gcp, src=nlk,   trg=trg_ath, gcp_lon=lon4, gcp_lat=lat4
  lf_get_gcp, src=nlk,   trg=trg_pkr, gcp_lon=lon5, gcp_lat=lat5
  nc = n_elements(lon1)/2
  
  time_start = time_double(start_date)
  time_stop  = time_double(stop_date)

  while (time_start lt time_stop) do begin
    t_string = time_string(time_start)

;    thm_asi_create_mosaic, t_string, /verbose, scale=2.1e7, xsize=1200, ysize=800, $
;      central_lat=53.0, central_lon=255.0, $
;                             show=['atha', 'tpas', 'pina']
;                             exclude=['chbg', 'ekat', 'fsmi', 'fsim', 'fykn', 'gako', 'gbay', 'gill', 'inuv', 'kapu', 'kian', 'kuuj', 'mcgr', 'pgeo', 'rank', 'snkq', 'whit', 'yknf', 'nrsq', 'snap', 'talo']
;    thm_asi_create_mosaic, t_string, /verbose, scale=1.6e7, xsize=800, ysize=800, $
;                             central_lat=55.0, central_lon=247.0, show=['atha']
;                           central_lat=54.0, central_lon=258.0, show=['tpas']
    thm_asi_merge_mosaic, t_string, /verbose, scale=1.5e7, xsize=1200, ysize=800, maxval=3000, minval=1, window=1, $
      central_lat=trg_ath[1], central_lon=trg_ath[0], show=['atha']

  
    plots,lon1,lat1, color=cgcolor('red')  &  xyouts, lon1[nc],lat1[nc], 'NDK(25.2)',ALIGNMENT=0.5
    plots,lon1[n_elements(lon1)/2], lat1[n_elements(lon1)/2], psym = 1, symsize = 3, color = cgcolor('red')
    plots,lon2,lat2, color=cgcolor('blue')  &  xyouts, lon2[nc],lat2[nc], 'NDK(25.2)',ALIGNMENT=0.5
    plots,lon2[n_elements(lon2)/2], lat2[n_elements(lon2)/2], psym = 1, symsize = 3, color = cgcolor('blue')
    plots,lon3,lat3, color=cgcolor('red')  &  xyouts, lon3[nc],lat3[nc], 'WWVB(60.0)',ALIGNMENT=0.5
    plots,lon3[n_elements(lon3)/2], lat3[n_elements(lon3)/2], psym = 1, symsize = 3, color = cgcolor('red')
    plots,lon4,lat4, color=cgcolor('red')  &  xyouts, lon4[nc],lat4[nc], 'NLK(24.8)',ALIGNMENT=0.5
    plots,lon4[n_elements(lon4)/2], lat4[n_elements(lon4)/2], psym = 1, symsize = 3, color = cgcolor('red')
    plots,lon5,lat5, color=cgcolor('blue')  &  xyouts, lon5[nc],lat5[nc], 'NLK(25.2)',ALIGNMENT=0.5
    plots,lon5[n_elements(lon5)/2], lat5[n_elements(lon5)/2], psym = 1, symsize = 3, color = cgcolor('blue')
    
    get_lval_trace, 3.5, glat=glat_L, glon=glon_L, n=100, hemis='n'
    plots, glon_L, glat_L, color=cgcolor('black'), linestyle=1
    get_lval_trace, 4.0, glat=glat_L, glon=glon_L, n=100, hemis='n'
    plots, glon_L, glat_L, color=cgcolor('black'), linestyle=1
    get_lval_trace, 4.5, glat=glat_L, glon=glon_L, n=100, hemis='n'
    plots, glon_L, glat_L, color=cgcolor('black'), linestyle=1
    get_lval_trace, 5.0, glat=glat_L, glon=glon_L, n=100, hemis='n'
    plots, glon_L, glat_L, color=cgcolor('black'), linestyle=1

    png_file = 'E:\backup\themis\data\asi\20170327\asi_20170327_ath\asi_'+strmid(t_string,0,4)+strmid(t_string,5,2)+strmid(t_string,8,2)+'_'+strmid(t_string,11,2)+strmid(t_string,14,2)+strmid(t_string,17,2)
    makepng, png_file

    time_start += interval_sec

  endwhile

end
