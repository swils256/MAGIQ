;=======================================================================================================
; Name:  EV_DATA
; Purpose:  The procedure EV_DATA is called when a user clicks on the "Data" menu in the program.   It
;       is responsible for directing the data gathered from the reading in of the data set.   It
;       sets the appropriate widget values to correspond to the read-in data, and concludes by
;       drawing the data set to the screen (in the graph).
; Parameters:  event - the event which triggered the call to this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_DATA, event
        COMMON common_vars
        COMMON common_widgets

    IF (window_flag EQ 1) THEN BEGIN
       ;Call the display procedure
       IF  (data_source EQ 'file') THEN READ_FITMAN_DATA ELSE INSERT_DATA ; added 11/01/2005

       setComponents,/ENABLE
       WIDGET_CONTROL,reload_output,SENSITIVE=0


       IF (error_flag) THEN BEGIN
         error_flag = 0
         RETURN
       ENDIF

       original_data = REFORM(time_data_points[0,*])

          AUTO_SCALE

       ; Set up the appropriate text field values in the widgets.
       WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.time_xmin
       WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.time_xmax
          WIDGET_CONTROL, Y_MAX, SET_VALUE = plot_info.time_ymax
       o_xmax=plot_info.time_xmax
          WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * plot_info.time_ymin
            WIDGET_CONTROL, INITIAL, SET_VALUE = plot_info.fft_initial
       middle_plot_info.phase = 0
          middle_plot_info.current_phase=0
          plot_info.fft_final = float(data_file_header.points/2 * data_file_header.dwell)
          WIDGET_CONTROL, FINAL, SET_VALUE = plot_info.fft_final

          ;Display only the real part of the time domain signal
          time_data_points[0,0] = complex(1,0)
          plot_info.traces = 0
       IF (plot_info.domain EQ 1) THEN BEGIN
          REDISPLAY
       ENDIF ELSE BEGIN
         DISPLAY_DATA
       ENDELSE
       WIDGET_CONTROL, button2, SENSITIVE=1
    ENDIF
    IF (window_flag EQ 2) THEN BEGIN    ; Middle Draw Widget
       ;Call the display procedure
       compSelect = obj_new('List') ; added 04/26/2002
       IF  (data_source EQ 'file') THEN MIDDLE_READ_FITMAN_DATA ELSE INSERT_DATA ; added 11/01/2005


            setComponents,/ENABLE
            WIDGET_CONTROL,reload_output,SENSITIVE=0

       IF (error_flag) THEN BEGIN
         error_flag = 0
         RETURN
       ENDIF

       middle_original_data = REFORM(middle_time_data_points[0,*])

          AUTO_SCALE

       ; Set up the appropriate text field values in the widgets.
       WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.time_xmin
       WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.time_xmax
          o_xmax2=middle_plot_info.time_xmax
       WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.time_ymax
          WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * middle_plot_info.time_ymin
          WIDGET_CONTROL, INITIAL, SET_VALUE = middle_plot_info.fft_initial
          middle_plot_info.fft_final = float(middle_data_file_header.points/2 * $
       middle_data_file_header.dwell)
          WIDGET_CONTROL, FINAL, SET_VALUE = middle_plot_info.fft_final
       WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE=0
       middle_plot_info.phase = 0
          middle_plot_info.current_phase=0
       ;Display only the real part of the time domain signal
          middle_time_data_points[0,0] = complex(1,0)
          middle_plot_info.traces = 0


       IF (middle_plot_info.domain EQ 1) THEN BEGIN
         REDISPLAY
       ENDIF ELSE BEGIN
         MIDDLE_DISPLAY_DATA
       ENDELSE

    ENDIF
    IF (window_flag EQ 3) THEN BEGIN     ; Bottom Draw Widget
       ;Call the display procedure
       IF  (data_source EQ 'file') THEN BOTTOM_READ_FITMAN_DATA ELSE INSERT_DATA ; added 11/01/2005


       IF (error_flag) THEN BEGIN
         error_flag = 0
         RETURN
       ENDIF

                setComponents,/ENABLE
                WIDGET_CONTROL,reload_output,SENSITIVE=0

       bottom_original_data = REFORM(bottom_time_data_points[0,*])

          AUTO_SCALE

       ; Set up the appropriate text field values in the widgets
       WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
       WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
          o_xmax3=bottom_plot_info.time_xmax
       WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
          WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
          WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
       middle_plot_info.phase = 0
          middle_plot_info.current_phase=0
            bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * $
       bottom_data_file_header.dwell)
          WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final

          ;Display only the real part of the time domain signal
          bottom_time_data_points[0,0] = complex(1,0)
          bottom_plot_info.traces = 0

       IF (bottom_plot_info.domain EQ 1) THEN BEGIN
         REDISPLAY
       ENDIF ELSE BEGIN
         BOTTOM_DISPLAY_DATA
       ENDELSE
    ENDIF
    data_source = 'file'
END

