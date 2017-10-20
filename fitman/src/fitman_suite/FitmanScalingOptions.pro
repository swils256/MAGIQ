;=======================================================================================================
; Name:  FitmanScalingOptions.pro
; Description:   Contains all procedures/functions that deal with FitmanGUI's scaling and subtraction
;     features.
; Dependancies:  FitmanGui_sept2000.pro, Display.pro
;=======================================================================================================


;=======================================================================================================
; Name:  EV_SUBTRACT
; Purpose:  To Subtract the top and middle graphs to provide a graph in the third (bottom) window.
; Parameters:  Event - The event which called this procedure.
; Return:  None.
;=======================================================================================================

PRO EV_SUBTRACT, event
     scaleDialog,event,'EVSUBTRACT'
END

PRO scaleDialog,event, ev_proc
   dir_base = WIDGET_BASE(COL=2, MAP=1, TITLE="Scaling Factor", UVALUE='d_base')
   path_base =WIDGET_BASE(dir_base,COL=2, MAP=1)
   path_label = CW_FIELD(path_base, TITLE='Enter Scaling Factor: ', /FLOATING)
   ok_base = WIDGET_BASE(dir_base,COL = 2, MAP = 1, /BASE_ALIGN_CENTER)
   ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok', EVENT_PRO=ev_proc,UVALUE="blah")
   cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_DIR_CANCEL')


   state = { path_label:path_label}
   pstate = ptr_new(state, /NO_COPY)

   WIDGET_CONTROL, dir_base, SET_UVALUE=pstate
   WIDGET_CONTROL, dir_base, /REALIZE
   XMANAGER, 'foo', dir_base
END

PRO EVSUBTRACT, event
    COMMON common_vars
    COMMON common_widgets

        WIDGET_CONTROL, event.top, GET_UVALUE = pstate
        WIDGET_CONTROL,(*pstate).path_label,GET_VALUE=str_factor
        WIDGET_CONTROL, event.top, /DESTROY

        s_factor = FLOAT(str_factor)
        WIDGET_CONTROL, SCALING_SLIDER, SET_VALUE=s_factor

print, "inside subtract"
    ; Check to make sure that the data files actually have been read in. If not, give error.
    IF (NOT((plot_info.data_file EQ '') OR (middle_plot_info.data_file EQ ''))) THEN BEGIN
        ; Check to see what domain the first data set is in.

        IF (plot_info.domain EQ 0) THEN BEGIN
          ;TIME_SUBTRACT, s_factor, b_factor
          TIME_SUBTRACT, s_factor

       ENDIF ELSE BEGIN
         FREQ_SUBTRACT, s_factor
       ENDELSE
    ENDIF ELSE BEGIN
       ;ERROR_MESSAGE, $
       ;"Cannot subtract,data does not exist!   Pleast load data into both TOP and MIDDLE windows."
    err_result = DIALOG_MESSAGE('Cannot subtract...data does not exist!   Pleast load data into both TOP and MIDDLE windows.', $
                               Title = 'ERROR', /ERROR)
    ENDELSE
END

;=======================================================================================================
; Name:  EV_SUBTRACT
; Purpose:  To Subtract the top and middle graphs to provide a graph in the third (bottom) window.
; Parameters:  Event - The event which called this procedure.
; Return:  None.
;=======================================================================================================

PRO EV_ADD, event
    scaleDialog, event,'EVADD'
END

PRO EVADD, event
     COMMON common_vars
     COMMON common_widgets

     WIDGET_CONTROL, event.top, GET_UVALUE = pstate
     WIDGET_CONTROL,(*pstate).path_label,GET_VALUE=str_factor
     WIDGET_CONTROL, event.top, /DESTROY

     s_factor = FLOAT(str_factor)
     WIDGET_CONTROL, SCALING_SLIDER, SET_VALUE=s_factor

    ; Check to make sure that the data files actually have been read in. If not, give error.
     IF (NOT((plot_info.data_file EQ '') OR (middle_plot_info.data_file EQ ''))) THEN BEGIN
        ; Check to see what domain the first data set is in.

        IF (plot_info.domain EQ 0) THEN BEGIN
                   TIME_ADD, s_factor, b_factor

       ENDIF ELSE BEGIN
         FREQ_ADD, s_factor
       ENDELSE
     ENDIF ELSE BEGIN
       ;ERROR_MESSAGE, $
       ;"Cannot add,data does not exist!   Pleast load data into both TOP and MIDDLE windows."
    err_result = DIALOG_MESSAGE('Cannot add, data does not exist!   Pleast load data into both TOP and MIDDLE windows.', $
                               Title = 'ERROR', /ERROR)

     ENDELSE
END

;=======================================================================================================
; Name:  EV_ALIGN										        
; Purpose:  To (manually) align the middle graph with the top graph, so the spectra can be added       
; Parameters:  Event - The event which called this procedure.						
; Return:  None.											
;=======================================================================================================

PRO shiftDialog,event, ev_proc
   dir_base = WIDGET_BASE(COL=1, MAP=1, TITLE="Scaling/Shifting Factor", UVALUE='d_base')
   path_base =WIDGET_BASE(dir_base,COL=2, MAP=1)
   path_label = CW_FIELD(path_base, TITLE='Enter Scaling Factor:             ', /FLOATING)
   path_base2 =WIDGET_BASE(dir_base,row=2, MAP=1)
   path_label2 = CW_FIELD(path_base2, TITLE='Enter Shifting Factor (in hertz): ', /FLOATING)
   ok_base = WIDGET_BASE(dir_base,col = 3, MAP = 1, /BASE_ALIGN_CENTER)
   ok_button = WIDGET_BUTTON(ok_base, VALUE='Ok', EVENT_PRO=ev_proc,UVALUE="blah")
   cancel_button = WIDGET_BUTTON(ok_base, VALUE='Cancel', EVENT_PRO='EV_DIR_CANCEL')


   state = { path_label:path_label, path_label2:path_label2}
   pstate = ptr_new(state, /NO_COPY)

   WIDGET_CONTROL, dir_base, SET_UVALUE=pstate
   WIDGET_CONTROL, dir_base, /REALIZE
   XMANAGER, 'foo', dir_base
END

PRO EV_ALIGN, event
    shiftDialog, event,'EVALIGN' 
END

PRO EVALIGN, event
     COMMON common_vars
     COMMON common_widgets

     WIDGET_CONTROL, event.top, GET_UVALUE = pstate
     WIDGET_CONTROL,(*pstate).path_label,GET_VALUE=str_factor
     WIDGET_CONTROL, event.top, GET_UVALUE = pstate2
     WIDGET_CONTROL,(*pstate).path_label2,GET_VALUE=shft_factor
     WIDGET_CONTROL, event.top, /DESTROY

     w_factor = DOUBLE(shft_factor)
     s_factor = FLOAT(str_factor) 
     WIDGET_CONTROL, SCALING_SLIDER, SET_VALUE=s_factor
	
	; Check to make sure that the data files actually have been read in. If not, give error.
     IF (NOT((plot_info.data_file EQ '') OR (middle_plot_info.data_file EQ ''))) THEN BEGIN
		 ; Check to see what domain the first data set is in.
		 ; Can only align in Frequency domain.

		 IF (plot_info.domain EQ 0) THEN BEGIN
		 	ERROR_MESSAGE, $
			"Cannot align, currently in time domain!  Please switch to the frequency domain."

 	 	 ENDIF ELSE BEGIN
		 	FREQ_ALIGN, s_factor, w_factor
 		 ENDELSE		
     ENDIF ELSE BEGIN
		ERROR_MESSAGE, $
		"Cannot align, data does not exist!   Please load data into both TOP and MIDDLE windows."
     ENDELSE
