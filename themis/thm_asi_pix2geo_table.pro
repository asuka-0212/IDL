pro thm_asi_pix2geo_table, site=site, trange=trange

if not keyword_set(site) then begin

  site=['atha','chbg','ekat','fsmi','fsim','fykn', $
        'gako','gbay','gill','inuv','kapu','kian', $
        'kuuj','mcgr','pgeo','pina','rank','snkq', $
        'tpas','whit','yknf','nrsq','snap','talo']
endif

if keyword_set(trange) then timespan,trange

for ii=0,n_elements(site)-1 do begin

	thm_load_asi_cal,site[ii],cal
	glon1=*cal.vars[6].dataptr
	glat1=*cal.vars[7].dataptr
	elev =*cal.vars[5].dataptr

	glon2=dblarr(256,256)
	glat2=dblarr(256,256)

	for jj=0,255 do begin
		for kk=0,255 do begin
			glon2[jj,kk]=(glon1[1,jj,kk]+glon1[1,jj+1,kk]+ $
						  glon1[1,jj,kk+1]+glon1[1,jj+1,kk+1])/4.0
			glat2[jj,kk]=(glat1[1,jj,kk]+glat1[1,jj+1,kk]+ $
						  glat1[1,jj,kk+1]+glat1[1,jj+1,kk+1])/4.0
		endfor
	endfor

	glon=glon2 & glat=glat2
	save,glon,glat,elev,file='thm_asi_'+site[ii]+'_pix2geo_table_v01.sav'
	dprint,'thm_asi_'+site[ii]+'_pix2geo_table_v01.sav was created.'

endfor 
end