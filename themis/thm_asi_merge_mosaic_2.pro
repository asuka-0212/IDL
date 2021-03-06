pro mlt2,t0,solar_dec,mlon,mlt,mslon
  common mlt_com,sol_dec_old,told,mslon1,mslon2

  if ((abs(solar_dec-sol_dec_old) gt 0.1) or (sol_dec_old eq 0)) then told=1e12
  if (abs(mslon2-mslon1) gt 10) then told=1e12;

  if ((t0 ge told) and (t0 lt (told+600))) then $
    mslon=mslon1+(t0-told)*(mslon2-mslon1)/600.0 $
  else begin
    told=t0
    sol_dec_old=solar_dec

    slon1 = (43200.0-t0)*15.0/3600.0
    slon2 = (43200.0-t0-600)*15.0/3600.0

    height = 450
    convert_geo_coord,solar_dec,slon1,height,mslat1,mslon1,4,err
    convert_geo_coord,solar_dec,slon2,height,mslat2,mslon2,4,err
    mslon=mslon1
  endelse


  mlt = (mlon - mslon) /15.0 + 12.0
  ia = where(mlt ge 24)
  ib = where(mlt lt 24)
  mlt[ia] = mlt[ia]-24
  mlt[ib] = mlt[ib]+24

end

function calc_mlt2,yr,t0,mlong
  if (yr gt 1900) then yr=yr-1900
  mean_lon=0.0
  dec=0.0
  mlt=0.0

  solar_loc,yr, t0,mean_lon,dec

  et = eqn_of_time(mean_lon, yr)
  dy=floor(t0/(24.*3600.))
  ut=float(t0-(dy*24*3600));
  apparent_time = ut + et;
  mlt2,apparent_time, dec, mlong, mlt,mslong
  return, mlt