;=======================================================================================================;
; Name:  EV_GUESS                          ;
; Purpose: To provide the functionality to the user so they can read in guess files (which act upon the ;
;      graph).  These can only be read in if the user has defined the graph and loaded in a   ;
;      constraints file.  We only want data to be read in if the middle window is active.     ;
; Parameters: event - the event that triggered the call tp this routine.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_GUESS, event
        COMMON common_vars
        COMMON common_widgets

        middle_plot_info.read_file_type = 0

        PHASE_TIME_DOMAIN_DATA
    MIDDLE_READ_GUESS_FILE

    WIDGET_CONTROL, /HOURGLASS

    ; If file is non-existant or invalid.
    filename = STRSPLIT(middle_plot_info.guess_file, '.', /EXTRACT)
    IF (filename[N_ELEMENTS(filename)-1] EQ '' ) THEN RETURN

    IF (filename[N_ELEMENTS(filename)-1] EQ 'ges' OR $
    filename[N_ELEMENTS(filename)-1] EQ 'out') THEN BEGIN

            CONVERT_TO_HERTZ
            UPDATE_LINKS
            GENERATE_FIT_CURVE
            GENERATE_RESIDUAL
            middle_plot_info.traces = middle_guess_info.num_peaks+2
            ;middle_plot_info.last_trace = 2

                 WIDGET_CONTROL,reload_guess_button,SENSITIVE=1
                 WIDGET_CONTROL,reload_const_button,SENSITIVE=1

                if(not(middle_plot_info.last_trace ge 3)) then begin
               middle_plot_info.last_trace = 2
            endif

            ; Set offset of the residual so that it appears at the top
            middle_plot_color[2].offset = -1*(middle_plot_info.freq_ymax - 0.1 * $
       middle_plot_info.freq_ymax)

            IF (ABS(middle_time_data_points[0,0]) GT 0) THEN BEGIN
                   FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                       middle_time_data_points[i,0] = middle_time_data_points[0,0]
                   ENDFOR
            ENDIF ELSE BEGIN
                   FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                       middle_time_data_points[i,0] = complex(1,0)
                  ENDFOR
            ENDELSE

       ;middle_plot_info.phase = fooze
            middle_plot_info.delay_time = middle_peak[5,1].pvalue
           WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
            PHASE_TIME_DOMAIN_DATA

            if (middle_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY

            ;MIDDLE_DISPLAY_DATA
            REDISPLAY
        ENDIF ELSE BEGIN
       ;ERROR_MESSAGE, "Invalid filename. (Guess files end in .ges or .out)"
       err_result = DIALOG_MESSAGE('Invalid filename.  Guess files end in .ges or .out', $
                 Title = 'WARNING')
            RETURN
    ENDELSE
    IF (middle_plot_info.const_file EQ '') THEN BEGIN
            WIDGET_CONTROL, button15, SENSITIVE=0
            WIDGET_CONTROL, create_noise, SENSITIVE=0
    ENDIF ELSE BEGIN
         WIDGET_CONTROL, button15, SENSITIVE=1
         WIDGET_CONTROL, create_noise, SENSITIVE=1
    ENDELSE

END

;=======================================================================================================;
; Name: EV_RGUESS                          ;
; Purpose:  This procedure will be called when the user clicks the 'Reset Guess File' button under the  ;
;           File menu.   It will reload the current guess file from the hard disk if one exists.  If    ;
;           no guess file has been loaded, nothing will be done.                                        ;
; Parameters:  event - The event that caused this procedure to be called.                               ;
; Return:  None.                               ;
;=======================================================================================================;
PRO EV_RGUESS, event

    COMMON common_vars
    COMMON common_widgets

    ; Guess files can only be loaded in the middle window, so we know that this option
    ; must only work in the middle window.


       IF (middle_plot_info.guess_file EQ '') THEN RETURN;

       ; If a file has been loaded already...
       middle_plot_info.read_file_type = 0

         PHASE_TIME_DOMAIN_DATA

         print, 'reload'

         reloadGC = 1; added 05/01/02

       MIDDLE_READ_GUESS_FILE

       reloadGC = 0; added 05/01/02

            CONVERT_TO_HERTZ
            UPDATE_LINKS
            GENERATE_FIT_CURVE
            GENERATE_RESIDUAL
            middle_plot_info.traces = middle_guess_info.num_peaks+2

            if(not(middle_plot_info.last_trace ge 3)) then begin
               middle_plot_info.last_trace = 2
            endif

            ; Set offset of the residual so that it appears at the top
            middle_plot_color[2].offset = -1*(middle_plot_info.freq_ymax - 0.1 *middle_plot_info.freq_ymax)

            IF (ABS(middle_time_data_points[0,0]) GT 0) THEN BEGIN
                   FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                       middle_time_data_points[i,0] = middle_time_data_points[0,0]
                   ENDFOR
            ENDIF ELSE BEGIN
                   FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                       middle_time_data_points[i,0] = complex(1,0)
                  ENDFOR
            ENDELSE

            middle_plot_info.delay_time = middle_peak[5,1].pvalue
           WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
            PHASE_TIME_DOMAIN_DATA

            if (middle_plot_info.domain EQ 1) THEN BEGIN
         GENERATE_FREQUENCY
              REDISPLAY
         ENDIF ELSE BEGIN
              ;ERROR_MESSAGE, "Invalid filename. (Guess files end in .ges or .out)"
         err_result = DIALOG_MESSAGE('Invalid filename.  Guess files end in .ges or .out', $
                Title = 'WARNING')
                  RETURN
       ENDELSE
       IF (middle_plot_info.const_file EQ '') THEN BEGIN
             WIDGET_CONTROL, button15, SENSITIVE=0
             WIDGET_CONTROL, create_noise, SENSITIVE=0
       ENDIF ELSE BEGIN
         WIDGET_CONTROL, button15, SENSITIVE=1
         WIDGET_CONTROL, create_noise, SENSITIVE=1
       ENDELSE
END
;=======================================================================================================;
; Name: EV_CONST
; Purpose: The EV_CONST procedure is called when a user clicks on the Constant button under the File
;      menu.   It is responsible for setting all required variables needed to set up the
;      constraints.  It sets up all the datapoints and plot information, then before exiting,
;      display the data on the screen.
; Parameters:  event -  The event that caused this procedure to be called.
; Return:  None.
;=======================================================================================================;
PRO EV_CONST, event
        COMMON common_vars
        COMMON common_widgets

        middle_plot_info.fft_recalc = 1
    WIDGET_CONTROL, PHASE_SLIDER, GET_VALUE = fooze
    middle_plot_info.phase = fooze
    WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase

        PHASE_TIME_DOMAIN_DATA
        MIDDLE_READ_CONSTRAINTS_FILE

    WIDGET_CONTROL, /HOURGLASS

    ; If file is non-existant or invalid.
        IF (middle_const_info.const_file_label EQ 0) THEN BEGIN
       IF (Error_Flag EQ 1) THEN BEGIN
         Error_Flag = 0
         RETURN
       ENDIF ELSE BEGIN
            ;ERROR_MESSAGE, "Invalid output file!  I cannot use this file."
       err_result = DIALOG_MESSAGE('Invalid output file!  I cannot use this file.', $
                   Title = 'ERROR', /ERROR)
                print, 'ERROR READING OUTPUT FILE'
       ENDELSE
        ENDIF ELSE BEGIN
            CONVERT_TO_HERTZ
            UPDATE_LINKS
            GENERATE_FIT_CURVE
            GENERATE_RESIDUAL
            middle_plot_info.traces = middle_guess_info.num_peaks+2
            middle_plot_info.last_trace = 2

            ; Set offset of the residual so that it appears at the top
            middle_plot_color[2].offset = -1*(middle_plot_info.freq_ymax - 0.1 * $
       middle_plot_info.freq_ymax)

            IF (ABS(middle_time_data_points[0,0]) GT 0) THEN BEGIN
                   FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                       middle_time_data_points[i,0] = middle_time_data_points[0,0]
                   ENDFOR
            ENDIF ELSE BEGIN
              FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                     middle_time_data_points[i,0] = complex(1,0)
        ENDFOR
            ENDELSE

            ;middle_plot_info.phase = middle_peak[4,1].pvalue * 180/!PI
            middle_plot_info.delay_time = middle_peak[5,1].pvalue
       WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
            PHASE_TIME_DOMAIN_DATA

            IF (middle_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
            MIDDLE_DISPLAY_DATA
        ENDELSE

    IF (middle_plot_info.const_file EQ '') THEN BEGIN
       WIDGET_CONTROL, button15, SENSITIVE=0
       WIDGET_CONTROL, create_noise, SENSITIVE=0
    ENDIF ELSE BEGIN
       WIDGET_CONTROL, button15, SENSITIVE=1
       WIDGET_CONTROL, create_noise, SENSITIVE=1
    ENDELSE
END

;=======================================================================================================;
; Name:  EV_RCONST                                 ;
; Purpose:  To allow a user to relaod a constraints file.  This will read the exact same file as loaded ;
;       before.  If no constraints file has been loaded before this command is pressed, nothing will;
;       happen.                                                                                     ;
; Parameters:  event - the event which called this procedure.               ;
; Return:  None.                           ;
;=======================================================================================================;
PRO EV_RCONST, event
    COMMON common_vars
        COMMON common_widgets
    ; Only be used from the middle window, so we only need to check it.

    IF (middle_const_info.const_file_label EQ 0) THEN RETURN

    ; Otherwise a file has been loaded that we can reload

    middle_plot_info.fft_recalc = 1
    WIDGET_CONTROL, PHASE_SLIDER, GET_VALUE = fooze
    middle_plot_info.phase = fooze
    WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase

        PHASE_TIME_DOMAIN_DATA

        reloadGC = 1 ; added 05/01/02

        MIDDLE_READ_CONSTRAINTS_FILE

        reloadGC = 0 ; added 05/01/02

    ; If file is non-existant or invalid.


        CONVERT_TO_HERTZ
        UPDATE_LINKS
        GENERATE_FIT_CURVE
        GENERATE_RESIDUAL
        middle_plot_info.traces = middle_guess_info.num_peaks+2

        if(not(middle_plot_info.last_trace ge 3)) then begin
           middle_plot_info.last_trace = 2
        endif

        ; Set offset of the residual so that it appears at the top
        middle_plot_color[2].offset = -1*(middle_plot_info.freq_ymax - 0.1 * $
    middle_plot_info.freq_ymax)

        IF (ABS(middle_time_data_points[0,0]) GT 0) THEN BEGIN
            FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
               middle_time_data_points[i,0] = middle_time_data_points[0,0]
            ENDFOR
        ENDIF ELSE BEGIN
            FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
               middle_time_data_points[i,0] = complex(1,0)
       ENDFOR
        ENDELSE


        middle_plot_info.delay_time = middle_peak[5,1].pvalue
    WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
        PHASE_TIME_DOMAIN_DATA

        IF (middle_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
        MIDDLE_DISPLAY_DATA
END

;=======================================================================================================;
; Name:  EV_OUT                              ;
; Purpose:  To allow a user to load in an output file.   Although a output file may be read for the     ;
;       constraints & guess files, this is not simply a "constraints & guess" in one function.   The;
;       components will not work as well as a few other things. It reads them both in, but does   ;
;       different things with the information.                                                      ;
; Parameters:  event - the event which called this procedure.               ;
; Return:  None.                           ;
;=======================================================================================================;
PRO EV_OUT, event
     OUTPUT_FILE,event
END

pro EV_OUT_RELOAD,event
   OUTPUT_FILE,event,/RELOAD
end

pro OUTPUT_FILE,event,RELOAD=reload_out
        COMMON common_vars
        COMMON common_widgets


    middle_plot_info.read_file_type = 1
        middle_plot_info.phase = 0.0
        middle_plot_info.fft_recalc = 1

    WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
        PHASE_TIME_DOMAIN_DATA

    if(keyword_set(reload_out)) then begin
      MIDDLE_READ_GUESS_FILE,/RELOAD_OUTPUT
    endif else if(not(keyword_set(reload_out)))then begin
          MIDDLE_READ_GUESS_FILE
          WIDGET_CONTROL,reload_output,SENSITIVE=1
        endif

    ; If file is non-existant or invalid.
    filename = STRSPLIT(middle_plot_info.guess_file, '.', /EXTRACT)
    IF (filename[N_ELEMENTS(filename)-1] EQ '' ) THEN RETURN
    IF (filename[N_ELEMENTS(filename)-1] NE 'out') THEN BEGIN
        ;ERROR_MESSAGE, "Invalid filename. (Output files end in .out)"
    err_result = DIALOG_MESSAGE('Invalid filename.  Output files end in .out', $
                 Title = 'WARNING')
        RETURN
    ENDIF


            CONVERT_TO_HERTZ
            GENERATE_FIT_CURVE
            GENERATE_RESIDUAL
            middle_plot_info.traces = middle_guess_info.num_peaks+2
            middle_plot_info.last_trace = 2

            ; Set offset of the residual so that it appears at the top
            middle_plot_color[2].offset = -1*(middle_plot_info.freq_ymax - 0.1 * $
                 middle_plot_info.freq_ymax)

            IF (ABS(middle_time_data_points[0,0]) GT 0) THEN BEGIN
                   FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                       middle_time_data_points[i,0] = middle_time_data_points[0,0]
                   ENDFOR
            ENDIF ELSE BEGIN
                   FOR i=1, middle_guess_info.num_peaks+2 DO BEGIN
                       middle_time_data_points[i,0] = complex(1,0)
                  ENDFOR
            ENDELSE

            middle_plot_info.phase = middle_peak[4,1].pvalue * 180/!PI
            middle_plot_info.delay_time = middle_peak[5,1].pvalue
           WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
            PHASE_TIME_DOMAIN_DATA

            IF (middle_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
             MIDDLE_DISPLAY_DATA

end

;=======================================================================================================;
; Name:  EV_PRINT                          ;
; Purpose: To provide a menu in which the user can select which graphs they wish to print.  This menu is;
;          accessed by clicking on "Print Graphs" under the file menu.                                  ;
; Parameters:  Event - the event which caused this procedure to be called.          ;
; Return: None.                              ;
;=======================================================================================================;
PRO EV_PRINT, event
    COMMON common_vars
    COMMON common_widgets
        COMMON common_print, print_top, print_middle, print_bottom,status_ptr

    WIDGET_CONTROL, main1, SENSITIVE=0
    print_base = WIDGET_BASE(ROW=3, MAP=1, TITLE='PRINT', UVALUE='PRINT',TLB_FRAME_ATTR= 8, MBAR=bar,$
          /TLB_SIZE_EVENTS)
    Warning_message = WIDGET_LABEL(print_base, $
         VALUE='WARNING!  This version can print on UNIX/LINUX stations only. ')
    Warning_message2= WIDGET_LABEL(print_base, $
         VALUE='MAC or WINDOWS will simply be printed to a file called "graphs.ps" ')
    choice_base = WIDGET_BASE(print_base,COL=2, MAP=1, TITLE='Select windows to print:', $
         UVALUE='CHOICES')
    window_base = WIDGET_BASE(choice_base, ROW=3, /FRAME)
    choice2_base = WIDGET_BASE(choice_base, ROW=3)
    window1_base = WIDGET_BASE(window_base,COL=2,/EXCLUSIVE)
    window1 = WIDGET_BUTTON(window1_base, VALUE = 'Print Top Graph', EVENT_PRO="EV_WIN1_PRINT")
    window1_off = WIDGET_BUTTON(window1_base, VALUE="Don't", EVENT_PRO="EV_WIN1_DONT")
    window2_base = WIDGET_BASE(window_base,COL=2,/EXCLUSIVE)
    window2 = WIDGET_BUTTON(window2_base, VALUE = 'Print Middle Graph', EVENT_PRO="EV_WIN2_PRINT")
    window2_off = WIDGET_BUTTON(window2_base, VALUE="Don't", EVENT_PRO="EV_WIN2_DONT")
    window3_base = WIDGET_BASE(window_base,COL=2,/EXCLUSIVE)
    window3 = WIDGET_BUTTON(window3_base, VALUE = 'Print Bottom Graph', EVENT_PRO="EV_WIN3_PRINT")
    window3_off = WIDGET_BUTTON(window3_base, VALUE="Don't", EVENT_PRO = "EV_WIN3_DONT")
    Ok_Button = WIDGET_BUTTON(choice2_base, Value='Ok', EVENT_PRO='EV_P_OK')
    Cancel_Button = WIDGET_BUTTON(choice2_base, Value='Cancel', EVENT_PRO= 'EV_P_CANCEL')

        subBase = widget_base(choice2_base,/NONEXCLUSIVE)
    subButton = WIDGET_BUTTON(subBase,VALUE ='Print Data On Graph(s)',EVENT_PRO='EV_PRINT_DATA')

    print_top =0
    print_middle =0
    print_bottom = 0

    status = {print_top:print_top, print_middle: print_middle, print_bottom:print_bottom,printData:0}
    status_ptr = ptr_new(status, /NO_COPY)

    WIDGET_CONTROL, print_base, SET_UVALUE=status_ptr
    WIDGET_CONTROL, print_base, /REALIZE
    XMANAGER, 'print!', print_base
END


;=======================================================================================================;
; Name:  EV_WIN1_PRINT, EV_WIN2_PRINT, EV_WIN3_PRINT                   ;
; Purpose:  Simple procedure to set which windows get printed by the print routine.        ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_WIN1_PRINT, event
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr
    (*status_ptr).print_top =1
END

PRO EV_WIN2_PRINT, event
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr
    (*status_ptr).print_middle =1
END

PRO EV_WIN3_PRINT, event
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr
    (*status_ptr).print_bottom =1
END

;=======================================================================================================;
; Name:  EV_WIN1_DONT, EV_WIN2_DONT, EV_WIN3_DONT                ;
; Purpose: A small procedure to set when the individual draw windows are not to be printed.        ;
; Parameters:  event - The event which called this procedure.                       ;
; Return:  None.                                     ;
;=======================================================================================================;
PRO EV_WIN1_DONT, Event
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr
    (*status_ptr).print_top = 0
END

PRO EV_WIN2_DONT, Event
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr
    (*status_ptr).print_middle = 0
END

PRO EV_WIN3_DONT, Event
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr
    (*status_ptr).print_bottom = 0
END

pro EV_PRINT_DATA, event
   COMMON common_print

   (*status_ptr).printData = event.select
end

function blackBack, red,green,blue
  s = SIZE(red)
  image3d = BYTARR(3, s[1], s[2])

  image3d[0, *, *] = red
  image3d[1, *, *] = green
  image3d[2, *, *] = blue

  return,image3d
end

function binaryImage,red,green,blue
   s = SIZE(red)

   c = s[1]
   r = s[2]

   for i = 0, c-1 do begin
      for j = 0, r-1 do begin
          ;if(red[i,j] eq 0 AND green[i,j] eq 0 AND blue[i,j] eq 0) then begin
          ;  red[i,j]   = 255
          ;  green[i,j] = 255
          ;  blue[i,j]  = 255
          ;endif else if(red[i,j] eq 255 AND green[i,j] eq 255 AND blue[i,j] eq 255) then begin
          ;  red[i,j]   = 0
          ;  green[i,j] = 0
          ;  blue[i,j]  = 0
          ;endif
          ;print, red[i,j],green[i,j],blue[i,j]

          if((red[i,j] ne 255 OR green[i,j] ne 255 OR blue[i,j] ne 255)) then begin
             ;print,red[i,j],' ',green[i,j],' ',blue[i,j]
             red[i,j]   = 0
             green[i,j] = 0
             blue[i,j]  = 0
          endif
      endfor
   endfor

   return, blackBack(red,green,blue)
end

function getPrintImage,event,drawID,fft_initial,fft_final,expon_filter,guass_filter,phase,scal_f,$
                       TOP=t,MIDDLE=m,BOTTOM=b
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr

    wset,drawID

    if(keyword_set(t) AND (*status_ptr).print_top) then begin
       DISPLAY_DATA
    endif else if(keyword_set(m) AND (*status_ptr).print_middle) then begin
       MIDDLE_DISPLAY_DATA
    endif else if(keyword_set(b) AND (*status_ptr).print_bottom) then begin
       BOTTOM_DISPLAY_DATA
    endif

    if((*status_ptr).printData) then begin
       setSubTitle,fft_initial,fft_final,expon_filter,guass_filter,phase,scal_f
    endif

    image = TVRD()
    TVLCT,r,g,b,/GET

    mr = r[image]
    mg = g[image]
    mb = b[image]

    return, blackBack(mr,mg,mb);
end


pro setSubTitle,fft_initial,fft_final,expon_filter,guass_filter,phase,scal_f
   initVal  = STRCOMPRESS(STRING(fft_initial),/REMOVE_ALL)
   finalVal = STRCOMPRESS(STRING(fft_final),/REMOVE_ALL)
   expVal   = STRCOMPRESS(STRING(expon_filter),/REMOVE_ALL)
   gaussVal = STRCOMPRESS(STRING(guass_filter),/REMOVE_ALL)
   phaseVal = STRCOMPRESS(STRING(phase),/REMOVE_ALL)
   scalVal = STRCOMPRESS(STRING(scal_f),/REMOVE_ALL)

   xpos = 100
   fsize = 2

   XYOUTS,xpos,225,'FFT1          : ' + initVal, COLOR=0,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,210,'FFT2          : ' + finalVal,COLOR=0,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,195,'Exponent Filter: ' + expVal,COLOR=0,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,180,'Gauss Filter   : ' + gaussVal,COLOR=0,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,165,'Phase         : ' + phaseVal,COLOR=0,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,150,'Scaling Factor:' + scalVal,COLOR=0,/DEVICE,CHARSIZE = fsize
end

pro setMULTI,event
  WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr

  if((*status_ptr).print_top AND (*status_ptr).print_middle AND (*status_ptr).print_bottom) then begin
      !P.MULTI = [0,1,3]
  endif else if( ((*status_ptr).print_top AND (*status_ptr).print_middle) OR ((*status_ptr).print_bottom $
                  AND (*status_ptr).print_top) OR ((*status_ptr).print_middle $
                  AND (*status_ptr).print_middle) ) then begin
      !P.MULTI = [0,1,2]
  endif else begin
      !P.MULTI = [0,0,0]
  endelse

end

function mergeImageArrays, event,imaget,imagem,imageb
   WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr

   rows = 0
   cols = 0

   ; create the big array

   if((*status_ptr).print_top) then begin
      st = SIZE(imaget)
      rows = rows + st[3]
      cols = st[2]
   endif

   if((*status_ptr).print_middle) then begin
      sm = SIZE(imagem)
      rows = rows + sm[3]
      cols = sm[2]
   endif

   if((*status_ptr).print_bottom) then begin
      sb = SIZE(imageb)
      rows = rows + sb[3]
      cols = sb[2]
   endif

   image = INTARR(3,cols,rows)
   arrPos = 0

   if((*status_ptr).print_bottom) then begin
     endPos = arrPos + sb[3]

     image[0,0:sb[2]-1,arrPos:endPos-1] = imageb[0,0:sb[2]-1,0:sb[3]-1]
     image[1,0:sb[2]-1,arrPos:endPos-1] = imageb[1,0:sb[2]-1,0:sb[3]-1]
     image[2,0:sb[2]-1,arrPos:endPos-1] = imageb[2,0:sb[2]-1,0:sb[3]-1]
     arrPos = endPos
   endif

   if((*status_ptr).print_middle) then begin
      endPos = arrPos + sm[3]

      image[0,0:sm[2]-1,arrPos:endPos-1] = imagem[0,0:sm[2]-1,0:sm[3]-1]
      image[1,0:sm[2]-1,arrPos:endPos-1] = imagem[1,0:sm[2]-1,0:sm[3]-1]
      image[2,0:sm[2]-1,arrPos:endPos-1] = imagem[2,0:sm[2]-1,0:sm[3]-1]
      arrPos = endPos
   endif

   if((*status_ptr).print_top) then begin
     endPos = arrPos + st[3]

    image[0,0:st[2]-1,arrPos:endPos-1] = imaget[0,0:st[2]-1,0:st[3]-1]
    image[1,0:st[2]-1,arrPos:endPos-1] = imaget[1,0:st[2]-1,0:st[3]-1]
    image[2,0:st[2]-1,arrPos:endPos-1] = imaget[2,0:st[2]-1,0:st[3]-1]
    arrPos = endPos
   endif

   return, image
end

;=======================================================================================================;
; Name:  EV_P_OK                             ;
; Purpose:  When the Ok button is pressed, the procedure will print the selected graphcs to either a    ;
;           printer, if on a UNIX/Linux machine or a file if on any other OS.                           ;
; Parameters:   Event - The event that caused this event to be triggered.          ;
; Return:  None.                             ;
;=======================================================================================================;

PRO EV_P_OK,event
   COMMON common_vars
   WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr

   currView = plot_info.view

   if(currView ne 1) then begin
      EV_VIEW_PAPER,event
   endif

   if((*status_ptr).printData) then begin
     EV_PRINT_VALUES,event
   endif else if(not((*status_ptr).printData)) then begin
     EV_POST_SCRIPT,event
   endif

   if(currView ne 1) then begin
    if(currView eq 0) then begin
            EV_VIEW_NORMAL,event
        endif else if(currView eq 2) then begin
            EV_VIEW_PAPER_NORMAL,event
    endif
   endif
end


;=======================================================================================================;
PRO EV_POST_SCRIPT, event
    COMMON common_vars
    COMMON common_widgets
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr

    ; If using X Windows (hence Unix/Linux) then print to a printer.
    IF (!D.Name EQ 'X') THEN BEGIN
    print_flag =1
       current = !d.name
       set_plot, "PS"
       ;!P.multi = [0,1,3]

       setMulti,event

       device, filename='graphs.ps', /inches, XSIZE=16, SCALE_FACTOR=.60, YSIZE =8.3, FONT_SIZE=20,/LANDSCAPE
       Previous_Flag = Window_Flag

       IF ((*status_ptr).print_top) THEN BEGIN
         DISPLAY_DATA
       ENDIF
       IF ((*status_ptr).print_middle) THEN BEGIN
               ;MIDDLE_DISPLAY_DATA
         Window_Flag = 2
         ;REDISPLAY
         ;GENERATE_FREQUENCY
         MIDDLE_DISPLAY_DATA
         Window_Flag = Previous_Flag
       ENDIF
       IF ((*status_ptr).print_bottom) THEN BEGIN
         BOTTOM_DISPLAY_DATA
       ENDIF
       device,/close
       command = defaultPrinter+' graphs.ps'
       ;command = 'ghostview graphs.ps'
       spawn, command
       set_plot, current
       print_flag = 0
    ENDIF

    ;If using MACOS then print to file.
    IF (!D.name EQ 'MAC') THEN BEGIN
            print_flag =1
       current = !d.name
       set_plot, "PS"
       !P.multi = [0,1,3]
       device, filename='graphs.ps', /inches, XSIZE=16, SCALE_FACTOR=.5, YSIZE =8.3, /LANDSCAPE

       IF ((*status_ptr).print_top) THEN DISPLAY_DATA
       IF ((*status_ptr).print_middle) THEN BEGIN
         REDISPLAY
       ENDIF
       if ((*status_ptr).print_bottom) THEN BOTTOM_DISPLAY_DATA
       device,/close
       set_plot,current
       print_flag = 0
    ENDIF

    ;If using Windows, then use system printer.
    IF (!D.name EQ 'WIN') THEN BEGIN
        print_flag =1
       current = !d.name
       set_plot, "printer"
       !P.multi = [0,1,3]

       printSetup = DIALOG_PRINTERSETUP()

       IF (printSetup NE 0) THEN BEGIN
         IF ((*status_ptr).print_top) THEN BEGIN
          DISPLAY_DATA
         ENDIF
         IF ((*status_ptr).print_middle) THEN BEGIN
          REDISPLAY
         ENDIF
         IF ((*status_ptr).print_bottom) THEN BEGIN
          BOTTOM_DISPLAY_DATA
         ENDIF
       ENDIF

       device,/close
       set_plot,current
       print_flag = 0

    ENDIF

    WIDGET_CONTROL, event.top, /DESTROY
    WIDGET_CONTROL, main1, SENSITIVE=1
    REDISPLAY
END


;=======================================================================================================;
PRO EV_PRINT_VALUES, event
    COMMON common_vars
    COMMON common_widgets
    COMMON draw1_comm
    WIDGET_CONTROL, event.top, GET_UVALUE=status_ptr
    WIDGET_CONTROL, Scaling_Slider,GET_VALUE = s_factor

    prevDrawID = draw2_id

    case (Window_Flag) of
            1: prevDrawID = draw1_id
            2: prevDrawID = draw2_id
            3: prevDrawID = draw3_id
        endcase

    imaget = 0
    imagem = 0
    imageb = 0

    WIDGET_CONTROL,/HOURGLASS

    IF ((*status_ptr).print_top) THEN begin
             imaget=getPrintImage(event,draw1_id,plot_info.fft_initial,plot_info.fft_final,$
                         plot_info.expon_filter,plot_info.gauss_filter,$
                         plot_info.phase,s_factor,/TOP)
    endif
    IF ((*status_ptr).print_middle) THEN BEGIN
         imagem=getPrintImage(event,draw2_id,middle_plot_info.fft_initial,middle_plot_info.fft_final,$
                         middle_plot_info.expon_filter,middle_plot_info.gauss_filter,$
                         middle_plot_info.phase,s_factor,/MIDDLE)
    endif
    IF ((*status_ptr).print_bottom) THEN begin
             imageb=getPrintImage(event,draw3_id,bottom_plot_info.fft_initial,bottom_plot_info.fft_final,$
                         bottom_plot_info.expon_filter,bottom_plot_info.gauss_filter,$
                         bottom_plot_info.phase,s_factor,/BOTTOM)
    endif

    image = mergeImageArrays(event,imaget,imagem,imageb)

    IF (!D.name EQ 'X' OR !D.name EQ 'MAC') THEN BEGIN
       print_flag =1
       current = !d.name
       set_plot, "PS"

       setMULTI,event

           device, filename='graphs.ps', /inches, XSIZE=16, SCALE_FACTOR=.65, YSIZE =8.3, FONT_SIZE=20,/LANDSCAPE
       Previous_Flag = Window_Flag

        TV,image,TRUE=1

       device,/close
       set_plot, current
    ENDIF

    IF (!D.Name EQ 'X') THEN BEGIN
       command = defaultPrinter+' graphs.ps'
       ;command = 'ghostview graphs.ps'
       spawn, command

       ;print, 'done print'
    ENDIF

        ;If using Windows, then use system printer.
    IF (!D.name EQ 'WIN') THEN BEGIN
        print_flag =1
       current = !d.name
       set_plot, "printer"
       ;!P.multi = [0,1,3]

       printSetup = DIALOG_PRINTERSETUP()

       setMULTI,event

        ;device, /inches, XSIZE=16, SCALE_FACTOR=.65, YSIZE =8.3, /LANDSCAPE
       Previous_Flag = Window_Flag

        TV,image,TRUE=1, /inches, XSIZE=8, YSIZE =4.15

       device,/close
       set_plot,current
       print_flag = 0

    ENDIF

    print_flag = 0

    WIDGET_CONTROL, event.top, /DESTROY
    WIDGET_CONTROL, main1, SENSITIVE=1

    ;REDISPLAY
    Window_Flag = 1
    wset,draw1_id
    DISPLAY_DATA

    Window_Flag = 2
    wset,draw2_id
    MIDDLE_DISPLAY_DATA

    Window_Flag = 3
    wset,draw3_id
    BOTTOM_DISPLAY_DATA

    Window_Flag = Previous_Flag
    wset,prevDrawID
END

;=======================================================================================================;
; Name:  EV_P_CANCEL                             ;
; Purpose:  Cleans up the menu and returns control to the main window.            ;
; Parameters:  Event - The event which caused this procedure to be called.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_P_CANCEL, event
    COMMON common_vars
    COMMON common_widgets
    WIDGET_CONTROL, event.top, /DESTROY
    WIDGET_CONTROL, main1, SENSITIVE=1

    IF (Window_Flag EQ 1) THEN DISPLAY_DATA
    IF (Window_Flag EQ 2) THEN REDISPLAY
    IF (Window_Flag EQ 3) THEN BOTTOM_DISPLAY_DATA
END

;=======================================================================================================;
; Name: EV_AVE                              ;
; Purpose:  To write the contents of the bottom draw widget to disk.  This comes in handy to the user   ;
;           during a subtraction since the resulting graph has not been written out anywhere.  It asks  ;
;       for a filename and writes it out.   It then sets the name of the third draw widget to be the;
;       same that it was written out to and draws the window again so the new location is displayed ;
; Parameters: event - the event which caused this procedure to be called.                               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_SAVE, event
    COMMON common_vars
        COMMON common_widgets

        count = 0

    Overwrite_Result = 'No'
    WHILE (Overwrite_Result EQ 'No') DO BEGIN
       ; Open the save file.
           SaveFile = DIALOG_PICKFILE(/WRITE, /OVERWRITE_PROMPT ,PATH=defaultpath, FILTER='*.dat')
       Overwrite_Result = 'Yes'

       ;Added 11/01/2005 .. checking for cancel
       IF (SaveFile EQ '') THEN RETURN

       extPos = strpos(savefile, '.', /REVERSE_SEARCH)
       SaveFileExt = strmid(savefile, extPos , strlen(savefile))

       IF (SaveFileExt NE '.dat') THEN BEGIN
         SaveFile = SaveFile + '.dat'
         SaveFileInfo = FILE_INFO(SaveFile)
         ;If file exists, ask user for confirmation;
         IF (SaveFileInfo.EXISTS) THEN BEGIN
          ;OVERWRITE, SaveFile
          OV_message = [SaveFile + ' already exists.', 'Do you want to replace it?']
          Overwrite_Result = DIALOG_MESSAGE(OV_message, $
                   Title = 'Please Select a File for Writing', $
                   /DEFAULT_NO, /QUESTION)

         ENDIF
       ENDIF
    END

    OPENW, unit, SaveFile, ERROR = openErr, /GET_LUN

    IF (Window_Flag EQ 1) THEN BEGIN
       IF (plot_info.data_file EQ "") THEN BEGIN
         CLOSE, unit
         FREE_LUN, unit
         RETURN
       ENDIF
       ; Write the data header to a file.
           PRINTF, unit, data_file_header.points
           PRINTF, unit, data_file_header.components
           PRINTF, unit, data_file_header.dwell
           PRINTF, unit, data_file_header.frequency
           PRINTF, unit, data_file_header.scans
           PRINTF, unit, data_file_header.comment1
           PRINTF, unit, data_file_header.comment2
           PRINTF, unit, data_file_header.comment3
           PRINTF, unit, data_file_header.comment4
           PRINTF, unit, data_file_header.acq_type
           PRINTF, unit, data_file_header.increment
           PRINTF, unit, data_file_header.empty

           ; We meed to keep the same file format, so we write the real part,
       ;then the imaginary part of the point on seperate lines.
       
       ; Change initial value for i to take into account the FT1   
           FOR i = ((plot_info.fft_initial / 0.0005) + 1), (data_file_header.points/2)+1 DO BEGIN
             PRINTF, unit, float(time_data_points[0,i])
         PRINTF, unit, imaginary(time_data_points[0,i])
           ENDFOR
           
       ; Pad the data file so the array is the right size
           IF plot_info.fft_initial GE 0.001 THEN BEGIN
         	FOR i = 2, ((plot_info.fft_initial / 0.0005) + 1) DO BEGIN
         	    PRINTF, unit, float(0.00000)
         	    PRINTF, unit, imaginary(0.00000)
         	ENDFOR
           ENDIF

           plot_info.data_file = SaveFile
          DISPLAY_DATA

        ENDIF
    IF (Window_Flag EQ 2) THEN BEGIN
       IF (middle_plot_info.data_file EQ '') THEN BEGIN
         CLOSE, unit
         FREE_LUN, unit
         RETURN
       ENDIF

       ; Write the data header to a file.
           PRINTF, unit, middle_data_file_header.points
           PRINTF, unit, middle_data_file_header.components
           PRINTF, unit, middle_data_file_header.dwell
           PRINTF, unit, middle_data_file_header.frequency
           PRINTF, unit, middle_data_file_header.scans
           PRINTF, unit, middle_data_file_header.comment1
           PRINTF, unit, middle_data_file_header.comment2
           PRINTF, unit, middle_data_file_header.comment3
           PRINTF, unit, middle_data_file_header.comment4
           PRINTF, unit, middle_data_file_header.acq_type
           PRINTF, unit, middle_data_file_header.increment
           PRINTF, unit, middle_data_file_header.empty

           ; We meed to keep the same file format, so we write the real part,
       ;then the imaginary part of the point on seperate lines.
       
       ; Change initial value for i to take into account the FT1   
           FOR i = ((middle_plot_info.fft_initial / 0.0005) + 1), (middle_data_file_header.points/2)+1 DO BEGIN
             PRINTF, unit, float(middle_time_data_points[0,i])
         PRINTF, unit, imaginary(middle_time_data_points[0,i])
           ENDFOR
           
       ; Pad the data file so the array is the right size
           IF middle_plot_info.fft_initial GE 0.001 THEN BEGIN
         	FOR i = 2, ((middle_plot_info.fft_initial / 0.0005) + 1) DO BEGIN
         	    PRINTF, unit, float(0.00000)
         	    PRINTF, unit, imaginary(0.00000)
         	ENDFOR
           ENDIF

           middle_plot_info.data_file = SaveFile
          MIDDLE_DISPLAY_DATA

    ENDIF
    IF (Window_Flag EQ 3) THEN BEGIN

       IF (Bottom_plot_info.data_file EQ '') THEN BEGIN
         CLOSE, unit
         FREE_LUN, unit
         RETURN
       ENDIF
       ; Write the data header to a file.
           PRINTF, unit, bottom_data_file_header.points
           PRINTF, unit, bottom_data_file_header.components
           PRINTF, unit, bottom_data_file_header.dwell
           PRINTF, unit, bottom_data_file_header.frequency
           PRINTF, unit, bottom_data_file_header.scans
           PRINTF, unit, bottom_data_file_header.comment1
           PRINTF, unit, bottom_data_file_header.comment2
           PRINTF, unit, bottom_data_file_header.comment3
           PRINTF, unit, bottom_data_file_header.comment4
           PRINTF, unit, bottom_data_file_header.acq_type
           PRINTF, unit, bottom_data_file_header.increment
           PRINTF, unit, bottom_data_file_header.empty

           ; We meed to keep the same file format, so we write the real part,
       ;then the imaginary part of the point on seperate lines.
       
       ; Change initial value for i to take into account the FT1   
           FOR i = ((bottom_plot_info.fft_initial / 0.0005) + 1), (bottom_data_file_header.points/2)+1 DO BEGIN
             PRINTF, unit, float(bottom_time_data_points[0,i])
         PRINTF, unit, imaginary(bottom_time_data_points[0,i])
           ENDFOR
           
       ; Pad the data file so the array is the right size
           IF bottom_plot_info.fft_initial GE 0.001 THEN BEGIN
         	FOR i = 2, ((bottom_plot_info.fft_initial / 0.0005) + 1) DO BEGIN
         	    PRINTF, unit, float(0.00000)
         	    PRINTF, unit, imaginary(0.00000)
         	ENDFOR
           ENDIF

           bottom_plot_info.data_file = SaveFile
          BOTTOM_DISPLAY_DATA

    ENDIF
        CLOSE, unit
        FREE_LUN, unit
END



;=======================================================================================================;
; Name:  EV_FIT
; Purpose:  This is to allow the user to fit a graph to produce an output file.  This procedure is
;       called when the user clicks on file, Fit.   It sets up the windows that will get the
;       information from the user to allow them to modify the fitting to the way that they want it.
; Paramters:  event - The event which called this procedure.
; Return: None.
;=======================================================================================================;
PRO EV_FIT, event
    COMMON common_vars
    COMMON common_widgets
;   COMMON fit_vars, Fill_field,Weighing_field,Variable_field,prms_field,args_field,Covariance_field,$
;     Output_field, command,list_element1,list_element2,list_element3,list_element4,list_element5, $
;     list_element6, list_element7,list_element8,list_element9,list_element10, var_base,files,fName_label,$
;     list,listIndex
;**** Remove list_element7 - 9 from list above

    COMMON fit_vars, Fill_field,Weighing_field,Variable_field,prms_field,args_field,Covariance_field,$
       Output_field, command,list_element1,list_element2,list_element3,list_element4,list_element5, $
       list_element6, var_base,files,fName_label,$
       list,listIndex

;**** END ADDITION  ---Three changes in total in this file

    files = obj_new('List')
    files->add,middle_plot_info.data_file

    ; We can only do this currently on a UNIX machine because the fitman program needs to be
    ; modified to work on a mac correctly.
    IF (!d.name EQ "X") THEN BEGIN
           WIDGET_CONTROL, main1, SENSITIVE=0

           toSet = 0
           fit_base = WIDGET_BASE(col=3, MAP=1, /SCROLL, X_SCROLL_SIZE=600,Y_SCROLL_SIZE=650, TITLE='Fit', UVALUE='FIT')

           lbase = widget_base(fit_base,ROW=4)

           fileBase = widget_base(lbase,ROW=3,/FRAME)
           tbase = widget_base(fileBase,COL=2)
           fName_label = CW_FIELD(tbase,TITLE='File to Fit',/STRING,XSIZE=30)
           broBtn = widget_button(tbase,VALUE='Browse',EVENT_PRO='EV_FILE_BROWSE')
           list = widget_list(fileBase,VALUE=[files->getData(0)],YSIZE=4,XSIZE=29,EVENT_PRO='EV_FITLIST')
           btnBase = widget_base(fileBase,COL=2)
           addBtn = widget_button(btnBase,VALUE='Add',EVENT_PRO='EV_FITADD')
           remBtn = widget_button(btnBase,VALUE='Remove',EVENT_PRO='EV_REM')

           option_base = WIDGET_BASE(lbase,row=10, MAP=1, /FRAME)
       var_base = WIDGET_BASE(fit_base, col =2, MAP=1, TITLE='Variable List', TLB_FRAME_ATTR=8)
       list_base = WIDGET_BASE(lbase,COL=3, MAP=1,/FRAME)
       other_base = WIDGET_BASE(lbase, COL=2, MAP=1)
           request_base = WIDGET_BASE(row=2,fit_base, MAP=1, UVALUE='OPTIONS')
           label = WIDGET_LABEL(option_base, VALUE='Enter the options you want to generate the fit.')
           Fill_field = CW_FIELD(option_base, TITLE = 'Zero fill to point:', VALUE = 0, /INTEGER, XSIZE=4)
           Weighing_field = CW_FIELD(option_base, TITLE = 'Apply Exponential Weighing (Hz):',$
       VALUE = 0,/INTEGER ,XSIZE=4)
           Variable_field = CW_FIELD(option_base, TITLE = 'Optional Variable File:', VALUE='',/STRING)
           prms_field = CW_FIELD(option_base,TITLE='Set/Override Fitting Parameter:',  VALUE='', /STRING)
           args_field = CW_FIELD(option_base, TITLE='                               Arguments:', VALUE='', $
       /STRING)
           Covariance_field = CW_FIELD(option_base, TITLE='Covariance Matrix Output File:', VALUE = '',$
       /STRING)



       Out_base = WIDGET_BASE(col=2, option_base, MAP=1)
           Output_field = CW_FIELD(out_base, TITLE='Output File:', VALUE='', /STRING)
           Out_button = WIDGET_BUTTON(out_base, VALUE='Browse', EVENT_PRO='EV_FIT_BROWSE')



            list_basel=WIDGET_BASE(list_base,ROW=2, MAP=1, /FRAME)
            list_basem=WIDGET_BASE(list_base,ROW=2, MAP=1, /FRAME)
            list_baser=WIDGET_BASE(list_base,ROW=2, MAP=1, /FRAME)

       list_element1 = CW_FIELD(list_basel,TITLE = 'Var 1:',VALUE='', /STRING,XSIZE=16)
       list_element2 = CW_FIELD(list_basel,TITLE = 'Var 2:',VALUE='', /STRING,XSIZE=16)
       list_element3 = CW_FIELD(list_basem,TITLE = 'Var 3:',VALUE='', /STRING,XSIZE=16)
       list_element4 = CW_FIELD(list_basem,TITLE = 'Var 4:',VALUE='', /STRING,XSIZE=16)
       list_element5 = CW_FIELD(list_baser,TITLE = 'Var 5:',VALUE='', /STRING,XSIZE=16)
       list_element6 = CW_FIELD(list_baser,TITLE = 'Var 6:',VALUE='', /STRING,XSIZE=16)
       ;list_element7 = CW_FIELD(list_baser,TITLE = 'Var 7:',VALUE='', /STRING,XSIZE=16)
       ;list_element8 = CW_FIELD(list_baser,TITLE = 'Var 8:',VALUE='', /STRING,XSIZE=16)
       ;list_element9 = CW_FIELD(list_baser,TITLE = 'Var 9:',VALUE='', /STRING,XSIZE=16)
       ;list_element10 = CW_FIELD(list_baser,TITLE = 'Var 10:',VALUE='',/STRING,XSIZE=15)
           WIDGET_CONTROL, fit_base, /REALIZE

       var_ok_button = WIDGET_BUTTON(other_base, VALUE='Ok', EVENT_PRO='EV_VAR_OK')
       var_cancel_button = WIDGET_BUTTON(other_base, VALUE='Cancel', EVENT_PRO='EV_VAR_CANCEL')

           XMANAGER, 'fit', fit_base
    ENDIF
END

function getOutFile, strFile
   pos = rstrpos(strFile,'.')

   return, STRMID(strFile,0,pos) + '.out'
end

function genOutputFileNames,list
  size = list->size()
  values = STRARR(size)

  for i = 0, size-1 do begin
     fName = list->getData(i)
     values[i] = getOutFile(fName)
  endfor

  return, values
end

PRO EV_FIT_BROWSE, event
    COMMON fit_vars
    COMMON common_vars

    file = DIALOG_PICKFILE(/READ, PATH=string(defaultpath))

    WIDGET_CONTROL, output_field, SET_VALUE=file
END

function toStringArray,list
  size = list->size()
  values = STRARR(size)

  for i = 0, size-1 do begin
     values[i] = list->getData(i)
  endfor

  return, values
end

pro EV_FITADD,event
  COMMON fit_vars

  WIDGET_CONTROL,fName_label,GET_VALUE=file

  allFiles = str_sep(file,' ')

  for i = 0, n_elements(allFiles)-1 do begin
    files->add,allFiles[i]
  endfor

  values = toStringArray(files)

  WIDGET_CONTROL,list,SET_VALUE=values
  WIDGET_CONTROL,fName_label,SET_VALUE=''
end

pro EV_FITLIST,event
   COMMON fit_vars

   listIndex = event.index
end

pro EV_REM,event
   COMMON fit_vars

   files->delete,listIndex

   if(files->size() ne 0) then begin
     values = toStringArray(files)
     WIDGET_CONTROL,list,SET_VALUE=values
   endif else begin
     WIDGET_CONTROL,list,SET_VALUE=''
   endelse
end

PRO EV_FILE_BROWSE, event
    COMMON fit_vars
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

function genCommands, flist,zeroFill,weight,variable,parameters,arguments,covariance,output,elements
   COMMON fit_vars
   COMMON common_vars

   HELP,zeroFill

   outFiles = genOutputFileNames(flist)
   fNames   = toStringArray(flist)

   cmds = STRARR(n_elements(fNames))

   if(n_elements(outFiles) eq 1) then begin
      outFiles[0] = output
   endif

   pwd = ''
   spawn,'pwd',pwd

   ;print,pwd+'/bin/ultra_fitman'

   for i = 0, n_elements(outFiles)-1 do begin
        cmds[i] = pwd+'/bin/ultra_fitman '+fNames[i] +' '+$
         middle_plot_info.guess_file+' '+middle_plot_info.const_file
    cmds[i] = cmds[i] + ' '+outFiles[i]
    IF (zeroFill GT 0) THEN cmds[i] = cmds[i] + ' -z '+STRCOMPRESS(STRING(zeroFill),/REMOVE_ALL)
    IF (weight NE '') THEN cmds[i] = cmds[i] + ' -ew '+weight
    IF (variable NE '') THEN cmds[i] = cmds[i] + ' -vf '+variable
    IF (parameters NE '') THEN BEGIN
       cmds[i] = cmds[i] + ' -fp '+parameters
    ENDIF
        IF (arguments NE '') THEN cmds[i] = cmds[i] + ' '+ arguments

    ;IF (middle_plot_info.domain EQ 0) THEN cmds[i] = cmds[i] + " -ti "
    ;IF (middle_plot_info.domain EQ 1) THEN cmds[i] = cmds[i]+ " -fr "
    IF (covariance NE '') THEN cmds[i] = cmds[i] + ' -c '+ covariance

    for j = 0, n_elements(elements)-1 do begin
      IF (elements[j] NE '') THEN cmds[i] = cmds[i] + ' -v '+elements[j]
    endfor

   endfor

   return, cmds
end

;=======================================================================================================;
; Name: EV_VAR_CANCEL                                                                                   ;
; Purpose:  Called if the user selects "Cancel" in the window where they are entering variables for the ;
;       fitman program. It will simply destroy the top widget.              ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_VAR_CANCEL, event
    COMMON common_widgets

    WIDGET_CONTROL, event.top, /DESTROY
    WIDGET_CONTROL, main1, SENSITIVE=1
END

;=======================================================================================================;
; Name: EV_VAR_OK                          ;
; Purpose: Called if the user selects "Ok" in the window where they are entering variables for the  ;
;      fitman program.   It will check to see which variables are no longer default and will add  ;
;      them to the command line that will spawn.                                   ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_VAR_OK, event
    COMMON fit_vars
    COMMON common_widgets
    COMMON common_vars
    COMMON draw1_comm

        elements = STRARR(10)

    WIDGET_CONTROL, Fill_field, GET_VALUE = zeroFill
    WIDGET_CONTROL, Weighing_field, GET_VALUE = wieght
    WIDGET_CONTROL, Variable_field, GET_VALUE = variable
    WIDGET_CONTROL, prms_field, GET_VALUE = parameters
    WIDGET_CONTROL, args_field, GET_VALUE = arguments
    WIDGET_CONTROL, Covariance_field, GET_VALUE = covariance
    WIDGET_CONTROL, Output_field, GET_VALUE = output
    WIDGET_CONTROL, list_element1, GET_VALUE = element1
    WIDGET_CONTROL, list_element2, GET_VALUE = element2
    WIDGET_CONTROL, list_element3, GET_VALUE = element3
    WIDGET_CONTROL, list_element4, GET_VALUE = element4
    WIDGET_CONTROL, list_element5, GET_VALUE = element5
    WIDGET_CONTROL, list_element6, GET_VALUE = element6


;****Remove four lines below
    ;WIDGET_CONTROL, list_element7, GET_VALUE = element7
    ;WIDGET_CONTROL, list_element8, GET_VALUE = element8
    ;WIDGET_CONTROL, list_element9, GET_VALUE = element9
    ;WIDGET_CONTROL, list_element10, GET_VALUE = element10
;****END ADDITION


    zeroFill = fix(zeroFill[0])
    wieght = fix(wieght[0])
    variable = STRING (variable[0])
    parameters = STRING (parameters[0])
    arguments = STRING(arguments[0])
    covariance = STRING(covariance[0])
    output = STRING(output[0])
    elements[0] = STRING(element1[0])
    elements[1] = STRING(element2[0])
    elements[2] = STRING(element3[0])
    elements[3] = STRING(element4[0])
    elements[4] = STRING(element5[0])
    elements[5] = STRING(element6[0])


;*****Remove four lines below
    ;elements[6] = STRING(element7[0])
    ;elements[7] = STRING(element8[0])
    ;elements[8] = STRING(element9[0])
    ;elements[9] = STRING(element10[0])
;*****END ADDITION



        WIDGET_CONTROL,/HOURGLASS
    ; Check to see that the variables have changed.  If they have, add the appropriate things to the
    ; command to spawn.
    IF ((middle_plot_info.data_file EQ '') OR (middle_plot_info.const_file EQ '') OR $
    (middle_plot_info.guess_file EQ '')) THEN BEGIN
        ;WIDGET_CONTROL, event.top, /DESTROY
        ;ERROR_MESSAGE, $
        ;'Missing needed data.   Make sure data, constants, and guess file are all loaded.'
    err_result = DIALOG_MESSAGE('Missing needed data.   Make sure data, constants, and guess file are all loaded.', $
                 Title = 'ERROR', /ERROR)
    ENDIF else begin
       commands = genCommands(files,zeroFill,wieght,variable,parameters,$
                           arguments,covariance,output,elements)

      for i = 0, n_elements(commands)-1 do begin
         spawn,commands[i]
             print, 'Fitman spawn commands: ', commands[i]
      endfor

    endelse

    WIDGET_CONTROL, event.top, /DESTROY

        noResize=1
    REDISPLAY
        noResize=0

    WIDGET_CONTROL, main1, SENSITIVE=1
END

;=======================================================================================================;
; Name:  EV_CONVERT
; Purpose:  To allow the user to convert raw data that has come out of the scanner to a usable format
;       that can be used for this program and various other programs.   This particular procedure
;       will set up the window and all the possible options and give control to the event handler.
; Parameters:  event - the event which called this procedure.
; Return:  None.
;=======================================================================================================;
PRO EV_CONVERT, event
    COMMON common_widgets
    COMMON common_vars

    ;WIDGET_CONTROL, main1, SENSITIVE=0

     WIDGET_CONTROL, event.id, GET_UVALUE=widg_uval

    ;This part is used for "Import file"
    IF (widg_uval EQ "SUPP" OR widg_uval EQ "UNSUPP") THEN BEGIN
    import_file_type = widg_uval
    ENDIF


    ;Main base window
    convert_main_base = WIDGET_BASE(ROW=4, MAP=1, TITLE='Convert Raw Data',UVALUE='CONVERT')

    ;Sub bases of main
    in_base = WIDGET_BASE(convert_main_base, ROW=6, MAP=1, UVALUE='IN_BASE')
    empty_subbase1 = WIDGET_BASE(convert_main_base, ROW=1, MAP=1, UVALUE='EMPTY_SUBBASE1')
    ref_base = WIDGET_BASE(convert_main_base, ROW=2, UVALUE='REF_BASE', /FRAME)


    ;Sub bases for ref_base
    mode_base = WIDGET_BASE(ref_base, COL=4, MAP=1, UVALUE='MODE', /EXCLUSIVE, /FRAME)
       ;Empty base and label for padding
    refbase_empty_pad1 = WIDGET_LABEL(ref_base, VALUE='          ')
    ir_base = WIDGET_BASE(ref_base, /row, MAP=1, UVALUE='IR', /FRAME)
    ref_subbase = WIDGET_BASE(ref_base, ROW=6, UVALUE='REF_SUBBASE', /FRAME)
       ;Empty base and label for padding
    refbase_empty_pad2 = WIDGET_LABEL(ref_base, VALUE='')

    ;------------ Part of in_base ---------------------------------------------------------------;
    ;Input file type buttons
    convert_choice_base = WIDGET_BASE(in_base, /FRAME, /ROW)
    convert_choice_label = WIDGET_LABEL(convert_choice_base, VALUE = 'INPUT FILE TYPE: ')
    convert_choice_buttonbase = WIDGET_BASE(convert_choice_base, /ROW, /EXCLUSIVE)
    convert_choice_GE = WIDGET_BUTTON(convert_choice_buttonbase, VALUE='GE', EVENT_PRO='EV_CONV_GE')
    convert_choice_SIEMENS = WIDGET_BUTTON(convert_choice_buttonbase, VALUE='SIEMENS', EVENT_PRO='EV_CONV_SIEMENS')
    convert_choice_VARIAN = WIDGET_BUTTON(convert_choice_buttonbase, VALUE='VARIAN', EVENT_PRO='EV_CONV_VARIAN')
    WIDGET_CONTROL, convert_choice_GE, TOOLTIP="GE Signa 8.x/9.x/11.x"
    WIDGET_CONTROL, convert_choice_SIEMENS, TOOLTIP="SIEMENS 9.5T"
    WIDGET_CONTROL, convert_choice_VARIAN, TOOLTIP="VARIAN 4T"

    ;VERBOSE button
    verb_base = WIDGET_BASE(in_base, MAP=1, UVALUE='VERB', /FRAME,  /NONEXCLUSIVE)
    verb_button = WIDGET_BUTTON(verb_base, VALUE='Verbose', EVENT_PRO='EV_CONV_VERB',  /ALIGN_RIGHT)
    WIDGET_CONTROL, verb_button, TOOLTIP="Verbose conversion process in console window"

    ;OVERWRITE button
    ow_base =WIDGET_BASE(in_base, COL=2, MAP=1, UVALUE='OW', /FRAME, /NONEXCLUSIVE)
    ow_button = WIDGET_BUTTON(ow_base, VALUE='Overwrite', EVENT_PRO='EV_CONV_OW')
    WIDGET_CONTROL, ow_button, TOOLTIP="Overwrite both output files"

    ;Empty base and label for padding
    inbase_empty_pad0 = WIDGET_LABEL(in_base, VALUE='')

    ;INPUT FILE selector
    infile_label = CW_FIELD(in_base, TITLE='Input Filename:   ', Value= '', /STRING, /ALL_EVENTS, XSIZE = 40)
    infile_browse = WIDGET_BUTTON(in_base, VALUE = 'Browse', EVENT_PRO = 'EV_INPUT_BROWSE')

    ;Empty base and label for padding
    inbase_empty_pad1 = WIDGET_LABEL(in_base, VALUE='')
    inbase_empty_pad2 = WIDGET_LABEL(in_base, VALUE='')

    ;OUTPUT FILE selector
    outfile_label = CW_FIELD(in_base, TITLE='Output Filename: ', VALUE='', /STRING, XSIZE = 40)
    output_browse = WIDGET_BUTTON(in_base, Value = 'Browse', EVENT_PRO = 'EV_OUTPUT_BROWSE')

    ;Empty base and label for padding
    inbase_empty_pad3 = WIDGET_LABEL(in_base, VALUE= '')

    ;Input file SCALE button set
    scale_label = CW_FIELD(in_base, TITLE="         Scale Factor:", VALUE=0.0, /FLOAT, /ALL_EVENTS)

    ;Input file BYTE SWAP button set
    bswap_base = WIDGET_BASE(in_base, /ROW, /FRAME)
    bswap_label = WIDGET_LABEL(bswap_base, VALUE = 'Input file byte swap: ')
    bswap_buttonbase = WIDGET_BASE(bswap_base, /ROW, /EXCLUSIVE)
    bswap_button = WIDGET_BUTTON(bswap_buttonbase, VALUE='Yes', EVENT_PRO='EV_CONV_BSW')
    no_bswap_button = WIDGET_BUTTON(bswap_buttonbase, VALUE='No', EVENT_PRO='EV_CONV_NBSW')
    auto_bswap_button = WIDGET_BUTTON(bswap_buttonbase, VALUE='Detect', EVENT_PRO='EV_CONV_BSW_AUTO')
    WIDGET_CONTROL, bswap_button, TOOLTIP="Forced byte swap"
    WIDGET_CONTROL, no_bswap_button, TOOLTIP="Forced NO byte swap"
    WIDGET_CONTROL, auto_bswap_button, TOOLTIP="Automatic byte swap detection"

    scale_note = WIDGET_LABEL(in_base, VALUE='         (Scale: -1 for none, 0 for auto)')

    ;Empty base and label for padding
    inbase_empty_pad5 = WIDGET_LABEL(in_base, VALUE='')

    ;Input file BASE LINE button set
    baseline_base = WIDGET_BASE(in_base, /ROW, /FRAME)
    baseline_label = WIDGET_LABEL(baseline_base, VALUE = 'Baseline correction : ')
    baseline_buttonbase = WIDGET_BASE(baseline_base, COL=2, MAP=1, UVALUE='BL', /EXCLUSIVE)
    baseline_yes_button = WIDGET_BUTTON(baseline_buttonbase, Value="Yes", EVENT_PRO='EV_CONV_YES' )
    baseline_no_button = WIDGET_BUTTON(baseline_buttonbase, VALUE="No", $
       EVENT_PRO='EV_CONV_NO')
    baseline_empty_pad1 = WIDGET_LABEL(baseline_base, VALUE='         ')

    ;Empty base and label for padding
    inbase_empty_pad6 = WIDGET_LABEL(in_base, VALUE='')
    inbase_empty_pad7 = WIDGET_LABEL(in_base, VALUE='')

    ;Input file AUTO FILTER button
    if_buttonbase =WIDGET_BASE(in_base, COL=1, MAP=1, /NONEXCLUSIVE, /FRAME)
    if_button = WIDGET_BUTTON(if_buttonbase, VALUE='Auto Filter', EVENT_PRO='EV_CONV_IF')
    WIDGET_CONTROL, if_button, TOOLTIP="Input file automatic exponential filter"

    ;Empty base and label for padding
    inbase_empty_pad8 = WIDGET_LABEL(in_base, VALUE='')

    ;Input file ZERO FILL button
    zf_label = CW_FIELD(in_base, TITLE='                         Zero Fill (Leave 0 for none):', VALUE=0, /INTEGER)


    ;------------ Part of empty_subbase1 ---------------------------------------------------------------;

    empty_subbase1_empty_pad4 = WIDGET_LABEL(empty_subbase1, VALUE=' ')


    ;------------ Part of ref_base ---------------------------------------------------------------;

    ;ECC, QUALITY & QUECC buttons
    ecc_button = WIDGET_BUTTON(mode_base, VALUE='ECC', EVENT_PRO='EV_CONV_ECC')
    quality_button = WIDGET_BUTTON(mode_base, VALUE='QUALITY', EVENT_PRO='EV_CONV_QUAL')
    quecc_button = WIDGET_BUTTON(mode_base, VALUE='QUECC', EVENT_PRO='EV_CONV_QUECC')
    no_quecc_button = WIDGET_BUTTON(mode_base, VALUE='NONE', EVENT_PRO='EV_CONV_NOQUECC')
    WIDGET_CONTROL, ecc_button, TOOLTIP="Eddy current correction"
    WIDGET_CONTROL, quality_button, TOOLTIP="Quality deconvolution"
    WIDGET_CONTROL, quecc_button, TOOLTIP="Combined ECC/QUALITY"
    WIDGET_CONTROL, no_quecc_button, TOOLTIP="No ECC/QUALITY/QUECC applied"


    ;IR, IRN buttons
    ir_label = WIDGET_LABEL(ir_base, VALUE = 'IR: ')
    ir_buttonbase = WIDGET_BASE(ir_base, /ROW, /NONEXCLUSIVE)
    ir_button = WIDGET_BUTTON(ir_buttonbase, VALUE='Options INcluded', EVENT_PRO='EV_CONV_IR')
    irn_button = WIDGET_BUTTON(ir_buttonbase, VALUE='Options EXcluded', EVENT_PRO='EV_CONV_IRN')
    WIDGET_CONTROL, ir_button, TOOLTIP="Identical reference file with input file, options INcluded"
    WIDGET_CONTROL, irn_button, TOOLTIP="Identical reference file with input file, options EXcluded"

    ;------------ Part of ref_subbase ---------------------------------------------------------------;

    ;REF FILE selector
    reference_label = CW_FIELD(ref_subbase, TITLE='Reference File: ',VALUE='', XSIZE = 40, /STRING)
    ref_browse = WIDGET_BUTTON(ref_subbase, VALUE='Browse', EVENT_PRO='EV_REF_BROWSE')

    ;Ref file SCALE button set
    rscale_label = CW_FIELD(ref_subbase, TITLE="          Scale Factor:", VALUE=0.0, /FLOAT)

    ;Input file BYTE SWAP button set
    rbswap_base = WIDGET_BASE(ref_subbase, /FRAME, /ROW)
    rbswap_label = WIDGET_LABEL(rbswap_base, VALUE = 'Reference file byte swap: ')
    rbswap_buttonbase = WIDGET_BASE(rbswap_base, /ROW, /EXCLUSIVE)
    rbswap_button = WIDGET_BUTTON(rbswap_buttonbase, VALUE='Yes', EVENT_PRO='EV_CONV_RBSW')
    rno_bswap_button = WIDGET_BUTTON(rbswap_buttonbase, VALUE='No', EVENT_PRO='EV_CONV_RNBSW')
    rauto_bswap_button = WIDGET_BUTTON(rbswap_buttonbase, VALUE='Detect', EVENT_PRO='EV_CONV_RBSW_AUTO')
    WIDGET_CONTROL, rbswap_button, TOOLTIP="Forced byte swap"
    WIDGET_CONTROL, rno_bswap_button, TOOLTIP="Forced NO byte swap"
    WIDGET_CONTROL, rauto_bswap_button, TOOLTIP="Automatic byte swap detection"

    rscale_note = WIDGET_LABEL(ref_subbase, VALUE='    (Scale: -1 for none, 0 for auto)')

    ;Empty base and label for padding
    refSubbase_empty_pad3 = WIDGET_LABEL(ref_subbase, VALUE='')

    ;Ref file BASE LINE button set
    rbaseline_base = WIDGET_BASE(ref_subbase, /ROW, /FRAME)
    rbaseline_label = WIDGET_LABEL(rbaseline_base, VALUE = 'Baseline correction     : ')
    rbaseline_buttonbase = WIDGET_BASE(rbaseline_base, COL=2, MAP=1, UVALUE='RBL', /EXCLUSIVE)
    rbaseline_yes_button = WIDGET_BUTTON(rbaseline_buttonbase, Value="Yes", EVENT_PRO='EV_CONV_YES2' )
    rbaseline_no_button = WIDGET_BUTTON(rbaseline_buttonbase, VALUE="No", $
       EVENT_PRO='EV_CONV_NO2')
    rbaseline_empty_pad1 = WIDGET_LABEL(rbaseline_base, VALUE='         ')

    ;Empty base and label for padding
    refSubbase_empty_pad4 = WIDGET_LABEL(ref_subbase, VALUE='')
    refSubbase_empty_pad5 = WIDGET_LABEL(ref_subbase, VALUE='')

    ;Ref file AUTO FILTER button
    rif_buttonbase = WIDGET_BASE(ref_subbase, COL=1, MAP=1, UVALUE='if', /FRAME, /NONEXCLUSIVE)
    rif_button = WIDGET_BUTTON(rif_buttonbase, VALUE = 'Auto Filter', EVENT_PRO='EV_CONV_RIF')
    WIDGET_CONTROL, if_button, TOOLTIP="Reference file automatic exponential filter"

    ;NORMALIZE button
    norm_base = WIDGET_BASE(ref_subbase, COL=1, MAP=1, UVALUE='nb', /frame, /NONEXCLUSIVE)
    norm_button = WIDGET_BUTTON(norm_base, VALUE='Normalize', EVENT_PRO='EV_CONV_NORM')
    WIDGET_CONTROL, norm_button, TOOLTIP="Normalize amplitude of first time domain point to 1"

    ;Ref file ZERO FILL button
    zf2_label = CW_FIELD(ref_subbase, TITLE='          Zero Fill (leave 0 for none):', VALUE=0, /INTEGER)


    ;Empty base and label for padding
    refSubbase_empty_pad6 = WIDGET_LABEL(ref_subbase, VALUE='')
    refSubbase_empty_pad7 = WIDGET_LABEL(ref_subbase, VALUE='')

    ;FILTER button
    options4_base = WIDGET_BASE(ref_subbase, col=2, UVALUE='option4')
    f_label = CW_FIELD(options4_base, $
                 TITLE='                                           Filter(Leave 0 for none):', $
           VALUE=0.0, /FLOAT)

    ;Empty base and label for padding
    refSubbase_empty_pad8 = WIDGET_LABEL(ref_subbase, VALUE='')

    ;TIME DELAY & QUALITY buttons
    options5_base =WIDGET_BASE(ref_subbase, col=2, UVALUE='option5')
    delay_label = CW_FIELD(options5_base, TITLE='Time Delay (ms):', VALUE=500.0, /FLOAT)
    pts_label = CW_FIELD(options5_base, TITLE='QUALITY: Points (Real+Imag):', VALUE=400, /INTEGER)

    ;OK & CANCEL buttons
        ok_base = WIDGET_BASE(convert_main_base,COL=2, MAP=1, UVALUE='ok_base', /BASE_ALIGN_RIGHT)
    Ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok', EVENT_PRO = 'EV_CONV_OK')
    Cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_CONV_CANCEL')

    file_type = 0       ;0=GE, 1=SIEMENS, 2=VARIAN
    option_status = 3   ;0=none, 1=ecc, 2=quality, 3=quecc
    baseln1 = 0
    baseln2 = 0
    norm = 1
    in_if = 1
    ref_if =1
    verbose = 1
    overwrite = 1
    byteswap = 2      ;Input file byte swap: 0=byte swap, 1=no byteswap, 2 = auto byte swap
    rbyteswap = 2       ;Ref   file byte swap: 0=byte swap, 1=no byteswap, 2 = auto byte swap
    ir = 1          ;ir: 0=no ir or irn, 1 ir, 2 irn
    ir_remember = ir     ;to conserve ir state

    structure = {  convert_main_base:convert_main_base, $
         option_status:option_status, $
         ecc_button:ecc_button, $
         quality_button:quality_button, $
         quecc_button:quecc_button, $
         no_quecc_button:no_quecc_button, $
             baseln1:baseln1, $
         baseln2:baseln2, $
         baseline_yes_button:baseline_yes_button, $
         rbaseline_yes_button:rbaseline_yes_button, $
         baseline_no_button:baseline_no_button, $
         rbaseline_no_button:rbaseline_no_button, $
         in_if:in_if, $
         norm:norm, $
         ref_if:ref_if, $
         infile_label: infile_label, $
         outfile_label:outfile_label, $
         zf_label:zf_label, $
         pts_label:pts_label, $
         delay_label:delay_label, $
         f_label:f_label, $
         if_button:if_button, $
         rif_button:rif_button, $
         norm_button:norm_button, $
         reference_label:reference_label, $
         scale_label:scale_label, $
         rscale_label:rscale_label, $
         zf2_label:zf2_label, $
         ref_subbase:ref_subbase, $
         convert_choice_GE:convert_choice_GE, $
         convert_choice_SIEMENS:convert_choice_SIEMENS, $
         convert_choice_VARIAN:convert_choice_VARIAN, $
         file_type:file_type, $
         ow_button:ow_button, $
         verb_button:verb_button, $
         verbose:verbose, $
         overwrite:overwrite, $
         bswap_button:bswap_button, $
         byteswap:byteswap, $
         no_bswap_button:no_bswap_button, $
         auto_bswap_button:auto_bswap_button, $
         rbswap_button:rbswap_button, $
         rbyteswap:rbyteswap, $
         rno_bswap_button:rno_bswap_button, $
         rauto_bswap_button:rauto_bswap_button, $
         ir_button:ir_button, $
         irn_button:irn_button, $
         ir_base:ir_base, $
         ir:ir, $
         ir_remember:ir_remember }

    struct_ptr = ptr_new(structure, /NO_COPY)
    WIDGET_CONTROL, convert_main_base, SET_UVALUE=struct_ptr

    WIDGET_CONTROL, convert_main_base, /REALIZE

    ;Initial state/settings of convert menu buttons.
    ;It starts in GE mode
    ;-----------------------------------------------
    WIDGET_CONTROL, convert_choice_GE, SET_BUTTON=1
    WIDGET_CONTROL, baseline_no_button, /SET_BUTTON
    WIDGET_CONTROL, quecc_button, /SET_BUTTON
    WIDGET_CONTROL, rbaseline_no_button, /SET_BUTTON
    WIDGET_CONTROL, ow_button, /SET_BUTTON
    WIDGET_CONTROL, auto_bswap_button, /SET_BUTTON
    WIDGET_CONTROL, rauto_bswap_button, /SET_BUTTON
    WIDGET_CONTROL, norm_button, /SET_BUTTON
    WIDGET_CONTROL, if_button, /SET_BUTTON
    WIDGET_CONTROL, rif_button, /SET_BUTTON
    WIDGET_CONTROL, ir_button, /SET_BUTTON
    WIDGET_CONTROL, verb_button, /SET_BUTTON

    ;This because GE filetype is set originally.
    WIDGET_CONTROL, zf_label, SENSITIVE=0
    WIDGET_CONTROL, zf2_label, SENSITIVE=0


    ; the new default conversion button is VARIAN, not GE
    ;WIDGET_CONTROL, convert_choice_VARIAN, SET_BUTTON=1
    ;CONV_VARIAN, struct_ptr

    ;------------------------------------------------
    ;End button intitiation.

    XMANAGER, 'convert', convert_main_base

END

;--------------------------------------------------------------------------------;
;This event is generated by 'cw_filed' '/ALL_EVENT'
;It is used to automatically copy the filename if needed
;as well as the scale factor
PRO CONVERT_EVENT, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr


    IF ((*struct_ptr).ir GT 0) THEN BEGIN
        IF ( (*struct_ptr).file_type EQ 0 ) THEN BEGIN
           ;Actually do this for GE only.  Siemens (and Varian) use separate files for reference.
            WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
            WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
        ENDIF
    ENDIF
    IF ((*struct_ptr).ir EQ 1) THEN BEGIN
       WIDGET_CONTROL ,(*struct_ptr).scale_label,  GET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = label
    ENDIF
END


;--------------------------------------------------------------------------------;
PRO EV_INPUT_BROWSE, event
    COMMON common_vars
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr

    ; modify the input dialog for VARIAN only (set in EV_CONV_VARIAN procedure )
    IF ( (*struct_ptr).file_type EQ 2 ) THEN BEGIN
       file = DIALOG_PICKFILE(/READ, /DIRECTORY, FILTER = '*.fid', PATH=string(defaultpath))
    ENDIF ELSE BEGIN
       file = DIALOG_PICKFILE(/READ, PATH=string(defaultpath))
    ENDELSE

    ;Getting rid of last character if it is "/" or "\"
    last_char = strmid(file,strlen(file)-1, 1)

    IF(last_char EQ "\" OR last_char EQ "/") THEN BEGIN
       file = strmid(file,0,strlen(file)-1)
    END

    WIDGET_CONTROL, (*struct_ptr).infile_label, SET_VALUE=file

    IF ((*struct_ptr).ir GT 0) THEN BEGIN
       ; If IR or IRN is set, referrence file is automatically set to input file,
       ; overwriting old setting if necessary.  This does not apply to VARIAN.
       ; IR is set to 0 when switching to VARIAN, hence no need for filetype checking.
       ; Once exitted from VARIAN mode, ir is reset to previous setting....(ir_remember)

       IF ( (*struct_ptr).file_type EQ 0 ) THEN BEGIN
           ;Actually do this for GE only.  Siemens (and Varian) use separate files for reference.
            WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
            WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
        ENDIF
    ENDIF


END


;--------------------------------------------------------------------------------;
PRO EV_OUTPUT_BROWSE, event
    COMMON common_vars
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr

    file = DIALOG_PICKFILE(/WRITE, FILTER = '*.*', PATH=string(defaultpath) )



    WIDGET_CONTROL, (*struct_ptr).outfile_label, SET_VALUE=file
END


;--------------------------------------------------------------------------------;
PRO EV_REF_BROWSE, event
    COMMON common_vars
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr

    ;  only use *.FID for the VARIAN file type
    IF ( (*struct_ptr).file_type EQ 2 ) THEN BEGIN
       file = DIALOG_PICKFILE(/READ, /DIRECTORY, FILTER = '*.fid', PATH=string(defaultpath))
    ENDIF ELSE BEGIN
       file = DIALOG_PICKFILE(/READ, PATH=string(defaultpath))
    ENDELSE

    ;Getting rid of last character if it is "/" or "\"
    last_char = strmid(file,strlen(file)-1, 1)

    IF(last_char EQ "\" OR last_char EQ "/") THEN BEGIN
       file = strmid(file,0,strlen(file)-1)
    END


    WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE=file
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_NORM, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    IF (WIDGET_INFO(EVENT.ID, /BUTTON_SET) EQ 1) THEN BEGIN
       (*struct_ptr).norm = 1
    ENDIF ELSE BEGIN
       (*struct_ptr).norm = 0
    ENDELSE
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_IF, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    IF (WIDGET_INFO(EVENT.ID, /BUTTON_SET) EQ 1) THEN BEGIN
       (*struct_ptr).in_if=1
    ENDIF ELSE BEGIN
       (*struct_ptr).in_if=0
    ENDELSE
    IF ((*struct_ptr).ir EQ 1) THEN BEGIN
       WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=(*struct_ptr).in_if
       (*struct_ptr).ref_if = (*struct_ptr).in_if
    ENDIF
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_OW, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    IF (WIDGET_INFO(EVENT.ID, /BUTTON_SET) EQ 1) THEN BEGIN
       (*struct_ptr).overwrite = 1
    ENDIF ELSE BEGIN
       (*struct_ptr).overwrite = 0
    ENDELSE
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_VERB, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    IF (WIDGET_INFO(EVENT.ID, /BUTTON_SET) EQ 1) THEN BEGIN
       (*struct_ptr).verbose = 1
    ENDIF ELSE BEGIN
       (*struct_ptr).verbose = 0
    ENDELSE
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_RIF, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    IF (WIDGET_INFO(EVENT.ID, /BUTTON_SET) EQ 1) THEN BEGIN
       (*struct_ptr).ref_if = 1
    ENDIF ELSE BEGIN
       (*struct_ptr).ref_if = 0
    ENDELSE
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_BSW, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    (*struct_ptr).byteswap = 0
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_NBSW, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    (*struct_ptr).byteswap = 1
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_BSW_AUTO, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    (*struct_ptr).byteswap = 2
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_RBSW, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    (*struct_ptr).rbyteswap = 0
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_RNBSW, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    (*struct_ptr).rbyteswap = 1
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_RBSW_AUTO, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    (*struct_ptr).rbyteswap = 2
END

;--------------------------------------------------------------------------------;
PRO EV_CONV_IR, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    IF (WIDGET_INFO(EVENT.ID, /BUTTON_SET) EQ 1) THEN BEGIN
         ;Copying reference file name
       WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
         ;Copying reference scale factor
       WIDGET_CONTROL ,(*struct_ptr).scale_label,  GET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = label
         ;Copying reference Auto filter state
       WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=(*struct_ptr).in_if
       (*struct_ptr).ref_if = (*struct_ptr).in_if
         ;Copying reference Baseline correction state
       WIDGET_CONTROL, (*struct_ptr).rbaseline_yes_button,  SET_BUTTON = (*struct_ptr).baseln1
       IF ((*struct_ptr).baseln1 EQ 0) THEN BEGIN
         WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  SET_BUTTON = 1
       ENDIF
       (*struct_ptr).baseln2 = (*struct_ptr).baseln1


         ;Setting IRN to "UNSET"
       WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
       (*struct_ptr).ir=1
       (*struct_ptr).ir_remember=(*struct_ptr).ir
    ENDIF ELSE BEGIN
       WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = ''
       WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = ''
       (*struct_ptr).ir=0
       (*struct_ptr).ir_remember=(*struct_ptr).ir
    ENDELSE

END


;--------------------------------------------------------------------------------;
PRO EV_CONV_IRN, event
    WIDGET_CONTROL, event.top, GET_UVALUE = struct_ptr
    IF (WIDGET_INFO(EVENT.ID, /BUTTON_SET) EQ 1) THEN BEGIN
         ;Copying reference file name
       WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
         ;Resting reference scale factor
       WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = '-1'
         ;Setting reference Auto filter state
       WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=0
       (*struct_ptr).ref_if = 0
         ;Setting reference Baseline correction state
       WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  SET_BUTTON = 1
       (*struct_ptr).baseln2 = 0


         ;Setting IR to "UNSET"
       WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
       (*struct_ptr).ir=2
       (*struct_ptr).ir_remember=(*struct_ptr).ir
    ENDIF ELSE BEGIN
       WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = ''
       (*struct_ptr).ir=0
       (*struct_ptr).ir_remember=(*struct_ptr).ir
    ENDELSE

END


;=======================================================================================================
; Name: EV_CONV_GE, EV_CONV_SIEMENS, EV_CONV_VARIAN
; Purpose:  To set the appropriate flag for the type of file that is being comnverted.
; Parameters:  event - The event which caused this procedure to be called.
; Return:   None.
;=======================================================================================================
PRO EV_CONV_GE, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    button_value=WIDGET_INFO((*struct_ptr).convert_choice_GE, /BUTTON_SET)


     IF (button_value EQ 1) THEN BEGIN
    (*struct_ptr).file_type = 0


    WIDGET_CONTROL, (*struct_ptr).bswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).no_bswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).rbswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).rno_bswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).verb_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).verb_button, SET_BUTTON=(*struct_ptr).verbose
    WIDGET_CONTROL, (*struct_ptr).ow_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).ow_button, SET_BUTTON=(*struct_ptr).overwrite
    WIDGET_CONTROL, (*struct_ptr).zf_label, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).zf2_label, SENSITIVE=0
    IF ((*struct_ptr).option_status GT 0) THEN BEGIN
       WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=1
       CASE (*struct_ptr).ir_remember OF
         0: BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
            END
         1:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=1
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
            END
         2:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=1
           END
       ENDCASE
       (*struct_ptr).ir = (*struct_ptr).ir_remember
    ENDIF
    IF ((*struct_ptr).ir GT 0) THEN BEGIN
       WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
    ENDIF
    IF ((*struct_ptr).ir EQ 1) THEN BEGIN
       WIDGET_CONTROL ,(*struct_ptr).scale_label,  GET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=(*struct_ptr).in_if
       (*struct_ptr).ref_if = (*struct_ptr).in_if
       WIDGET_CONTROL, (*struct_ptr).rbaseline_yes_button,  SET_BUTTON = (*struct_ptr).baseln1
       IF ((*struct_ptr).baseln1 EQ 0) THEN BEGIN
         WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  SET_BUTTON = 1
       ENDIF
       (*struct_ptr).baseln2 = (*struct_ptr).baseln1
    ENDIF
     ENDIF