END

;=======================================================================================================
; Name:  EV_ALIGN_AUTO											
; Purpose:  To (automatically) align the middle graph with the top graph, so the spectra can be added   
; Parameters:  Event - The event which called this procedure.						
; Return:  None.											
;=======================================================================================================

PRO EV_ALIGN_AUTO, event
    scaleDialog, event,'EVALIGN_AUTO' 
END

PRO EVALIGN_AUTO, event
     COMMON common_vars
     COMMON common_widgets

     WIDGET_CONTROL, event.top, GET_UVALUE = pstate
     WIDGET_CONTROL,(*pstate).path_label,GET_VALUE=str_factor
     WIDGET_CONTROL, event.top, /DESTROY
        
     s_factor = FLOAT(str_factor) 
     WIDGET_CONTROL, SCALING_SLIDER, SET_VALUE=s_factor
	
	; Check to make sure that the data files actually have been read in. If not, give error.
     IF (NOT((plot_info.data_file EQ '') OR (middle_plot_info.data_file EQ ''))) THEN BEGIN
		 ; Check to see what domain the first data set is in.
		 ; Can only align in Frequency domain.

		 IF (plot_info.domain EQ 0) THEN BEGIN
	               ERROR_MESSAGE, $
	               "Cannot align, currently in time domain!  Please switch to the frequency domain."

 	 	 ENDIF ELSE BEGIN
		 	FREQ_ALIGN_AUTO, s_factor
 		 ENDELSE		
     ENDIF ELSE BEGIN
		ERROR_MESSAGE, $
		"Cannot add, data does not exist!   Please load data into both TOP and MIDDLE windows."
     ENDELSE
END

;=======================================================================================================
; Name:  EV_CALC_ORIG_SCALING
; Purpose:  This procedure draws the window for the scaling operation that we wish to perform on a
;           graph loaded in the top window.    THis will set up the graph and all the buttons/fields and
;           give control to the event handler.
; Parameters:  Event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_CALC_ORIG_SCALING, event
        COMMON common_vars
        COMMON common_widgets
        COMMON scaling_widgets, s_max, s_min, previous_flag

    calc_SF_only = 1

    EV_SCALING, event

print, "BACK"

END

;=======================================================================================================
; Name:  EV_SUB_SAVED_SCALING
; Purpose:  This procedure draws the window for the scaling operation that we wish to perform on a
;           graph loaded in the top window.    THis will set up the graph and all the buttons/fields and
;           give control to the event handler.
; Parameters:  Event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_SUB_SAVED_SCALING, event
        COMMON common_vars
        COMMON common_widgets
        COMMON scaling_widgets, s_max, s_min, previous_flag

    use_orig_SF = 1

    EV_OK


END



;=======================================================================================================
; Name:  EV_SCALING
; Purpose:  This procedure draws the window for the scaling operation that we wish to perform on a
;           graph loaded in the top window.    THis will set up the graph and all the buttons/fields and
;           give control to the event handler.
; Parameters:  Event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_SCALING, event
        COMMON common_vars
        COMMON common_widgets
        COMMON scaling_widgets, s_max, s_min, previous_flag


    values = strarr(10)

    FOR I = 0, 9 DO BEGIN
       values[I] = STRING(I + 1)
    ENDFOR

        ; Store the old window information
    previous_flag = Window_Flag

    ; Load the top draw widget's data into the new draw widget in this window.
    ; Test if domains are the same/
    IF (plot_info.domain NE middle_plot_info.domain) THEN BEGIN
          ;ERROR_MESSAGE, "Please place both windows in the same domain."
            err_result = DIALOG_MESSAGE('Please place both windows in the same domain.', $
                               Title = 'ERROR', /ERROR)
       RETURN
        ENDIF ELSE BEGIN

          ; Test if they contain information
       IF (plot_info.data_file EQ '' OR middle_plot_info.data_file EQ '') THEN BEGIN
         ;ERROR_MESSAGE, "Please load data sets for top and middle windows"
         err_result = DIALOG_MESSAGE('Please load data sets for top and middle windows.', $
                               Title = 'ERROR', /ERROR)
         RETURN
          ENDIF

          ; Make main window un-usable.
       WIDGET_CONTROL, main1, SENSITIVE=0

       IF (plot_info.domain EQ 1) THEN startingDomain = 'Time'
          IF (plot_info.domain EQ 0) THEN startingDomain = 'Freqency'

          ; Draw window
       scaling_window = WIDGET_BASE(ROW=3, MAP=1, TITLE='Auto Scaling', TLB_FRAME_ATTR= 8,UVALUE='A_SCALING')
          scaling_draw = WIDGET_DRAW(scaling_window, RETAIN=1, UVALUE='S_DRAW', XSIZE=820, YSIZE=300)
          button_base = WIDGET_BASE (scaling_window,COLUMN=3, MAP=1, UVALUE='A_BUTTONS')
       slider_base = WIDGET_BASE (button_base, MAP=1)
       pd_menu = WIDGET_DROPLIST (slider_base,TITLE="ROI:",VALUE=values, /DYNAMIC_RESIZE, EVENT_PRO='EV_REGION')
          value_base = WIDGET_BASE (button_base, COLUMN=1, MAP=1, UVALUE='V_BASE')
          min_base = WIDGET_BASE(button_base, COLUMN=1, MAP=1, UVALUE='V_BASE')
          ok_base = WIDGET_BASE (button_base, COLUMN=1, MAP=1, UVALUE='Ok_BASE')
          s_min = CW_FIELD(value_base, TITLE='Min. Scaling Location',VALUE=0.0, UVALUE='S_MIN', /FRAME)
          s_max = CW_FIELD(value_base, TITLE='Max. Scaling Location',VALUE=0.0, UVALUE='S_MAX', /FRAME)
          zoom_out_button = WIDGET_BUTTON (min_base, VALUE="Zoom Out", UVALUE='S_ZOOM', /FRAME, EVENT_PRO='EV_ZOOM_OUT')
          check_button = WIDGET_BUTTON(min_base, VALUE="Check", UVALUE='CHK_BTN',/FRAME, EVENT_PRO='EV_CHECK')
          ok_button = WIDGET_BUTTON ( ok_base, VALUE='Ok', /FRAME, EVENT_PRO='EV_OK')
          cancel_button = WIDGET_BUTTON (ok_base, VALUE="Cancel", /FRAME, EVENT_PRO='EV_S_CANCEL')
          WIDGET_CONTROL, scaling_window, /REALIZE


          WIDGET_CONTROL, scaling_draw, GET_VALUE=s_drawId

          WSET, s_drawId
          Window_Flag =1

           AUTO_SCALE
           DISPLAY_DATA

       state = { roi:REPLICATE ({smin:0.0, smax:0.0},10), currentSelection:0, pd_menu:pd_menu,values:values,s_min:s_min, s_max:s_max }
       pstate = ptr_new(state, /NO_COPY)


       WIDGET_CONTROL, scaling_window, SET_UVALUE=pstate
       XMANAGER, 'Foo', scaling_window
        ENDELSE

END

PRO EV_REGION, event

    WIDGET_CONTROL, event.top, GET_UVALUE=state

    WIDGET_CONTROL, (*state).s_min, GET_VALUE = temp1
    (*state).roi[(*state).currentSelection].smin = temp1
    WIDGET_CONTROL, (*state).s_max, GET_VALUE = temp1
    (*state).roi[(*state).currentSelection].smax = temp1
    WIDGET_CONTROL, (*state).pd_Menu, GET_UVALUE=values
    (*state).currentSelection = WIDGET_INFO ((*state).pd_menu, /DROPLIST_SELECT)

    ; Set the appropriate values in the display
    WIDGET_CONTROL,(*state).s_min, SET_VALUE = (*state).roi[(*state).currentSelection].smin
    WIDGET_CONTROL,(*state).s_max, SET_VALUE = (*state).roi[(*state).currentSelection].smax
