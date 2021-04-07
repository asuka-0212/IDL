;-----------------------------------------------------------------------------------------------------------------------------------------
; make THEMIS ASI Keogram along VLF/LF subionospheric propagation path
; 
; (in)  rx=rx : receiver station name ('ath', 'pkr', or 'nal')
;       tx=tx : transmiter name ('ndk', 'nlk', so on)
;       asi=asi : list of ASI stations (ex asi=['tpas','atha','pina']) 
;       lf_freq=lf_freq : LF freq @RX to read (ex lf_freq=25.2)
;       trange (option) : time span
;       median_set (option) : spatial median filter to aurora image
;       no_load : set this if you already have ASI data cute
; (out) tplot variable : asi_keo_lf_(rx)_(tx)
;
; Usage
;        THEMIS> asi_keo_lf_path, rx=rx, tx=tx, asi=asi, lf_freq=lf_freq, trange=trange
;   ex)  THEMIS> asi_keo_lf_path, rx='ath', tx='ndk', asi=['tpas','atha','pina'], lf_freq=25.20, trange=['2017-03-27/07:13:20','2017-03-27/07:15:40']
; 
; -- use proceedure below --
; load_data_cube_thm_asi
; thm_asi_pix2geo_table
; lf_get_gcp
; ll2rb
; rb2ll
; 
; last update
;   2018-04-10 F. Tsuchiya 
;
;-----------------------------------------------------------------------------------------------------------------------------------------