END

;--------------------------------------------------------------------------------;
PRO EV_CONV_SIEMENS, event

    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    button_value=WIDGET_INFO((*struct_ptr).convert_choice_SIEMENS, /BUTTON_SET)

     IF (button_value EQ 1) THEN BEGIN

    (*struct_ptr).file_type = 1

    WIDGET_CONTROL, (*struct_ptr).bswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).no_bswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).rbswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).rno_bswap_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).verb_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).verb_button, SET_BUTTON=(*struct_ptr).verbose
    WIDGET_CONTROL, (*struct_ptr).ow_button, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).ow_button, SET_BUTTON=(*struct_ptr).overwrite
    WIDGET_CONTROL, (*struct_ptr).zf_label, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).zf2_label, SENSITIVE=0
    IF ((*struct_ptr).option_status GT 0) THEN BEGIN
       WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=1
       CASE (*struct_ptr).ir_remember OF
         0: BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
            END
         1:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=1
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
            END
         2:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=1
           END
       ENDCASE
       (*struct_ptr).ir = (*struct_ptr).ir_remember
    ENDIF
    IF ((*struct_ptr).ir GT 0) THEN BEGIN
       WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
       ;This is temporarely disabled until a finalized Siemens file format is availbale.
       ;At this point it is not known if in and ref files can be part of one file.
       ;WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
    ENDIF
    ;Disable the next line if the above WIDGET_CONTRO is changed.
    
    WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = ''
    
    IF ((*struct_ptr).ir EQ 1) THEN BEGIN
       WIDGET_CONTROL ,(*struct_ptr).scale_label,  GET_VALUE = label
       
       WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = label
       WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=(*struct_ptr).in_if
       (*struct_ptr).ref_if = (*struct_ptr).in_if
       WIDGET_CONTROL, (*struct_ptr).rbaseline_yes_button,  SET_BUTTON = (*struct_ptr).baseln1
       IF ((*struct_ptr).baseln1 EQ 0) THEN BEGIN
         WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  SET_BUTTON = 1
       ENDIF
       (*struct_ptr).baseln2 = (*struct_ptr).baseln1
    ENDIF
     ENDIF