END


;=======================================================================================================
; Name:  EV_CHECK
; Purpose:  When a user clicks on the check button, it zooms in on the area with the xmin/max having
;           the selected values so that the user can check to see if area is correct.
; Parameters:  Event - the event which caused this procedure to be called.
; Return:  None.
;=======================================================================================================
PRO EV_CHECK, event
        COMMON common_vars
        COMMON scaling_widgets
        COMMON common_widgets

    WIDGET_CONTROL, s_max, GET_VALUE=smax
        WIDGET_CONTROL, s_min, GET_VALUE=smin
        WIDGET_CONTROL, y_max, GET_VALUE=symax
        WIDGET_CONTROL, y_min, GET_VALUE=symin

        ; Set the new values to be the ones to zoom in on.
    plot_info.x1 = smin
        plot_info.y2 = symax
        plot_info.x2 = smax
        plot_info.y1 = symin

    ; Zoom in.
        IF (plot_info.domain EQ 0) THEN BEGIN
          plot_info.time_auto_scale_y = 0
            plot_info.time_auto_scale_x = 0
        ENDIF ELSE BEGIN
            plot_info.freq_auto_scale_y = 0
            plot_info.freq_auto_scale_x = 0
        ENDELSE
        plot_info.fft_recalc = 1

        IF (plot_info.domain EQ 0) AND (plot_info.x1 LT 0) THEN plot_info.x1 = 0
        IF (plot_info.domain EQ 0) AND (plot_info.x2 GT (data_file_header.points/2-1)*data_file_header.dwell) THEN $
       plot_info.x2 = (data_file_header.points/2-1)*data_file_header.dwell
        IF (plot_info.domain EQ 0) THEN plot_info.time_xmin = plot_info.x1 ELSE plot_info.freq_xmin = plot_info.x1
        IF (plot_info.domain EQ 0) THEN plot_info.time_xmax = plot_info.x2 ELSE plot_info.freq_xmax = plot_info.x2
        IF (plot_info.domain EQ 0) THEN plot_info.time_ymin = plot_info.y1 ELSE plot_info.freq_ymin = plot_info.y1
        IF (plot_info.domain EQ 0) THEN plot_info.time_ymax = plot_info.y2 ELSE plot_info.freq_ymax = plot_info.y2

        DISPLAY_DATA
END


;=======================================================================================================
; Name: EV_Ok
; Purpose:  When Ok is selected, this procedure will perform an autoscaling routine on the area provided
;       and scale the subtraction accordingly.
; Parameters:  Event - the event which called this procedure.
; Return:  None.
;=======================================================================================================

