; ----------------------------------------------------------------------------------------------------------
; load THEMIS GBO ASI
; ----------------------------------------------------------------------------------------------------------
;
; usage :
; ERG> trange = '2017-03-27/07:00:00'
; ERG> site = 'atha'
; ERG> median_set=0
; ERG> load_data_cube_thm_asi, site, trange, dcube, ts, median_set=median_set
;
pro load_data_cube_thm_asi, site, trange, dcube, ts, median_set=median_set, no_download=no_download

  if not keyword_set(median_set) then median_set=0

  ; time setting
  dt = 3.0  ; time step  [sec]
  if n_elements(trange) eq 1 then begin
    nt = 1
    ts = trange
  endif else begin
    t = time_double(trange)
    nt = fix( (t[1]-t[0]) / dt )
    td = t[0] + dindgen(nt) * dt
    ts = time_string(td)
  endelse

  for i=0L,nt-1L do begin
    ; load ASI image
    thm_load_asi,site=site, time=ts[i], datatype='asf', no_download=no_download

    get_data, 'thg_asf_'+site, data=data
    im = data.y
    if median_set then im = median(im, median_set, /double, /even)
    if i ne 0 then dcube = [ [[dcube]], [[im]] ] else dcube=im

  endfor

end

