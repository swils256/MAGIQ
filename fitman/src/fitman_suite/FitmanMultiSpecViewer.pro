function getxScale
  common common_vars
  return,xScale
end

function getyScale
  common common_vars
  return,yScale
end

pro EV_MutliSpecViewer,event
    common multiCommon, plotList,tempdraw,yMin,yMax,xMin,xMax,ft1,ft2,ef,gf,phase,view,pymin,pymax,$
                        zScale, zAngle,plotAngle,bleh,domainMenu,viewMenu,printButton
    
    compBase = WIDGET_BASE(COL=2, MAP=1, TITLE='Multi-Spectrum Viewer',MBAR=bar, TLB_FRAME_ATTR= 8)

    ; set up menu bar 
    fileMenu = WIDGET_BUTTON(bar, VALUE='File', /MENU)
    openButton = WIDGET_BUTTON(fileMenu, VALUE = 'Open Series of Spectra', EVENT_PRO='EV_OpenMultiSpec')
    printButton = WIDGET_BUTTON(fileMenu,VALUE='Print',EVENT_PRO='ev_SpecPrint')
    closeButton = WIDGET_BUTTON(fileMenu, VALUE = 'Close', EVENT_PRO='EV_OCANCEL')    
    
    domainMenu = WIDGET_BUTTON(bar, VALUE='Domain', /MENU)
    tmButton = WIDGET_BUTTON(domainMenu, VALUE = 'Time',UVALUE='time',EVENT_PRO='ev_specDomain')
    frButton = WIDGET_BUTTON(domainMenu, VALUE = 'Frequency',UVALUE='freq',EVENT_PRO='ev_specDomain')
        
   
    viewMenu = WIDGET_BUTTON(bar, VALUE='View', /MENU)
    horButton = WIDGET_BUTTON(viewMenu, VALUE = 'Vertical View',UVALUE='vv',EVENT_PRO='EV_specView')
    verButton = WIDGET_BUTTON(viewMenu, VALUE = 'Horizontal View',UVALUE='hv',EVENT_PRO='EV_specView')
    threedButton = WIDGET_BUTTON(viewMenu, VALUE = '3-D View',UVALUE='threeDv',EVENT_PRO='EV_specView')
     
    ; set-up textfields
    sideBase = widget_base(compBase,ROW=11,/FRAME)
    btnsizeX =15 
    yMin = CW_Field(sideBase, TITLE = 'Y Min', UVALUE='YMIN', VALUE = 0.0, /FLOATING, $
		/RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 
    yMax = CW_Field(sideBase, TITLE = 'Y Max', UVALUE='YMAX', VALUE = 0.0, /FLOATING, $
		/RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 
    xMin = CW_Field(sideBase, TITLE = 'X Min', UVALUE='XMIN', VALUE = 0.0, /FLOATING, $
		/RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 
    xMax = CW_Field(sideBase, TITLE = 'X Max', UVALUE='XMAX', VALUE = 0.0, /FLOATING, $
		/RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 

    ft1 = CW_Field(sideBase, TITLE = 'FT1 (s)', UVALUE='FFT_INITIAL', VALUE = 0.0,$
		/FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 
    ft2  = CW_Field(sideBase, TITLE = 'FT2 (s)', UVALUE='FFT_FINAL', VALUE = 0.0, $
		/FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 
    ef = CW_Field(sideBase, TITLE = 'EF (Hz)', UVALUE='E_FILTER', VALUE = 0.0,$ 
		/FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 
    gf = CW_Field(sideBase, TITLE = 'GF (Hz)', UVALUE='G_FILTER', VALUE = 0.0, $
		/FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME) 
    phase = CW_FSLIDER(sideBase, TITLE = 'Phase (Degrees)', /DRAG, UVALUE = 'PH_SLIDER', $
		VALUE = 0.0, MAXIMUM = 360.0, MINIMUM = -360, /FRAME, /EDIT)
    plotAngle = CW_FSLIDER(sideBase, TITLE = '3D Plot Angle (Degrees)', /DRAG, UVALUE = 'AN_SLIDER', $
		VALUE = 65.0, MAXIMUM = 360.0, MINIMUM = -360, /FRAME, /EDIT)
    bleh = CW_BGROUP(sideBase,["Same Y Min/Max"],/NONEXCLUSIVE,COL=colNum,/FRAME,UVALUE="BLEH")
    dBase = widget_base(compBase,ROW=2,/FRAME)
    drawArea = WIDGET_DRAW(dBase, RETAIN=1, UVALUE='S_DRAW', XSIZE=750*getxScale(), YSIZE=750*getyScale())
    
    view = 0
    zScale = 1
    zAngle = 65

    state = {yMin:yMin,yMax:yMax,xMin:xMin,xMax:xMax,ft1:ft1,ft2:ft2,ef:ef,gf:gf,phase:phase}
    pstate = PTR_NEW(state,/NO_COPY)	
    WIDGET_CONTROL, compBase, SET_UVALUE=pstate
                
    ; display the dialog
    WIDGET_CONTROL, compBase, /REALIZE
    WIDGET_CONTROL, drawArea, get_value= tempdraw
    WSET, tempdraw
	
    setSpecComponents,/DISABLE 

    XMANAGER, "multiSpec",compBase
end

pro EV_OpenMultiSpec, event
      common openSpec_vars, fName_label,files,list,listIndex,multFiles_label    

      files = obj_new('List')   
      listIndex = 0

      spec_base = WIDGET_BASE(col=3, MAP=1, TITLE='Open Series of Spectra', UVALUE='FIT')
	   	
      lbase = widget_base(spec_base,ROW=4)
	   	
      fileBase = widget_base(lbase,ROW=4,/FRAME)
      tbase = widget_base(fileBase,COL=2)
      fName_label = CW_FIELD(tbase,TITLE='File(s) to View',/STRING,XSIZE=30)
      broBtn = widget_button(tbase,VALUE='Browse',EVENT_PRO='EV_specFileBrowse') 
      multFiles_label = cw_field(fileBase,TITLE='Common File Name',/STRING,XSIZE=30)
      list = widget_list(fileBase,YSIZE=4,XSIZE=35,EVENT_PRO='ev_specList')
      btnBase = widget_base(fileBase,COL=2)
      addBtn = widget_button(btnBase,VALUE='Add',EVENT_PRO='ev_specAdd')
      remBtn = widget_button(btnBase,VALUE='Remove',EVENT_PRO='ev_specRemove') 
      mbase = widget_base(lbase,COL=2)
      openButton = WIDGET_BUTTON(mbase, VALUE = 'Open', EVENT_PRO='EV_openSpecFiles') 
      closeButton = WIDGET_BUTTON(mbase, VALUE = 'Cancel', EVENT_PRO='EV_OCANCEL')  
 
      WIDGET_CONTROL,fName_label,SET_VALUE=''
      WIDGET_CONTROL,multFiles_label,SET_VALUE=''

      WIDGET_CONTROL, spec_base, /REALIZE
      XMANAGER, 'specOpen', spec_base
end

pro drawPlots
   common multiCommon
   
   WIDGET_CONTROL,xmin,SET_VALUE=plotList[0]->getXMin()
   WIDGET_CONTROL,xmax,SET_VALUE=plotList[0]->getXMax()
   WIDGET_CONTROL,ymin,SET_VALUE=plotList[0]->getYMin()
   WIDGET_CONTROL,ymax,SET_VALUE=plotList[0]->getYMax()
   WIDGET_CONTROL,ft1,SET_VALUE=plotList[0]->getFFTInitial()
   WIDGET_CONTROL,ft2,SET_VALUE=plotList[0]->getFFTFinal()
   WIDGET_CONTROL,phase,SET_VALUE=plotList[0]->getPhase()
   WIDGET_CONTROL,ef,SET_VALUE=plotList[0]->getExponFilter()
   WIDGET_CONTROL,gf,SET_VALUE=plotList[0]->getGaussFilter()
       
   if(view eq 1) then begin
       getYMinMax   
       domain = plotList[0]->getDomain()

       if(domain eq 0) then begin
         surface,DIST(2), /NODATA,/SAVE,XRANGE=[plotList[0]->getXMin(),plotList[0]->getXMax()], $
            YRANGE=[1,n_elements(plotList)*zScale],ZRANGE=[pymin,pymax],XSTYLE=1,YSTYLE=1,ZSTYLE=1,$
            color=plotList[0]->getAxisColor(),CHARSIZE=1.5, AZ=zAngle
       endif 

       if(domain eq 1) then begin
          surface,DIST(2),/NODATA,/SAVE,YRANGE=[plotList[0]->getXMin(),plotList[0]->getXMax()], $
            XRANGE=[1,n_elements(plotList)*zScale],ZRANGE=[pymin,pymax],XSTYLE=1,YSTYLE=1,ZSTYLE=1,$
            color=plotList[0]->getAxisColor(),CHARSIZE=1.5,AZ=zAngle
       endif       
   endif

   for i = 0, n_elements(plotList)-1 do begin
      plotList[i]->displayData
   endfor 
end

pro multiSpec_event, event
   common multiCommon
   WIDGET_CONTROL, event.Id, GET_UVALUE=ev
   WIDGET_CONTROL,event.ID,get_value=val

   if(ev eq 'BLEH') then begin
      if(val eq 1) then begin
         getYMinMax
         for i = 0, n_elements(plotList)-1 do begin
             plotList[i]->saveYMinMax
             plotList[i]->setYMin,pymin
             plotList[i]->setYMax,pymax 
         endfor 
      endif else begin
         for i = 0, n_elements(plotList)-1 do begin
             plotList[i]->restoreYMinMax
         endfor
      endelse
   endif else begin
      for i = 0, n_elements(plotList)-1 do begin
        case ev of
          'XMIN': plotList[i]->setXMin,val
          'YMIN': begin
             WIDGET_CONTROL,bleh,GET_VALUE=changeY
             if(changeY eq 1) then plotList[i]->setYMin,val
           end
          'XMAX': plotList[i]->setXMax,val 
          'YMAX': begin
             WIDGET_CONTROL,bleh,GET_VALUE=changeY
             if(changeY eq 1)then plotList[i]->setYMax,val
           end  
          'FFT_INITIAL': plotList[i]->setFFTInitial,val
          'FFT_FINAL': plotList[i]->setFFTFinal,val
          'PH_SLIDER': plotList[i]->setPhase,val  
          'E_FILTER':plotList[i]->setExponFilter,val
          'G_FILTER':plotList[i]->setGaussFilter,val
          'AN_SLIDER': zAngle=val
         endcase   
      endfor
   endelse   
   drawPlots    
end

pro EV_openSpecFiles,event
   common openSpec_vars
   common multiCommon

   EV_OCANCEL,event
   fileNames = toStringArray(files)
   plotList = objarr(n_elements(fileNames)) 

   !P.MULTI = [0,1,n_elements(fileNames)]
   wset,tempdraw   

   for i = 0, n_elements(fileNames)-1 do begin    
      plotList[i] = obj_new('CSpecPlot')
      plotList[i]->loadFitmanData,fileNames[i]   
   endfor   

   drawPlots
   setSpecComponents,/ENABLE
end


pro ev_SpecPrint,event
   common common_vars 
   common multicommon
 
   current = !d.name
   set_plot, "PS"
		
   device, filename='graphs.ps', /inches, XSIZE=16, SCALE_FACTOR=.60, YSIZE =8.3, FONT_SIZE=20,/LANDSCAPE
   
   for i = 0, n_elements(plotList)-1 do begin
      plotList[i]->setPrint,/ENABLE
   endfor 
   drawPlots   

   device,/close
   command = defaultPrinter+' graphs.ps'   
   ;command = 'ghostview graphs.ps'
   spawn, command
   set_plot, current

   for i = 0, n_elements(plotList)-1 do begin
      plotList[i]->setPrint,/DISABLE
   endfor 
   drawPlots
   drawPlots
end

PRO EV_specFileBrowse, event
    COMMON openSpec_vars
    COMMON common_vars
    
    file = DIALOG_PICKFILE(/READ, PATH=string(defaultpath),FILTER='*.dat',/MULTIPLE_FILES)
    
    allFiles = ''

    for i = 0, n_elements(file)-1 do begin
      if(i ne n_elements(file)-1) then begin
         allFiles = allFiles + file[i] + ' '      
      endif else begin
         allFiles = allFiles + file[i]
      endelse  
    endfor
    
    WIDGET_CONTROL, fName_label, SET_VALUE=allFiles
END

pro ev_specAdd,event
  COMMON openSpec_vars
  COMMON common_vars
  
  WIDGET_CONTROL,fName_label,GET_VALUE=files1
  widget_control,multFiles_label,GET_VALUE=files2
   
  m = strlen(files1) 

  if(m[0] ne 0) then begin
     print,"adding from fName label"
     allFiles = str_sep(files1,' ')
  
     for i = 0, n_elements(allFiles)-1 do begin
       files->add,allFiles[i]
     endfor
  endif

  m = strlen(files2) 

  if(m[0] ne 0) then begin
     print, "Common files"
     stri = STRING(defaultpath+files2)
     fs = findfile(stri[0]+'')
     for i = 0, n_elements(fs)-1 do begin
        files->add,fs[i]
     endfor  
  endif   

  if(files->isEmpty() ne 1) then begin
     values = toStringArray(files)
     WIDGET_CONTROL,list,SET_VALUE=values 
  endif
  
  WIDGET_CONTROL,fName_label,SET_VALUE=''
  WIDGET_CONTROL,multFiles_label,SET_VALUE=''
end

pro ev_specList,event
   COMMON openSpec_vars

   listIndex = event.index
end

pro ev_specRemove,event
   COMMON openSpec_vars
   
   files->delete,listIndex
   
   if(files->size() ne 0) then begin
     values = toStringArray(files)
     WIDGET_CONTROL,list,SET_VALUE=values
   endif else begin
     WIDGET_CONTROL,list,SET_VALUE=''
   endelse
end

pro EV_specView,event
   common multiCommon
   WIDGET_CONTROL, event.Id, GET_UVALUE=ev       

   case ev of
        'hv': begin
           view = 0 
           !P.MULTI = [0,n_elements(plotList),1]
         end
         'vv': begin
           view = 0 
           !P.MULTI = [0,1,n_elements(plotList)]
         end 
         'threeDv':begin
           view = 1 
           !P.MULTI=[0,0,0]
         end  
   endcase 
   
   for i = 0, n_elements(plotList)-1 do begin
      if(view eq 0) then begin
         plotList[i]->setView,/NORMAL
      endif else if(view eq 1) then begin
         plotList[i]->setView,/V3D
         plotList[i]->setZCoord,((i+1)*zScale)
      endif
   end
   getYMinMax
   drawPlots 
end

pro getYMinMax
   common multiCommon

   tymin = plotList[0]->getYMin()
   tymax = plotList[0]->getYMax()

   for i = 0, n_elements(plotList)-1 do begin
       if(tymin gt plotList[i]->getYMin()) then begin
          tymin = plotList[i]->getYMin()
       endif
       
       if(tymax lt plotList[i]->getYMax()) then begin
          tymax = plotList[i]->getYMax()
       endif
   endfor
   pymin = tymin
   pymax = tymax 
end

pro ev_specDomain, event
   common multiCommon
   WIDGET_CONTROL, event.Id, GET_UVALUE=ev
   
   case ev of
       'time': begin
           for i = 0, n_elements(plotList)-1 do begin
               plotList[i]->setDomain,0
           endfor
           drawPlots
        end
        'freq':begin
           for i = 0, n_elements(plotList)-1 do begin
               plotList[i]->setDomain,1
               plotList[i]->phaseTimeDomainData
               plotList[i]->generateFrequency
           endfor
           drawPlots
        end       
   endcase
   getYMinMax
end

pro setSpecComponents, ENABLE=enable,DISABLE=disable
   common multiCommon
 
   val = 0
   if(keyword_set(enable)) then begin 
      val = 1
   endif  

   WIDGET_CONTROL,xmin,SENSITIVE=val
   WIDGET_CONTROL,xmax,SENSITIVE=val
   WIDGET_CONTROL,ymin,SENSITIVE=val
   WIDGET_CONTROL,ymax,SENSITIVE=val
   WIDGET_CONTROL,ft1,SENSITIVE=val
   WIDGET_CONTROL,ft2,SENSITIVE=val
   WIDGET_CONTROL,phase,SENSITIVE=val
   WIDGET_CONTROL,ef,SENSITIVE=val
   WIDGET_CONTROL,gf,SENSITIVE=val
   WIDGET_CONTROL,plotAngle,SENSITIVE=val
   WIDGET_CONTROL,bleh,SENSITIVE=val
   WIDGET_CONTROL,viewMenu,SENSITIVE=val
   WIDGET_CONTROL,domainMenu,SENSITIVE=val
   WIDGET_CONTROL,printButton,SENSITIVE=val
end
