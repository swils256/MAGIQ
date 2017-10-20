;=======================================================================================================;
; Name:  FitmanMouseControls.pro                        
; Purpose:  To provide a set of functions for FitmanGUI that will handle all mouse events.   This       
;       includes zooming, setting active windows, and displaying coordinates to the screem.   
; Dependancies:  FitmanGui_sept2000.pro, Display.pro                   
;=======================================================================================================;

;======================================================================================================;
; Name:  MOUSE_EV                                                                                      
; Purpose:  The procedure MOUSE_EV is called when we are on the draw widget DRAW1 and we notice a mouse
;        event.   It takes one parameter, like all event driven procedures, called event.   This   
;        procedure is responsible for gathering data about the points that are needed for use with
;        redrawing the zoom area (if active_cursor is set) and just general housekeeping of mouse  
;        movement/button clicking in regards to the WIDGET_DRAW for the graph.                     
; Parameters:  Event - The event that caused this procedure to be called.                              
; Return:   None.                                                                                      
;======================================================================================================;
PRO MOUSE_EV, event
        COMMON common_vars
        COMMON common_widgets
        COMMON Draw1_Comm

        WIDGET_CONTROL, event.top, GET_UVALUE = pstate
    ; If we have the right button being clicked, we want to set this draw window as the active window.
    IF (event.press EQ 4) THEN BEGIN
       WSET, Draw1_Id

       ; Set non needed menus off
          WIDGET_CONTROL, button2, SENSITIVE=0
          WIDGET_CONTROL, button3, SENSITIVE=0
          WIDGET_CONTROL, button4, SENSITIVE=0
          WIDGET_CONTROL, menu4, SENSITIVE=0
          WIDGET_CONTROL, menu5, SENSITIVE=0
       WIDGET_CONTROL, fit_button, SENSITIVE=0
       WIDGET_CONTROL, reload_guess_button, SENSITIVE=0
       WIDGET_CONTROL, reload_const_button, SENSITIVE=0

                if(plot_info.data_file EQ '') then begin
          setComponents,/DISABLE
       endif else begin
          setComponents,/ENABLE
       endelse

       Window_Flag = 1

       ;Set appropriate values in the widgets.
       IF (plot_info.domain EQ 0) THEN BEGIN
         WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.time_xmax
         WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.time_xmin
         WIDGET_CONTROL, Y_MAX, SET_VALUE = plot_info.time_ymax
         WIDGET_CONTROL, Y_MIN, SET_VALUE = plot_info.time_ymin
         WIDGET_CONTROL, INITIAL, SET_VALUE = plot_info.fft_initial
         WIDGET_CONTROL, FINAL, SET_VALUE = plot_info.fft_final
       ENDIF ElSE BEGIN
         WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.freq_xmin
         WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.freq_xmax
           WIDGET_CONTROL, Y_MAX, SET_VALUE = plot_info.freq_ymax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * plot_info.freq_ymin
           WIDGET_CONTROL, INITIAL, SET_VALUE = plot_info.fft_initial
         WIDGET_CONTROL, FINAL, SET_VALUE = plot_info.fft_final
       ENDELSE

                if(plot_info.fft_final eq 0) then begin
           plot_info.fft_final = float(middle_data_file_header.points/2 * $
                                  data_file_header.dwell)
                endif
          WIDGET_CONTROL, FINAL, SET_VALUE = plot_info.fft_final
       WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = plot_info.phase
       WIDGET_CONTROL, EXPON_FILTER, SET_VALUE = plot_info.expon_filter
       WIDGET_CONTROL, GAUSS_FILTER, SET_VALUE = plot_info.gauss_filter
    ENDIF

    IF (event.press EQ 2) THEN BEGIN
       ; Convert the coordinates from device to data
       datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
       plot_info.sx = STRTRIM(datac[0],2)
       plot_info.sy = STRTRIM(datac[1],2)
    ENDIF
    IF (event.release EQ 2) THEN BEGIN
       ; Convert the coordinates from device to data
            datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
       plot_info.dx = STRTRIM(datac[0],2)
            plot_info.dy = STRTRIM(datac[1],2)

       ; Determine which difference is greater, the horizontal component, or the
       ; vertical one.  This determines which way to scale.
       IF (plot_info.domain EQ 0) THEN BEGIN
         norm_x = (ABS(plot_info.sx - plot_info.dx))/plot_info.time_xmax
         norm_y = (ABS(plot_info.sy - plot_info.dy))/plot_info.time_ymax
         IF ( norm_y GT norm_x) THEN BEGIN
          Scale_Flag = 0
         ENDIF ELSE BEGIN
          Scale_Flag =1
         ENDELSE
       ENDIF ELSE BEGIN
         norm_x = (ABS(plot_info.sx - plot_info.dx))/plot_info.freq_xmax
         norm_y = (ABS(plot_info.sy - plot_info.dy))/plot_info.freq_ymax
         IF ( norm_y GT norm_x) THEN BEGIN
          Scale_Flag = 0
         ENDIF ELSE BEGIN
          Scale_Flag =1
         ENDELSE
       ENDELSE

       ; Determine which difference is greater, the horizontal component, or the
       ; vertical one.  This determines which way to scale.

       IF (Scale_Flag EQ 0) THEN BEGIN
         WIDGET_CONTROL, Y_MAX, GET_VALUE=ymax
         WIDGET_CONTROL, Y_MIN, GET_VALUE=ymin

         IF (plot_info.sy GT ymax) THEN plot_info.sy = ymax
         IF (plot_info.sy LT ymin) THEN plot_info.sy = ymin
         IF (plot_info.dy GT ymax) THEN plot_info.dy = ymax
         IF (plot_info.dy LT ymin) THEN plot_info.dy = ymin

         ScaleFactor = ABS(plot_info.sy) - ABS(plot_info.dy)

         ;Normalize, get percent to zoom in by.
         ScaleFactor = ABS(ScaleFactor / (ymax-ymin))
         IF (ScaleFactor GT 1) THEN ScaleFactor =1

         ; We have upward movement, we know they want to scale "inward"
         IF (plot_info.dy GT plot_info.sy) THEN BEGIN
          ScaleFactor = 1 + ScaleFactor
          WIDGET_CONTROL, Y_MAX, SET_VALUE=ymax*ScaleFactor
          PRINT, "scale up - middle window"
         ENDIF

         ; Otherwise we have downward movement.
         IF (plot_info.dy LT plot_info.sy) THEN BEGIN
          ScaleFactor = 1 - ScaleFactor
          WIDGET_CONTROL, Y_MAX, SET_VALUE=ymax
          print, "scale downward - middle window"
         ENDIF

         ; Get backup info for undo.
         IF (plot_info.domain EQ 0) THEN BEGIN
          undo_array[1,0]=plot_info.time_xmin
          undo_array[1,1]=plot_info.time_xmax
          undo_array[1,2]=plot_info.time_ymin
          undo_array[1,3]=plot_info.time_ymax
               ENDIF
         IF (plot_info.domain EQ 1) THEN BEGIN
          undo_array[1,0]=plot_info.freq_xmin
          undo_array[1,1]=plot_info.freq_xmax
          undo_array[1,2]=plot_info.freq_ymin
          undo_array[1,3]=plot_info.freq_ymax
         ENDIF

               IF (plot_info.domain EQ 0) THEN plot_info.time_ymax = ymax*ScaleFactor $
         ELSE plot_info.freq_ymax = ymax*ScaleFactor

         IF (plot_info.domain EQ 0) THEN BEGIN
                   plot_info.time_auto_scale_y = 0
                   plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   plot_info.freq_auto_scale_y = 0
                   plot_info.freq_auto_scale_x = 0
               ENDELSE
               plot_info.fft_recalc = 1

         DISPLAY_DATA

       ENDIF ELSE BEGIN
         WIDGET_CONTROL, X_MAX, GET_VALUE=xmax
         WIDGET_CONTROL, X_MIN, GET_VALUE=xmin

         IF (plot_info.sx GT xmax) THEN plot_info.sx = xmax
         IF (plot_info.sx LT xmin) THEN plot_info.sx = xmin
         IF (plot_info.dx GT xmax) THEN plot_info.dx = xmax
         IF (plot_info.dx LT xmin) THEN plot_info.dx = xmin

         ScaleFactor = ABS(plot_info.sx) - ABS(plot_info.dx)

         ;Normalize, get percent to zoom in by.
         ScaleFactor = ABS(ScaleFactor / (xmax-xmin))
         IF (ScaleFactor GT 1) THEN ScaleFactor =1

         ; We have outward movement, we know they want to scale out
         IF (plot_info.dx GT plot_info.sx) THEN BEGIN
          PRINT, "In here - Scaling outwards"
          ScaleFactor = 1 + ScaleFactor
          IF(o_xmax LE xmax*ScaleFactor) THEN BEGIN
              PRINT, " Original is less than the new scalefactor"
              ;IF (plot_info.domain EQ 0) THEN RETURN
              RETURN

          ENDIF ELSE BEGIN
              Print, "Getting to Widget Control"
              WIDGET_CONTROL, X_MAX, SET_VALUE=xmax*ScaleFactor

          ENDELSE

         endif
         ; Otherwise we have to scale inwards.
         IF (plot_info.dx LT plot_info.sx) THEN BEGIN
          ;PRINT, "In Here2"
          ScaleFactor = 1 - ScaleFactor
          Print, "Getting to Widget Control"
          WIDGET_CONTROL, X_MAX, SET_VALUE=xmax*ScaleFactor
         ENDIF

         ; Get backup info for undo.
         IF (plot_info.domain EQ 0) THEN BEGIN
          undo_array[0,0]=plot_info.time_xmin
          undo_array[0,1]=plot_info.time_xmax
          undo_array[0,2]=plot_info.time_ymin
          undo_array[0,3]=plot_info.time_ymax
               ENDIF
         IF (plot_info.domain EQ 1) THEN BEGIN
          undo_array[0,0]=plot_info.freq_xmin
          undo_array[0,1]=plot_info.freq_xmax
          undo_array[0,2]=plot_info.freq_ymin
          undo_array[0,3]=plot_info.freq_ymax
         ENDIF

               IF (plot_info.domain EQ 0) THEN plot_info.time_xmax = xmax*ScaleFactor $
         ELSE plot_info.freq_xmax = xmax*ScaleFactor

         IF (plot_info.domain EQ 0) THEN BEGIN
                   plot_info.time_auto_scale_y = 0
                   plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   plot_info.freq_auto_scale_y = 0
                   plot_info.freq_auto_scale_x = 0
               ENDELSE
               plot_info.fft_recalc = 1

         DISPLAY_DATA

       ENDELSE
    ENDIF

    ; Test if button has been pressed on mouse (button 1).
        ; Convert the coordinates from device to data
    IF (Window_Flag EQ 1) THEN BEGIN
            datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
            statusstr = strtrim(datac[0],2) + ',' + strtrim(datac[1],2)
       widget_control, (*pstate).status, SET_VALUE = statusstr
    ENDIF
    IF (plot_info.mz_cursor_active EQ 0) THEN BEGIN
       ; Test if we want to zoom.   This is if button one is pressed.
            IF (event.press EQ 1 AND Window_Flag EQ 1 AND plot_info.data_file NE '') THEN BEGIN
         ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               plot_info.x1 = datac[0]
               plot_info.y2 = datac[1]
         IF (plot_info.down EQ 0) THEN BEGIN
          plot_info.sx = strtrim(datac[0],2)
          plot_info.sy = strtrim(datac[1],2)
          plot_info.dx = strtrim(datac[0],2)
          plot_info.dy = strtrim(datac[1],2)
          plot_info.down = 1
         ENDIF ELSE BEGIN
          plot_info.dx = strtrim(datac[0],2)
          plot_info.dy = strtrim(datac[1],2)
         ENDELSE

         isDrag = 1
        ENDIF

       ; If button 1 is released.
            IF (event.release EQ 1 AND Window_Flag EQ 1 AND plot_info.data_file NE '') THEN BEGIN
         ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
         plot_info.dx = strtrim(datac[0],2)
               plot_info.dy = strtrim(datac[1],2)
               plot_info.x2 = datac[0]
               plot_info.y1 = datac[1]
         plot_info.down = 0

         isDrag = 0
                        plot_info.isZoomed = 1

         IF (plot_info.x1 GT plot_info.x2) THEN BEGIN
          plot_info.x2 = plot_info.x1
          plot_info.x1 = plot_info.dx
          plot_info.sx = plot_info.x1
          plot_info.dx = plot_info.x2
         ENDIF

         IF (plot_info.y1 GT plot_info.y2) THEN BEGIN
          plot_info.y2 = plot_info.y1
          plot_info.y1 = plot_info.sy
          plot_info.sy = plot_info.y1
          plot_info.dy = plot_info.y2
         ENDIF

         IF (plot_info.domain EQ 0) THEN BEGIN
                   plot_info.time_auto_scale_y = 0
                   plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   plot_info.freq_auto_scale_y = 0
                   plot_info.freq_auto_scale_x = 0
               ENDELSE
               plot_info.fft_recalc = 1

         IF (plot_info.domain EQ 0) THEN BEGIN
          undo_array[0,0]=plot_info.time_xmin
          undo_array[0,1]=plot_info.time_xmax
          undo_array[0,2]=plot_info.time_ymin
          undo_array[0,3]=plot_info.time_ymax
               ENDIF
         IF (plot_info.domain EQ 1) THEN BEGIN
          undo_array[0,0]=plot_info.freq_xmin
          undo_array[0,1]=plot_info.freq_xmax
          undo_array[0,2]=plot_info.freq_ymin
          undo_array[0,3]=plot_info.freq_ymax
         ENDIF

                        ;(*pstate).undo->push,undo_array

               IF (plot_info.domain EQ 0) AND (plot_info.x1 LT 0) THEN plot_info.x1 = 0
               IF (plot_info.domain EQ 0) AND $
         (plot_info.x2 GT(data_file_header.points/2-1)*data_file_header.dwell) $
         THEN plot_info.x2 = (data_file_header.points/2-1)*data_file_header.dwell

               IF (plot_info.domain EQ 0) THEN plot_info.time_xmin = plot_info.x1 $
         ELSE plot_info.freq_xmin = plot_info.x1
               IF (plot_info.domain EQ 0) THEN plot_info.time_xmax = plot_info.x2 $
         ELSE plot_info.freq_xmax = plot_info.x2
               IF (plot_info.domain EQ 0) THEN plot_info.time_ymin = plot_info.y1 $
         ELSE plot_info.freq_ymin = plot_info.y1
               IF (plot_info.domain EQ 0) THEN plot_info.time_ymax = plot_info.y2 $
         ELSE plot_info.freq_ymax = plot_info.y2

         IF ((plot_info.sx EQ plot_info.dx) OR $
              (plot_info.sy EQ plot_info.dy)) THEN RETURN

         WIDGET_CONTROL, X_MIN, SET_VALUE= plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE= plot_info.x2
               WIDGET_CONTROL, Y_MIN, SET_VALUE= plot_info.y1
               WIDGET_CONTROL, Y_MAX, SET_VALUE= plot_info.y2
               DISPLAY_DATA

       ENDIF
    ENDIF
        IF (plot_info.mz_cursor_active EQ 1) THEN BEGIN

       ; Perform same tests as before, but this time we check for the mulitple zoom.
          IF (event.press EQ 1) AND (plot_info.mz_cursor_active EQ 1) THEN BEGIN
           ; Convert the coordinates from the device to data, give it to all three windows.
           datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
           plot_info.x1 = datac[0]
           middle_plot_info.x1 = datac[0]
           bottom_plot_info.x1 = datac[0]
       plot_info.y2 = datac[1]
           middle_plot_info.y2 = datac[1]
           bottom_plot_info.y2 = datac[1]

                        plot_info.sx = strtrim(datac[0],2)
         plot_info.sy = strtrim(datac[1],2)
                        middle_plot_info.sx = strtrim(datac[0],2)
         middle_plot_info.sy = strtrim(datac[1],2)
                        bottom_plot_info.sx = strtrim(datac[0],2)
         bottom_plot_info.sy = strtrim(datac[1],2)

           isDrag = 1
          ENDIF
          IF (event.release EQ 1) AND (plot_info.mz_cursor_active EQ 1) THEN BEGIN
           datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               plot_info.x2 = datac[0]
               middle_plot_info.x2 = datac[0]
               bottom_plot_info.x2 = datac[0]
               plot_info.y1 = datac[1]
               middle_plot_info.y1 = datac[1]
               bottom_plot_info.y1 = datac[1]

               isDrag = 0
                        plot_info.isZoomed = 1
                        middle_plot_info.isZoomed = 1
                        bottom_plot_info.isZoomed = 1

         IF (plot_info.domain EQ 0) THEN BEGIN
          undo_array[0,0]=plot_info.time_xmin
          undo_array[0,1]=plot_info.time_xmax
          undo_array[0,2]=plot_info.time_ymin
          undo_array[0,3]=plot_info.time_ymax
          undo_array[1,0]=middle_plot_info.time_xmin
          undo_array[1,1]=middle_plot_info.time_xmax
          undo_array[1,2]=middle_plot_info.time_ymin
          undo_array[1,3]=middle_plot_info.time_ymax
          undo_array[2,0]=bottom_plot_info.time_xmin
          undo_array[2,1]=bottom_plot_info.time_xmax
          undo_array[2,2]=bottom_plot_info.time_ymin
          undo_array[2,3]=bottom_plot_info.time_ymax
               ENDIF
         IF (plot_info.domain EQ 1) THEN BEGIN
          undo_array[0,0]=plot_info.freq_xmin
          undo_array[0,1]=plot_info.freq_xmax
          undo_array[0,2]=plot_info.freq_ymin
          undo_array[0,3]=plot_info.freq_ymax
          undo_array[1,0]=middle_plot_info.freq_xmin
          undo_array[1,1]=middle_plot_info.freq_xmax
          undo_array[1,2]=middle_plot_info.freq_ymin
          undo_array[1,3]=middle_plot_info.freq_ymax
          undo_array[2,0]=bottom_plot_info.freq_xmin
          undo_array[2,1]=bottom_plot_info.freq_xmax
          undo_array[2,2]=bottom_plot_info.freq_ymin
          undo_array[2,3]=bottom_plot_info.freq_ymax
         ENDIF

                    ;(*pstate).undo->push,undo_array

           DO_MULTI_ZOOM

             Window_Flag = 1
         WSET, DRAW1_Id

         WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.x2
               WIDGET_CONTROL, Y_MIN, SET_VALUE = plot_info.y1
               WIDGET_CONTROL, Y_MAX, SET_VALUE = plot_info.y2
         ENDIF
    ENDIF

    mouseDrag,event,plot_info,plot_color,/TOP