END

;--------------------------------------------------------------------------------;
; procedure used to setup the button configuration on the CONVERT DATA dialog to VARIAN format
PRO CONV_VARIAN, struct_ptr
    t= WIDGET_INFO((*struct_ptr).verb_button, /BUTTON_SET)

    (*struct_ptr).file_type = 2
    WIDGET_CONTROL, (*struct_ptr).auto_bswap_button, SET_BUTTON=1
    WIDGET_CONTROL, (*struct_ptr).bswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).no_bswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).rauto_bswap_button, SET_BUTTON=1
    WIDGET_CONTROL, (*struct_ptr).rbswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).rno_bswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).verb_button, SET_BUTTON=0
    WIDGET_CONTROL, (*struct_ptr).verb_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).ow_button, SET_BUTTON=0
    WIDGET_CONTROL, (*struct_ptr).ow_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).zf_label, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).zf2_label, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
    WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
        (*struct_ptr).ir_remember = (*struct_ptr).ir
    (*struct_ptr).ir=0
    WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = ''
    WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = ''

END


;--------------------------------------------------------------------------------;
PRO EV_CONV_VARIAN, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    button_value=WIDGET_INFO((*struct_ptr).convert_choice_VARIAN, /BUTTON_SET)

     IF (button_value EQ 1) THEN BEGIN

    t= WIDGET_INFO((*struct_ptr).verb_button, /BUTTON_SET)

    (*struct_ptr).file_type = 2
    WIDGET_CONTROL, (*struct_ptr).auto_bswap_button, SET_BUTTON=1
    WIDGET_CONTROL, (*struct_ptr).bswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).no_bswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).rauto_bswap_button, SET_BUTTON=1
    WIDGET_CONTROL, (*struct_ptr).rbswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).rno_bswap_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).verb_button, SET_BUTTON=0
    WIDGET_CONTROL, (*struct_ptr).verb_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).ow_button, SET_BUTTON=0
    WIDGET_CONTROL, (*struct_ptr).ow_button, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).zf_label, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).zf2_label, SENSITIVE=1
    WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
    WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
    IF ((*struct_ptr).option_status GT 0) THEN BEGIN
            ; Only do this if options is NOT "NONE".
            (*struct_ptr).ir_remember = (*struct_ptr).ir
       (*struct_ptr).ir=0
    ENDIF
    WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=0
    WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = ''
    WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = ''
     ENDIF

