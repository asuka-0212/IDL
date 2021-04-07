
pro x_themis_asi_movie_test, start_date=start_date, stop_date=stop_date, interval_min = interval_min, interval_sec = interval_sec
  cpath='/Volumes/moxonraid/data/themis/thg/graph'
  if not keyword_set(start_date)   then start_date='2017-03-21/06:00:00'
  if not keyword_set(stop_date)    then stop_date='2017-03-21/10:00:00'
  if not keyword_set(interval_min) then interval_min = 5
  
  strarr=strsplit(start_date,'-/:',/ext)
  outdir=strarr[0]+strarr[1]+strarr[2]+strarr[3]
  file_mkdir, cpath+'/'+outdir
  
  ;scale=5.0e7
;  scale=2.5d+7
  scale=0.d
  if not keyword_set(start_date) or not keyword_set(stop_date) then begin
    print, 'Usage : THEMIS> x_themis_asi_movie_test, start_date=start_date, stop_date=stop_date, interval_min = interval_min'
    print, "    ex) THEMIS> x_themis_asi_movie_test, start_date='2017-03-21/06:00:00', stop_date='2017-03-21/10:00:00', interval_min = 10"
    print, "    ex) THEMIS> x_themis_asi_movie_test, start_date='2017-03-27/10:00:00', stop_date='2017-03-27/11:20:00', interval_sec = 3"
    stop
  endif

  if not keyword_set(interval_min) and not keyword_set(interval_sec) then begin
    interval_sec = 3
  endif
  
  time_start = time_double(start_date)
  time_stop  = time_double(stop_date)

  image_count=0l
  while (time_start lt time_stop) do begin
    t_string = time_string(time_start)
    if image_count eq 0l then create_window=1l else create_window=!NULL
    thm_asi_merge_mosaic, t_string, /verbose, scale=scale, xsize=1200, ysize=800, color_background=1;, create_window=create_window

  
    png_file = 'asi_'+strmid(t_string,0,4)+strmid(t_string,5,2)+strmid(t_string,8,2)+'_'+strmid(t_string,11,2)+strmid(t_string,14,2)+strmid(t_string,17,2)
    makepng, cpath+'/'+outdir+'/'+png_file

    if keyword_set(interval_sec) then begin      
      time_start += interval_sec
    endif else if keyword_set(interval_min) then begin
      time_start += interval_min * 60.0
    endif
  image_count++
  endwhile

end