END

;=======================================================================================================;
; Name:  MOUSE_EV2                                                                                      
; Purpose:  The procedure MOUSE_EV2 is called when we are on the draw widget DRAW2 and we notice a mouse
;        event.   It takes one parameter, like all event driven procedures, called event.   This    
;        procedure is responsible for gathering data about the points that are needed for use with  
;            redrawing the zoom area (if active_cursor is set) and just general housekeeping of mouse   
;        movement/button clicking in regards to the WIDGET_DRAW for the graph.                
; Parameters:  Event - The event that caused this procedure to be called.                               
; Return:   None.                                                                                       
;=======================================================================================================;
PRO MOUSE_EV2, event
        COMMON common_vars
        COMMON common_widgets
        COMMON Draw1_Comm

        WIDGET_CONTROL, event.top, GET_UVALUE = pstate

    IF (event.press EQ 4) THEN BEGIN
            ;print, middle_plot_info.fft_final
       Window_flag = 2
       WSET, Draw2_Id

          ; Set non-needed menus off/needed menus on
       WIDGET_CONTROL, button2, SENSITIVE=1
          WIDGET_CONTROL, button3, SENSITIVE=1
          WIDGET_CONTROL, button4, SENSITIVE=1
          WIDGET_CONTROL, menu4, SENSITIVE=1
          WIDGET_CONTROL, menu5, SENSITIVE=1
          if(middle_plot_info.guess_file ne '') then begin
          WIDGET_CONTROL, reload_guess_button, SENSITIVE=1
       endif
       if(middle_plot_info.const_file ne '') then begin
          WIDGET_CONTROL, reload_const_button, SENSITIVE=1
       endif
       WIDGET_CONTROL, fit_button, SENSITIVE=1

       IF (middle_plot_info.const_file EQ '') THEN BEGIN
            WIDGET_CONTROL, button15, SENSITIVE=0
       ENDIF ELSE BEGIN
         WIDGET_CONTROL, button15, SENSITIVE=1
       ENDELSE

       if(middle_plot_info.data_file EQ '') then begin
          setComponents,/DISABLE
       endif else begin
          setComponents,/ENABLE
       endelse

       IF (middle_plot_info.domain EQ 0) THEN BEGIN
         WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.time_xmin
         WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.time_xmax
           WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.time_ymax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * middle_plot_info.time_ymin
           WIDGET_CONTROL, INITIAL, SET_VALUE = middle_plot_info.fft_initial
           WIDGET_CONTROL, FINAL, SET_VALUE = middle_plot_info.fft_final

          ENDIF ELSE BEGIN
         WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.freq_xmin
         WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.freq_xmax
           WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.freq_ymax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * middle_plot_info.freq_ymin
           WIDGET_CONTROL, INITIAL, SET_VALUE = middle_plot_info.fft_initial
           WIDGET_CONTROL, FINAL, SET_VALUE = middle_plot_info.fft_final
       ENDELSE

                if(middle_plot_info.fft_final eq 0) then begin
          middle_plot_info.fft_final = float(middle_data_file_header.points/2 * $
                                       middle_data_file_header.dwell)
                endif
          WIDGET_CONTROL, FINAL, SET_VALUE = middle_plot_info.fft_final
       WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
       WIDGET_CONTROL, EXPON_FILTER, SET_VALUE = middle_plot_info.expon_filter
       WIDGET_CONTROL, GAUSS_FILTER, SET_VALUE = middle_plot_info.gauss_filter
    ENDIF

        ; Convert the coordinates from device to data
        IF (Window_Flag EQ 2) THEN BEGIN
       datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
            statusstr = strtrim(datac[0],2) + ',' + strtrim(datac[1],2)
            widget_control, (*pstate).status, SET_VALUE = statusstr
    ENDIF

    IF (event.press EQ 2) THEN BEGIN
       ; Convert the coordinates from device to data
       datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
       middle_plot_info.sx = STRTRIM(datac[0],2)
       middle_plot_info.sy = STRTRIM(datac[1],2)

    ENDIF
    IF (event.release EQ 2) THEN BEGIN
            print,'release'
       ; Convert the coordinates from device to data
            datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
       middle_plot_info.dx = STRTRIM(datac[0],2)
            middle_plot_info.dy = STRTRIM(datac[1],2)

       ; Determine which difference is greater, the horizontal component, or the
       ; vertical one.  This determines which way to scale.
       IF (middle_plot_info.domain EQ 0) THEN BEGIN
         norm_x = (ABS(middle_plot_info.sx - middle_plot_info.dx))/middle_plot_info.time_xmax
         norm_y = (ABS(middle_plot_info.sy - middle_plot_info.dy))/middle_plot_info.time_ymax
         IF ( norm_y GT norm_x) THEN BEGIN
          Scale_Flag = 0
         ENDIF ELSE BEGIN
          Scale_Flag =1
         ENDELSE
       ENDIF ELSE BEGIN
         norm_x = (ABS(middle_plot_info.sx - middle_plot_info.dx))/middle_plot_info.freq_xmax
         norm_y = (ABS(middle_plot_info.sy - middle_plot_info.dy))/middle_plot_info.freq_ymax
         IF ( norm_y GT norm_x) THEN BEGIN
          Scale_Flag = 0
         ENDIF ELSE BEGIN
          Scale_Flag =1
         ENDELSE
       ENDELSE
       ;print, norm_y, norm_x, Scale_Flag
       IF (Scale_Flag EQ 0) THEN BEGIN
         WIDGET_CONTROL, Y_MAX, GET_VALUE=ymax
         WIDGET_CONTROL, Y_MIN, GET_VALUE=ymin

         IF (middle_plot_info.sy GT ymax) THEN middle_plot_info.sy = ymax
         IF (middle_plot_info.sy LT ymin) THEN middle_plot_info.sy = ymin
         IF (middle_plot_info.dy GT ymax) THEN middle_plot_info.dy = ymax
         IF (middle_plot_info.dy LT ymin) THEN middle_plot_info.dy = ymin

         ScaleFactor = ABS(middle_plot_info.sy) - ABS(middle_plot_info.dy)

         ;Normalize, get percent to zoom in by.
         ScaleFactor = ABS(ScaleFactor / (ymax-ymin))
         IF (ScaleFactor GT 1) THEN ScaleFactor =1

         ; We have upward movement, we know they want to scale "inward"
         IF (middle_plot_info.dy GT middle_plot_info.sy) THEN BEGIN
          ScaleFactor = 1 + ScaleFactor
          WIDGET_CONTROL, Y_MAX, SET_VALUE=ymax*ScaleFactor
          PRINT, "scale up - middle window"
         ENDIF

         ; Otherwise we have downward movement.
         IF (middle_plot_info.dy LT middle_plot_info.sy) THEN BEGIN
          ScaleFactor = 1 - ScaleFactor
          WIDGET_CONTROL, Y_MAX, SET_VALUE=ymax
          print, "scale downward - middle window"
         ENDIF

         ; Get backup info for undo.
         IF (middle_plot_info.domain EQ 0) THEN BEGIN
          undo_array[1,0]=middle_plot_info.time_xmin
          undo_array[1,1]=middle_plot_info.time_xmax
          undo_array[1,2]=middle_plot_info.time_ymin
          undo_array[1,3]=middle_plot_info.time_ymax
               ENDIF
         IF (middle_plot_info.domain EQ 1) THEN BEGIN
          undo_array[1,0]=middle_plot_info.freq_xmin
          undo_array[1,1]=middle_plot_info.freq_xmax
          undo_array[1,2]=middle_plot_info.freq_ymin
          undo_array[1,3]=middle_plot_info.freq_ymax
         ENDIF

               IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_ymax = ymax*ScaleFactor $
         ELSE middle_plot_info.freq_ymax = ymax*ScaleFactor

         IF (middle_plot_info.domain EQ 0) THEN BEGIN
                   middle_plot_info.time_auto_scale_y = 0
                   middle_plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   middle_plot_info.freq_auto_scale_y = 0
                   middle_plot_info.freq_auto_scale_x = 0
               ENDELSE
               middle_plot_info.fft_recalc = 1

         middle_DISPLAY_DATA
       ENDIF ELSE BEGIN
         WIDGET_CONTROL, X_MAX, GET_VALUE=xmax
         WIDGET_CONTROL, X_MIN, GET_VALUE=xmin

         IF (middle_plot_info.sx GT xmax) THEN middle_plot_info.sx = xmax
         IF (middle_plot_info.sx LT xmin) THEN middle_plot_info.sx = xmin
         IF (middle_plot_info.dx GT xmax) THEN middle_plot_info.dx = xmax
         IF (middle_plot_info.dx LT xmin) THEN middle_plot_info.dx = xmin

         ScaleFactor = ABS(middle_plot_info.sx) - ABS(middle_plot_info.dx)

         ;Normalize, get percent to zoom in by.
         ScaleFactor = ABS(ScaleFactor / (xmax-xmin))
         IF (ScaleFactor GT 1) THEN ScaleFactor =1

         ; We have outward movement, we know they want to scale out
         IF (middle_plot_info.dx GT middle_plot_info.sx) THEN BEGIN
          ;PRINT, "In here"
          ScaleFactor = 1 + ScaleFactor
          IF(o_xmax2 LE xmax*ScaleFactor) THEN BEGIN
              ;Print, "test", o_xmax, xmax*ScaleFactor
              if (middle_plot_info.domain EQ 0) THEN RETURN

          ENDIF
          WIDGET_CONTROL, X_MAX, SET_VALUE=xmax*ScaleFactor
         ENDIF

         ; Otherwise we have to scale inwards.
         IF (middle_plot_info.dx LT middle_plot_info.sx) THEN BEGIN
          ScaleFactor = 1 - ScaleFactor
          WIDGET_CONTROL, X_MAX, SET_VALUE=xmax*ScaleFactor
         ENDIF

         ; Get backup info for undo.
         IF (middle_plot_info.domain EQ 0) THEN BEGIN
          undo_array[1,0]=middle_plot_info.time_xmin
          undo_array[1,1]=middle_plot_info.time_xmax
          undo_array[1,2]=middle_plot_info.time_ymin
          undo_array[1,3]=middle_plot_info.time_ymax
               ENDIF
         IF (middle_plot_info.domain EQ 1) THEN BEGIN
          undo_array[1,0]=middle_plot_info.freq_xmin
          undo_array[1,1]=middle_plot_info.freq_xmax
          undo_array[1,2]=middle_plot_info.freq_ymin
          undo_array[1,3]=middle_plot_info.freq_ymax
         ENDIF

               IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_xmax = xmax*ScaleFactor $
         ELSE middle_plot_info.freq_xmax = xmax*ScaleFactor

         IF (middle_plot_info.domain EQ 0) THEN BEGIN
                   middle_plot_info.time_auto_scale_y = 0
                   middle_plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   middle_plot_info.freq_auto_scale_y = 0
                   middle_plot_info.freq_auto_scale_x = 0
               ENDELSE
               middle_plot_info.fft_recalc = 1

         middle_DISPLAY_DATA

       ENDELSE
    ENDIF


    ; Check to make sure Multi-Zoom(tm) isn't turned on.
    IF (middle_plot_info.mz_cursor_active EQ 0 ) THEN BEGIN
       ; Test for button movement and zoom button turned on.
          IF (event.press EQ 1 AND Window_Flag EQ 2 AND middle_plot_info.data_file NE '') THEN BEGIN
            ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               middle_plot_info.x1 = datac[0]
               middle_plot_info.y2 = datac[1]
         middle_plot_info.sx = strtrim(datac[0],2)
         middle_plot_info.sy = strtrim(datac[1],2)

         isDrag = 1
      ENDIF

       ; Test if button is being released and zoom button turned on.
          IF (event.release EQ 1 AND Window_Flag EQ 2 AND middle_plot_info.data_file NE '') THEN BEGIN
               ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               middle_plot_info.x2 = datac[0]
               middle_plot_info.y1 = datac[1]
         middle_plot_info.dx = strtrim(datac[0],2)
               middle_plot_info.dy = strtrim(datac[1],2)

                        isDrag = 0
                        middle_plot_info.isZoomed = 1

         IF (middle_plot_info.x1 GT middle_plot_info.x2) THEN BEGIN
          middle_plot_info.x2 = middle_plot_info.x1
          middle_plot_info.x1 = middle_plot_info.dx
          middle_plot_info.sx = middle_plot_info.x1
          middle_plot_info.dx = middle_plot_info.x2
         ENDIF
         IF (middle_plot_info.y1 GT middle_plot_info.y2) THEN BEGIN
          middle_plot_info.y2 = middle_plot_info.y1
          middle_plot_info.y1 = middle_plot_info.sy
          middle_plot_info.sy = middle_plot_info.y1
          middle_plot_info.dy = middle_plot_info.y2
         ENDIF
               IF (middle_plot_info.domain EQ 0) THEN BEGIN
                   middle_plot_info.time_auto_scale_y = 0
                   middle_plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   middle_plot_info.freq_auto_scale_y = 0
                   middle_plot_info.freq_auto_scale_x = 0
               ENDELSE

         IF (middle_plot_info.domain EQ 0) THEN BEGIN
          undo_array[1,0]=middle_plot_info.time_xmin
          undo_array[1,1]=middle_plot_info.time_xmax
          undo_array[1,2]=middle_plot_info.time_ymin
          undo_array[1,3]=middle_plot_info.time_ymax
               ENDIF
         IF (middle_plot_info.domain EQ 1) THEN BEGIN
          undo_array[1,0]=middle_plot_info.freq_xmin
          undo_array[1,1]=middle_plot_info.freq_xmax
          undo_array[1,2]=middle_plot_info.freq_ymin
          undo_array[1,3]=middle_plot_info.freq_ymax
         ENDIF

         ;(*pstate).undo->push,undo_array
         ;print,'pushing array'

               middle_plot_info.fft_recalc = 1

           IF (middle_plot_info.domain EQ 0) AND (middle_plot_info.x1 LT 0) THEN $
          middle_plot_info.x1 = 0
               IF ((middle_plot_info.domain EQ 0) AND $
          (middle_plot_info.x2 GT (middle_data_file_header.points/2-1)* $
          middle_data_file_header.dwell)) THEN $
         middle_plot_info.x2 = $
          (middle_data_file_header.points/2-1)*middle_data_file_header.dwell

               IF (middle_plot_info.domain EQ 0) THEN $
          middle_plot_info.time_xmin = middle_plot_info.x1 ELSE $
          middle_plot_info.freq_xmin = middle_plot_info.x1
               IF (middle_plot_info.domain EQ 0) THEN $
          middle_plot_info.time_xmax = middle_plot_info.x2 ELSE $
          middle_plot_info.freq_xmax = middle_plot_info.x2
               IF (middle_plot_info.domain EQ 0) THEN $
          middle_plot_info.time_ymin = middle_plot_info.y1 ELSE $
          middle_plot_info.freq_ymin = middle_plot_info.y1
               IF (middle_plot_info.domain EQ 0) THEN $
          middle_plot_info.time_ymax = middle_plot_info.y2 ELSE $
          middle_plot_info.freq_ymax = middle_plot_info.y2

         IF ((middle_plot_info.sx EQ middle_plot_info.dx) OR $
          (middle_plot_info.sy EQ middle_plot_info.dy)) THEN RETURN

               WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.x2
               WIDGET_CONTROL, Y_MIN, SET_VALUE = middle_plot_info.y1
               WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.y2

               MIDDLE_DISPLAY_DATA
          ENDIF
        ENDIF
    IF (middle_plot_info.mz_cursor_active EQ 1) THEN BEGIN

       ; Perform same tests as above, but for the multiple zoom this time.
          IF (event.press EQ 1) AND (middle_plot_info.mz_cursor_active EQ 1) THEN BEGIN

       ; Convert the coordinates from the device to data, give it to all three windows.
           datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
           plot_info.x1 = datac[0]
           middle_plot_info.x1 = datac[0]
           bottom_plot_info.x1 = datac[0]
         plot_info.y2 = datac[1]
           middle_plot_info.y2 = datac[1]
           bottom_plot_info.y2 = datac[1]

                        plot_info.sx = strtrim(datac[0],2)
         plot_info.sy = strtrim(datac[1],2)
                        middle_plot_info.sx = strtrim(datac[0],2)
         middle_plot_info.sy = strtrim(datac[1],2)
                        bottom_plot_info.sx = strtrim(datac[0],2)
         bottom_plot_info.sy = strtrim(datac[1],2)

           isDrag = 1

          ENDIF

       ; When the button is released.
          IF (event.release EQ 1) AND (middle_plot_info.mz_cursor_active EQ 1) THEN BEGIN
           datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               plot_info.x2 = datac[0]
               middle_plot_info.x2 = datac[0]
               bottom_plot_info.x2 = datac[0]
               plot_info.y1 = datac[1]
               middle_plot_info.y1 = datac[1]
               bottom_plot_info.y1 = datac[1]

               isDrag = 0
                        plot_info.isZoomed = 1
                        middle_plot_info.isZoomed = 1
                        bottom_plot_info.isZoomed = 1

         IF (middle_plot_info.domain EQ 0) THEN BEGIN
          undo_array[0,0]=plot_info.time_xmin
          undo_array[0,1]=plot_info.time_xmax
          undo_array[0,2]=plot_info.time_ymin
          undo_array[0,3]=plot_info.time_ymax
          undo_array[1,0]=middle_plot_info.time_xmin
          undo_array[1,1]=middle_plot_info.time_xmax
          undo_array[1,2]=middle_plot_info.time_ymin
          undo_array[1,3]=middle_plot_info.time_ymax
          undo_array[2,0]=bottom_plot_info.time_xmin
          undo_array[2,1]=bottom_plot_info.time_xmax
          undo_array[2,2]=bottom_plot_info.time_ymin
          undo_array[2,3]=bottom_plot_info.time_ymax
               ENDIF
         IF (middle_plot_info.domain EQ 1) THEN BEGIN
          undo_array[0,0]=plot_info.freq_xmin
          undo_array[0,1]=plot_info.freq_xmax
          undo_array[0,2]=plot_info.freq_ymin
          undo_array[0,3]=plot_info.freq_ymax
          undo_array[1,0]=middle_plot_info.freq_xmin
          undo_array[1,1]=middle_plot_info.freq_xmax
          undo_array[1,2]=middle_plot_info.freq_ymin
          undo_array[1,3]=middle_plot_info.freq_ymax
          undo_array[2,0]=bottom_plot_info.freq_xmin
          undo_array[2,1]=bottom_plot_info.freq_xmax
          undo_array[2,2]=bottom_plot_info.freq_ymin
          undo_array[2,3]=bottom_plot_info.freq_ymax
               ENDIF

               ;(*pstate).undo->push,undo_array

           DO_MULTI_ZOOM

         Window_Flag = 2
         WSET, DRAW2_Id

         WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.x2
               WIDGET_CONTROL, Y_MIN, SET_VALUE = middle_plot_info.y1
               WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.y2
         ENDIF
    ENDIF
    noResize = 1
    mouseDrag,event,middle_plot_info,middle_plot_color,/MIDDLE
    noResize = 0