end
;+
; NAME:
;    THM_ASI_MERGE_MOSAIC_2
;
; PURPOSE:
;    create mosaic with all THEMIS ASI
;
; CATEGORY:
;    None
;
; CALLING SEQUENCE:
;    THM_ASI_MERGE_MOSAIC,time
;
; INPUTS:
;    Time like '2006-01-01/05:00:00'
;
; OPTIONAL INPUTS:
;    None
;
; KEYWORD PARAMETERS:
;    cal_files    calibration files if they do not need to be read
;    pgm_file     do not read CDF, but pgm-files
;    verbose      print some diagnostics
;    insert   insert stop before end of program
;
;    gif_out      create a gif-file
;    gif_dir    directory for gif-output
;
;    exclude      string of station names that should not be plotted
;    show         string of station names that should only be plotted
;    minval   minimum value for black
;    maxval   maximum value for white
;    minimum_elevation  minimum elevation to plot in degrees
;    mask   mask certain parts of image
;
;    scale              scale for map set
;    central_lon        geographic longitude of center of plot
;    central_lat        geographic latitude of center of plot
;    rotation   rotate map
;    projection   projection for map set, MAP_PROJ_INFO, PROJ_NAMES=names
;    color_continent    shade of continent fill
;    color_background   shade of background
;
;    zbuffer      do in z-buffer, not on the screen
;    cursor       finish with cursor info, loop if cursor>1
;    window       set window number
;    xsize              xsize of window
;    ysize              ysize of window
;    position=position  position of plot on window (normal coordinates)
;    noerase=noerase    do not erase current window (no effect if {x,y}size set
;    keep_z   keep z-buffer open for further plotting
;
;    no_grid=no_grid  do not plot geomagnetic grid
;    no_midnight=no_midnight  do not plot midnight meridian
;    no_label   do not label mosaic with date and time
;    add_plot           stop because we want to add something
;    force_map    plot map even if there are no images
;
;    xy_pos             xy position
;    location   mark geographic location [lo,la]
;    track1             mark geographic location [lo,la]
;    track2             mark geographic location [lo,la]
;
;    top          top color to be used for polyfill
;    no_color   do not load color table, use existing
;    xy_cursor    create array of cursor selected values to pass to upper program
;    ssize    size of symbol for location
;    sym_color    color of location
;
;    stoptime   create multiple mosaics
;    timestep   time steps for multiple mosaics in seconds
;
; OUTPUTS:
;    None
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None
;
; RESTRICTIONS:
;    None
;
; EXAMPLE:
;    THM_ASI_MERGE_MOSAIC,'2006-01-01/05:00:00'
;    THM_ASI_MERGE_MOSAIC,'2007-03-01/04:00:00',exclude='ekat'
;
; MODIFICATION HISTORY:
;    Written by: Harald Frey, 09/06/2011
;                based on example from Donovan/Jackel and thm_asi_create_mosaic
;    Modified by: Asuka Hirai, 13/09/2019            
;                modify THM_ASI_MERGE_MOSAIC to configure detail setting
;                - add "map_grid, color = 0" to plot lines of geographic latitude and longitude
;    Modified by: Asuka Hirai, 30/09/2019
;                polar plot            
;
; NOTES:
;     WARNING!!!!!!!!!!!!!!
;     This program may not be perfect and may not work in every situation. Especially if stations
;     are influenced by stray or moon light it may still be better to use thm_asi_create_mosaic.
;     Also occasionally there are still sharp borders between overlapping images. If you encounter
;     such a situation send me an email hfrey@ssl.berkeley.edu. (hfrey, 09/21/2011)
;
; VERSION:
;   $LastChangedBy:
;   $LastChangedDate:
;   $LastChangedRevision:
;   $URL:
;
;-

PRO THM_ASI_MERGE_MOSAIC_2,time,$
  cal_files=cal_files,$              ; calibration files already read
  gif_out=gif_out,$                  ; output in gif file
  verbose=verbose,$                  ; print debug messages
  pgm_file=pgm_file,$                ; read raw pgm files

  exclude=exclude,$                  ; exclude certain stations
  top=top,$                          ; set top value for image

  show=show,$                        ; limit stations shown
  scale=scale,$                      ; scale for map set
  central_lat=central_lat,$          ; geographic latitude of center of plot
  central_lon=central_lon,$          ; geographic longitude of center of plot
  color_continent=color_continent,$  ; shade of continent fill
  color_background=color_background,$; shade of background
  position=position,$                ; position of plot on window (normal coordinates)
  xsize=xsize,$                      ; xsize of window
  ysize=ysize,$                      ; ysize of window
  noerase=noerase,$                  ; do not erase current window (no effect if {x,y}size set)
  zbuffer=zbuffer,$          ; do it in z-buffer
  cursor=cursor,$          ; finish with cursor info
  projection=projection,$        ; map projection
  maxval=maxval,$          ; brightness scaling of images
  minval=minval,$                    ; brightness scaling of images
  window=window,$              ; set window number
  rotation=rotation,$                ; rotate map away from North up

  minimum_elevation=minimum_elevation,$ ; set minimum elevation

  gif_dir=gif_dir,$                  ; An output directory for the gif output, default is the local working dir.
  force_map=force_map,$              ; force display of empty map
  no_grid=no_grid,$                  ; do not plot grid
  no_midnight=no_midnight,$          ; do not plot midnight meridian
  add_plot=add_plot,$                ; stop so we can add something
  mask=mask,$         ; mask part of image
  xy_pos=xy_pos,$     ; mark specific x,y-location
  location=location,$     ; mark geographic location=[long,lat] or [[lo,la],[lo,la],[lo,la]]
  no_color=no_color, $    ; do not load color table
  xy_cursor=xy_cursor,$   ; create an array that records the cursor output and passes it to upper program
  track1=track1,$     ; mark geographic location=[long,lat] or [[lo,la],[lo,la],[lo,la]]
  track2=track2,$     ; mark geographic location=[long,lat] or [[lo,la],[lo,la],[lo,la]]
  ssize=ssize,$     ; size of symbol for location
  sym_color=sym_color,$   ; color of location
  keep_z=keep_z,$     ; keep z-buffer open
  stoptime=stoptime,$     ; create multiple mosaics
  timestep=timestep,$     ; time step in seconds for multiple mosaics
  grid=geid,$             ; plot lines of gogeographic latitude and longitude
  mlt=mlt,$           ; if set, coordinate system is MLT-magnetic latitude 
  bytval=bytval,$     ; check whether image exists. if no image exists, bytval = 1
  
  insert=insert     ; insert stop before end of program




  ; input check
  if keyword_set(verbose) then verbose=systime(1)
  if (strlen(time) ne 19) then begin
    dprint, 'Wrong time input'
    dprint, 'Correct value like 2006-01-01/05:00:00'
    return
  endif
  if keyword_set(xy_pos) then begin
    dd=size(xy_pos)
    if (dd[2] ne 2) then begin
      dprint, 'XY_pos input wrong!'
      dprint, 'Needs to be given like [[x1,x2,x3,x4,x5,...],[y1,y2,y3,y4,y5,...]]'
      return
    endif
  endif

  ; check brightness scaling
  if keyword_set(maxval) then begin
    if not keyword_set(minval) then begin
      dprint, 'minval has to be set with maxval'
      return
    endif
    if not keyword_set(show) then begin
      dprint, 'Show has to be set with maxval'
      return
    endif
    if n_elements(show) ne n_elements(maxval) then begin
      dprint, 'N_elements of show and maxval have to match'
      return
    endif
  endif

  ; strip time
  res=time_struct(time)
  year=res.year
  month=res.month
  day=res.date
  hour=res.hour
  minute=res.min
  second=res.sec

  ; setup
  del_data,'thg_asf_*'
  del_data,'thg_ast_*'
  thm_init
  timespan,time,1,/hour
  thm_asi_stations,site,loc
  if keyword_set(zbuffer) then map_scale=2.6e7 else map_scale=4.e7
  if keyword_set(scale) then map_scale=scale
  if not keyword_set(central_lon) then central_lon=255.
  if not keyword_set(central_lat) then central_lat=63.
  if not keyword_set(xsize) then xsize=700
  if not keyword_set(ysize) then ysize=410
  if not keyword_set(top) then top=254

  ; characters
  if keyword_set(zbuffer) then chars=1.15 else chars=1.5

  ; some setup
  if keyword_set(minimum_elevation) then minimum_elevation_to_plot=minimum_elevation else minimum_elevation_to_plot=8. ;degrees
  n1=256l*256l






  ; clean up before start
  names=tnames('thg_as*')
  if (names[0] ne '') then store_data,delete=names

  ;load weights
  file_loc=!themis.local_data_dir+'thg/l2/asi/cal/'
  file_weights = file_loc+'true_weights_new.sav'
  if ~file_test(file_weights) then begin
    paths = spd_download( remote_file='http://themis.ssl.berkeley.edu/data/themis/thg/l2/asi/cal/true_weights_new.sav', $
      local_path=file_loc)
  endif
  restore,file_weights

  ; load cal_files once for the whole loop
  if keyword_set(stoptime) then begin
    if keyword_set(show) then thm_load_asi_cal,show,cal_files else $
      thm_load_asi_cal,'atha chbg ekat fsmi fsim fykn gako gbay gill inuv kapu kian kuuj mcgr pgeo pina rank snkq tpas whit yknf nrsq snap talo',cal_files
  endif

  ; point to run another mosaic
  repeat_loop:

  ; search for midnight file
  if not keyword_set(no_midnight) then begin
    f=file_search('midnight.sav',count=midnight_count)
;    f=file_search('C:\Users\Asuka Hirai\IDLWorkspace\Default\themis\11214_2018_576_MOESM3_ESM.sav',count=midnight_count)
    if (midnight_count eq 1) then begin
      midlons=fltarr(40)+!values.f_nan
      ut_hour=float(hour)+float(minute)/60.+float(second)/3600.
      restore,f
      for i=0,39 do begin
        lon=interpol(findgen(141)+start_longitude,reform(midnight[i,*]),ut_hour)
        midlons[i]=lon[0]
      endfor
      bad=where(midlons gt 360.,count)
      if (count gt 0) then midlons[bad]=!values.f_nan
    endif
  endif else midnight_count=0

  ; read available data
  thm_mosaic_array,year,month,day,hour,minute,second,strlowcase(site),$
    image,corners,elevation,pixel_illuminated,n_sites,verbose=verbose,$
    cal_files=cal_files,pgm_file=pgm_file,$
    show=show,exclude=exclude,$
    mask=mask
    
  ; coordinate transformation from geo to mag
  corners_m = make_array(n_elements(corners[*,0,0,0]), 4, 2, n_sites)     ; [mlon, mlat]
  r_array = fltarr(n_elements(corners[*,0,0,0]), 4, 1, n_sites) + 1.017265735  ;hight of lower ionosphere (r=110km from surface)
  geopack_recalc, year, month, day, hour, minute, second, /date
  geopack_sphcar, r_array, 90.-corners[*,*,1,*], corners[*,*,0,*], x, y, z, /to_rect, /degree       ;r=110km from surface
  geopack_conv_coord, x, y, z, d1, d2, d3, /FROM_GEO, /TO_MAG
  geopack_sphcar, d1, d2, d3, r, theta, phi, /to_sphere, /degree
  corners_m[*,*,1,*] = 90 - theta ;mlat
  corners_m[*,*,0,*] = phi        ;mlon
  ;subsolar point
  geopack_conv_coord, 1, 0, 0, s1, s2, s3, /FROM_SM, /TO_MAG
  geopack_sphcar, s1, s2, s3, r_s, theta_s, phi_s, /to_sphere, /degree
  phi_s_array = fltarr(n_elements(corners[*,0,0,0]), 4, 1, n_sites) + phi_s ;mlon array od subsolar point
  
  
  ; magnetic latitude and longitude of each site
  mloc = make_array(2, n_elements(loc[0,*]))
  mlt  = make_array(n_elements(loc[0,*]))
  r_array = fltarr(1, n_elements(loc[0,*])) + 1.017265735
  geopack_sphcar, r_array, 90.-loc[0,*], loc[1,*], x, y, z, /to_rect, /degree    ;loc[0,*]:latitude, loc[1,*]:longitude 
  geopack_conv_coord, x, y, z, d1, d2, d3, /FROM_GEO, /TO_MAG
  geopack_sphcar, d1, d2, d3, r, theta, phi, /to_sphere, /degree
  mloc[0,*] = 90 - theta ;mlat
  mloc[1,*] = phi        ;mlon
  if keyword_set(mlt) then begin
    corners_m[*,*,0,*] = (corners_m[*,*,0,*]-phi_s_array)/15.+12.   ;MLT
    mlt = (reform(mloc[1,*])-(fltarr(n_elements(mloc[1,*]))+phi_s))/15.+12.  ;site MLT
  endif
  if keyword_set(verbose) then dprint, 'After : calc_mlt',systime(1)-verbose, ' Seconds'

  ; determine which sites to plot
  site_exist=intarr(n_sites)
  if keyword_set(show) then begin ; isolates only sites chosen to be shown
    for i=0,n_elements(show)-1 do site_exist[where(strlowcase(site) eq strlowcase(show[i]))]=1
  endif else begin
    site_exist=intarr(n_sites)+1
    site_exist[where(elevation[0,*] eq 0.)]=0 ; checks for stations without data
  endelse

  ; exclude unwanted sites
  if keyword_set(exclude) then begin
    for i=0,n_elements(exclude)-1 do begin
      not_site=where(strlowcase(site) eq strlowcase(exclude[i]),count)
      if (count eq 0) then dprint, 'Not a valid site: ',exclude[i] else begin
        corners_m[*,*,*,not_site]=!values.f_nan
        image[*,not_site]=!values.f_nan
        site_exist[not_site]=0.
      endelse
    endfor
  endif

  ; fill variables
  bytval=fltarr(n_sites)+1.
  bitval=fltarr(n_sites)
  if keyword_set(maxval) then begin
    for i=0,n_elements(maxval)-1 do begin
      index=where(strlowcase(site) eq strlowcase(show[i]))
      bytval[index]=maxval[i]
      bitval[index]=minval[i]
    endfor
    for i=0,n_sites-1 do image[*,i]=bytscl(image[*,i],min=bitval[i],max=bytval[i])
  endif else begin
    for i=0,n_sites-1 do bytval[i]=(median(image[*,i]) > 1) ; prevent divide by zero
    for i=0,n_sites-1 do image[*,i]=((image[*,i]/bytval[i])*64.) < 254
  endelse ; maxval

  ; no images found
  if (max(bytval) eq 1.) then begin
    dprint, 'No images for ',time
    if not keyword_set(force_map) then begin
      if keyword_set(gif_out) then gif_out=''
      if double(!version.release) lt 8.0d then heap_gc
      return
    endif
  endif

  ; exclude unwanted sites
  if keyword_set(exclude) then begin
    for i=0,n_elements(exclude)-1 do begin
      not_site=where(strlowcase(site) eq strlowcase(exclude[i]),count)
      if (count eq 0) then dprint, 'Not a valid site: ',exclude[i] else begin
        corners_m[*,*,*,not_site]=!values.f_nan
        bytval[not_site]=!values.f_nan
      endelse
    endfor
  endif

  ;zbuffer needs to be set before the loadct call in thm_map_set,
  ;otherwise this bombs the second time through because of reset to 'x'
  ;later in this program, jmm 21-dec-2007
  loadct, 0
  if(keyword_set(zbuffer)) then set_plot, 'z'

  ; set up the map
;  thm_map_set,scale=map_scale,$
;    central_lat=central_lat,$           ; geographic latitude of center of plot
;    central_lon=central_lon,$           ; geographic longitude of center of plot
;    color_continent=color_continent,$   ; shade of continent fill
;    color_background=color_background,$ ; shade of background
;    position=position,$                 ; position of plot on window (normal coordinates)
;    xsize=xsize,$                       ; xsize of window
;    ysize=ysize,$                       ; ysize of window
;    noerase=noerase,$                   ; do not erase current window (no effect if {x,y}size set
;    zbuffer=zbuffer,$
;    projection=projection,$
;    window=window,$
;    rotation=rotation,$
;    no_color=no_color

  ;map set
  window, window, xsize = xsize, ysize = ysize
  mlat_contour = [40.,50.,60.,70.,80, 90.]
  plot, [0,1], [0,1], xr = [-40., 40], yr = [-40., 40.], /nodata, xtickformat = '(a1)', ytickformat = '(a1)', $
    position = [0.05,0.07,0.95,0.97]
  oplot, -([40:90]-90.)*cos(-90.*!pi/180), -([40:90]-90.)*sin(-90.*!pi/180), color = 2, thick = 0.5, linestyle = 2 
  for i = 0, n_elements(mlat_contour)-1 do begin
    oplot, -(mlat_contour[i]-90.)*cos([0:360]*!pi/180), -(mlat_contour[i]-90)*sin([0:360]*!pi/180), color = 2, thick = 0.5, $
      linestyle = 2  
  endfor
  cglegend,title=['90'],location=[0, 0], /data, Length=0.0
  cglegend,title=['80'],location=[10/sqrt(2), 10/sqrt(2)], /data, Length=0.0
  cglegend,title=['70'],location=[20/sqrt(2), 20/sqrt(2)], /data, Length=0.0
  cglegend,title=['60'],location=[30/sqrt(2), 30/sqrt(2)], /data, Length=0.0
  cglegend,title=['50'],location=[40/sqrt(2), 40/sqrt(2)], /data, Length=0.0
  cglegend,title=['40'],location=[50/sqrt(2), 50/sqrt(2)], /data, Length=0.0
  if ~keyword_set(mlt) then begin
    cglegend,title=['0'],location=[40,0], /data, Length=0.0
    cglegend,title=['90'],location=[-1,42], /data, Length=0.0
    cglegend,title=['180'],location=[-46,0], /data, Length=0.0
    cglegend,title=['270'],location=[-1,-41], /data, Length=0.0
  endif else begin
    cglegend,title=['6'],location=[40,0], /data, Length=0.0
    cglegend,title=['12'],location=[-1,42], /data, Length=0.0
    cglegend,title=['18'],location=[-46,0], /data, Length=0.0
    cglegend,title=['0'],location=[-1,-41], /data, Length=0.0
  endelse

  ; normal filling
  for pixel=0l,n1-1l do begin
    for i_site=0,n_sites-1 do begin
      weighted_image=0.
      if ((pixel_illuminated[pixel,i_site] eq 1) and $
        (elevation[pixel,i_site] gt minimum_elevation_to_plot)) then begin
        ; implement weights
        for j_site=0,n_sites-1 do begin
          if(site_exist[j_site] eq 1) then begin
            weighted_image=weighted_image+(true_weights[i_site,pixel,j_site,1]*$
              image[true_weights[i_site,pixel,j_site,0],j_site])
          endif
        endfor

        ; normalize image
        weighted_image=weighted_image/total(true_weights[i_site,pixel,where(site_exist eq 1),1])
;        polyfill,corners_m[pixel,[0,1,2,3,0],0,i_site],$
;          corners_m[pixel,[0,1,2,3,0],1,i_site],color=weighted_image  < top
        if ~keyword_set(mlt) then begin
          polyfill, -(corners_m[pixel,[0,1,2,3,0],1,i_site]-90.)*cos(corners_m[pixel,[0,1,2,3,0],0,i_site]*!pi/180), $
            -(corners_m[pixel,[0,1,2,3,0],1,i_site]-90)*sin(corners_m[pixel,[0,1,2,3,0],0,i_site]*!pi/180),$
            color=weighted_image < top
        endif else begin
          polyfill, -(corners_m[pixel,[0,1,2,3,0],1,i_site]-90.)*cos((corners_m[pixel,[0,1,2,3,0],0,i_site]-6)*15*!pi/180), $
            -(corners_m[pixel,[0,1,2,3,0],1,i_site]-90)*sin((corners_m[pixel,[0,1,2,3,0],0,i_site]-6)*15*!pi/180), $
            color=weighted_image < top
        endelse  

      endif

    endfor
  endfor
  
  ; plot site location
;  loadct, 39
;  a = where(site_exist eq 1, count)
;  for i = 0, count-1 do begin
;    if ~keyword_set(mlt) then begin
;      x = -(mloc[0,a[i]]-90.)*cos(mloc[1,a[i]]*!pi/180)
;      y = -(mloc[0,a[i]]-90.)*sin(mloc[1,a[i]]*!pi/180)
;    endif else begin
;      x = -(mloc[0,a[i]]-90.)*cos((mlt[a[i]]-6)*15*!pi/180)
;      y = -(mloc[0,a[i]]-90.)*sin((mlt[a[i]]-6)*15*!pi/180)
;    endelse
;    plots, x, y, psym = 1, color=250
;    xyouts, x,y+0.8, site[a[i]], ALIGNMENT=0.5, color=250
;  endfor
;  loadct, 0

  ; finish map
  return_lons=1
  return_lats=1
  thm_map_add,invariant_lats=findgen(4)*10.+50.,invariant_color=210,$
    invariant_linestyle=1,/invariant_lons,return_lons=return_lons,$
    return_lats=return_lats,no_grid=no_grid
  xyouts,0.005,0.018,time,color=0,/normal,charsize=chars
  xyouts,0.005,0.050,'THEMIS-GBO ASI',color=0,/normal,charsize=chars

  if keyword_set(verbose) then dprint, 'After map: ',systime(1)-verbose,$
    ' Seconds'

  ; search for midnight file
  if (not keyword_set(no_midnight) and midnight_count eq 1) then $
    plots, -(mid_mlats-90.)*cos(mid_mlons*!pi/180), -(mid_mlats-90)*sin(mid_mlons*!pi/180), $
    color=255;, /data
;    plots,smooth(midlons-360.,5),findgen(40)+40.,color=255,/data
    

  ; stop so we can add something
  if keyword_set(add_plot) then stop

  ; mark ground tracks of satellites
  if keyword_set(track1) then begin
    plots,track1[0,*],track1[1,*],psym=3
  endif

  if keyword_set(track2) then begin
    plots,track2[0,*],track2[1,*],psym=4
  endif

  if keyword_set(location) then begin
    if keyword_set(ssize) then ssize=ssize else ssize=1
    if keyword_set(sym_color) then scolor=sym_color else scolor=255
    plots,location[0,*],location[1,*],psym=2,symsize=ssize,color=scolor
  endif

  if keyword_set(cursor) then begin
    ss=size(cursor)
    xy_cursor=fltarr(cursor,4)
    if (ss[1] ne 2) then cursor=1
    for loop=1,cursor do begin
      dprint, 'Point cursor on map!'
      cursor,x,y,/data
      wait,0.25
      res=convert_coord(x,y,/data,/to_device)
      dprint, 'Location: ',res,x,y
      xy_cursor[loop-1L,*]=[res[0],res[1],x,y]
    endfor
  endif

  ; input like [[x1,x2,x3,x4,x5,...],[y1,y2,y3,y4,y5,...]]
  if keyword_set(xy_pos) then begin
    dd=size(xy_pos)
    if (dd[0] eq 1) then begin
      res=convert_coord(xy_pos[0],xy_pos[1],/to_data,/device)
      dprint, 'Location: ',xy_pos,res[0:1],format='(a12,2i5,2f10.3)'
      xy_pos_out=[xy_pos[0],xy_pos[1],res[0],res[1]]
    endif else begin
      xy_pos_out=fltarr(dd[1],4)
      res=convert_coord(xy_pos[*,0],xy_pos[*,1],/to_data,/device)
      for i1=0L,dd[1]-1L do begin
        dprint, 'Location: ',xy_pos[i1,*],res[0:1,i1],format='(a12,2i5,2f10.3)'
        xy_pos_out[i1,*]=[xy_pos[i1,0],xy_pos[i1,1],res[0,i1],res[1,i1]]
      endfor
    endelse
    xy_pos=xy_pos_out
  endif

  ; gif output
  if keyword_set(gif_out) then begin
    If(keyword_set(gif_dir)) Then gdir = gif_dir Else gdir = './'
    tvlct,r,g,b,/get
    img=tvrd()
    ; now add the secret code of input parameters
    img[40:43,0]=[13,251,117,239]
    ; time of mosaic
    img[0:6,0]=[year/100,year-(year/100)*100,month,day,hour,minute,second]
    ; thumb flag used to label merge
    img[7,0]=9
    ; central_lon and lat of mosaic
    if (central_lon lt 0.) then central_lon=central_lon+360.
    img[8:12,0]=[fix(central_lon)/100,fix(central_lon)-(fix(central_lon)/100)*100,$
      fix((central_lon-fix(central_lon))*100),$
      fix(central_lat),fix((central_lat-fix(central_lat))*100)]
    ; map_scale
    res=strsplit(string(map_scale*1.e10),'e',/extract)
    img[13:15,0]=[fix(res[0]),fix((float(res[0])-fix(res[0]))*100),fix(res[1])-10]
    ; xsize and ysize
    img[16:19,0]=[xsize/100,xsize-(xsize/100)*100,ysize/100,ysize-(ysize/100)*100]
    ; rotation
    if keyword_set(rotation) then begin
      if (rotation lt 0.) then rotation=rotation+360.
      img[20:22,0]=[fix(rotation/100),fix(rotation-(fix(rotation)/100)*100),$
        fix((rotation-fix(rotation))*100)]
    endif else img[20:22]=[0,0,0]
    ; minimum elevation
    img[23:24,0]=[fix(minimum_elevation_to_plot),$
      fix((minimum_elevation_to_plot-fix(minimum_elevation_to_plot))*100)]
    ; zbuffer
    if keyword_set(zbuffer) then img[25,0]=1 else img[25,0]=0
    ; code stations
    img[49,0]=n_sites
    for i1=0,n_sites-1 do begin
      case 1 of
        finite(bytval[i1]) eq 0: img[50+i1,0]=0
        bytval[i1] eq 1.: img[50+i1,0]=1
        bytval[i1] gt 1.: img[50+i1,0]=2
      endcase
    endfor
    ; construct the name
    out_name='MOSA.'+string(year,'(i4.4)')+'.'+string(month,'(i2.2)')+'.'+$
      string(day,'(i2.2)')+'.'+string(hour,'(i2.2)')+'.'+string(minute,'(i2.2)')+$
      '.'+string(second,'(i2.2)')+'.gif'
    write_gif,gdir+out_name,img,r,g,b
    dprint, 'Output in ',out_name
    gif_out=out_name
    tv,img
  endif

  if keyword_set(zbuffer) then zbuffer=tvrd()
  if not keyword_set(keep_z) and keyword_set(zbuffer) then begin
    device,/close
    set_plot,'x'
  endif

  ; loop of mosaics
  if keyword_set(stoptime) then begin
    if keyword_set(timestep) then new_time=time_double(time)+timestep else new_time=time_double(time)+3.d0
    ; strip time
    res=time_struct(new_time)
    year=res.year
    month=res.month
    day=res.date
    hour=res.hour
    minute=res.min
    second=res.sec
    if (new_time le time_double(stoptime)) then begin
      time=time_string(new_time)
      goto,repeat_loop
    endif
  endif

  if keyword_set(verbose) then dprint, 'Calculation took ',systime(1)-verbose,$
    ' Seconds'

  if double(!version.release) lt 8.0d then heap_gc
  if keyword_set(insert) then stop
  

end