PRO EV_OK,event
         ; updated 05/02/02
        COMMON scaling_widgets
        COMMON common_vars
        COMMON common_widgets
        COMMON draw1_comm

    num = 0
    avg2 = 0
    avg = 0
    smooth_avg = 0




    IF (use_orig_SF EQ 0) THEN BEGIN

       WIDGET_CONTROL, event.top, GET_UVALUE=state

       pts =0
       ;Set the last value into the variable
       WIDGET_CONTROL, (*state).s_min, GET_VALUE = temp1
       (*state).roi[(*state).currentSelection].smin = temp1
       WIDGET_CONTROL, (*state).s_max, GET_VALUE = temp1
       (*state).roi[(*state).currentSelection].smax = temp1
       WIDGET_CONTROL, (*state).pd_Menu, GET_UVALUE=values
       (*state).currentSelection = WIDGET_INFO ((*state).pd_menu, /DROPLIST_SELECT)

       ; Test to make sure values are in range.
       IF (plot_info.domain EQ 0) THEN BEGIN
         IF ((*state).roi[(*state).currentSelection].smax GT plot_info.time_xmax) THEN $
          (*state).roi[(*state).currentSelection].smax = plot_info.time_xmax
         IF ((*state).roi[(*state).currentSelection].smin LT plot_info.time_xmin) THEN $
          (*state).roi[(*state).currentSelection].smin = plot_info.time_xmin
       ENDIF ELSE BEGIN
         IF ((*state).roi[(*state).currentSelection].smax GT plot_info.freq_xmax) THEN $
          (*state).roi[(*state).currentSelection].smax = plot_info.freq_xmax
         IF ((*state).roi[(*state).currentSelection].smin LT plot_info.freq_xmin) THEN $
          (*state).roi[(*state).currentSelection].smin = plot_info.freq_xmin
       ENDELSE
       ;Calculate the number of ROIs used.
       FOR i =0, 9 DO BEGIN
         IF ((*state).roi[i].smin NE 0.0 OR (*state).roi[i].smax NE 0.0) THEN $
          num = num + 1
       ENDFOR

       FOR i =0, num DO BEGIN
           num_of_points = data_file_header.points/2
           smin=(*state).roi[(*state).currentSelection].smin
         smax=(*state).roi[(*state).currentSelection].smax

         IF (reverse_flag EQ 0) THEN BEGIN
                        temp_smin = smin
               smin = -smax
               smax = -temp_smin
         ENDIF

         ;Calculate the scaling factor.   Some actions are determined depending on what domain the graphs
         ;are in.

           IF (middle_plot_info.domain EQ 1) THEN BEGIN
               htz_per_pt = (1/middle_data_file_header.dwell)/num_of_points
               start_pt = FIX(smin/htz_per_pt)
               end_pt = FIX(smax/htz_per_pt)
           ENDIF

           IF (middle_plot_info.domain EQ 0) THEN BEGIN
               start_pt = FIX(smin/middle_data_file_header.dwell)
               end_pt = FIX(smax/middle_data_file_header.dwell)
           ENDIF

           IF (middle_plot_info.domain EQ 1) THEN BEGIN
          start_pt = (num_of_points/2) + start_pt
          end_pt = (num_of_points/2) + end_pt
           ENDIF

           IF (plot_info.domain EQ 0) THEN BEGIN
          IF (i EQ 0) THEN BEGIN
              top_window_vector = [abs(time_data_points[0,start_pt:end_pt])]
                  middle_window_vector = [abs(middle_time_data_points[0,start_pt:end_pt])]
          ENDIF ELSE BEGIN
              top_window_vector = [top_window_vector, abs(time_data_points[0,start_pt:end_pt])]
                  middle_window_vector = [middle_window_vector, abs(middle_time_data_points[0,start_pt:end_pt])]
          ENDELSE
           ENDIF ELSE BEGIN
            first_fft = fix(plot_info.fft_initial/data_file_header.dwell)
            last_fft = fix(plot_info.fft_final/data_file_header.dwell)-1

           N_middle = (last_fft - first_fft)/2+1
                 N_end = (last_fft - first_fft)
                 temp1 = freq_data_points[0, N_middle : N_end]
                 temp2 = freq_data_points[0, 1: N_middle]
                 temp1 = REFORM(temp1)
                 temp2 = REFORM(temp2)
                 actual_freq_data_points = [temp1, temp2 ]

          IF (i EQ 0) THEN BEGIN
                  top_window_vector_real = [float(actual_freq_data_points[start_pt:end_pt])]
              top_window_vector_imag = [IMAGINARY(actual_freq_data_points[start_pt:end_pt])]
               ENDIF ELSE BEGIN
               top_window_vector_real = [top_window_vector_real, float(actual_freq_data_points[start_pt:end_pt])]
               top_window_vector_imag = [top_window_vector_imag, IMAGINARY(actual_freq_data_points[start_pt:end_pt])]
          ENDELSE

                 temp1 = middle_freq_data_points[0, N_middle : N_end]
                 temp2 = middle_freq_data_points[0, 1: N_middle]
                 temp1 = REFORM(temp1)
                 temp2 = REFORM(temp2)
                 middle_actual_freq_data_points = [temp1, temp2 ]

          IF (i EQ 0) THEN BEGIN
                  middle_window_vector_real = [float(middle_actual_freq_data_points[start_pt:end_pt])]
              middle_window_vector_imag = [IMAGINARY(middle_actual_freq_data_points[start_pt:end_pt])]
               ENDIF ELSE BEGIN
               middle_window_vector_real = [middle_window_vector_real, float(middle_actual_freq_data_points[start_pt:end_pt])]
               middle_window_vector_imag = [middle_window_vector_imag, IMAGINARY(middle_actual_freq_data_points[start_pt:end_pt])]
          ENDELSE

           ENDELSE
       ENDFOR




          result_window_vector_real = fltarr(N_ELEMENTS(top_Window_vector_real))
          result_window_vector_imag= fltarr(N_ELEMENTS(top_Window_vector_imag))

          bottom_result_window_vector_real = fltarr(N_ELEMENTS(top_Window_vector_real))
          bottom_result_window_vector_imag= fltarr(N_ELEMENTS(top_Window_vector_imag))
       bottom_result_window_vector_abs= fltarr(N_ELEMENTS(top_Window_vector_real))

       line_out_real = fltarr(N_ELEMENTS(top_Window_vector_real))
       line_out_imag = fltarr(N_ELEMENTS(top_Window_vector_imag))


          for i=0, N_ELEMENTS(top_window_vector) -1 DO BEGIN
           result_window_vector_real[i] = top_window_vector_real[i] / middle_window_vector_real[i]
           result_window_vector_imag[i] = top_window_vector_imag[i] / middle_window_vector_imag[i]

          ENDFOR


       avg_fit_real=LADFIT(top_window_vector_real, middle_window_vector_real)

       plot, top_window_vector_real, middle_window_vector_real, psym=7, linestyle=0
       line_out_real = (avg_fit_real[1] *top_window_vector_real) + avg_fit_real[0]
       oplot, top_window_vector_real, line_out_real
            print, "Scaling Factor = ", avg_fit_real
       WAIT, 3

       avg = (1/(avg_fit_real[1]))


            print, "Regression Estimated Scale Factor = ", avg

       original_SF = avg


          WIDGET_CONTROL,main1, SENSITIVE=1
          WIDGET_CONTROL, event.top, /DESTROY


       current_window = Window_flag

       finished = 0
       num_iterations = 0

       current_SF = original_SF

        WHILE (finished LT 5) DO BEGIN
             num_iterations = num_iterations + 1

             TIME_SUBTRACT, current_SF

        ; Examine the data in the third window
               temp1 = bottom_freq_data_points[0, N_middle : N_end]
               temp2 = bottom_freq_data_points[0, 1: N_middle]
               temp1 = REFORM(temp1)
               temp2 = REFORM(temp2)
               bottom_actual_freq_data_points = [temp1, temp2 ]

           bottom_window_vector_real = [float(bottom_actual_freq_data_points[start_pt:end_pt])]
         bottom_window_vector_imag = [IMAGINARY(bottom_actual_freq_data_points[start_pt:end_pt])]

         ; Calculate the merrit function
         bottom_window_vector_abs = sqrt(bottom_window_vector_real^2 + bottom_window_vector_imag^2)
         merrit = TOTAL(sqrt(bottom_window_vector_real^2 + bottom_window_vector_imag^2))
         ;plot, bottom_window_vector_abs, psym=7, linestyle=0
         ;WAIT, 0.4

         print, "Merrit value = ", merrit, "Current SF = ", current_SF

         IF (num_iterations EQ 1) THEN BEGIN
          best_merrit = merrit
          best_SF = current_SF
          current_SF = current_SF*1.01
         ENDIF ELSE BEGIN
          IF (merrit LT 0.01) THEN BEGIN
              finished = 5
          ENDIF ELSE BEGIN
              IF (merrit LT best_merrit) THEN BEGIN
                 finished = 0
                 best_merrit = merrit
                 print, "Best Merrit adjusted = ", best_merrit
                 IF (current_SF GT best_SF) THEN BEGIN
                   best_SF = current_SF
                   current_SF = current_SF*1.005
                 ENDIF ELSE BEGIN
                   best_SF = current_SF
                   current_SF = current_SF*0.995
                 ENDELSE
              ENDIF ELSE BEGIN
                 finished = finished + 1
                 IF (current_SF GT best_SF) THEN BEGIN
                   current_SF = current_SF*(1-(0.01*1/finished))
                 ENDIF ELSE BEGIN
                   current_SF = current_SF*(1+(0.01*1/finished))
                 ENDELSE
              ENDELSE
          ENDELSE
         ENDELSE
        ENDWHILE


       IF (use_orig_SF EQ 1) THEN BEGIN
           TIME_SUBTRACT, original_SF
       ENDIF ELSE BEGIN
         print, "Using Scale Factor = ", best_SF
         TIME_SUBTRACT, best_SF
         original_SF = best_SF
       ENDELSE


          Window_flag = current_window

    ENDIF ELSE BEGIN
       print, "Scale Factor Used = ", original_SF

       TIME_SUBTRACT, original_SF
       current_window = Window_flag
    ENDELSE




    IF (Window_flag EQ 1) THEN BEGIN
       WSET, DRAW1_Id
       DISPLAY_DATA
      ENDIF
         IF (Window_flag EQ 2) THEN BEGIN
       WSET, DRAW2_ID
       MIDDLE_DISPLAY_DATA
     ENDIF
         IF (Window_flag EQ 3) THEN BEGIN
       BOTTOM_DISPLAY_DATA
        ENDIF


    IF (calc_SF_only EQ 0) THEN BEGIN
          WSET, DRAW3_ID
          Window_Flag = 3
       bottom_data_file_header = data_file_header
    ENDIF

    calc_SF_only = 0
    use_orig_SF = 0
    iterate = 0
end


;=======================================================================================================
; Name:  EV_S_DOMAIN
; Purpose:  When the user clicks on the domain, it switches the graph to display the other domain (time,
;       and frequency).
; Parameter:  event - the event which triggered this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_S_DOMAIN, event
        COMMON scaling_widgets
        COMMON common_vars
        WIDGET_CONTROL, domain_button,GET_VALUE= value

        IF (value EQ 'Frequency') THEN BEGIN
          WIDGET_CONTROL, domain_button, SET_VALUE= 'Time'
          plot_info.domain = 0
          REDISPLAY
        ENDIF ELSE BEGIN
          WIDGET_CONTROL, domain_button, SET_VALUE= 'Frequency'
          plot_info.domain = 1
          REDISPLAY
        ENDELSE

END