pro asi_keo_lf_path, rx=rx, tx=tx, asi=asi, lf_freq=lf_freq, trange=trange, median_set=median_set, no_load=no_load, no_download=no_download

  ;-----------------------------------------------------------
  ; 入力キーワードのチェック
  ;-----------------------------------------------------------
  if not keyword_set(rx) or not keyword_set(tx) then begin
    print,'usage  THEMIS> asi_keo_lf_path, rx=rx, tx=tx, asi=asi, trange=trange'
    print,"  ex)  THEMIS> asi_keo_lf_path, rx='ath', tx='ndk', asi=['tpas','atha','pina'], lf_freq=25.20, trange=['2017-03-27/07:00:00','2017-03-27/07:40:00'], /no_load'
    print,"  ex)  THEMIS> asi_keo_lf_path, rx='ath', tx='ndk', asi=['tpas','atha','pina'], lf_freq=25.20, trange=['2017-03-27/10:40:00','2017-03-27/11:20:00'], /no_load'
    print,"  ex)  THEMIS> asi_keo_lf_path, rx='ath', tx='ndk', asi=['tpas','atha','pina'], lf_freq=25.20, trange=['2017-03-27/11:20:00','2017-03-27/12:00:00'], /no_load'
    print,"  ex)  THEMIS> asi_keo_lf_path, rx='ath', tx='nlk', asi=['atha'], lf_freq=24.79, trange=['2017-03-27/06:00:00','2017-03-27/06:40:00'], /no_load, /no_download, median_set=5'
    exit   
  endif
  if not keyword_set(median_set) then median_set=0
  
  ;-----------------------------------------------------------
  ; timespanの設定
  ;-----------------------------------------------------------
  if keyword_set(trange) then timespan, trange
  
  ;-----------------------------------------------------------
  ; time label
  ;-----------------------------------------------------------
  get_timespan, t
  ts = time_string(t)
  ret = strsplit(ts,'-/:',/extract)
  tlabel = ret[0,0]+ret[0,1]+ret[0,2]+ret[0,3]+ret[0,4]+ret[0,5]+'_'+ret[1,0]+ret[1,1]+ret[1,2]+ret[1,3]+ret[1,4]+ret[1,5]

  ;-----------------------------------------------------------
  ; 受信点座標の設定
  ;-----------------------------------------------------------
  case rx of
    'ath': rx_loc = [-113.4593, 54.6929]
    else: begin
          print, 'invalid rx name: ',rx
          return
          end
  endcase

  ;-----------------------------------------------------------
  ; 送信局座標の設定
  ;-----------------------------------------------------------
  case tx of
    'ndk': tx_loc = [ -98.3357, 46.3660]
    'nlk': tx_loc = [-121.9170, 48.2000]
    else: begin
      print, 'invalid tx name: ',tx
      return
    end
  endcase

  ;-----------------------------------------------------------
  ; ASIの画像各ピクセルの緯度・経度値の取得
  ;-----------------------------------------------------------
  ; get thm_asi_(site)_pix2geo_table_v01.sav
  ; glon(256,256),glat(256,256),elev(256,256)
  thm_asi_pix2geo_table, site=asi, trange=trange

  asi_glon = []
  asi_glat = []
  asi_elev = []
  n_asi = n_elements(asi)
  for i=0, n_asi-1 do begin
    restore, file='thm_asi_'+asi[i]+'_pix2geo_table_v01.sav'
    asi_glon = [ [[asi_glon]], [[glon]] ]
    asi_glat = [ [[asi_glat]], [[glat]] ]
    asi_elev = [ [[asi_elev]], [[elev]] ]
  endfor
  
  ;-----------------------------------------------------------
  ; RX-TX GCP沿いの緯度・経度の取得
  ;-----------------------------------------------------------
  lf_get_gcp, src=tx_loc, trg=rx_loc, gcp_lon=gcp_lon, gcp_lat=gcp_lat, step=5.0

  ;-----------------------------------------------------------
  ; RX-TX GCP沿いのASIピクセル値の取得
  ;-----------------------------------------------------------
  n_gcp = n_elements(gcp_lon)
  pix_lon = indgen(n_gcp,n_asi)
  pix_lat = indgen(n_gcp,n_asi)

  limit = 1.0 ; deg
  for j=0, n_asi-1 do begin
    for i=0, n_gcp-1 do begin
      ll2rb, gcp_lon[i], gcp_lat[i], asi_glon[*,*,j], asi_glat[*,*,j], r, b
      ret = min( r, imin, /nan )
      i_lon = imin mod 256
      i_lat = imin / 256
      if asi_elev[i_lon,i_lat,j] ge limit then begin
        pix_lon[i,j] = i_lon
        pix_lat[i,j] = i_lat
      endif else begin
        pix_lon[i,j] = !values.f_nan
        pix_lat[i,j] = !values.f_nan
      endelse
    endfor
  endfor

  ;-----------------------------------------------------------
  ; GBO ASI data cubeの読み込み
  ;-----------------------------------------------------------
  if not keyword_set(no_load) then begin
    for i=0, n_asi-1 do begin
      load_data_cube_thm_asi, asi[i], trange, dcube, ts, no_download=no_download
      save, filename = 'C:\data\themis\data\asi\20170327\keogram\' + asi[i]+'_dcube_'+tlabel+'.sav', dcube, ts
    endfor
  endif

  ;-----------------------------------------------------------
  ; GCPに沿ったオーロラ輝度分布の取得
  ;-----------------------------------------------------------
  dt = 3.0  ; time step  [sec]
  t = time_double(trange)
  n_ts = fix( (t[1]-t[0]) / dt )
  asi_keo_lf = fltarr(n_ts, n_gcp, n_asi)
  asi_tvar = asi + '_keo_lf_' + tx + '_' + rx + '_med' + string(median_set,format='(i3.3)')
  
  for k=0, n_asi-1 do begin

    ;-----------------------------------------------------------
    ; dcube[256,256,n_ts], ts[n_ts], median_set
    ;-----------------------------------------------------------
    restore, filename='E:\backup\themis\data\asi\20170327\keogram\' + asi[k]+'_dcube_'+tlabel+'.sav'
    for i=0, n_ts-1 do begin
      
      im = dcube[*,*,i]
      if median_set then im = median(im, median_set, /double, /even)
      
      for j=0, n_gcp-1 do begin
        if pix_lon[j,k] ne !values.f_nan then begin
          asi_keo_lf[i,j,k] = im[pix_lon[j,k], pix_lat[j,k]]
        endif else begin
          asi_keo_lf[i,j,k] = !values.f_nan
        endelse
      endfor
    endfor

    ;-----------------------------------------------------------
    ; ASI Keogram along LF path : TPLOT変数化
    ;-----------------------------------------------------------
    td = time_double(ts)
    store_data, asi_tvar[k], data={x:td,y:asi_keo_lf[*,*,k],v:gcp_lon}, dlim={spec:1,ytitle:'Longitude [deg]', ztitle:'Brightness('+asi[k]+') [R]', zrange:[min(asi_keo_lf[*,*,k]),max(asi_keo_lf[*,*,k])]}
    zlim, asi_tvar[k], 2500,4500,0
    
  endfor
  
  ;-----------------------------------------------------------
  ; LF dataの読み込み
  ;-----------------------------------------------------------
  dt_lf    = 1.0           ; sampling freq [sec]

  filter=10
  lf_tvar     = 'lf_ath_'+string(lf_freq,format='(f4.1)')+'_amp_10hz_flt'+string(filter,format='(i3.3)')
  lf_tvar_new = 'lf_ath_'+tx+'_amp_10hz_hpf'
  if fix(filter*dt_lf) gt 1 then begin
    load_lf_data_10hz, site=rx, freq=lf_freq, err=err, filter=filter, dir='E:\Data\', reduce=fix(filter*dt_lf), /no_download
    print, 'lf data reduce: ',fix(filter*dt_lf)
  endif else begin
    load_lf_data_10hz, site=rx, freq=lf_freq, err=err, filter=filter, dir='E:\Data\', /no_download
  endelse

  options,  lf_tvar, 'psym', 0
  get_data, lf_tvar, data=lf, dlim=dlim

  n_lf = n_elements(lf.x)
  f_cutoff = 1.0/120.0      ; cutoff [Hz]
  n_cutoff = fix(n_lf * dt_lf * f_cutoff)
  filter_lf = butterworth(n_lf, 2, cutoff=n_cutoff, order=4)
  lf.y = fft ( fft (lf.y, -1) * (1.0-filter_lf), 1 )
  store_data,lf_tvar_new, data={x:lf.x, y:real_part(lf.y)}, dlim=dlim
  
  ;-----------------------------------------------------------
  ; PLOT
  ;-----------------------------------------------------------
  tplot, [asi_tvar,lf_tvar, lf_tvar_new]
  
  ;-----------------------------------------------------------
  ; Tplot変数の保存
  ;-----------------------------------------------------------
  for k=0, n_asi-1 do begin
    filename = 'C:\data\themis\data\asi\20170327\keogram\' + asi[k] + '_keo_lf_' + tx + '_' + rx + '_med' + string(median_set,format='(i3.3)') + '_' + tlabel
    tplot_save, file=filename, [asi_tvar, lf_tvar_new, lf_tvar]
  endfor

end
