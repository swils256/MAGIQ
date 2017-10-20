;=======================================================================================================;
; Name:  FitmanConfigOptions.                         ;
; Purpose:  Contains the set of procedures and functions that are called when a user clicks an option   ;
;           under the Configuration menu for FitmanGui.                  ;
; Dependancies:  FitmanGui_Sept2000.pro                     ;
;=======================================================================================================;

;=======================================================================================================;
; Name:  EV_SETDIR                           ;
; Purpose:  This procedure sets up the window so that the user can set the default path.  This will     ;
;       affect all load and saves done within idl.   This will also be saved to the HD so that the  ;
;       user doesn't have to keep setting a defualt path every session.          ;
; Parameters:  event - The event that called this procedure.                ;
; Return: None.                              ;
;=======================================================================================================;
PRO EV_SETDIR, event
    COMMON common_vars

    dir_base = WIDGET_BASE(COL=2, MAP=1, TITLE="Configuration:Default Directory", UVALUE='d_base')
    path_base =WIDGET_BASE(dir_base,COL=2, MAP=1)
    path_label = CW_FIELD(path_base, TITLE='Default Directory: ', VALUE=defaultpath, /STRING)
    path_browse = WIDGET_BUTTON(path_base, VALUE = "Browse", EVENT_PRO = 'EV_PATH_BROWSE')
    ok_base = WIDGET_BASE(dir_base,ROW = 2, MAP = 1, /BASE_ALIGN_CENTER)
    ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok', EVENT_PRO= 'EV_DIR_OK',UVALUE='dir_ok')
    cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_DIR_CANCEL')


    state = { path_label:path_label}
    pstate = ptr_new(state, /NO_COPY)

    WIDGET_CONTROL, dir_base, SET_UVALUE=pstate
    WIDGET_CONTROL, dir_base, /REALIZE
    XMANAGER, 'foo', dir_base
END

;=======================================================================================================;
; Name: EV_PATH_BROWSE                           ;
; Purpose:  To allow the user to browse to find the path they want to use.          ;
; Parameters:   event - The event that called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;

pro pathBrowse, event,dpath
    COMMON common_vars
    WIDGET_CONTROL, event.top, GET_UVALUE = pstate

    placeholder = 0

    WHILE (placeholder EQ 0) DO BEGIN
       IF (STRING(dpath) EQ '') THEN file = DIALOG_PICKFILE(/READ)