END


;=======================================================================================================;
; Name: EV_CONV_ECC, EV_CONV_QUAL, EV_CONV_QUECC                   ;
; Purpose:  To set the appropriate flag when either the ECC, QUALITY, or QUECC button are clicked on.   ;
; Parameters:  event - The event which caused this procedure to be called.          ;
; Return:   None.                          ;
;=======================================================================================================;
PRO EV_CONV_NOQUECC, event

    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    button_value=WIDGET_INFO((*struct_ptr).no_quecc_button, /BUTTON_SET)

        IF (button_value EQ 1) THEN BEGIN

       IF ((*struct_ptr).file_type NE 2) THEN BEGIN
        ;IR settings do not apply to VARIAN!

         WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
         WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
               (*struct_ptr).ir_remember = (*struct_ptr).ir
         (*struct_ptr).ir=0
         WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=0
       ENDIF

       WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = ''
       WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = ''
       WIDGET_CONTROL, (*struct_ptr).rif_button, SET_BUTTON=0
       WIDGET_CONTROL, (*struct_ptr).norm_button, SET_BUTTON=0
       WIDGET_CONTROL, (*struct_ptr).ref_subbase, SENSITIVE=0
       (*struct_ptr).option_status = 0
    ENDIF
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_ECC, event

    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    button_value=WIDGET_INFO((*struct_ptr).ecc_button, /BUTTON_SET)

        IF (button_value EQ 1) THEN BEGIN
       IF ((*struct_ptr).file_type NE 2) THEN BEGIN
       ;IR settings do not apply to VARIAN!
         CASE (*struct_ptr).ir_remember OF
           0: BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
               END
           1:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=1
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
           END
           2:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=1
             END
         ENDCASE
         (*struct_ptr).ir = (*struct_ptr).ir_remember
         IF ((*struct_ptr).ir GT 0) THEN BEGIN
          WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
         ENDIF
         IF ((*struct_ptr).ir EQ 1) THEN BEGIN
          WIDGET_CONTROL ,(*struct_ptr).scale_label,  GET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=(*struct_ptr).in_if
          (*struct_ptr).ref_if = (*struct_ptr).in_if
          WIDGET_CONTROL, (*struct_ptr).rbaseline_yes_button,  SET_BUTTON = (*struct_ptr).baseln1
          IF ((*struct_ptr).baseln1 EQ 0) THEN BEGIN
              WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  SET_BUTTON = 1
          ENDIF
          (*struct_ptr).baseln2 = (*struct_ptr).baseln1
         ENDIF
         WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=1
       ENDIF

       WIDGET_CONTROL, (*struct_ptr).norm_button,  SET_BUTTON=(*struct_ptr).norm
       WIDGET_CONTROL, (*struct_ptr).ref_subbase, SENSITIVE=1
       WIDGET_CONTROL,(*struct_ptr).pts_label , SENSITIVE=0
       WIDGET_CONTROL,(*struct_ptr).f_label , SENSITIVE=0
       WIDGET_CONTROL,(*struct_ptr).delay_label , SENSITIVE=0

       (*struct_ptr).option_status = 1

    ENDIF
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_QUAL, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    button_value=WIDGET_INFO((*struct_ptr).quality_button, /BUTTON_SET)

        IF (button_value EQ 1) THEN BEGIN
       IF ((*struct_ptr).file_type NE 2) THEN BEGIN
       ;IR settings do not apply to VARIAN!
         CASE (*struct_ptr).ir_remember OF
          0: BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
                END
           1:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=1
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
           END
           2:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=1
           END
         ENDCASE
         (*struct_ptr).ir = (*struct_ptr).ir_remember
         IF ((*struct_ptr).ir GT 0) THEN BEGIN
          WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
         ENDIF
         IF ((*struct_ptr).ir EQ 1) THEN BEGIN
          WIDGET_CONTROL ,(*struct_ptr).scale_label,  GET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=(*struct_ptr).in_if
          (*struct_ptr).ref_if = (*struct_ptr).in_if
          WIDGET_CONTROL, (*struct_ptr).rbaseline_yes_button,  SET_BUTTON = (*struct_ptr).baseln1
          IF ((*struct_ptr).baseln1 EQ 0) THEN BEGIN
              WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  SET_BUTTON = 1
          ENDIF
          (*struct_ptr).baseln2 = (*struct_ptr).baseln1
         ENDIF
         WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=1
       ENDIF

       WIDGET_CONTROL, (*struct_ptr).norm_button,  SET_BUTTON=(*struct_ptr).norm
       WIDGET_CONTROL, (*struct_ptr).ref_subbase, SENSITIVE=1
       WIDGET_CONTROL,(*struct_ptr).pts_label , SENSITIVE=0
       WIDGET_CONTROL,(*struct_ptr).f_label , SENSITIVE=1
       WIDGET_CONTROL,(*struct_ptr).delay_label , SENSITIVE=1

       (*struct_ptr).option_status = 2

    ENDIF