END

pro mouseDrag,event,p_info,p_color,TOP=t,MIDDLE=m,BOTTOM=b
   COMMON draw1_comm

   if(isDrag) then begin
       datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
           dx = strtrim(datac[0],2)
           dy = strtrim(datac[1],2)

           sx = p_info.sx
           sy = p_info.sy

           if(keyword_set(m)) then begin
             MIDDLE_DISPLAY_DATA
           endif else if(keyword_set(t)) then begin
             DISPLAY_DATA
           endif else if(keyword_set(b)) then begin
             BOTTOM_DISPLAY_DATA
           endif

       oplot,[sx,dx],[sy,sy],COLOR=2,THICK=p_color[0].thick
       oplot,[sx,dx],[dy,dy],COLOR=2,THICK=p_color[0].thick
       oplot,[dx,dx],[dy,sy],COLOR=2,THICK=p_color[0].thick
       oplot,[sx,sx],[dy,sy],COLOR=2,THICK=p_color[0].thick
   endif

end

;=======================================================================================================;
; Name:  MOUSE_EV3                                                                                      ;
; Purpose:  The procedure MOUSE_EV3 is called when we are on the draw widget DRAW2 and we notice a mouse;
;        event.   It takes one parameter, like all event driven procedures, called event.     ;
;        This procedure is responsible for gathering data about the points that are needed for use    ;
;        with redrawing the zoom area (if active_cursor is set) and just general housekeeping of    ;
;        mouse movement/button clicking in regards to the WIDGET_DRAW for the graph.                ;
; Parameters:  Event - The event that caused this procedure to be called.                               ;
; Return:   None.                                                                                       ;
;=======================================================================================================;
PRO MOUSE_EV3, event
        COMMON common_vars
        COMMON common_widgets
        COMMON Draw1_Comm

        WIDGET_CONTROL, event.top, GET_UVALUE = pstate

    IF (event.press EQ 4) THEN BEGIN
          window_flag =3
          WSET, Draw3_Id

            ; Set non needed menus off
       WIDGET_CONTROL, fit_button, SENSITIVE=0
          WIDGET_CONTROL, button2, SENSITIVE=0
          WIDGET_CONTROL, button3, SENSITIVE=0
          WIDGET_CONTROL, button4, SENSITIVE=0
            WIDGET_CONTROL, menu4, SENSITIVE=0
          WIDGET_CONTROL, menu5, SENSITIVE=0
       WIDGET_CONTROL, reload_guess_button, SENSITIVE=0
       WIDGET_CONTROL, reload_const_button, SENSITIVE=0

            if(bottom_plot_info.data_file EQ '') then begin
          setComponents,/DISABLE
       endif else begin
          setComponents,/ENABLE
       endelse

       IF (middle_plot_info.domain EQ 0) THEN BEGIN
         WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
         WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
           WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
          ENDIF ELSE BEGIN
         WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.freq_xmin
         WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.freq_xmax
           WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.freq_ymax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.freq_ymin
       ENDELSE

       WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial

                if(bottom_plot_info.fft_final eq 0) then begin
                          bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * bottom_data_file_header.dwell)
                endif

                WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
       WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = bottom_plot_info.phase
       WIDGET_CONTROL, EXPON_FILTER, SET_VALUE = bottom_plot_info.expon_filter
       WIDGET_CONTROL, GAUSS_FILTER, SET_VALUE = bottom_plot_info.gauss_filter

    ENDIF

        IF (Window_Flag EQ 3) THEN BEGIN
            ; Convert the coordinates from device to data
            datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
            statusstr = strtrim(datac[0],2) + ',' + strtrim(datac[1],2)
            widget_control, (*pstate).status, SET_VALUE = statusstr

        ENDIF

    IF (event.press EQ 2) THEN BEGIN
       ; Convert the coordinates from device to data
       datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
       bottom_plot_info.sx = STRTRIM(datac[0],2)
       bottom_plot_info.sy = STRTRIM(datac[1],2)
    ENDIF
    IF (event.release EQ 2) THEN BEGIN

       ; Convert the coordinates from device to data
            datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
       bottom_plot_info.dx = STRTRIM(datac[0],2)
            bottom_plot_info.dy = STRTRIM(datac[1],2)

       ; Determine which difference is greater, the horizontal component, or the
       ; vertical one.  This determines which way to scale.
       IF (bottom_plot_info.domain EQ 0) THEN BEGIN
         norm_x = (ABS(bottom_plot_info.sx - bottom_plot_info.dx))/bottom_plot_info.time_xmax
         norm_y = (ABS(bottom_plot_info.sy - bottom_plot_info.dy))/bottom_plot_info.time_ymax
         IF ( norm_y GT norm_x) THEN BEGIN
          Scale_Flag = 0
         ENDIF ELSE BEGIN
          Scale_Flag =1
         ENDELSE
       ENDIF ELSE BEGIN
         norm_x = (ABS(bottom_plot_info.sx - bottom_plot_info.dx))/bottom_plot_info.freq_xmax
         norm_y = (ABS(bottom_plot_info.sy - bottom_plot_info.dy))/bottom_plot_info.freq_ymax
         IF ( norm_y GT norm_x) THEN BEGIN
          Scale_Flag = 0
         ENDIF ELSE BEGIN
          Scale_Flag =1
         ENDELSE
       ENDELSE

       ; Determine which difference is greater, the horizontal component, or the
       ; vertical one.  This determines which way to scale.
       IF (Scale_Flag EQ 0) THEN BEGIN
         WIDGET_CONTROL, Y_MAX, GET_VALUE=ymax
         WIDGET_CONTROL, Y_MIN, GET_VALUE=ymin

         IF (bottom_plot_info.sy GT ymax) THEN bottom_plot_info.sy = ymax
         IF (bottom_plot_info.sy LT ymin) THEN bottom_plot_info.sy = ymin
         IF (bottom_plot_info.dy GT ymax) THEN bottom_plot_info.dy = ymax
         IF (bottom_plot_info.dy LT ymin) THEN bottom_plot_info.dy = ymin

         ScaleFactor = ABS(bottom_plot_info.sy) - ABS(bottom_plot_info.dy)

         ;Normalize, get percent to zoom in by.
         ScaleFactor = ABS(ScaleFactor / (ymax-ymin))
         IF (ScaleFactor GT 1) THEN ScaleFactor =1

         ; We have upward movement, we know they want to scale "inward"
         IF (bottom_plot_info.dy GT bottom_plot_info.sy) THEN BEGIN
          ScaleFactor = 1 + ScaleFactor
          WIDGET_CONTROL, Y_MAX, SET_VALUE=ymax*ScaleFactor
          PRINT, "scale up - middle window"
         ENDIF

         ; Otherwise we have downward movement.
         IF (bottom_plot_info.dy LT bottom_plot_info.sy) THEN BEGIN
          ScaleFactor = 1 - ScaleFactor
          WIDGET_CONTROL, Y_MAX, SET_VALUE=ymax
          print, "scale downward - middle window"
         ENDIF

         ; Get backup info for undo.
         IF (bottom_plot_info.domain EQ 0) THEN BEGIN
          undo_array[1,0]=bottom_plot_info.time_xmin
          undo_array[1,1]=bottom_plot_info.time_xmax
          undo_array[1,2]=bottom_plot_info.time_ymin
          undo_array[1,3]=bottom_plot_info.time_ymax
               ENDIF
         IF (bottom_plot_info.domain EQ 1) THEN BEGIN
          undo_array[1,0]=bottom_plot_info.freq_xmin
          undo_array[1,1]=bottom_plot_info.freq_xmax
          undo_array[1,2]=bottom_plot_info.freq_ymin
          undo_array[1,3]=bottom_plot_info.freq_ymax
         ENDIF

               IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_ymax = ymax*ScaleFactor $
         ELSE bottom_plot_info.freq_ymax = ymax*ScaleFactor

         IF (bottom_plot_info.domain EQ 0) THEN BEGIN
                   bottom_plot_info.time_auto_scale_y = 0
                   bottom_plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   bottom_plot_info.freq_auto_scale_y = 0
                   bottom_plot_info.freq_auto_scale_x = 0
               ENDELSE
               bottom_plot_info.fft_recalc = 1

         bottom_DISPLAY_DATA
       ENDIF ELSE BEGIN
         WIDGET_CONTROL, X_MAX, GET_VALUE=xmax
         WIDGET_CONTROL, X_MIN, GET_VALUE=xmin

         IF (bottom_plot_info.sx GT xmax) THEN bottom_plot_info.sx = xmax
         IF (bottom_plot_info.sx LT xmin) THEN bottom_plot_info.sx = xmin
         IF (bottom_plot_info.dx GT xmax) THEN bottom_plot_info.dx = xmax
         IF (bottom_plot_info.dx LT xmin) THEN bottom_plot_info.dx = xmin

         ScaleFactor = ABS(bottom_plot_info.sx) - ABS(bottom_plot_info.dx)

         ;Normalize, get percent to zoom in by.
         ScaleFactor = ABS(ScaleFactor / (xmax-xmin))
         IF (ScaleFactor GT 1) THEN ScaleFactor =1

         ; We have outward movement, we know they want to scale out
         IF (bottom_plot_info.dx GT bottom_plot_info.sx) THEN BEGIN
          ;PRINT, "In here"
          ScaleFactor = 1 + ScaleFactor
          IF(o_xmax3 LE xmax*ScaleFactor) THEN BEGIN
              ;Print, "test", o_xmax, xmax*ScaleFactor
              if (bottom_plot_info.domain EQ 0) THEN RETURN

          ENDIF
          WIDGET_CONTROL, X_MAX, SET_VALUE=xmax*ScaleFactor
         ENDIF

         ; Otherwise we have to scale inwards.
         IF (bottom_plot_info.dx LT bottom_plot_info.sx) THEN BEGIN
          ScaleFactor = 1 - ScaleFactor
          WIDGET_CONTROL, X_MAX, SET_VALUE=xmax*ScaleFactor
         ENDIF

         ; Get backup info for undo.
         IF (bottom_plot_info.domain EQ 0) THEN BEGIN
          undo_array[2,0]=bottom_plot_info.time_xmin
          undo_array[2,1]=bottom_plot_info.time_xmax
          undo_array[2,2]=bottom_plot_info.time_ymin
          undo_array[2,3]=bottom_plot_info.time_ymax
               ENDIF

         IF (bottom_plot_info.domain EQ 1) THEN BEGIN
          undo_array[2,0]=bottom_plot_info.freq_xmin
          undo_array[2,1]=bottom_plot_info.freq_xmax
          undo_array[2,2]=bottom_plot_info.freq_ymin
          undo_array[2,3]=bottom_plot_info.freq_ymax
         ENDIF

               IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_xmax = xmax*ScaleFactor $
         ELSE bottom_plot_info.freq_xmax = xmax*ScaleFactor

         IF (bottom_plot_info.domain EQ 0) THEN BEGIN

                   bottom_plot_info.time_auto_scale_y = 0
                   bottom_plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   bottom_plot_info.freq_auto_scale_y = 0
                   bottom_plot_info.freq_auto_scale_x = 0
               ENDELSE
               bottom_plot_info.fft_recalc = 1

         bottom_DISPLAY_DATA
       ENDELSE
    ENDIF
    ; Check to make sure Multi-Zoom(tm) isn't on.
    IF (bottom_plot_info.mz_cursor_active EQ 0) THEN BEGIN

       ; Test for mouse release and the zoom button being on.
          IF (event.press EQ 1 AND Window_Flag EQ 3 AND bottom_plot_info.data_file NE '') THEN BEGIN
               ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               bottom_plot_info.x1 = datac[0]
               bottom_plot_info.y2 = datac[1]
         bottom_plot_info.sx = strtrim(datac[0],2)
         bottom_plot_info.sy = strtrim(datac[1],2)
         isDrag = 1
          ENDIF
       ; Test for button being pressed and zoom button being on.
          IF (event.release EQ 1 AND Window_Flag EQ 3 AND bottom_plot_info.data_file NE '') THEN BEGIN
               ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               bottom_plot_info.x2 = datac[0]
               bottom_plot_info.y1 = datac[1]
               bottom_plot_info.dx = strtrim(datac[0],2)
         bottom_plot_info.dy = strtrim(datac[1],2)

                        isDrag = 0
                        bottom_plot_info.isZoomed = 1

         IF (bottom_plot_info.domain EQ 0) THEN BEGIN
                   bottom_plot_info.time_auto_scale_y = 0
                   bottom_plot_info.time_auto_scale_x = 0
               ENDIF ELSE BEGIN
                   bottom_plot_info.freq_auto_scale_y = 0
                   bottom_plot_info.freq_auto_scale_x = 0
               ENDELSE

         IF (bottom_plot_info.x1 GT bottom_plot_info.x2) THEN BEGIN
          bottom_plot_info.x2 = bottom_plot_info.x1
          bottom_plot_info.x1 = bottom_plot_info.dx
          bottom_plot_info.sx = bottom_plot_info.x1
          bottom_plot_info.dx = bottom_plot_info.x2
         ENDIF
         IF (bottom_plot_info.y1 GT bottom_plot_info.y2) THEN BEGIN
          bottom_plot_info.y2 = bottom_plot_info.y1
          bottom_plot_info.y1 = bottom_plot_info.sy
          bottom_plot_info.sy = bottom_plot_info.y1
          bottom_plot_info.dy = bottom_plot_info.y2
         ENDIF
         IF (bottom_plot_info.domain EQ 0) THEN BEGIN
          undo_array[2,0]=bottom_plot_info.time_xmin
          undo_array[2,1]=bottom_plot_info.time_xmax
          undo_array[2,2]=bottom_plot_info.time_ymin
          undo_array[2,3]=bottom_plot_info.time_ymax
               ENDIF
         IF (bottom_plot_info.domain EQ 1) THEN BEGIN
          undo_array[2,0]=bottom_plot_info.freq_xmin
          undo_array[2,1]=bottom_plot_info.freq_xmax
          undo_array[2,2]=bottom_plot_info.freq_ymin
          undo_array[2,3]=bottom_plot_info.freq_ymax
         ENDIF

         ;(*pstate).undo->push,undo_array

               bottom_plot_info.fft_recalc = 1

               IF (bottom_plot_info.domain EQ 0) AND (bottom_plot_info.x1 LT 0) THEN $
          bottom_plot_info.x1 = 0
               IF (bottom_plot_info.domain EQ 0) AND (bottom_plot_info.x2 GT $
          (bottom_data_file_header.points/2-1)*bottom_data_file_header.dwell) THEN $
          bottom_plot_info.x2 = (bottom_data_file_header.points/2-1)* $
          bottom_data_file_header.dwell
         IF (bottom_plot_info.domain EQ 0) THEN $
          bottom_plot_info.time_xmin = bottom_plot_info.x1 ELSE $
          bottom_plot_info.freq_xmin = bottom_plot_info.x1
               IF (bottom_plot_info.domain EQ 0) THEN $
          bottom_plot_info.time_xmax = bottom_plot_info.x2 ELSE $
          bottom_plot_info.freq_xmax = bottom_plot_info.x2
               IF (bottom_plot_info.domain EQ 0) THEN $
          bottom_plot_info.time_ymin = bottom_plot_info.y1 ELSE $
          bottom_plot_info.freq_ymin = bottom_plot_info.y1
               IF (bottom_plot_info.domain EQ 0) THEN $
          bottom_plot_info.time_ymax = bottom_plot_info.y2 ELSE $
          bottom_plot_info.freq_ymax = bottom_plot_info.y2

         IF ((bottom_plot_info.sx EQ bottom_plot_info.dx) OR $
          (bottom_plot_info.sy EQ bottom_plot_info.dy)) THEN RETURN
               WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.x2
               WIDGET_CONTROL, Y_MIN, SET_VALUE = bottom_plot_info.y1
               WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.y2

               BOTTOM_DISPLAY_DATA
          ENDIF
    ENDIF
    IF ( bottom_plot_info.mz_cursor_active EQ 1) THEN BEGIN

          ;Perform same tests as above, but for multi-zoom this time.
          IF (event.press EQ 1) AND (bottom_plot_info.mz_cursor_active EQ 1) THEN BEGIN
           ; Convert the coordinates from the device to data, give it to all three windows.
           datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
           plot_info.x1 = datac[0]
           middle_plot_info.x1 = datac[0]
           bottom_plot_info.x1 = datac[0]
         plot_info.y2 = datac[1]
           middle_plot_info.y2 = datac[1]
           bottom_plot_info.y2 = datac[1]

                        plot_info.sx = strtrim(datac[0],2)
         plot_info.sy = strtrim(datac[1],2)
                        middle_plot_info.sx = strtrim(datac[0],2)
         middle_plot_info.sy = strtrim(datac[1],2)
                        bottom_plot_info.sx = strtrim(datac[0],2)
         bottom_plot_info.sy = strtrim(datac[1],2)

           isDrag = 1
          ENDIF
          IF (event.release EQ 1) AND (bottom_plot_info.mz_cursor_active EQ 1) THEN BEGIN
           datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               plot_info.x2 = datac[0]
               middle_plot_info.x2 = datac[0]
               bottom_plot_info.x2 = datac[0]
               plot_info.y1 = datac[1]
               middle_plot_info.y1 = datac[1]
               bottom_plot_info.y1 = datac[1]

               isDrag = 0
                        plot_info.isZoomed = 1
                        middle_plot_info.isZoomed = 1
                        bottom_plot_info.isZoomed = 1

         IF (bottom_plot_info.domain EQ 0) THEN BEGIN
          undo_array[0,0]=plot_info.time_xmin
          undo_array[0,1]=plot_info.time_xmax
          undo_array[0,2]=plot_info.time_ymin
          undo_array[0,3]=plot_info.time_ymax
          undo_array[1,0]=middle_plot_info.time_xmin
          undo_array[1,1]=middle_plot_info.time_xmax
          undo_array[1,2]=middle_plot_info.time_ymin
          undo_array[1,3]=middle_plot_info.time_ymax
          undo_array[2,0]=bottom_plot_info.time_xmin
          undo_array[2,1]=bottom_plot_info.time_xmax
          undo_array[2,2]=bottom_plot_info.time_ymin
          undo_array[2,3]=bottom_plot_info.time_ymax
               ENDIF
         IF (bottom_plot_info.domain EQ 1) THEN BEGIN
          undo_array[0,0]=plot_info.freq_xmin
          undo_array[0,1]=plot_info.freq_xmax
          undo_array[0,2]=plot_info.freq_ymin
          undo_array[0,3]=plot_info.freq_ymax
          undo_array[1,0]=middle_plot_info.freq_xmin
          undo_array[1,1]=middle_plot_info.freq_xmax
          undo_array[1,2]=middle_plot_info.freq_ymin
          undo_array[1,3]=middle_plot_info.freq_ymax
          undo_array[2,0]=bottom_plot_info.freq_xmin
          undo_array[2,1]=bottom_plot_info.freq_xmax
          undo_array[2,2]=bottom_plot_info.freq_ymin
          undo_array[2,3]=bottom_plot_info.freq_ymax
         ENDIF

                        ;(*pstate).undo->push,undo_array

           DO_MULTI_ZOOM

         Window_Flag = 3
         WSET, DRAW3_Id

         WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.x2
               WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.x1
               WIDGET_CONTROL, Y_MIN, SET_VALUE = bottom_plot_info.y1
               WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.y2
         ENDIF
    ENDIF

    mouseDrag,event,bottom_plot_info,bottom_plot_color,/BOTTOM