;=======================================================================================================
; Name: EV_S_CANCEL
; Purpose: Called when the user clicks on Ok from the Auto Scaling window.   It destroys the top widget,
;      redraws a draw widget (the active one seemed to disappear every time the new window opened,
;      and sets the main window to be sensitive again.
; Parameters:  event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_S_CANCEL, event
    COMMON common_widgets
    COMMON scaling_widgets
    COMMON common_vars
    COMMON DRAW1_Comm

    WIDGET_CONTROL, main1, SENSITIVE=1
    WIDGET_CONTROL, event.top, /DESTROY

    ; Restore the previous current draw window values.
    Window_Flag =previous_flag

    IF (Window_Flag EQ 1) THEN WSET, Draw1_Id
    IF (Window_Flag EQ 2) THEN WSET, Draw2_Id
    IF (Window_Flag EQ 3) THEN WSET, Draw3_Id

    REDISPLAY
END

;=======================================================================================================
; Name:  EV_FITSUB
; Purpose:  Performs a subtraction routine using the hlfit software (HLSVD).   This procedure will set
;           up the window and the widgets as well as reading in the needed file to get the values of the
;           widgets.
; Parameters:  event - The event which called this procedure.
; Return:  None.
; References:
; Programers:   Chandrew Rajakumar  2004 - Initial implementation, based on references above.
;          Csaba Kiss 2005 - Final implementation, optimized code with improvements,
;                      fixed phase issue and improved SRSV detection.
;=======================================================================================================
PRO EV_FITSUB, event
    COMMON common_vars
    COMMON common_widgets
    COMMON HSVD_vars, range_min, range_max, SRSV_autodetect

    ; To determine whether HSVD was called to remove water or fit data
    WIDGET_CONTROL, event.ID, GET_UVALUE=HSVD_purpose

    print, ''
    print, 'Starting ', HSVD_purpose, ' ...'
    print, ''


    ;Make main window inaccessible.
    WIDGET_CONTROL, main1, SENSITIVE=0

    WIDGET_CONTROL, X_MAX ,GET_VALUE = xmax
    WIDGET_CONTROL, X_MIN ,GET_VALUE = xmin

    ;**** The optimal values are based on optimization from :
    ;     "Optimization of Residual Water Signal Removal by HLSVD on Simulated
    ;   Short Echo Time Proton MR Spectra of the Human Brain",
    ;   E. Cabanes, S. Confort-Gouny, Y. Le Fur, G. Simond, and P. J. Cozzone,
    ;   Journal of Magnetic Resonance 150, 116-125 (2001).
    ;Default settings for HSVD fittting
       points = 512
       Henkel_ratio = 1.25		;This is midway between the optimal range of 0.5 <= L/M <= 2.0
       srsv = 35
       IF (window_flag EQ 1) THEN BEGIN
            ppm_values =FLOAT(((1/FLOAT(data_file_header.dwell))/FLOAT(data_file_header.frequency))/2)
       ENDIF
       IF (window_flag EQ 2) THEN BEGIN
            ppm_values =FLOAT(((1/FLOAT(middle_data_file_header.dwell))/FLOAT(middle_data_file_header.frequency))/2)
       ENDIF
       IF (window_flag EQ 3) THEN BEGIN
            ppm_values =FLOAT(((1/FLOAT(bottom_data_file_header.dwell))/FLOAT(bottom_data_file_header.frequency))/2)
       ENDIF
       start = 0.01
       range_min = -1*ppm_values
       range_max = ppm_values

    ;Default settings for water removal
    IF (HSVD_purpose EQ 'REMOVE') THEN BEGIN
       points = 512
       Henkel_ratio = 1.25		;This is midway between the optimal range of 0.5 <= L/M <= 2.0	
       srsv = 35
       start = 0.01
       range_min = -0.5
       range_max = 1.5
    ENDIF

    ;Checking data set in the chosen window
    IF (window_flag EQ 1) THEN BEGIN
        print, 'Data contains ', data_file_header.points/2, ' complex points'
    ENDIF
    IF (window_flag EQ 2) THEN BEGIN
        print, 'Data contains ', middle_data_file_header.points/2, ' complex points'
    ENDIF
    IF (window_flag EQ 3) THEN BEGIN
        print, 'Data contains ', bottom_data_file_header.points/2, ' complex points'
    ENDIF

    ;Set up window.
    IF (HSVD_purpose EQ 'FITSUB') THEN BEGIN
        remove_base = WIDGET_BASE(COLUMN=2, MAP=1, TITLE='HSVD Fit',UVALUE='Hankel SVD')
    ENDIF ELSE BEGIN
        remove_base = WIDGET_BASE(COLUMN=2, MAP=1, TITLE='HSVD Water Removal',UVALUE='Hankel SVD')
    ENDELSE

    options_base = WIDGET_BASE(remove_base, COL=1, MAP =1, UVALUE='options', /BASE_ALIGN_RIGHT)
    confirm_base = WIDGET_BASE(remove_base, ROW=2, MAP=1, UVALUE='CONFIRM')
    points_field = CW_FIELD(options_base, TITLE='Number of Points: ', VALUE=points,/INTEGER)
    
    Henkel_field = CW_FIELD(options_base, TITLE='Hankel matrix row/col ratio: ', VALUE=Henkel_ratio, /FLOATING)
    Henkel_label = WIDGET_LABEL(options_base, VALUE = '    ( Optimal range: 0.5 < row/col < 2.0 )')

    ;SRSV_base = WIDGET_BASE(options_base, COL=1, MAP=1, UVALUE='SRSV_BASE', /BASE_ALIGN_RIGHT)
    SRSV_field = CW_FIELD(options_base, TITLE='Signal Related Singular Values: ', VALUE=srsv, /INTEGER)
    SRSV_buttonbase =WIDGET_BASE(options_base, COL=1, MAP=1, /NONEXCLUSIVE)
    SRSV_button = WIDGET_BUTTON(SRSV_buttonbase,  VALUE = 'SRSV Auto Detect  ', EVENT_PRO='EV_SRSV_BUTTON', UNAME="SRSV_button")
    WIDGET_CONTROL, SRSV_button, TOOLTIP="Auto detect number of SRSVs"

    
    IF (HSVD_purpose EQ 'REMOVE') THEN BEGIN
	freq_base = WIDGET_BASE(options_base, COL=1, MAP=1, UVALUE='FREQ_RANGE', /BASE_ALIGN_RIGHT, /FRAME)
        range_label  = WIDGET_LABEL(freq_base, VALUE = '    Frequency Range :                             ')
	;range_label2 = WIDGET_LABEL(freq_base, VALUE = '         -----------------                       ')
        xmin_field = CW_FIELD(freq_base, TITLE='Xmin (in PPM): ', VALUE=range_min, /FLOAT)
        xmax_field = CW_FIELD(freq_base, TITLE='Xmax (in PPM): ', VALUE=range_max, /FLOAT)
    ENDIF ELSE BEGIN
       range_label = WIDGET_LABEL(options_base, VALUE = '          Frequency Range :    ' + string(range_min, format = '(f8.4)') + $
                   '  <  PPM  <  ' + string(range_max, format = '(f8.4)') + '  ', /frame)
    ENDELSE

    ok_button = WIDGET_BUTTON(confirm_base, VALUE='Ok', EVENT_PRO='CURSVD')
    cancel_button = WIDGET_BUTTON(confirm_base, VALUE='Cancel', EVENT_PRO='EV_FITSUB_CANCEL')

    IF (HSVD_purpose EQ 'REMOVE') THEN BEGIN
        widgets = {points_field:points_field, Henkel_field:Henkel_field, SRSV_field:SRSV_field, $
                  xmin_field:xmin_field, xmax_field:xmax_field, SRSV_button:SRSV_button}
    ENDIF ELSE BEGIN
        widgets = {points_field:points_field, Henkel_field:Henkel_field, SRSV_field:SRSV_field, $
                 SRSV_button:SRSV_button}
    ENDELSE
    r_pstate = ptr_new(widgets, /NO_COPY)

    WIDGET_CONTROL, remove_base, SET_UVALUE=r_pstate
    WIDGET_CONTROL, remove_base, /REALIZE

    ;Initial state/settings of convert menu buttons.
    ;------------------------------------------------
    WIDGET_CONTROL, SRSV_field, SENSITIVE=0
    WIDGET_CONTROL,    SRSV_button, SET_BUTTON=1
    SRSV_autodetect = 1
    ;------------------------------------------------

    XMANAGER, "remove", remove_base
END


;=======================================================================================================
; Name:  EV_FITSUB_CANCEL
; Purpose:  Triggered when the user selects cancel button.   Will just destroy top level widget and
;           return control to event handler.
;           widgets.
; Parameters:  event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_FITSUB_CANCEL, event
    COMMON common_widgets

    WIDGET_CONTROL, main1, SENSITIVE=1
    WIDGET_CONTROL, event.top, /DESTROY
END


;=======================================================================================================
; Name:  EV_SRSV_BUTTON
; Purpose:  Triggered when the user selects cancel button.   Will just destroy top level widget and
;           return control to event handler.
;           widgets.
; Parameters:  event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_SRSV_BUTTON, event
    COMMON common_widgets
    COMMON HSVD_vars

    WIDGET_CONTROL, event.top, get_UVALUE=widgets

    IF (SRSV_autodetect EQ 1) THEN BEGIN
       WIDGET_CONTROL, (*widgets).SRSV_field, SENSITIVE=1
       WIDGET_CONTROL,   (*widgets).SRSV_button, SET_BUTTON=0
       SRSV_autodetect = 0
    ENDIF ELSE BEGIN
       WIDGET_CONTROL, (*widgets).SRSV_field, SENSITIVE=0
       WIDGET_CONTROL,   (*widgets).SRSV_button, SET_BUTTON=1
       SRSV_autodetect = 1
    ENDELSE

END


;=======================================================================================================
; Name:  EV_FITSUB_OK
; Purpose:  When the user selects ok, it will call the HLSVD software to perform the subtraction instead
;           of using the one written in IDL.   The source for this program is in ~/Fit/HLSVD/hslvd_robar
;           ts/hlmain.f.
; Parameters:  event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO CURSVD, event

    COMMON common_vars
    COMMON common_widgets
    COMMON Draw1_comm
    COMMON HSVD_vars

    PRINT, ''
    PRINT, '***** BEGIN HSVD *****'
    PRINT, ''

    WIDGET_CONTROL, /HOURGLASS

    ;Setting the auto SRSV flag
    SRSV_button_ID = WIDGET_INFO( event.top, FIND_BY_UNAME="SRSV_button")
    autoSRSV = WIDGET_INFO( SRSV_button_ID,  /BUTTON_SET)

    ;Getting info on data
    IF (window_flag EQ 1) THEN BEGIN
        frequency = data_file_header.frequency
        dwell = data_file_header.dwell
        points = data_file_header.points
    ENDIF
    IF (window_flag EQ 2) THEN BEGIN
        frequency = middle_data_file_header.frequency
        dwell = middle_data_file_header.dwell
        points = middle_data_file_header.points
    ENDIF
    IF (window_flag EQ 3) THEN BEGIN
        frequency = bottom_data_file_header.frequency
        dwell = bottom_data_file_header.dwell
        points = bottom_data_file_header.points
    ENDIF

    WIDGET_CONTROL, event.top, get_UVALUE=widgets
    WIDGET_CONTROL, X_MAX, GET_VALUE=xmax
    WIDGET_CONTROL, X_MIN, GET_VALUE=xmin

    WIDGET_CONTROL, (*widgets).points_field, GET_VALUE=np
    np = FLOAT(np)

    WIDGET_CONTROL, (*widgets).Henkel_field, GET_VALUE=Henk_ratio
    Henk_ratio = FLOAT(Henk_ratio)

    WIDGET_CONTROL, (*widgets).SRSV_field, GET_VALUE=sv_k
    sv_k = FLOAT(sv_k)

    IF (sv_k LT 2) THEN BEGIN
       Result = DIALOG_MESSAGE('The number singular values must be greater then 1.', $
             Title = 'WARNING')
        ;WIDGET_CONTROL, event.top, SENSITIVE =1
        RETURN
    ENDIF


    IF (HSVD_purpose EQ 'REMOVE') THEN BEGIN
    ;Needed to adjust min/max scaling according to NMR convention
    WIDGET_CONTROL, (*widgets).xmin_field, GET_VALUE=ppm_range_min
        range_max = (-1)*FLOAT(ppm_range_min)*frequency

        WIDGET_CONTROL, (*widgets).xmax_field, GET_VALUE=ppm_range_max
        range_min = (-1)*FLOAT(ppm_range_max)*frequency
    ENDIF

    print, 'Points = ', np
    print, 'Hankel matrix ratio = ', Henk_ratio
    print, 'Peaks = ', sv_k
    print, 'Range_min (Hz)= ', range_min
    print, 'Range_max (Hz)= ', range_max

    ; Form the data array from user given range
    IF (window_flag EQ 1) THEN BEGIN
        SVD_actual_time_data_points = REFORM(time_data_points[0, fix(0)+1:(fix(np))])
    ENDIF
    IF (window_flag EQ 2) THEN BEGIN
        SVD_actual_time_data_points = REFORM(middle_time_data_points[0, fix(0)+1:(fix(np))])
    ENDIF
    IF (window_flag EQ 3) THEN BEGIN
        SVD_actual_time_data_points = REFORM(bottom_time_data_points[0, fix(0)+1:(fix(np))])
    ENDIF

    Y = SVD_actual_time_data_points

    ; Create the index time array X
    X = make_array(np, /FLOAT)
    FOR i=0, np-1 DO BEGIN
        X[i] = i * dwell
    ENDFOR


    ;IMPORTANT:  At this point Y is np size vector that
    ;            holds ONE complex number PER ELEMENT

    ; Now create S matrix with a Hankel structure
    ;Define L and M (rows and cols)
    ;Matrix size is based on np, L, M and Henk_ratio..following the above mentioned paper.
    ;It's been shown that precision varies only slightly within 0.5 <= L/M <= 2.0
    ;Hence the default value of the ratio is set to satisfy L+M=N+1
    
    M = fix((np+1)/(Henk_ratio+1))
    L = fix((Henk_ratio * (np+1))/(Henk_ratio+1))

    ;Create S matrix
    Print, FORMAT = '("Creating Hankel matrix:    [ ", I4, "  X ", I4, " ] ")', L, M
    Slm = make_array(M,L, /DCOMPLEX)
    p = 0
      FOR j=0, L-1 DO BEGIN
         FOR i=0, M-1 DO BEGIN
          Slm[i,j] = Y[j+i] ;[i,j] = [COL, ROW]
         ENDFOR
       ENDFOR

    ;Perform SVD
    Print, 'Performing Singular Value Decomposition...'
    a = Slm
    LA_SVD, a, w, u, v, /DOUBLE
    ; a = u ## DIAG_MATRIX(w) ## TRANSPOSE(CONJ(v))


;print,""
;print,"Initial Henkel singular values:"
;print, w
;print,""

    ; Create axis index for X and plot the singular values
    indK = FINDGEN(sv_k)+1
    plot, indK, w, TITLE='SVD Singular Values', THICK=1




    ;<--------------- Counting signal related singular values based on tolerance -------------->;
    ; The rest are simply ingnored later by forming a truncated U matrix -> Ulk
    Print, 'Detecting Signal Related Singular Values...'

    ;<--------------- Detecting Signal Related Singular Values (SRSVs). -------------->;

    IF (autoSRSV EQ 1) THEN BEGIN
    	;AUTO DETECTION PART
    	;Exctracting noise points.  We extract the last noise_pointPercent number of points
    	;from the original signal.  The actual percentage is set by trial.
    	noise_pointPercent = 0.1          ; This is the signal point percentage used for noise detection
    	numComplPairs = fix(points /2)
    	first_noise_indx = fix(numComplPairs - (numComplPairs * noise_pointPercent) + ((numComplPairs * noise_pointPercent) mod 2))
    	first_noise_indx = first_noise_indx + 1         ;Shifting first index by one...fitMAN convention
    	IF (window_flag EQ 1) THEN BEGIN
        	noise_points = REFORM(time_data_points[0, first_noise_indx:numComplPairs])
    	ENDIF
    	IF (window_flag EQ 2) THEN BEGIN
        	noise_points = REFORM(middle_time_data_points[0, first_noise_indx:numComplPairs])
    	ENDIF
    	IF (window_flag EQ 3) THEN BEGIN
        	noise_points = REFORM(bottom_time_data_points[0, first_noise_indx:numComplPairs])
   	 ENDIF


    	;Creating noise related Henkel matrix
    	; Number of rows ~50% of number of noise points
    	nL = fix(n_elements(noise_points) * 0.5)
    	;Number of columns...the usual
    	nM = n_elements(noise_points) - nL +1

    	;Create noise S matrix
       	nSlm = make_array(nM,nL, /DCOMPLEX)
       	FOR j=0, nL-1 DO BEGIN
         	FOR i=0, nM-1 DO BEGIN
          		nSlm[i,j] = noise_points[j+i] ;[i,j] = [COL, ROW]
         	ENDFOR
       	ENDFOR

    	;Perform SVD for noise
    	LA_SVD, nSlm, nW, nU, nV, /DOUBLE

    	;Could use the maximum found noise SVD or the mean SVD
    	;Based on results, decided to go with the max.
    	n_thresh = nW[0]
    	;n_thresh = MEAN(nW)
    	print, '                    ...SV noise threshold estimated at :', n_thresh

    	numSV=1
    	IF (L LT M OR L EQ M) THEN BEGIN
       		upperLimitSVK = L-1
    	ENDIF ELSE BEGIN
      		upperLimitSVK = M-1
   	ENDELSE

    	;Counting the number of sv_k
   	 FOR i=1, upperLimitSVK DO BEGIN
        	IF (w[i] GT n_thresh) THEN BEGIN
            		numSV = numSV +1
        	ENDIF
    	ENDFOR
	sv_k = numSV
    	print, '                           ...number of SRSVs detected :', sv_k
    ENDIF ELSE BEGIN
	print, '        Number of Signal Related Singular Values used :', sv_k
    ENDELSE

    IF (sv_k EQ 1) THEN BEGIN
	error_msg = ['Only one singular value detected...', 'Cannot continue!']
	Result = DIALOG_MESSAGE(error_msg,Title = 'ERROR', /ERROR)
	GOTO, REDISPLAY
    ENDIF

    ;<--------------- Truncating matrix U and calculating Z' -------------->;
    ;Truncate U matrix into Ulk according to the number of signal related singular values found.
    Ulk = make_array(sv_k, L, /DCOMPLEX)
    Ulk[0:sv_k-1, 0:L-1] = u[0:sv_k-1, 0:L-1]

    ;Applying info from "The SVD-based State Space method" paper to find matrix z
    Print, 'Extrapolating parameters...'
    Ub = make_array(sv_k, L-1, /DCOMPLEX) ; k*L-1 is k*k
    Ut = Ub
    FOR i=0, L-2 DO Ub[*,i]   = Ulk[*,i] ;rm bottom row
    FOR i=1, L-1 DO Ut[*,i-1] = Ulk[*,i] ;rm top row
    tempMat =  TRANSPOSE(CONJ(Ub)) ## Ub
    z_prime = INVERT(tempMat) ## TRANSPOSE(CONJ(Ub)) ## Ut


    ;Now that we have z' we can calculate z by diagonalization
    ;essentially we say that z' = P*z*INV(P) where z contains
    ;all the eigenvalues of z' along its diagonal and all else 0's
    eig = LA_EIGENPROBLEM(z_prime, /double)
    z = DIAG_MATRIX(eig)

    ; z matrix contains the decay constants and
    ;the frequencies numerically mashed together
    ;as signal poles located along the diagonal.

    ;<--------------- Computing decay and frequencies -------------->;
    Print, 'Computing Decay Constants...'
    Print, 'Computing Frequencies...'
    holdMat = make_array(sv_k,/DCOMPLEX)
    alpha = make_array(sv_k,/DOUBLE)
    omega = make_array(sv_k,/DOUBLE)
    FOR loop=0, sv_k-1 DO BEGIN
        holdMat[loop] = ALOG(z[loop,loop])
        alpha[loop] = REAL_PART(holdMat[loop])/(-1*!Pi*dwell)
        omega[loop] = IMAGINARY(holdMat[loop])/(2*!Pi*dwell)
    ENDFOR

    ;<--------------- Calculating coefficients for amplitude and phase in Least Square sense. -------------->;
    ; If B * b = x   then   b = (B~ * B)' * B~ * x 
    ; ...where B~ is the conjugate transpose of B.
    ;<------------------------------------------------------------------------------------------------------>;	
    matrix_B = make_array(sv_k, np, /dcomplex)

    FOR term_num=0, sv_k-1 DO BEGIN
        matrix_B[term_num, 0:np-1] = exp(complex(-1*!Pi*alpha[term_num], 2*!Pi*omega[term_num])*X[0:np-1])
    ENDFOR

    matrix_B_Conj_Transp = conj(transpose(matrix_B))
    vector_b = INVERT(matrix_B_Conj_Transp##matrix_B)##matrix_B_Conj_Transp##Y

    ;<--------------- Computing amplitudes by fitting with decay and freq. -------------->;
    Print, 'Computing Amplitudes...
    Amp = make_array(sv_k,/DOUBLE)

    FOR term_num=0, sv_k-1 DO BEGIN
        Amp[term_num] = sqrt(real_part(vector_b[term_num])^2+imaginary(vector_b[term_num])^2)
    ENDFOR

    ;<--------------- Computing phase by fitting with decay and freq. -------------->;
    Print, 'Computing Phase Shifts...'
    phase = make_array(sv_k,/DOUBLE)

    FOR term_num=0, sv_k-1 DO BEGIN
        phase[term_num] = atan(imaginary(vector_b[term_num]),real_part(vector_b[term_num]))
    ENDFOR

    ;<--------------- Compiling fit curve -------------->;
    Print, 'Compiling Fit Curve...'

    ;<--------------- Printing resulted parameters -------------->;
    params = make_array(4, sv_k, /double)
    params[0,*] = omega[*]
    params[1,*] = amp[*]
    params[2,*] = alpha[*]
    params[3,*] = phase[*]

    ;print, params

    sorted_params = params(*,sort(params[0,*]))

    Print, ""
    Print, "Peak#       Feq.(Hz)     Ampl.(au)     Damp. fact.      Phase(Deg)"
    FOR j=0, sv_k-1 DO BEGIN
       Print,  format = '(I3, T10, f10.4, T25, f10.4, T40, f10.4, T55, f10.4)', j+1, sorted_params[0,j], sorted_params[1,j], sorted_params[2,j], sorted_params[3,j]*180/!Pi
    ENDFOR

    ; WATER REMOVAL PART
    IF (HSVD_purpose EQ 'REMOVE') THEN BEGIN
        IF (window_flag EQ 1) THEN BEGIN
            temp_display = time_data_points[0,0]
            subtract_portion = REFORM(time_data_points[0,*])
        ENDIF
        IF (window_flag EQ 2) THEN BEGIN
            temp_display = middle_time_data_points[0,0]
            subtract_portion = REFORM(middle_time_data_points[0,*])
        ENDIF
        IF (window_flag EQ 3) THEN BEGIN
            temp_display = bottom_time_data_points[0,0]
            subtract_portion = REFORM(bottom_time_data_points[0,*])
        ENDIF

        subtract_portion[*] = complex(0.0,0.0)

        FOR i=1, points DO BEGIN
            FOR j=0, sv_k-1 DO BEGIN
             IF omega[j] GT range_min AND omega[j] LT range_max AND alpha[j] GT 0 THEN BEGIN
                 subtract_portion[i] = subtract_portion[i] + $
                                    amp[j]*EXP(COMPLEX(0,phase[j]))*$
                                    EXP(COMPLEX(-1*!Pi*(i-1)*dwell*alpha[j],2*!Pi*omega[j]*(i-1)*dwell))
             ENDIF
            ENDFOR
        ENDFOR

       ;Finally subtract all resonances from the data and put in array from window three
        IF (window_flag EQ 1) THEN BEGIN
            FOR i=1, points DO BEGIN
                time_data_points[0,i] = time_data_points[0,i] - subtract_portion[i]
            ENDFOR
            time_data_points[0,0] = temp_display
        ENDIF
        IF (window_flag EQ 2) THEN BEGIN
         FOR i=1, points DO BEGIN
                middle_time_data_points[0,i] = middle_time_data_points[0,i] - subtract_portion[i]
            ENDFOR
            middle_time_data_points[0,0] = temp_display
        ENDIF
        IF (window_flag EQ 3) THEN BEGIN
         FOR i=1, points DO BEGIN
                bottom_time_data_points[0,i] = bottom_time_data_points[0,i] - subtract_portion[i]
            ENDFOR
            bottom_time_data_points[0,0] = temp_display
        ENDIF


    ; FITTING PART
    ENDIF ELSE BEGIN
        IF (window_flag EQ 1) THEN BEGIN
            ;temp_time_data_points = REFORM(time_data_points[0,*])
            temp_display = time_data_points[0,0]
            time_data_points[0,*] = COMPLEX(0.0,0.0)
            time_data_points[0,0] = temp_display
            FOR i=1, points DO BEGIN
                FOR j=0, sv_k-1 DO BEGIN
                  IF alpha[j] GT 0 THEN BEGIN
                       time_data_points[0,i] = time_data_points[0,i] + $
                                        amp[j]*EXP(COMPLEX(0,phase[j]))*$
                                        EXP(COMPLEX(-1*!Pi*(i-1)*dwell*alpha[j],$
                                        2*!Pi*omega[j]*(i-1)*dwell))
                  ENDIF
                ENDFOR
            ENDFOR
        ENDIF
        IF (window_flag EQ 2) THEN BEGIN
            temp_display = middle_time_data_points[0,0]
            middle_time_data_points[0,*] = COMPLEX(0.0,0.0)
            middle_time_data_points[0,0] = temp_display
            FOR i=1, points DO BEGIN
                FOR j=0, sv_k-1 DO BEGIN
                  IF alpha[j] GT 0 THEN BEGIN
                       middle_time_data_points[0,i] = middle_time_data_points[0,i] + $
                                        amp[j]*EXP(COMPLEX(0,phase[j]))*$
                                        EXP(COMPLEX(-1*!Pi*(i-1)*dwell*alpha[j],$
                                        2*!Pi*omega[j]*(i-1)*dwell))
                  ENDIF
                ENDFOR
            ENDFOR
        ENDIF
        IF (window_flag EQ 3) THEN BEGIN
            temp_display = bottom_time_data_points[0,0]
            bottom_time_data_points[0,*] = COMPLEX(0.0,0.0)
            bottom_time_data_points[0,0] = temp_display
            FOR i=1, points DO BEGIN
                FOR j=0, sv_k-1 DO BEGIN
                  IF alpha[j] GT 0 THEN BEGIN
                       bottom_time_data_points[0,i] = bottom_time_data_points[0,i] + $
                                        amp[j]*EXP(COMPLEX(0,phase[j]))*$
                                        EXP(COMPLEX(-1*!Pi*(i-1)*dwell*alpha[j],$
                                        2*!Pi*omega[j]*(i-1)*dwell))
                  ENDIF
                ENDFOR
            ENDFOR
        ENDIF
    ENDELSE


    REDISPLAY:
    IF (window_flag EQ 1) THEN BEGIN
        ;Insert the result of yfit back into the original data matrix and then redisplay
        original_data = REFORM(time_data_points[0,*])

        ;Redisplay
        AUTO_SCALE

        ; Set up the appropriate text field values in the widgets.
        WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.time_xmin
        WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.time_xmax
        o_xmax=plot_info.time_xmax
        WIDGET_CONTROL, Y_MAX, SET_VALUE = plot_info.time_ymax
        WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * plot_info.time_ymin
        WIDGET_CONTROL, INITIAL, SET_VALUE = plot_info.fft_initial
        plot_info.fft_final = float(points/2 * dwell)
        WIDGET_CONTROL, FINAL, SET_VALUE = plot_info.fft_final
        WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE=0
        plot_info.phase = 0
        plot_info.current_phase=0

        ;Display only the real part of the time domain signal
        time_data_points[0,0] = complex(1,0)
        plot_info.traces = 0

        IF (plot_info.domain EQ 1) THEN BEGIN
            ;print, 'running redisplay'
            REDISPLAY
        ENDIF ELSE BEGIN
            ;print, 'running display_data'
            DISPLAY_DATA
        ENDELSE
    ENDIF
    IF (window_flag EQ 2) THEN BEGIN
        ;Insert the result of yfit back into the original data matrix and then redisplay
        middle_original_data = REFORM(middle_time_data_points[0,*])

        ;Redisplay
        AUTO_SCALE

        ; Set up the appropriate text field values in the widgets.
        WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.time_xmin
        WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.time_xmax
        o_xmax2=middle_plot_info.time_xmax
        WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.time_ymax
        WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * middle_plot_info.time_ymin
        WIDGET_CONTROL, INITIAL, SET_VALUE = middle_plot_info.fft_initial
        middle_plot_info.fft_final = float(points/2 * dwell)
        WIDGET_CONTROL, FINAL, SET_VALUE = middle_plot_info.fft_final
        WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE=0
        middle_plot_info.phase = 0
        middle_plot_info.current_phase=0

        ;Display only the real part of the time domain signal
        middle_time_data_points[0,0] = complex(1,0)
        middle_plot_info.traces = 0

        IF (middle_plot_info.domain EQ 1) THEN BEGIN
            ;print, 'running redisplay'
            REDISPLAY
        ENDIF ELSE BEGIN
            ;print, 'running middle_display_data'
            MIDDLE_DISPLAY_DATA
        ENDELSE
    ENDIF
    IF (window_flag EQ 3) THEN BEGIN
        ;Insert the result of yfit back into the original data matrix and then redisplay
        bottom_original_data = REFORM(bottom_time_data_points[0,*])

        ;Redisplay
        AUTO_SCALE

        ; Set up the appropriate text field values in the widgets.
        WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
        WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
        o_xmax3=bottom_plot_info.time_xmax
        WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
        WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
        WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
        bottom_plot_info.fft_final = float(points/2 * dwell)
        WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
        WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE=0
        bottom_plot_info.phase = 0
        bottom_plot_info.current_phase=0

        ;Display only the real part of the time domain signal
        bottom_time_data_points[0,0] = complex(1,0)
        bottom_plot_info.traces = 0

        IF (bottom_plot_info.domain EQ 1) THEN BEGIN
            ;print, 'running redisplay'
            REDISPLAY
        ENDIF ELSE BEGIN
            ;print, 'running bottom_display_data'
            BOTTOM_DISPLAY_DATA
        ENDELSE
    ENDIF

    PRINT, ''
    PRINT, '****** END HSVD ******'
    PRINT, ''

    WIDGET_CONTROL, main1, SENSITIVE=1
    WIDGET_CONTROL, event.top, /DESTROY
END