END


;--------------------------------------------------------------------------------;
PRO EV_CONV_QUECC, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    button_value=WIDGET_INFO((*struct_ptr).quecc_button, /BUTTON_SET)

        IF (button_value EQ 1) THEN BEGIN
       IF ((*struct_ptr).file_type NE 2) THEN BEGIN
       ;IR settings do not apply to VARIAN!
         CASE (*struct_ptr).ir_remember OF
           0: BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
               END
           1:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=1
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=0
           END
           2:BEGIN
          WIDGET_CONTROL, (*struct_ptr).ir_button, SET_BUTTON=0
          WIDGET_CONTROL, (*struct_ptr).irn_button, SET_BUTTON=1
         END
         ENDCASE
         (*struct_ptr).ir = (*struct_ptr).ir_remember
         IF ((*struct_ptr).ir GT 0) THEN BEGIN
          WIDGET_CONTROL ,(*struct_ptr).infile_label,  GET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).reference_label, SET_VALUE = label
         ENDIF
         IF ((*struct_ptr).ir EQ 1) THEN BEGIN
          WIDGET_CONTROL ,(*struct_ptr).scale_label,  GET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).rscale_label, SET_VALUE = label
          WIDGET_CONTROL, (*struct_ptr).rif_button,  SET_BUTTON=(*struct_ptr).in_if
          (*struct_ptr).ref_if = (*struct_ptr).in_if
          WIDGET_CONTROL, (*struct_ptr).rbaseline_yes_button,  SET_BUTTON = (*struct_ptr).baseln1
          IF ((*struct_ptr).baseln1 EQ 0) THEN BEGIN
              WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  SET_BUTTON = 1
          ENDIF
          (*struct_ptr).baseln2 = (*struct_ptr).baseln1
         ENDIF
         WIDGET_CONTROL, (*struct_ptr).ir_base, SENSITIVE=1
       ENDIF

       WIDGET_CONTROL, (*struct_ptr).norm_button,  SET_BUTTON=(*struct_ptr).norm
       WIDGET_CONTROL, (*struct_ptr).ref_subbase, SENSITIVE=1
       WIDGET_CONTROL,(*struct_ptr).pts_label , SENSITIVE=1
       WIDGET_CONTROL,(*struct_ptr).f_label , SENSITIVE=1
       WIDGET_CONTROL,(*struct_ptr).delay_label , SENSITIVE=1

       (*struct_ptr).option_status = 3

    ENDIF
END

;=======================================================================================================;
; Name:  EV_CONV_YES, EV_CONV_YES2                      ;
; Purpose:  When the baseline buttons are selected to 'On', the flag for the respective variable is set ;
;       to on (or 1).                                      ;
; Parameters:  Event - The event which caused this procedure to be called.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_CONV_YES, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    (*struct_ptr).baseln1 = 1

    IF ((*struct_ptr).ir EQ 1) THEN BEGIN
       WIDGET_CONTROL, (*struct_ptr).rbaseline_yes_button,  /SET_BUTTON
       (*struct_ptr).baseln2 = (*struct_ptr).baseln1
    ENDIF
END

PRO EV_CONV_YES2, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    (*struct_ptr).baseln2 = 1
END

;=======================================================================================================;
; Name:  EV_CONV_NO, EV_CONV_NO2                        ;
; Purpose:  When the baseline buttons are selected to 'Off', the flag for the respective variable is set;
;        to off (or 0).                                    ;
; Parameters:  Event - The event which caused this procedure to be called.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_CONV_NO, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    (*struct_ptr).baseln1 = 0

    IF ((*struct_ptr).ir EQ 1) THEN BEGIN
       WIDGET_CONTROL, (*struct_ptr).rbaseline_no_button,  /SET_BUTTON
       (*struct_ptr).baseln2 = (*struct_ptr).baseln1
    ENDIF
END

PRO EV_CONV_NO2, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    (*struct_ptr).baseln2 = 0
END

