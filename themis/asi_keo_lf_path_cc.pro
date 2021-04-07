;====================================================================================================
;
; tplot_file : created by asi_keo_lf_path.pro
; 
; event-A
;(ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327070000_20170327074000.tplot', plot_trange=['2017-03-27/07:00:00','2017-03-27/07:40:00'], trg_lon = [247.5,252.0])
;(ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327070000_20170327074000.tplot', plot_trange=['2017-03-27/07:12:50','2017-03-27/07:15:20'], trg_lon = [247.5,252.0])
; ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327070000_20170327074000.tplot', plot_trange=['2017-03-27/07:12:45','2017-03-27/07:15:05'], trg_lon = [247.5,252.0]
; ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327070000_20170327074000.tplot', plot_trange=['2017-03-27/07:12:45','2017-03-27/07:15:05'], trg_lon = [247.5,258.0]
; ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327070000_20170327074000.tplot', plot_trange=['2017-03-27/07:12:45','2017-03-27/07:16:05'], trg_lon = [255.0,258.0]
; ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327070000_20170327074000.tplot', plot_trange=['2017-03-27/07:12:45','2017-03-27/07:15:05'], trg_lon = [248.0,251.0]

;
; event-B
;( ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327104000_20170327112000.tplot', plot_trange=['2017-03-27/10:40:00','2017-03-27/11:20:00'])
;( ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327104000_20170327112000.tplot', plot_trange=['2017-03-27/10:57:40','2017-03-27/11:00:10'], trg_lon = [248.5,251.0])
; ERG> asi_keo_lf_path_cc, tplot_file='tpas_keo_lf_ndk_ath_med000_20170327104000_20170327112000.tplot', plot_trange=['2017-03-27/10:57:30','2017-03-27/10:59:50'], trg_lon = [248.5,251.0]
;
; event-C
; ERG> asi_keo_lf_path_cc, tplot_file='atha_keo_lf_nlk_ath_med005_20170327060000_20170327064000.tplot', plot_trange=['2017-03-27/06:00:00','2017-03-27/06:30:00'], trg_lon = [242.0,244.0]
;====================================================================================================
;
pro asi_keo_lf_path_cc, tplot_file=tplot_file, plot_trange=plot_trange, trg_lon=trg_lon

  dt_lf_corr=0.3 ; [sec]

  ;----------------------------------
  ; Tplot変数データのリストア　(asi_keo_lf_path.proで作成された.tplotファイル)
  ;----------------------------------
  print, tplot_file
  tplot_restore, file='E:\data\themis\data\asi\20170327\keogram\' + tplot_file

  ret = strsplit(tplot_file,'_-.',/extract)
  tvar_asi = ret[0]+'_keo_lf_'+ret[3]+'_'+ret[4]+'_'+ret[5]
  tvar_lf = 'lf_'+ret[4]+'_'+ret[3]+'_amp_10hz_hpf'
  
  if ret[0] eq 'tpas' then y_sel = [247.5,260.0] 
  if ret[0] eq 'atha' then y_sel = [242.0,252.0]
  if ret[0] eq 'pina' then y_sel = [250.0,262.0]
  if not keyword_set(trg_lon) then trg_lon=y_sel
  
  options, tvar_asi, 'title', 'Themis GBO '+strupcase(ret[0])+' VS. VLF from '+strupcase(ret[3])+' to '+ strupcase(ret[4])
  options, tvar_asi, 'ytitle', 'Aurora brightess'
  options, tvar_asi, 'ysubtitle', 'Longitude [deg]'
  options, tvar_asi, 'ztitle', 'Brightess [R]'
  zlim, tvar_asi, 3000, 4500
  
  options, tvar_lf, 'ysubtitle', strupcase(ret[3])+' to '+ strupcase(ret[4])
  options, tvar_lf, 'ytitle', 'Filtered amplitude [dB]'
  ylim,    tvar_lf, -3.0,2.0

  get_data, tvar_asi, data=asi
  get_data, tvar_lf, data=lf, dlim=lf_dlim

  ;----------------------------------
  ; LFデータの時間修正
  ;----------------------------------
  lf.x += dt_lf_corr
  store_data, tvar_lf, data=lf, dlim=lf_dlim

  ;----------------------------------
  ; ASIデータの補間及びHPF処理
  ;----------------------------------
  ; sourceデータの配列数取得
  n_asi = n_elements(asi.x)
  m_asi = n_elements(asi.v)
  n_lf  = n_elements(lf.x)

  ; asiデータの存在時間範囲の取得
  td_s = asi.x[0]
  td_e = asi.x[n_asi-1]
  idx_s = nn(lf,td_s)
  idx_e = nn(lf,td_e)
  lf_x = lf.x[idx_s:idx_e]
  lf_y = lf.y[idx_s:idx_e]
  ; 補間・HPF処理後のasiデータ保管領域の確保
  n = idx_e-idx_s+1
  asi_hpf = dblarr(n,m_asi)
  asi_a = dblarr(n,m_asi)
  timespan, [td_s,td_e]
  
  ; HPFの定義・フィルタ関数生成
  dt = 1.0                 ; [sec]
  f_cutoff = 1.0/120.0      ; cutoff [Hz]
  n_cutoff = fix(n * dt * f_cutoff)
  filter = butterworth(n, 2, cutoff=n_cutoff, order=4)

  ; 補間・HPF処理の実施
  for i=0,m_asi-1 do begin
    din = asi.y[*,i]
    dout = interpol(din, asi.x, lf_x, /spline)
    asi_a[*,i] = dout
    dout = fft ( fft (dout, -1) * (1.0-filter), 1 )
    asi_hpf[*,i] = real_part(dout)
  endfor
  ;-----------------------------
;  idx = where(asi_hpf lt 0.0)
;  asi_hpf[idx] = 0.0
  ;-----------------------------
  store_data,tvar_asi+'_hpf', data={x:lf_x, y:asi_hpf, v:asi.v}, $
    dlim={spec:1, yrange:y_sel, zrange:[-100.0,100.0], $
    ytitle:'Filtered brightness',ysubtitle:'Longitude [deg]',ztitle:'Brightness [R]'}

  ;----------------------------------
  ; 電波の伝搬経路全体に沿ったオーロラ輝度変化の積分データ生成
  ;----------------------------------
  ret = min(abs(asi.v-y_sel[0]), imin)
  ret = min(abs(asi.v-y_sel[1]), imax)
  hpf_int = mean(asi_hpf[*,imin:imax],dimension=2, /nan)
  store_data,tvar_asi+'_hpf_int', data={x:lf_x, y:hpf_int}, $
    dlim={ytitle:'Mean brightness [R]'}
    
  ;----------------------------------
  ; 電波の伝搬経路の特定点（指定範囲の積分）のオーロラ輝度変化データの抜き出し（この後のデータ処理では未使用）
  ;----------------------------------
  ret = min(abs(asi.v-trg_lon[0]), i_trg1)
  ret = min(abs(asi.v-trg_lon[1]), i_trg0)
  hpf_sel = mean(asi_hpf[*,i_trg1:i_trg0],dimension=2, /nan)
  lon_lab = string(trg_lon[0],trg_lon[1], format='(f5.1,"-",f5.1,"[deg]")')
  store_data,tvar_asi+'_hpf_sel', data={x:lf_x, y:hpf_sel}, $
    dlim={ytitle:'Mean brightness [R]'}
  options, tvar_asi+'_hpf_sel', 'ysubtitle', lon_lab

  ;----------------------------------
  ; 電波の伝搬経路の特定点（指定範囲の積分）のオーロラ輝度変化データの抜き出し（この後のデータ処理では未使用）※HPF通さない
  ;----------------------------------
  ret = min(abs(asi.v-trg_lon[0]), i_trg1)
  ret = min(abs(asi.v-trg_lon[1]), i_trg0)
  sel = mean(asi_a[*,i_trg1:i_trg0],dimension=2, /nan)
  lon_lab = string(trg_lon[0],trg_lon[1], format='(f5.1,"-",f5.1,"[deg]")')
  store_data,tvar_asi+'_sel', data={x:lf_x, y:sel}, $
    dlim={ytitle:'Mean brightness [R]'}
  options, tvar_asi+'_sel', 'ysubtitle', lon_lab

  ;----------------------------------
  ; 電波の伝搬経路の点毎に、オーロラ輝度変化と電波の振幅変化の相互相関を計算
  ;----------------------------------
  n_win = 300L
  n_lag = 80L
  lag = -fix(n_lag/2) + indgen(n_lag)
  n_cc = n - n_win
  cc = dblarr(n_cc,n_lag,m_asi)
  cc_int = dblarr(n_cc,n_lag)
  cc_sel = dblarr(n_cc,n_lag)
  cc_sel_EMIC = dblarr(n_cc,n_lag)
  cc_min_val = dblarr(n_cc,m_asi)
  cc_min_lag = dblarr(n_cc,m_asi)
  cc_max_val = dblarr(n_cc,m_asi)
  cc_max_lag = dblarr(n_cc,m_asi)

  ;電波の伝搬経路全体に沿ったオーロラ変化積分と、LFの相関
  for j=0,n_cc-1 do begin
    xx = lf_y[j:j+n_win-1]
    yy = hpf_int[j:j+n_win-1]
    res = C_CORRELATE(xx, yy, lag)
    cc_int[j,*] = res
  endfor
  store_data,tvar_asi+'_cc_int', data={x:lf_x[n_win/2:n_cc+n_win/2-1], y:cc_int, v:double(lag)}, $
    dlim={spec:1, ytitle:'Aurora vs VLF', ysubtitle:'Lag time [sec]', ztitle:'Correlation coeff.', zrange:[-0.4,0.4], zstyle:1}

  ;電波の伝搬経路上の特定点（指定範囲の積分）のオーロラ変化と、LFの相関
  for j=0,n_cc-1 do begin
    xx = lf_y[j:j+n_win-1]
    yy = hpf_sel[j:j+n_win-1]
    res = C_CORRELATE(xx, yy, lag)
    cc_sel[j,*] = res
  endfor
  store_data,tvar_asi+'_cc_sel', data={x:lf_x[n_win/2:n_cc+n_win/2-1], y:cc_sel, v:double(lag)}, $
    dlim={spec:1, ytitle:'Aurora vs VLF', ysubtitle:'Lag time [sec]', ztitle:'Correlation coeff.'}
    
  ;電波の伝搬経路上の特定点（指定範囲の積分）のオーロラ変化と、LFの相関 ※HPFなし
  for j=0,n_cc-1 do begin
    xx = lf_y[j:j+n_win-1]
    yy = sel[j:j+n_win-1]
    res = C_CORRELATE(xx, yy, lag)
    cc_sel_EMIC[j,*] = res
  endfor
  store_data,tvar_asi+'_cc_sel_EMIC', data={x:lf_x[n_win/2:n_cc+n_win/2-1], y:cc_sel_EMIC, v:double(lag)}, $
    dlim={spec:1, ytitle:'Aurora vs VLF', ysubtitle:'Lag time [sec]', ztitle:'Correlation coeff.'}

  ;電波の伝搬経路の各点のオーロラ変化積分と、LFの相関
  for i=0,m_asi-1 do begin
    for j=0,n_cc-1 do begin
      xx = lf_y[j:j+n_win-1]
      yy = reform(asi_hpf[j:j+n_win-1,i])
      res = C_CORRELATE(xx, yy, lag)
      cc[j,*,i] = res
      cc_min0  = min(res, imin)
      cc_max0  = max(res, imax)
      cc_min_val[j,i] = cc_min0
      cc_min_lag[j,i] = lag[imin]
      cc_max_val[j,i] = cc_max0
      cc_max_lag[j,i] = lag[imax]
    endfor
  endfor

  ;相関係数の統計的優位性確認 (p_sig未満の場合は、相関値をNANに置き換え)
  p_sig = 0.01  ; 1% significance
  n_free =  n_win-2L
  res = t_cvf(p_sig*0.5, n_free)
  t = sqrt(n_free)*abs(cc_min_val)/sqrt(1.0-cc_min_val^2)
  ind = where(t le res)
;  cc_min_val[ind] = !values.f_nan 
  cc_min_lag[ind] = !values.f_nan
  t = sqrt(n_free)*abs(cc_max_val)/sqrt(1.0-cc_max_val^2)
  ind = where(t le res)
;  cc_max_val[ind] = !values.f_nan
  cc_max_lag[ind] = !values.f_nan

  store_data,tvar_asi+'_min_cc',  data={x:lf_x[n_win/2:n_cc+n_win/2-1], y:cc_min_val, v:asi.v}, $
    dlim={spec:1, yrange:y_sel, zrange:[-0.4,0.0], $
    ytitle:'Longitude [deg]', ztitle:'Min. coeff.'}
  store_data,tvar_asi+'_min_lag', data={x:lf_x[n_win/2:n_cc+n_win/2-1], y:cc_min_lag, v:asi.v}, $
    dlim={spec:1, yrange:y_sel, $
    ytitle:'Longitude [deg]', ztitle:'Lag [s] (min. coeff)'}
  store_data,tvar_asi+'_max_cc',  data={x:lf_x[n_win/2:n_cc+n_win/2-1], y:cc_max_val, v:asi.v}, $
  dlim={spec:1, yrange:y_sel, zrange:[0.0,0.4], $
    ytitle:'Longitude [deg]', ztitle:'Max. coeff.'}
  store_data,tvar_asi+'_max_lag', data={x:lf_x[n_win/2:n_cc+n_win/2-1], y:cc_max_lag, v:asi.v}, $
    dlim={spec:1, yrange:y_sel, $
    ytitle:'Longitude [deg]', ztitle:'Lag [s] (max. coeff)'}
  
  ;----------------------------------
  ; PLOT
  ;----------------------------------
  ylim, [tvar_asi, $
         tvar_asi+'_hpf', $
         tvar_asi+'_min_cc', $
         tvar_asi+'_min_lag'], y_sel[0], y_sel[1]

  timespan, plot_trange
  trg = 'sel'
;  trg = 'int'
  window, xsize=900, ysize=1000
  tvars =  [tvar_asi, $
            tvar_asi+'_hpf', $
            tvar_asi+'_hpf_'+trg, $
            tvar_lf]
  options, tvars, panel_size=1.0 
  tplot, tvars
;  window, xsize=900, ysize=1200
;  tplot, [tvar_asi, $
;          tvar_asi+'_hpf', $
;          tvar_asi+'_hpf_'+trg, $
;          tvar_lf, $
;          tvar_asi+'_cc_'+trg]
;  tplot, [tvar_asi, $
;          tvar_asi+'_hpf', $
;          tvar_asi+'_hpf_'+trg, $
;          tvar_lf, $
;          tvar_asi+'_cc_'+trg, $
;          tvar_asi+'_min_cc', $
;          tvar_asi+'_min_lag']

  makepng, 'Spedas_data\'+file_basename(tplot_file)

  window, 1, xsize=600, ysize=500
  !p.charsize=1.5
  get_data, tvar_asi+'_cc_sel', data=data
  plot_td = time_double(plot_trange)
  td_cent = mean(plot_td)
  idx = nn( data.x, td_cent )
  tlabel = time_string([td_cent-n_win/2,td_cent+n_win/2])
  title = strmid(tlabel[0],11,8)+'-'+strmid(tlabel[1],11,8)
  cc_sel_cent=cc_sel[idx,*]
  plot, lag, cc_sel_cent, xtitle='Lag time [sec]', ytitle='Correlation coefficient', /nodata
  oplot, lag, cc_sel_cent, linestyle=2
  oplot, lag, cc_sel_cent, psym=1

  print, min(cc_sel_cent), max(cc_sel_cent)

  p_sig = 0.01  ; 1% significance
  n_free =  n_win-2L
  res = t_cvf(p_sig*0.5, n_free)
  t = sqrt(n_free)*abs(cc_sel_cent)/sqrt(1.0-cc_sel_cent^2)
  ind = where(t le res)
  cc_sel_cent[ind] = !values.f_nan
  ind = where(cc_sel_cent gt 0.0)
  cc_sel_cent[ind] = !values.f_nan
  oplot, lag, cc_sel_cent
  oplot, lag, cc_sel_cent, psym=6

  xyouts, -5.0, min(cc_sel[idx-n_win/2:idx+n_win/2,*])-0.1, title,  ALIGNMENT=0.0
  !p.charsize=0

  makepng, 'Spedas_data\'+file_basename(tplot_file)+'_center'
  
end
