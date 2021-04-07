; thm_gmag_plot
;
; PURPOSE:
;     plot themis gmag data in North America
;
; keywords:
;     date      : 'YYYY-MM-DD'
;     omni=omni : if you set the "/omni", you plot sym-H, AE, and AU index.
;     ath=ath   : if you set the "/ath", you plot dynamic spectra of ATH H-component.
;
; EXAMPLES:
;     thm_gmag_plot, '2018-01-01', /omni, /ath
;
; HISTORY:
;     created by Asuka Hirai, 2018-09-11
;-
pro thm_gmag_plot, date, omni=omni, ath=ath

  timespan, date
  
;  fsmi gmlat = 67.29, gmlon = 307.05
;  snkq gmlat = 66.21, gmlon = 357.20
;  gill gmlat = 66.00, gmlon = 333.19
;  pokr gmlat = 65.40, gmlon = 265.79  
;  whit gmlat = 63.64, gmlon = 279.62
;  tpas gmlat = 63.12, gmlon = 324.23
;  atha gmlat = 61.88, gmlon = 307.21
;  pina gmlat = 59.96, gmlon = 331.87
;  pgeo gmlat = 59.07, gmlon = 296.09
;  vldr gmlat = 58.88, gmlon = 358.08
;  sit  gmlat = 51.07, gmlon = 206.80

  
  station = ['fsmi','snkq','gill','whit','tpas','atha','pina','pgeo','vldr','sit'] ;'pokr'
  color = 130-findgen(n_elements(station))*20
  tvar = []
  for i = 0, n_elements(station)-1 do begin
    thm_load_gmag, site = station[i], /subtract_averag
    split_vec, 'thg_mag_' + station[i]
    len = strlen(tnames('thg_mag_' + station[i] + '_x'))
    if len gt 0 then begin
      get_data, 'thg_mag_' + station[i] + '_x', data=data, dlim=dlim
      data.y[where(abs(data.y) gt 1500, count1)] = !values.f_nan
      store_data, 'thg_mag_' + station[i] + '_x', data = {x:data.x, y:data.y, v:data.v}
      str_element, dlim, 'colors', color[i], /ADD_REPLACE
      str_element, dlim, 'labels', station[i], /ADD_REPLACE
      store_data, 'thg_mag_' + station[i] + '_x', data=data, dlim=dlim
    endif
    if len gt 0 then tvar = [tvar, 'thg_mag_' + station[i] + '_x']
  endfor
  
  store_data, 'thm_mag_multi', data = tvar
  options, 'thm_mag_multi', 'labflag', -1
  options, 'thm_mag_multi', 'ytitle', 'THEMIS GMAG H'
  options, 'thm_mag_multi', 'ysubtitle', 'B[nT]'
  
  tplot_var = ['thm_mag_multi']
  if keyword_set(omni) then begin
    omni_hro_load
    tplot_var = ['OMNI_HRO_1min_SYM_H', 'OMNI_HRO_1min_AE_INDEX', 'OMNI_HRO_1min_AU_INDEX', tplot_var]
  endif
  if keyword_set(ath) then begin
    cal_induction_spc_plot, date, site = 'ath'
    tplot_var = [tplot_var, 'cal_ath_h']
  endif
  
  tplot, tplot_var
  options, 'thm_mag_multi', 'databar', {yval:[-200.,-50.,50.,200.], linestyle:1}
  tplot_apply_databar
  
  res = file_test('E:\backup\event_plot\' + time_string(date, tformat='YYYYMMDD'))
  if res eq 0 then file_mkdir,'E:\backup\event_plot\' + time_string(date, tformat='YYYYMMDD')
  makepng, 'E:\backup\event_plot\' + time_string(date, tformat='YYYYMMDD') + '\symh_ae_al_gmag_pc1'
  
  
end