;=======================================================================================================
;  Name: EV_CONV_Ok
;  Purpose:  When the user selects "ok' from the convert menu, it will send the command to 4t_cv with
;            the appropriate parameters that the user requested.
;  Parameters:  event - the event that triggered this procedure to be called.
;  Return: None.
;=======================================================================================================
PRO EV_CONV_OK, event
    COMMON common_widgets
    COMMON common_vars
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr

    WIDGET_CONTROL, (*struct_ptr).infile_label, GET_VALUE=infile
    WIDGET_CONTROL, (*struct_ptr).outfile_label, GET_VALUE=outfile
    WIDGET_CONTROL, (*struct_ptr).scale_label, GET_VALUE=scaleby
    WIDGET_CONTROL, (*struct_ptr).zf_label, GET_VALUE=zf
    WIDGET_CONTROL, (*struct_ptr).reference_label, GET_VALUE=ref
    WIDGET_CONTROL, (*struct_ptr).rscale_label, GET_VALUE=scale
    WIDGET_CONTROL, (*struct_ptr).zf2_label, GET_VALUE=zf2
    WIDGET_CONTROL, (*struct_ptr).f_label, GET_VALUE=f
    WIDGET_CONTROL, (*struct_ptr).delay_label, GET_VALUE=delay
    WIDGET_CONTROL, (*struct_ptr).pts_label, GET_VALUE=pts

    infile = infile[0]
    outfile = outfile[0]
    scaleby = scaleby[0]
    zf = zf[0]
    zf2 = zf2[0]
    ref = ref[0]
    f = f[0]
    delay = delay[0]
    pts = pts[0]

    IF (infile EQ '' OR outfile EQ '') THEN BEGIN
        err_result = DIALOG_MESSAGE('Need an input and output filename.', $
             Title = 'ERROR', /ERROR)
       ;WIDGET_CONTROL, event.top, /DESTROY
       ;WIDGET_CONTROL, error_window_ID, /DESTROY
       RETURN
    ENDIF

    IF (ref EQ '' AND (*struct_ptr).option_status GT 0) THEN BEGIN
        err_result = DIALOG_MESSAGE('Reference file not specified.', $
             Title = 'ERROR', /ERROR)
       ;WIDGET_CONTROL, event.top, /DESTROY
       ;WIDGET_CONTROL, error_window_ID, /DESTROY
       RETURN
    ENDIF

    ;-------------------- Starting conversion ------------------------------

    WIDGET_CONTROL, /HOURGLASS


    ;err_result = DIALOG_MESSAGE('See the background console for the conversion process.', $
    ;         Title = 'Conversion')
    ERROR_MESSAGE, "  See the background console for the conversion process.  ", TITLE="CONVERSION"

    infile = '"' + infile + '" '
    ref = '"' + ref + '" '
    outfile = '"' + outfile + '" '

    pwd = ''
    CASE !VERSION.OS OF
        'sunos': BEGIN
         pwd = pwd + './bin/SunOS/'
        END
        'linux': BEGIN
         pwd = pwd + './bin/Linux/'
        END
        'MacOS': BEGIN
         pwd = pwd + './bin/MacOS/'
        END
        'darwin': BEGIN
         pwd = pwd + './bin/MacOS/'
        END
        'Win32': BEGIN
                    pwd = pwd + '.\bin\Win32\'
        END
    ELSE: BEGIN
           err_result = DIALOG_MESSAGE('This Operating System (' + !VERSION.OS + ') is not supported for file conversion.', $
                               Title = 'ERROR', /ERROR)
           WIDGET_CONTROL, error_window_ID, /DESTROY
           WIDGET_CONTROL, event.top, /DESTROY
           WIDGET_CONTROL, main1, SENSITIVE=1
           RETURN
           END
    ENDCASE

    PRINT, ''
    PRINT, '***** BEGIN CONVERSION *****'
    PRINT, ''

    CASE (*struct_ptr).file_type OF
       ;GE file type
       0: BEGIN
            IF (!d.name EQ 'WIN') THEN BEGIN
                command = pwd + 'fitMAN_convert ' + pwd + 'ge2fitman '
            ENDIF ELSE BEGIN
                command = pwd + 'ge2fitman '
            ENDELSE
            IF ((*struct_ptr).verbose EQ 0) THEN command = command + '-nv '
            IF ((*struct_ptr).overwrite EQ 1) THEN command = command + '-ow '
            command = command + infile
            IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-bs '
            IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-nbs '
          END

       ;SIEMENS file type
       1: BEGIN
            IF (!d.name EQ 'WIN') THEN BEGIN
                command = pwd + 'fitMAN_convert ' + pwd + 'sim2fitman '
            ENDIF ELSE BEGIN
                command = pwd + 'sim2fitman '
            ENDELSE
            IF ((*struct_ptr).verbose EQ 0) THEN command = command + '-nv '
            IF ((*struct_ptr).overwrite EQ 1) THEN command = command + '-ow '
            command = command + infile
            IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-bs '
            IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-nbs '
          END

       ;VARIAN file type
       2: BEGIN
            IF (!d.name EQ 'WIN') THEN BEGIN
                command = pwd + 'fitMAN_convert ' + pwd + '4t_cv '+infile+' '+outfile+' '
            ENDIF ELSE BEGIN
                command = pwd + '4t_cv '+infile+' '+outfile+' '
            ENDELSE
            IF (zf GT 0 ) THEN command = command +'-zf '+STRING(zf)+' '
          END
    ENDCASE


    IF (scaleby EQ 0.0) THEN command = command + '-scale '
    IF (scaleby GT 0.0) THEN command = command + '-scaleby '+STRCOMPRESS(STRING(scaleby))+' '
    IF ((*struct_ptr).baseln1 EQ 1) THEN command = command + '-bc '
    IF ((*struct_ptr).in_if EQ 1) THEN command = command + '-if '

    ;NO_QUECC
    IF ((*struct_ptr).option_status EQ 0) THEN BEGIN



       CASE (*struct_ptr).file_type OF
         ;GE file type
         0: BEGIN
          command = command + outfile
      ;For this case just use the same switches for the ref file as the input file
      ;so both unsuppressed and suppressd output is generated.
      IF (scaleby EQ 0.0) THEN command = command + '-rscale '
          IF (scaleby GT 0.0) THEN command = command + '-rscaleby '+STRCOMPRESS(STRING(scaleby))+' '
          IF ((*struct_ptr).baseln1 EQ 1) THEN command = command + '-rbc '
          IF ((*struct_ptr).in_if EQ 1) THEN command = command + '-rif '
            END
         ;SIEMENS file type
         1: BEGIN
          command = command + outfile

      ;For this case just use the same switches for the ref file as the input file
      ;so both unsuppressed and suppressd output is generated.

      ;revised for Siemens one data set file
      IF (scaleby EQ 0.0) THEN command = command
          IF (scaleby GT 0.0) THEN command = command
          IF ((*struct_ptr).baseln1 EQ 1) THEN command = command
          IF ((*struct_ptr).in_if EQ 1) THEN command = command
            END
         ;VARIAN file type
         2: BEGIN
          command = command + ' '
            END
       ENDCASE
    ENDIF

    ;ECC
    IF ((*struct_ptr).option_status EQ 1) THEN BEGIN
       command = command + '-ecc ' + ref +' '
       IF (ref EQ '' OR ref EQ ' ') THEN BEGIN
            ;ERROR_MESSAGE, "Invalid Reference File"
       err_result = DIALOG_MESSAGE('Invalid reference file.', $
                               Title = 'WARNING')
         WIDGET_CONTROL, error_window_ID, /DESTROY
            ;WIDGET_CONTROL, event.top, /DESTROY
             RETURN
       ENDIF
       IF ((*struct_ptr).norm EQ 1) THEN command = command + '-norm '
       CASE (*struct_ptr).file_type OF
         ;GE file type
         0: BEGIN
          IF (scale EQ 0) THEN command = command + '-rscale '
          IF (scale GT 0) THEN command = command + '-rscaleby '+scale+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-rbc '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-rif '
          IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-rbs '
          IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-rnbs '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
          command = command + outfile
            END
         ;SIEMENS file type
         1: BEGIN
            IF (scale EQ 0) THEN command = command + '-rscale '
          IF (scale GT 0) THEN command = command + '-rscaleby '+scale+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-rbc '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-rif '
          IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-rbs '
          IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-rnbs '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
          command = command + outfile
                END
         ;VARIAN file type
         2: BEGIN
          IF (scale EQ 0) THEN command = command + '-scale '
          IF (scale GT 0) THEN command = command + '-scaleby '+scale+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-bc '
          IF (zf2 GT 0) THEN command = command + '-zf '+ STRCOMPRESS(STRING(zf2)) + ' '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-if '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
            END
       ENDCASE

    ENDIF

    ;QUALITY
    IF ((*struct_ptr).option_status EQ 2) THEN BEGIN
       command = command + '-quality ' +STRCOMPRESS(STRING(delay)) + ' '+ref+' '
       IF (ref EQ '' OR ref EQ ' ') THEN BEGIN
            ;ERROR_MESSAGE, "Invalid Reference File"
       err_result = DIALOG_MESSAGE('Invalid reference file.', $
                               Title = 'WARNING')
            WIDGET_CONTROL, error_window_ID, /DESTROY
            ;WIDGET_CONTROL, event.top, /DESTROY
            RETURN
       ENDIF
       IF ((*struct_ptr).norm EQ 1) THEN command = command + '-norm '

       CASE (*struct_ptr).file_type OF
         ;GE file type
         0: BEGIN
          IF (scale EQ 0) THEN command = command + '-rscale '
          IF (scale GT 0) THEN command = command + '-rscaleby '+STRCOMPRESS(STRING(scale))+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-rbc '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-rif '
          IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-rbs '
          IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-rnbs '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
          command = command + outfile
            END
         ;SIEMENS file type
         1: BEGIN
          IF (scale EQ 0) THEN command = command + '-rscale '
          IF (scale GT 0) THEN command = command + '-rscaleby '+STRCOMPRESS(STRING(scale))+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-rbc '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-rif '
          IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-rbs '
          IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-rnbs '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
          command = command + outfile
                END
         ;VARIAN file type
         2: BEGIN
          IF (scale EQ 0) THEN command = command + '-scale '
          IF (scale GT 0) THEN command = command + '-scaleby '+STRCOMPRESS(STRING(scale))+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-bc '
          IF (zf2 GT 0) THEN command = command + '-zf '+ STRCOMPRESS(STRING(zf2)) + ' '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-if '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
            END
       ENDCASE

    ENDIF


    ;QUECC
    IF ((*struct_ptr).option_status EQ 3) THEN BEGIN
       command = command + '-quecc ' + STRCOMPRESS(STRING(pts)) +' ' +STRCOMPRESS(STRING(delay)) + ' '+ref+' '
       IF (ref EQ '' OR ref EQ ' ') THEN BEGIN
            ;ERROR_MESSAGE, "Invalid Reference File"
       err_result = DIALOG_MESSAGE('Invalid reference file.', $
                               Title = 'WARNING')
            WIDGET_CONTROL, error_window_ID, /DESTROY
            ;WIDGET_CONTROL, event.top, /DESTROY
             RETURN
       ENDIF
       IF ((*struct_ptr).norm EQ 1) THEN command = command +'-norm '
       CASE (*struct_ptr).file_type OF
         ;GE file type
         0: BEGIN
          IF (scale EQ 0) THEN command = command + '-rscale '
          IF (scale GT 0) THEN command = command + '-rscaleby '+STRCOMPRESS(STRING(scale))+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-rbc '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-rif '
          IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-rbs '
          IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-rnbs '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
          command = command + outfile
            END
         ;SIEMENS file type
         1: BEGIN
          IF (scale EQ 0) THEN command = command + '-rscale '
          IF (scale GT 0) THEN command = command + '-rscaleby '+STRCOMPRESS(STRING(scale))+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-rbc '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-rif '
          IF ((*struct_ptr).byteswap EQ 0) THEN command = command + '-rbs '
          IF ((*struct_ptr).byteswap EQ 1) THEN command = command + '-rnbs '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
          command = command + outfile
                END
         ;VARIAN file type
         2: BEGIN
          IF (scale EQ 0) THEN command = command + '-scale '
          IF (scale GT 0) THEN command = command + '-scaleby '+STRCOMPRESS(STRING(scale))+' '
          IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-bc '
          IF (zf2 GT 0) THEN command = command + '-zf '+ STRCOMPRESS(STRING(zf2)) + ' '
          IF ((*struct_ptr).ref_if EQ 1) THEN command = command + '-if '
          IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
            END
       ENDCASE
    ENDIF

    ;Spawn the conversion command
    print,command
    SPAWN, command

    PRINT, '****** END CONVERSION ******'
    PRINT, ''

    ;This part is used for "Import file"
    IF (import_file_type EQ "SUPP" OR import_file_type EQ "UNSUPP") THEN BEGIN
    GET_IMPORTED_DATA_FILENAME, outfile
    import_file_info = FILE_INFO(imported_data_filename)
    IF (import_file_info.read EQ 0) THEN BEGIN
       imp_msg = ['Error reading import file...', 'Please refer to the background console for conversion results.']
       err_result = DIALOG_MESSAGE(imp_msg, Title = 'ERROR', /ERROR)
    ENDIF ELSE BEGIN
       EV_DATA, event
    ENDELSE
    ENDIF

    WIDGET_CONTROL, error_window_ID, /DESTROY
    WIDGET_CONTROL, main1, SENSITIVE=1
    WIDGET_CONTROL, event.top, /DESTROY

    ;Clearing the common variables
     imported_data_filename = ""
     import_file_type=""


END

;=======================================================================================================;
; Name:  EV_CONV_CANCEL
; Purpose: To destroy the window when the user selects the cancel button in the Convert Raw Data menu.
; Parameters: event, the event which caused this procedure.
; Return:  None.
;=======================================================================================================;
PRO EV_CONV_CANCEL, event
    COMMON common_widgets
    COMMON common_vars


    WIDGET_CONTROL, event.top, /DESTROY
    WIDGET_CONTROL, main1, SENSITIVE=1
END

;=======================================================================================================;
; Name:  EV_EXIT
; Purpose:  Called when the user clicks on the exit button under the File menu.   It will destroy the
;           top level widget, and free all memory.   It will then exit the program.
; Parameters:  event - The event which caused this procedure to be called.
; Return:  None.
;=======================================================================================================;
PRO EV_EXIT, event
        COMMON common_vars
        COMMON common_widgets

    ;The following command is very useful because it ends the program and
    ;closes the window.
    WIDGET_CONTROL, event.top, /DESTROY

        RETALL    ;frees all variables, memory, etc. before exitting the program.
END

;========================================================================================================;
; Name: EV_SVIMG
;
;========================================================================================================

pro EV_SVIMG, event
   COMMON common_vars
   COMMON draw1_comm


   svbase = WIDGET_BASE(ROW=3, MAP=1, TITLE="Save Graph to *.jpg", UVALUE='d_base')
   path_base =WIDGET_BASE(svbase,COL=2, MAP=1)
   file_label = CW_FIELD(path_base, TITLE='File Name: ', /STRING)
   jpg_browse = WIDGET_BUTTON(path_base, VALUE = "Browse", EVENT_PRO = 'EV_JPGBROWSE')

   midBase = widget_base(svbase,COL=2)

   imgBase = widget_base(midBase,ROW=3,/EXCLUSIVE,/FRAME)
   wButton = widget_button(imgBase,VALUE='White Background',UVALUE='w',EVENT_PRO='EV_JPG')
   bButton = widget_button(imgBase,VALUE='Black Background',UVALUE='b',EVENT_PRO='EV_JPG')
   bwButton = widget_button(imgBase,VALUE='Black and White Image',UVALUE='bw',EVENT_PRO='EV_JPG')

   qBase = widget_base(midBase,/FRAME)
   qSlider = CW_FSLIDER(qBase, /DRAG,TITLE='Image Quality', UVALUE = 'SCALE', VALUE = 100, $
       MAXIMUM = 100, MINIMUM = 0, /FRAME, /EDIT)

   ok_base = WIDGET_BASE(svbase,COL= 2, MAP = 1, /BASE_ALIGN_CENTER)
   ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok', EVENT_PRO= 'svJPG',UVALUE='svJPG')
   cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_DIR_CANCEL')


   state = { file_label:file_label,bgtype:1,slider:qSlider}
   pstate = ptr_new(state, /NO_COPY)

   WIDGET_CONTROL, svbase, SET_UVALUE=pstate
   WIDGET_CONTROL, svbase, /REALIZE
   XMANAGER, 'foo', svbase

end

pro EV_JPGBROWSE,event
  COMMON common_vars

  WIDGET_CONTROL, event.top, GET_UVALUE = pstate

  file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.jpg')

  WIDGET_CONTROL, (*pstate).file_label, SET_VALUE=file
end

pro EV_JPG,event

   WIDGET_CONTROL,event.top,GET_UVALUE=pstate
   WIDGET_CONTROL, event.id,GET_UVALUE = uval

   case(uval) of
     'w': (*pstate).bgtype = 0
     'b': (*pstate).bgtype = 1
     'bw': (*pstate).bgtype = 2
   endcase

   print,(*pstate).bgtype
end


pro svJPG,event
   WIDGET_CONTROL,event.top,GET_UVALUE=pstate
   WIDGET_CONTROL,(*pstate).file_label,GET_VALUE=fname
   WIDGET_CONTROL,(*pstate).slider,GET_VALUE=quality

   COMMON common_vars
   COMMON draw1_comm

   image = TVRD()
   TVLCT,r,g,b,/GET

   mred = r[image]
   mgreen = g[image]
   mblue = b[image]

   print,quality

   case ((*pstate).bgtype) of
      0: begin
        image3d = filterBlackWhite(mred,mgreen,mblue)
      end
      1: begin
        image3d = blackBack(mred,mgreen,mblue)
      end
      2: begin
        image3d = binaryImage(mred,mgreen,mblue)
      end
   endcase

   WRITE_JPEG, fname, image3d,TRUE=1,QUALITY=quality

   WIDGET_CONTROL, event.top, /DESTROY
end

pro FOO_EVENT,event

end

pro EV_DELFILE,event
     hlsvd_base = WIDGET_BASE(COL=2, MAP=1, TITLE="Delete File ...", UVALUE='d_base')
     path_base =WIDGET_BASE(hlsvd_base,COL=2, MAP=1)
     path_label = CW_FIELD(path_base, TITLE='File: ', VALUE=hlsvdpath, /STRING)
     path_browse = WIDGET_BUTTON(path_base, VALUE = "Browse", EVENT_PRO = 'EV_DELFILE_BROWSE')
     ok_base = WIDGET_BASE(hlsvd_base,ROW = 2, MAP = 1, /BASE_ALIGN_CENTER)
     ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok',EVENT_PRO = 'EV_DELFILE_OK',UVALUE='_ok')
     cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_DELFILE_CANCEL')


     state = { path_label:path_label}
     pstate = ptr_new(state, /NO_COPY)

     WIDGET_CONTROL, hlsvd_base, SET_UVALUE=pstate
     WIDGET_CONTROL, hlsvd_base, /REALIZE
     XMANAGER, 'delFile', hlsvd_base
