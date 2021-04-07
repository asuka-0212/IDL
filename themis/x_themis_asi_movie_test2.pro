pro x_themis_asi_movie_test2, $
  start_date=start_date, stop_date=stop_date, interval_min = interval_min, interval_sec = interval_sec, mlt = mlt

  if not keyword_set(start_date) or not keyword_set(stop_date) then begin
    print, 'Usage : THEMIS> x_themis_asi_movie_test2, start_date=start_date, stop_date=stop_date, interval_min = interval_min'
    print, "    ex) THEMIS> x_themis_asi_movie_test2, start_date='2017-03-27/03:00:00', stop_date='2017-03-27/12:00:00', interval_min = 10"
    print, "    ex) THEMIS> x_themis_asi_movie_test2, start_date='2017-03-21/06:00:00', stop_date='2017-03-21/10:00:00', interval_min = 10"
    print, "    ex) THEMIS> x_themis_asi_movie_test2, start_date='2017-03-29/05:00:00', stop_date='2017-03-29/12:00:00', interval_min = 10"
    print, "    ex) THEMIS> x_themis_asi_movie_test2, start_date='2011-07-07/06:00:00', stop_date='2011-07-07/10:00:00', interval_sec = 3"
    print, "    ex) THEMIS> x_themis_asi_movie_test2, start_date='2017-03-27/10:00:00', stop_date='2017-03-27/11:20:00', interval_sec = 3"
    print, "    ex) THEMIS> x_themis_asi_movie_test2, start_date='2017-03-27/10:00:00', stop_date='2017-03-27/11:20:00', interval_sec = 3, /mlt"
    stop
  endif

  if not keyword_set(interval_min) and not keyword_set(interval_sec) then begin
    interval_sec = 3
  endif

  time_start = time_double(start_date)
  time_stop  = time_double(stop_date)
  
  ;calcurate magnetic north
  t = time_struct(start_date)
  geopack_recalc, t.year, t.month, t.date, t.hour, t.sec, t.min, /date
  geopack_sphcar, 1.017265735, 0, 255, x, y, z, /to_rect, /degree       ;r=110km from surface
  geopack_conv_coord, x, y, z, d1, d2, d3, /FROM_MAG, /TO_GEO
  geopack_sphcar, d1, d2, d3, r, theta, phi, /to_sphere, /degree
  mlat_n = 90 - theta ;magneic north
  mlon_n = phi
  
  
  
  while (time_start lt time_stop) do begin
    t_string = time_string(time_start)

    ;    thm_asi_create_mosaic, t_string, /verbose, scale=5.0e7, xsize=1200, ysize=800
    thm_asi_merge_mosaic_2, $
      t_string, central_lat = 90, central_lon = 255, $
      color_continent = 254, color_background = 254, /verbose, /no_grid, scale=5e7, xsize=1000, ysize=1000, window =4, $
      projection = STEREOGRAPHIC, /mlt
;    map_grid, color = 0  

    file = 'E:\backup\themis\data\asi\' + strmid(start_date, 0, 4) + strmid(start_date, 5, 2) + strmid(start_date, 8, 2) + $
      '\asi_' + strmid(start_date, 0, 4) + strmid(start_date, 5, 2) + strmid(start_date, 8, 2) + '_northamerica'
    png  = 'asi_'+strmid(t_string,0,4)+strmid(t_string,5,2)+strmid(t_string,8,2)+'_'+strmid(t_string,11,2)+strmid(t_string,14,2)+strmid(t_string,17,2)
    res  = file_test(file)
    if res eq 0 then file_mkdir, file
;    makepng, file + '\' + png

    if keyword_set(interval_sec) then begin
      time_start += interval_sec
    endif else if keyword_set(interval_min) then begin
      time_start += interval_min * 60.0
    endif

  endwhile

end