END

PRO EV_SCALE_HORZ, event
    COMMON common_vars
    Scale_Flag = 1
END

PRO EV_SCALE_VERT, event
    COMMON common_vars
    Scale_Flag = 0
END

;=======================================================================================================;
pro setComponents, ENABLE=on,DISABLE=off
   COMMON common_widgets

   compSet = 1

   IF(keyword_set(on) AND keyword_set(off)) then begin
      print, 'setComponents: ENABLE and DISABLE cannot be set at the same time'
      return
   endif else if(keyword_set(on) AND not(keyword_set(off))) then begin
     compSet = 1
   endif else if(not(keyword_set(on)) AND keyword_set(off)) then begin
     compSet = 0
   endif else begin
     print, 'setComponents: must set either /ENABLE XOR /DISABLE'
     return
   endelse

   WIDGET_CONTROL,statsMenu,SENSITIVE=compSet
   WIDGET_CONTROL,simulationMenu,SENSITIVE=compSet
   WIDGET_CONTROL,menu7,SENSITIVE=compSet
   WIDGET_CONTROL,menu5,SENSITIVE=compSet
   WIDGET_CONTROL,menu3,SENSITIVE=compSet
   WIDGET_CONTROL,menu4,SENSITIVE=compSet
   WIDGET_CONTROL,fit_button,SENSITIVE=compSet
   WIDGET_CONTROL,save_button,SENSITIVE=compSet
   WIDGET_CONTROL,imgSaveButton,SENSITIVE=compSet
   WIDGET_CONTROL,print_button,SENSITIVE=compSet
   WIDGET_CONTROL,fit_sub_button,SENSITIVE=compSet
   ;WIDGET_CONTROL,convert_button,SENSITIVE=compSet
   WIDGET_CONTROL,remove_button,SENSITIVE=compSet
   WIDGET_CONTROL,button4,SENSITIVE=compSet
   WIDGET_CONTROL,reload_output,SENSITIVE=compSet
end