end

pro EV_DELFILE_BROWSE, event
   COMMON common_vars

   file = DIALOG_PICKFILE(/READ, PATH=string(defaultpath),FILTER='*.*')

   WIDGET_CONTROL, event.top, GET_UVALUE = pstate
   IF (STRING(file) NE '') THEN WIDGET_CONTROL, (*pstate).path_label, SET_VALUE=file
end

pro EV_DELFILE_OK, event
   WIDGET_CONTROL, event.top, GET_UVALUE = pstate
   WIDGET_CONTROL, (*pstate).path_label, GET_VALUE=file
   FILE_DELETE, file
   print, "file:",file," deleted"
   WIDGET_CONTROL, event.top, /DESTROY
end

pro EV_DELFILE_CANCEL, event
   WIDGET_CONTROL, event.top, /DESTROY
end



;**************** Alex Li adding EV_CONVERTCSI event on Nov 14, 2005*****************
;=======================================================================================================;
; Name:  EV_CONVERTCSI                           ;
; Purpose:  To allow the user to convert CSI raw data that has come out of the scanner to a usable format   ;
;       that can be used for this program and various other programs.   This particular procedure   ;
;       will set up the window and all the possible options and give control to the event handler.  ;
; Parameters:  event - the event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_CONVERTCSI, event

    convert_base = WIDGET_BASE(ROW=7, MAP=1, TITLE='Convert CSI Raw Data',UVALUE='CONVERTCSI')
    main_options = WIDGET_BASE(convert_base,COL=3, MAP=1, UVALUE='MAIN')
    main_opt =WIDGET_BASE(convert_base,COL=3, MAP=1, UVALUE='MAIN')
    main2_options = WIDGET_BASE(convert_base, COL=2, MAP=1, UVALUE='MAIN2')
    infile_label = CW_FIELD(main_opt, TITLE='Input Files Path:   ', Value= '', /STRING)
    infile_browse = WIDGET_BUTTON(main_opt, VALUE = 'Browse', EVENT_PRO = 'EV_INPUT_BROWSE')
    button_base =WIDGET_BASE(main_opt, COL=2, MAP=1, UVALUE='BL', /FRAME, /EXCLUSIVE)
    main_if_button = WIDGET_BUTTON(button_base, VALUE='Auto Filter', EVENT_PRO='EV_CONV_MAIN_IF')
    outfile_label = CW_FIELD(main_options, TITLE="Output Files Path:", VALUE='', /STRING)
    output_browse = WIDGET_BUTTON(main_options, Value = 'Browse', EVENT_PRO = 'EV_OUTPUT_BROWSE')
    scaleby_label = CW_FIELD(main_options, TITLE="Scale Factor (-1 for none, 0 for auto scaling):", $
       VALUE=0.0, /FLOAT)
    baseline_base = WIDGET_BASE(main2_options, COL=2, MAP=1, UVALUE='BL', /FRAME, /EXCLUSIVE)
    yes_button = WIDGET_BUTTON(baseline_base, Value="Use Baseline Correction", EVENT_PRO='EV_CONV_YES' )
    no_button = WIDGET_BUTTON(baseline_base, VALUE="Don't use Baseline Correction", $
       EVENT_PRO='EV_CONV_NO')
    zf_label = CW_FIELD(main2_options, TITLE="Zero Fill (Leave 0 for none): ", VALUE=0, /INTEGER)
    mode_base = WIDGET_BASE(convert_base, COL=3, MAP=1, UVALUE='MODE', /EXCLUSIVE)
    ecc_button = WIDGET_BUTTON(mode_base, VALUE='ECC   ', EVENT_PRO='EV_CONV_ECC')
    quality_button = WIDGET_BUTTON(mode_base, VALUE='QUALITY   ', EVENT_PRO='EV_CONV_QUAL')
    quecc_button = WIDGET_BUTTON(mode_base, VALUE='QUECC   ', EVENT_PRO='EV_CONV_QUECC')
    empty_base = WIDGET_BASE(convert_base, COL=2, MAP=1, UVALUE='EMPTY')
    empty_label = WIDGET_LABEL(empty_base, VALUE=' ')
    options_base = WIDGET_BASE(convert_base, row=5, UVALUE='options', /FRAME)
    options1_base = WIDGET_BASE(options_base, col=3, UVALUE='option1')
    options2_base =  WIDGET_BASE(options_base, col=2, UVALUE='option2')
    options3_base = WIDGET_BASE(options_base, col=2, UVALUE='option3')
    options4_base = WIDGET_BASE(options_base, col=2, UVALUE='option4')
    options5_base =WIDGET_BASE(options_base, col=2, UVALUE='option5')
    reference_label = CW_FIELD(options1_base, TITLE='Reference Files Path:',VALUE='', /STRING)
    ref_browse = WIDGET_BUTTON(options1_base, VALUE='Browse', EVENT_PRO='EV_REF_BROWSE')
    scale_label = CW_FIELD(options1_base, TITLE="Scale Factor (-1 for none, 0 for auto scaling):", $
       VALUE=0.0, /FLOAT)
    baseline2_base = WIDGET_BASE(options2_base, COL=2, MAP=1, UVALUE='BL', /FRAME, /EXCLUSIVE)
    yes2_button = WIDGET_BUTTON(baseline2_base, Value="Use Baseline Correction", $
       EVENT_PRO='EV_CONV_YES2' )
    no2_button = WIDGET_BUTTON(baseline2_base, VALUE="Don't use Baseline Correction", $
       EVENT_PRO='EV_CONV_NO2')
    zf2_label = CW_FIELD(options2_base, TITLE='Zero Fill (leave 0 for none):', VALUE=0, /INTEGER)
    norm_base = WIDGET_BASE(options3_base, COL=1, MAP=1, UVALUE='nb', /frame, /EXCLUSIVE)
    norm_button = WIDGET_BUTTON(norm_base, VALUE='Normalize', EVENT_PRO='EV_CONV_NORM')
    if_base = WIDGET_BASE(options3_base, COL=1, MAP=1, UVALUE='if', /FRAME, /EXCLUSIVE)
    if_button = WIDGET_BUTTON(if_base, VALUE = 'Auto Filter ', EVENT_PRO='EV_CONV_IF')
    f_label = CW_FIELD(options4_base, TITLE='Filter(Leave 0 for none): ',VALUE=0.0, /FLOAT)
    delay_label = CW_FIELD(options5_base, TITLE='Time Delay (micro seconds): ', VALUE=500.0, /FLOAT)
    pts_label = CW_FIELD(options5_base, TITLE='QUALITY: Points (Real+Imag): ', VALUE=400, /INTEGER)
    ok_base = WIDGET_BASE(convert_base,COL=2, MAP=1, UVALUE='ok_base', /BASE_ALIGN_RIGHT)
    Ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok', EVENT_PRO = 'EV_CONVCSI_OK')
    Cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_CONV_CANCEL')

    option_status = 0
    scale1 = 0
    scale2 = 0
    baseln1 = 0
    baseln2 = 0
    norm = 0
    f_auto =0
    main_f_auto = 0
    structure = { option_status:option_status,  baseln1:baseln1, baseln2:baseln2, $
       main_f_auto:main_f_auto, norm:norm, f_auto:f_auto, infile_label: infile_label, $
       outfile_label:outfile_label, scaleby_label:scaleby_label, xf_label:zf_label, $
       pts_label:pts_label, delay_label:delay_label, f_label:f_label, if_button:if_button, $
       norm_button:norm_button, reference_label:reference_label, scale_label:scale_label, $
       zf2_label:zf2_label  }
    struct_ptr = ptr_new(structure, /NO_COPY)
    WIDGET_CONTROL, convert_base, SET_UVALUE=struct_ptr
    WIDGET_CONTROL, convert_base, /REALIZE
    XMANAGER, "convert", convert_base
END

;******* end of EV_CONVERTCSI event*******************



;********Alex Li adding EV_CONVCSI_OK on Nov 14, 2005**********************
    ;=======================================================================================================;
;  Name: EV_CONVCSI_Ok                           ;
;  Purpose:  When the user selects "ok' from the convert menu, it will send the command to 4t_cv with   ;
;            the appropriate parameters that the user requested.              ;
;  Parameters:  event - the event that triggered this procedure to be called.          ;
;  Return: None.                             ;
;=======================================================================================================;
PRO EV_CONVCSI_OK, event
    WIDGET_CONTROL, event.top, GET_UVALUE=struct_ptr
    WIDGET_CONTROL, (*struct_ptr).infile_label, GET_VALUE=infile
    WIDGET_CONTROL, (*struct_ptr).outfile_label, GET_VALUE=outfile
    WIDGET_CONTROL, (*struct_ptr).scaleby_label, GET_VALUE=scaleby
    WIDGET_CONTROL, (*struct_ptr).xf_label, GET_VALUE=zf
    WIDGET_CONTROL, (*struct_ptr).reference_label, GET_VALUE=ref
    WIDGET_CONTROL, (*struct_ptr).scale_label, GET_VALUE=scale
    WIDGET_CONTROL, (*struct_ptr).zf2_label, GET_VALUE=zf2
    WIDGET_CONTROL, (*struct_ptr).f_label, GET_VALUE=f
    WIDGET_CONTROL, (*struct_ptr).delay_label, GET_VALUE=delay
    WIDGET_CONTROL, (*struct_ptr).pts_label, GET_VALUE=pts

    infile = infile[0]
    outfile = outfile[0]
    scaleby = scaleby[0]
    zf = zf[0]
    zf2 = zf2[0]
    ref = ref[0]
    f = f[0]
    delay = delay[0]
    pts = pts[0]

    ;check folders end with / or not

    IF (STRMID(infile, 0, /REVERSE_OFFSET) EQ '/') THEN infile=infile ELSE infile=infile+'/'
    IF (STRMID(outfile, 0, /REVERSE_OFFSET) EQ '/') THEN outfile1=outfile ELSE outfile1=outfile+'/'
    IF (STRMID(ref, 0, /REVERSE_OFFSET) EQ '/') THEN ref1=ref ELSE ref1=ref+'/'

    ;**************adding loop inside the folder***********
    subfolderarray=FILE_SEARCH(infile, '*.fid',COUNT=totalsubfolders) ;put subfolder name into an array

    IF (totalsubfolders EQ 0) THEN BEGIN
       ;ERROR_MESSAGE, "****** There is no file in the folder *******."
    err_result = DIALOG_MESSAGE('There is no file in the folder.', $
                               Title = 'ERROR', /ERROR)
       WIDGET_CONTROL, event.top, /DESTROY
    RETURN
    ENDIF

    FOR i=0, totalsubfolders-1 DO BEGIN
       subfoldername=STRMID(subfolderarray[i],5,/REVERSE_OFFSET)
       subfoldernamewithoutfid=STRMID(subfoldername,0,2)
       infile=subfolderarray[i]+'/'
       outfile=outfile1 + subfoldernamewithoutfid
       ref=ref1+subfoldername+'/'
       ;PRINT, infile
       ;PRINT, outfile
       ;PRINT, ref
    ;ENDFOR

    IF (infile EQ '' OR outfile EQ '') THEN BEGIN
       ;ERROR_MESSAGE, "Need an input and output filename."
    err_result = DIALOG_MESSAGE('Need an input and output filename.', $
                               Title = 'ERROR', /ERROR)
       WIDGET_CONTROL, event.top, /DESTROY
    RETURN
    ENDIF

        pwd = ''
        spawn, 'pwd',pwd


    command = pwd + '/bin/4t_cv '+infile+' '+outfile+' '

    IF (scaleby EQ 0.0) THEN command = command + '-scale '
    IF (scaleby GT 0.0) THEN command = command + '-scaleby '+STRCOMPRESS(STRING(scaleby))+' '
    IF ((*struct_ptr).baseln1 EQ 1) THEN command = command + '-bc '
    IF (zf GT 0 ) THEN command = command +'-zf '+STRING(zf)+' '
    IF ((*struct_ptr).main_f_auto EQ 1) THEN command = command + '-if '

    IF ((*struct_ptr).option_status EQ 1) THEN BEGIN
       command = command + '-ecc ' + ref +' '
       IF (ref EQ '' ) THEN BEGIN
         ;ERROR_MESSAGE, "Invalid Reference File"
     err_result = DIALOG_MESSAGE('Invalid reference file.', $
                               Title = 'ERROR', /ERROR)
         WIDGET_CONTROL, event.top, /DESTROY
    RETURN
       ENDIF
       IF (scale EQ 0) THEN command = command + '-scale '
       IF (scale GT 0) THEN command = command + '-scaleby '+scale+' '
       IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-bc '
       IF (zf2 GT 0) THEN command = command + '-zf '+ STRCOMPRESS(STRING(zf2)) + ' '
       IF ((*struct_ptr).f_auto EQ 1) THEN command = command + '-if '

    ENDIF
    IF ((*struct_ptr).option_status EQ 2) THEN BEGIN
       command = command + '-quality ' +STRCOMPRESS(STRING(delay)) + ' '+ref+' '
       IF (ref EQ '' ) THEN BEGIN
         ;ERROR_MESSAGE, "Invalid Reference File"
     err_result = DIALOG_MESSAGE('Invalid reference file.', $
                               Title = 'ERROR', /ERROR)
         WIDGET_CONTROL, event.top, /DESTROY
     RETURN
       ENDIF
       IF ((*struct_ptr).norm EQ 1) THEN command = command + '-norm '
       IF (scale EQ 0) THEN command = command + '-scale '
       IF (scale GT 0) THEN command = command + '-scaleby '+STRCOMPRESS(STRING(scale))+' '
       IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-bc '
       IF (zf2 GT 0) THEN command = command + '-zf '+ STRCOMPRESS(STRING(zf2)) + ' '
       IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
    ENDIF
    IF ((*struct_ptr).option_status EQ 3) THEN BEGIN
       command = command + '-quecc ' + STRCOMPRESS(STRING(pts)) +' ' +STRCOMPRESS(STRING(delay)) + ' '+ref+' '
       IF (ref EQ '' ) THEN BEGIN
         ;ERROR_MESSAGE, "Invalid Reference File"
     err_result = DIALOG_MESSAGE('Invalid reference file.', $
                               Title = 'ERROR', /ERROR)
         WIDGET_CONTROL, event.top, /DESTROY
     RETURN
       ENDIF
       IF ((*struct_ptr).norm EQ 1) THEN command = command +'-norm '
       IF (scale EQ 0) THEN command = command + '-scale '
       IF (scale GT 0) THEN command = command + '-scaleby '+STRCOMPRESS(STRING(scale))+' '
       IF ((*struct_ptr).baseln2 EQ 1) THEN command = command + '-bc '
       IF (zf2 GT 0) THEN command = command + '-zf '+ STRCOMPRESS(STRING(zf2)) + ' '
       IF (f GT 0) THEN command = command + '-f ' + STRCOMPRESS(STRING(f)) +' '
       IF ((*struct_ptr).f_auto EQ 1) THEN command = command + '-if '
    ENDIF

    SPAWN, command
    print,command

  ENDFOR ;/ending the for loop

  WIDGET_CONTROL, event.top, /DESTROY
END

;********end of EV_CONVCSI_OK**********************************************




;=======================================================================================================;
; Name:  GET_IMPORTED_DATA_FILENAME
; Purpose: To convert and import raw data file.
; Parameters: event, the event which caused this procedure.
; Return:  None.
;=======================================================================================================;
PRO GET_IMPORTED_DATA_FILENAME, outfile
    COMMON common_vars
    COMMON common_widgets


    extPos = strpos(outfile, '.', /REVERSE_SEARCH)

    IF (import_file_type EQ "SUPP") THEN BEGIN
       FileExt = strmid(outfile, extPos-2 , 6)
       IF (FileExt NE "_s.dat") THEN BEGIN
         FileExt = strmid(outfile, extPos-4 , 8)
         IF(FileExt EQ "_uns.dat") THEN BEGIN
          imported_data_filename = strmid(outfile, 0 , strlen(outfile)-10)
         ENDIF ELSE BEGIN
          imported_data_filename = strmid(outfile, 0 , strlen(outfile)-2)

         ENDELSE
         imported_data_filename = imported_data_filename  + '_s.dat"'
       ENDIF ELSE BEGIN
         imported_data_filename = strmid(outfile, 0 , strlen(outfile)-1)
       ENDELSE
    ENDIF ELSE  BEGIN
       FileExt = strmid(outfile, extPos-4 , 8)
       IF (FileExt NE "_uns.dat") THEN BEGIN
         FileExt = strmid(outfile, extPos-2 , 6)
         IF(FileExt EQ "_s.dat") THEN BEGIN
          imported_data_filename = strmid(outfile, 0 , strlen(outfile)-8)
         ENDIF ELSE BEGIN
          imported_data_filename = strmid(outfile, 0 , strlen(outfile)-2)

         ENDELSE
         imported_data_filename = imported_data_filename  + '_uns.dat"'
       ENDIF ELSE BEGIN
         imported_data_filename = strmid(outfile, 0 , strlen(outfile)-1)
       ENDELSE
    ENDELSE

    imported_data_filename = strmid(imported_data_filename, 1 , strlen(imported_data_filename)-2)

    print, imported_data_filename

END
