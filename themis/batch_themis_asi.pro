pro batch_themis_asi, template=template, interval_min=interval_min
  if not keyword_set(interval_min) then interval_min=5
  if not keyword_set(delt)         then delt=7200.d;sec
  if not keyword_set(intime)       then intime='2017-01'
  cpath='/Volumes/moxonraid/data/themis/thg'
  omnipath='/Volumes/moxonraid/data/themis/omni'
  tempfile='datetemp.sav'
  infile='20180415-23-08-substorms.txt'
  infile=file_search(cpath,infile)
  infile=infile[0]
  if keyword_set(template) then begin
    template=ascii_template(infile)
    save, template, filename=cpath+'/'+tempfile
  endif else begin
    restore, cpath+'/'+tempfile
  endelse
  data=read_ascii(infile, template=template)
  year =string(data.field1[*])
  month=string(data.field2[*])
  day  =string(data.field3[*])
  hour =string(data.field4[*])
  min  =string(data.field5[*])
  datearr =year+'-'+month+'-'+day+'/'+hour+':'+min+':00'
  datearr0=datearr
  datearr1=datearr
  ndate=n_elements(datearr)
  for i=0l, ndate-1l do begin
    time_double=time_double(datearr[i])
    cdate0=time_double - delt
    cdate1=time_double + delt
    datearr0[i]=time_string(cdate0)
    datearr1[i]=time_string(cdate1)
  endfor
  ii=where(stregex(datearr0, intime) eq 0)
  if ii[0] eq -1 then message, 'invalid input parameter in in time'
  ndate=n_elements(ii)
  datearr0=datearr0[ii]
  datearr1=datearr1[ii]
  datearr=[[datearr0],[datearr1]]; define time range +/-2h from substorm onset
  
  ;  datearr=[$
  ;    ['2017-03-21/06:00:00','2017-03-21/10:00:00'],$
  ;    ['2017-03-22/06:00:00','2017-03-22/10:00:00'] $
  ;    ]
  ;  datearr=transpose(datearr)
  
  for i=0l, ndate-1l do begin
    start_date=datearr[i,0]
    stop_date=datearr[i,1]
    strarr=strsplit(start_date,'-/:',/ext)
    outdir=strarr[0]+strarr[1]+strarr[2]+strarr[3]
    file_mkdir, cpath+'/graph/'+outdir
    omnioutfile=cpath+'/graph/'+outdir+'/omni_'+outdir+'.txt'
;    omni2asc, trange=[start_date,stop_date], outfile=omnioutfile, /res5min, /long_format
    x_themis_asi_movie_test, start_date=start_date, stop_date=stop_date, interval_min = interval_min
  endfor
  return
end