;       IF (!d.name EQ 'X') OR (!d.name EQ 'MAC') THEN $
;       		IF (STRING(dpath) NE '') THEN file = DIALOG_PICKFILE(PATH=STRING(dpath))
;       IF (!d.name EQ 'WIN') THEN $
       		IF (STRING(dpath) NE '') THEN file = DIALOG_PICKFILE(PATH=STRING(dpath), /DIRECTORY)


       IF (STRING(file) EQ '') THEN BREAK
       IF (!d.name EQ 'X') THEN BEGIN
        IF (STRMID(file, STRLEN(file)-1, 1) EQ '/') THEN BREAK
       ENDIF
       IF (!d.name EQ 'WIN') THEN BEGIN
        IF (STRMID(file, STRLEN(file)-1, 1) EQ '\') THEN BREAK
       ENDIF
     ENDWHILE

     IF (STRING(file) NE '') THEN WIDGET_CONTROL, (*pstate).path_label, SET_VALUE=file
end

PRO EV_PATH_BROWSE, event
   COMMON common_vars

   pathBrowse,event,defaultpath
END

pro EV_PATH_BROWSEhlsvd, event
   COMMON common_vars

   pathBrowse,event,hlsvdpath
end

;=======================================================================================================;
; Name:  EV_DIR_CANCEL                           ;
; Purpose:  This will destroy the window for setting the default path and will not save the directory.  ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_DIR_CANCEL, event

    WIDGET_CONTROL, event.top, /DESTROY
END

;=======================================================================================================;
; Name:  EV_DIR_OK                           ;
; Purpose:  When OK is selected from the window, it will set the default path as the selected path and  ;
;       save it for later use.                       ;
; Parameters: Event - The event which called this procedure.                 ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_DIR_OK, event
    COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=pstate
    WIDGET_CONTROL, (*pstate).path_label, GET_VALUE=defaultpath
    WIDGET_CONTROL, event.top, /DESTROY

    IF (!d.name EQ 'X') OR (!d.name EQ 'MAC') THEN BEGIN
        IF (STRMID(defaultpath[0], STRLEN(defaultpath)-1,1) EQ '/') THEN BEGIN
            defaultpath = defaultpath[0]
        ENDIF ELSE BEGIN
            defaultpath = defaultpath[0] +'/'
        ENDELSE
    ENDIF

    IF (!d.name EQ 'WIN') THEN BEGIN
        IF (STRMID(defaultpath[0], STRLEN(defaultpath)-1,1) EQ '\') THEN BEGIN
            defaultpath = defaultpath[0]
        ENDIF ELSE BEGIN
            defaultpath = defaultpath[0] +'\'
        ENDELSE
    ENDIF

    ; Write it to a file called Fitman.cfg
    openw, unit, 'Fitman.cfg', /GET_LUN    ;opens data file
    printf, unit, defaultpath
    close, unit
    free_lun, unit
END

;=======================================================================================================;
; Name: EV_SETPTR                          ;
; Purpose:  Allows a user to select the printer to print to.  The default will be read in when the      ;
;          program is loaded.                         ;
; Parameters:  Event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_SETPTR, event
    COMMON common_vars

    ptr_base = WIDGET_BASE(COL=2, MAP=1, TITLE="Configuration:Default Printer", UVALUE='d_base')
    type_base =WIDGET_BASE(ptr_base,COL=2, MAP=1)
    ptr_label = CW_FIELD(type_base, TITLE='Default Printer: ', VALUE=defaultprinter, /STRING)
    ok_base = WIDGET_BASE(ptr_base,ROW = 2, MAP = 1, /BASE_ALIGN_CENTER)
    ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok', EVENT_PRO= 'EV_PTR_OK')
    cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_PTR_CANCEL')


    state = { ptr_label:ptr_label}
    pstate = ptr_new(state, /NO_COPY)

    WIDGET_CONTROL, ptr_base, SET_UVALUE=pstate
    WIDGET_CONTROL, ptr_base, /REALIZE
    XMANAGER, 'foo', ptr_base
END

;=======================================================================================================;
; Name:  EV_PTR_CANCEL                           ;
; Purpose:  This will destroy the window for setting the default path and will not save the directory.  ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_PTR_CANCEL, event

    WIDGET_CONTROL, event.top, /DESTROY
END

;=======================================================================================================;
; Name:  EV_PTR_OK                           ;
; Purpose:  When OK is selected from the window, it will set the default path as the selected path and  ;
;       save it for later use.                       ;
; Parameters: Event - The event which called this procedure.                 ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_PTR_OK, event
    COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=pstate
    WIDGET_CONTROL, (*pstate).ptr_label, GET_VALUE=ptr_name
    WIDGET_CONTROL, event.top, /DESTROY

    defaultPrinter = ptr_name
    ; Write it to a file called Fitman.cfg
    openw, unit, 'Printer.cfg', /GET_LUN   ;opens data file
    printf, unit, ptr_name
    close, unit
    free_lun, unit
END

;========================================================================================================;
; new code starts here - HLSV and watersub path set
;========================================================================================================

;========================================================================================================;
;
;
;
;========================================================================================================;

pro EV_setHLSVDPath, event
    COMMON common_vars

        hlsvd_base = WIDGET_BASE(COL=2, MAP=1, TITLE="Configuration:Default HLSVD Directory", UVALUE='d_base')
    path_base =WIDGET_BASE(hlsvd_base,COL=2, MAP=1)
    path_label = CW_FIELD(path_base, TITLE='Default Directory: ', VALUE=hlsvdpath, /STRING)
    path_browse = WIDGET_BUTTON(path_base, VALUE = "Browse", EVENT_PRO = 'EV_PATH_BROWSEhlsvd')
    ok_base = WIDGET_BASE(hlsvd_base,ROW = 2, MAP = 1, /BASE_ALIGN_CENTER)
    ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok',EVENT_PRO = 'EV_HLSVD_OK',UVALUE='hlsvd_ok')
    cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_DIR_CANCEL')


    state = { path_label:path_label}
    pstate = ptr_new(state, /NO_COPY)

    WIDGET_CONTROL, hlsvd_base, SET_UVALUE=pstate
    WIDGET_CONTROL, hlsvd_base, /REALIZE
    XMANAGER, 'foo', hlsvd_base
end

pro EV_HLSVD_OK,event
    COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=pstate
    WIDGET_CONTROL, (*pstate).path_label, GET_VALUE=hlsvdpath
    WIDGET_CONTROL, event.top, /DESTROY

    if (STRMID(hlsvdpath[0], STRLEN(hlsvdpath)-1,1) EQ '/') THEN BEGIN
              hlsvdpath = hlsvdpath[0]
    ENDIF ELSE BEGIN
          hlsvdpath = hlsvdpath[0] +'/'
    ENDELSE
        print, hlsvdpath

    ; Write it to a file called Fitman2.cfg
    openw, unit, 'Fitman2.cfg', /GET_LUN   ;opens data file
    printf, unit, hlsvdpath
    close, unit
    free_lun, unit

    correctWater_Sub

end

function getCmd, strPath
   pos = rstrpos(strPath,'/') + 1

   return, STRMID(strPath,pos)
end

pro correctWater_Sub
   print, 'in correctWater_Sub'
   COMMON common_vars

   file = hlsvdpath + 'water_sub'
   openr, unit, file, /GET_LUN
   parms = ''

   ;readf, unit, parms
   ;line1 = getCmd(STRMID(parms,0))

   ;readf, unit, parms
   ;line2 = STR_SEP(STRMID(parms,0),' ')
   ;print, n_elements(line2)

   repeat begin
        null_string = 1
        readf, unit, parms
        if parms EQ "" THEN null_string = 0
   endrep until null_string ;reads next line of file.
   line1 = getCmd(STRMID(parms,0))

   repeat begin
        null_string = 1
        readf, unit, parms
        if parms EQ "" THEN null_string = 0
   endrep until null_string ;reads next line of file.
   water_line_two = STRMID(parms,0)
   line2 = STR_SEP(STRMID(water_line_two,0),' ')

   CLOSE, unit
   FREE_LUN, unit

   print, line1
   lineTwo = ''

   print, n_elements(line2)

   for i = 0, n_elements(line2)-1 do begin

     if ((i ne 3 AND i ne 4) AND (line2[i] ne '')) then begin
        line2[i] =  hlsvdpath + getCmd(line2[i])
     endif

     if(line2[i] ne '') then begin
        print, line2[i]
        lineTwo = lineTwo + line2[i]+ ' '
     endif
   endfor

   file = hlsvdpath+'water_sub'
   openw, unit, file, /GET_LUN
   printf, unit,(hlsvdpath+line1)
   printf, unit, lineTwo

   close, unit
   free_lun, unit
end
