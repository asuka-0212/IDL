; NAME:
;     thm_asi_merge_mosaic_2_repeat
;
; PURPOSE:
;     repeat 'thm_asi_merge_mosaic_2' (creating mosaic with all THEMIS ASI) from start date to stop date
;
; KEYWORDS:   
;     date         : substorm event time
;     hr           : hour before and after "date". Images in this period are output
;     interval_min : interval time between images
;     interval_sec : interval time between images
;     mlt          : if this keyword is set, images are plotted in mlat-MLT coordinates.    
;
; EXAMPLE:
;     thm_asi_merge_mosaic_2_repeat, date='2008-03-09/11:00:00', hr = 3, interval_min = 5, /mlt
;
; HISTORY:
;     written by Asuka Hirai, 2020-03-11
;     modified by Asuka Hirai, 2020-03-23
;-
pro thm_asi_merge_mosaic_2_repeat, $
  date = date, hr = hr, interval_min = interval_min, interval_sec = interval_sec, mlt = mlt  
  
  timespan, date
  if not keyword_set(date) then begin
    print, 'Usage : THEMIS> thm_asi_merge_mosaic_2_repeat, date=date, hr = hr, interval_min = interval_min, mlt = mlt'
    print, "    ex) THEMIS> thm_asi_merge_mosaic_2_repeat, date='2008-03-09/11:00:00', hr = 3, interval_min = 5, /mlt"
    print, "    ex) THEMIS> thm_asi_merge_mosaic_2_repeat, date='2017-03-27/10:00:00', hr = 1, interval_sec = 3, /mlt"
    stop
  endif

  if not keyword_set(interval_min) and not keyword_set(interval_sec) then begin
    interval_sec = 3
    interval_min = 5
  endif

  time_start = time_double(date) - hr*60*60
  time_stop  = time_double(date) + hr*60*60

  while (time_start lt time_stop) do begin
    t_string = time_string(time_start)

    thm_asi_merge_mosaic_2, $
      t_string, central_lat = 90, central_lon = 255, $
      color_continent = 254, color_background = 254, /verbose, /no_grid, scale=5e7, xsize=1000, ysize=1000, window = 0, $
      /mlt, bytval = bytval

    if (max(bytval) ne 1.) then begin
    file = '\\130.34.116.251\machine_learning\themis\asi_pol\' + time_string(time_double(date), tformat='YYYYMMDDhhmmss') + '\'
;      file = 'E:\backup\themis\data\machine_learning\' + time_string(t_string, tformat='YYYYMMDD') + '\' 
      png = time_string(time_start, tformat='YYYYMMDDhhmmss')
      file_mkdir, file
      makepng, file + png
    endif  

    if keyword_set(interval_sec) then begin
      time_start += interval_sec
    endif else if keyword_set(interval_min) then begin
      time_start += interval_min * 60.0
    endif

  endwhile

end

pro thm_substorm_event

  time = []
  openr, lun, '\\130.34.116.251\machine_learning\themis\asi_pol\substorm_event.txt', /get_lun
  line = ' '
  while (~eof(lun)) do begin
    readf, lun, line
    time = [[time], [strmid(line,0,4), strmid(line,5,2), strmid(line,8,2), strmid(line,11,2), strmid(line,14,2)]]
  endwhile
  free_lun, lun
  
  clock_time = []
  st = systime(1)
  openw, lun,  '\\130.34.116.251\machine_learning\themis\asi_pol\clock_time.txt', /get_lun
  for i = 0, n_elements(time[0,*])-1 do begin
    date = time[0,i] + '-' + time[1,i] + '-' + time[2,i] + '/' + time[3,i] + ':' + time[4,i] + ':00'
    thm_asi_merge_mosaic_2_repeat, date = date, hr = 3, interval_min = 5, /mlt
    clock_time = [clock_time, systime(1)-st] 
    printf, lun, string(systime(1)-st) + ' sec'
  endfor
  
  free_lun, lun


end