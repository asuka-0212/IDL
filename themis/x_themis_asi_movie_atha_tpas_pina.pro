pro x_themis_asi_movie_atha_tpas_pina, start_date=start_date, stop_date=stop_date, interval_sec = interval_sec

  if not keyword_set(start_date) or not keyword_set(stop_date) then begin
    print, 'Usage : THEMIS> x_themis_asi_movie_atha_tpas_pina, start_date=start_date, stop_date=stop_date, interval_min = interval_min'
    print, "    ex) THEMIS> x_themis_asi_movie_atha_tpas_pina, start_date='2017-03-27/07:00:00', stop_date='2017-03-27/07:30:00', interval_sec = 3"
    print, "    ex) THEMIS> x_themis_asi_movie_atha_tpas_pina, start_date='2017-03-27/07:00:00', stop_date='2017-03-27/07:00:03', interval_sec = 3"
    print, "    ex) THEMIS> x_themis_asi_movie_atha_tpas_pina, start_date='2017-03-27/10:00:00', stop_date='2017-03-27/11:20:00', interval_sec = 3"
    stop
  endif

  trg_ath = [246.7  ,54.7  ]
  trg_pkr = [212.512  ,65.125]
  ndk = [261.467,46.367] ; 25.2kHz
  lf_get_gcp, src=ndk,  trg=trg_ath, gcp_lon=lon1, gcp_lat=lat1
  lf_get_gcp, src=ndk,  trg=trg_pkr, gcp_lon=lon2, gcp_lat=lat2
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
    thm_asi_merge_mosaic, t_string, /verbose, scale=2.1e7, xsize=1200, ysize=800, $
      central_lat=53.0, central_lon=255.0, show=['atha', 'tpas', 'pina']

  
    plots,lon1,lat1, color=cgcolor('red')  &  xyouts, lon1[nc],lat1[nc], 'NDK(25.2)',ALIGNMENT=0.5
    plots,lon2,lat2, color=cgcolor('blue')  &  xyouts, lon2[nc],lat2[nc], 'NDK(25.2)',ALIGNMENT=0.5

    png_file = 'asi_'+strmid(t_string,0,4)+strmid(t_string,5,2)+strmid(t_string,8,2)+'_'+strmid(t_string,11,2)+strmid(t_string,14,2)+strmid(t_string,17,2)
    makepng, png_file

    time_start += interval_sec

  endwhile

end
