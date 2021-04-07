pro x_themis_asi_movie, start_date=start_date, stop_date=stop_date, interval_min = interval_min, interval_sec = interval_sec

  if not keyword_set(start_date) or not keyword_set(stop_date) then begin
    print, 'Usage : THEMIS> x_themis_asi_movie, start_date=start_date, stop_date=stop_date, interval_min = interval_min'
    print, "    ex) THEMIS> x_themis_asi_movie, start_date='2017-03-27/03:00:00', stop_date='2017-03-27/12:00:00', interval_min = 10"
    print, "    ex) THEMIS> x_themis_asi_movie, start_date='2017-03-21/06:00:00', stop_date='2017-03-21/10:00:00', interval_min = 10"
    print, "    ex) THEMIS> x_themis_asi_movie, start_date='2017-03-29/05:00:00', stop_date='2017-03-29/12:00:00', interval_min = 10"
    print, "    ex) THEMIS> x_themis_asi_movie, start_date='2011-07-07/06:00:00', stop_date='2011-07-07/10:00:00', interval_sec = 3"
    print, "    ex) THEMIS> x_themis_asi_movie, start_date='2017-03-27/10:00:00', stop_date='2017-03-27/11:20:00', interval_sec = 3"
    stop
  endif

  if not keyword_set(interval_min) and not keyword_set(interval_sec) then begin
    interval_sec = 3
  endif

  trg_ath = [246.7  ,54.7  ]
  trg_pkr = [212.512  ,65.125]
  wwvb= [254.950,40.667] ; 60.0kHz
  naa = [292.717,44.650] ; 24.0kHz
  ndk = [261.467,46.367] ; 25.2kHz
  nlk = [238.083,48.200] ; 24.8kHz
  lf_get_gcp, src=wwvb, trg=trg_ath, gcp_lon=lon1, gcp_lat=lat1
  lf_get_gcp, src=naa,  trg=trg_ath, gcp_lon=lon2, gcp_lat=lat2
  lf_get_gcp, src=ndk,  trg=trg_ath, gcp_lon=lon3, gcp_lat=lat3
  lf_get_gcp, src=nlk,  trg=trg_ath, gcp_lon=lon4, gcp_lat=lat4
  lf_get_gcp, src=ndk,  trg=trg_pkr, gcp_lon=lon5, gcp_lat=lat5
  lf_get_gcp, src=nlk,  trg=trg_pkr, gcp_lon=lon6, gcp_lat=lat6
  nc = n_elements(lon1)/2
  
  time_start = time_double(start_date)
  time_stop  = time_double(stop_date)

  while (time_start lt time_stop) do begin
    t_string = time_string(time_start)

;    thm_asi_create_mosaic, t_string, /verbose, scale=5.0e7, xsize=1200, ysize=800
    thm_asi_merge_mosaic, t_string, /verbose, scale=5.0e7, xsize=1200, ysize=800
  
    plots,lon1,lat1, color=cgcolor('red')  &  xyouts, lon1[nc],lat1[nc], 'WWVB(60.0)',ALIGNMENT=0.5
    plots,lon2,lat2, color=cgcolor('red')  &  xyouts, lon2[nc],lat2[nc], 'NAA(24.0)',ALIGNMENT=0.5
    plots,lon3,lat3, color=cgcolor('red')  &  xyouts, lon3[nc],lat3[nc], 'NDK(25.2)',ALIGNMENT=0.5
    plots,lon4,lat4, color=cgcolor('red')  &  xyouts, lon4[nc],lat4[nc], 'NLK(24.8)',ALIGNMENT=0.5
    plots,lon5,lat5, color=cgcolor('blue')  &  xyouts, lon5[nc],lat5[nc], 'NDK(25.2)',ALIGNMENT=0.5
    plots,lon6,lat6, color=cgcolor('blue')  &  xyouts, lon6[nc],lat6[nc], 'NLK(24.8)',ALIGNMENT=0.5

    file = 'E:\backup\themis\data\asi\' + strmid(start_date, 0, 4) + strmid(start_date, 5, 2) + strmid(start_date, 8, 2) + $
      '\asi_' + strmid(start_date, 0, 4) + strmid(start_date, 5, 2) + strmid(start_date, 8, 2) + '_northamerica'
    png  = 'asi_'+strmid(t_string,0,4)+strmid(t_string,5,2)+strmid(t_string,8,2)+'_'+strmid(t_string,11,2)+strmid(t_string,14,2)+strmid(t_string,17,2) 
    res  = file_test(file)
    if res eq 0 then file_mkdir, file
    makepng, file + '\' + png

    if keyword_set(interval_sec) then begin      
      time_start += interval_sec
    endif else if keyword_set(interval_min) then begin
      time_start += interval_min * 60.0
    endif

  endwhile

end
