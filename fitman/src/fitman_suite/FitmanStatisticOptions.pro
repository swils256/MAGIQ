;=======================================================================================================;
; Name: EV_STDDEV                          ;
; Purpose: To allow a user to get statistical data regarding a data set.   Specifically this will give  ;
;          the user the standard deviation of a graph and the max and min values.      ;
; Parameters:  Event - The event which called this procedure.               ;
; Return: None.                              ;
;=======================================================================================================;
PRO EV_STDDEV, event

    COMMON common_vars
    COMMON draw1_comm

        noResize = 1

    stats_window = WIDGET_BASE(ROW=3, MAP=1, TITLE='Statistics', TLB_FRAME_ATTR= 8)
        stats_draw = WIDGET_DRAW(stats_window, RETAIN=1, UVALUE='S_DRAW', XSIZE=1050, YSIZE=300)
        button_base = WIDGET_BASE (stats_window,COLUMN=3, MAP=1, UVALUE='A_BUTTONS')
    slider_base = WIDGET_BASE (button_base, MAP=1)
    value_base = WIDGET_BASE (button_base, COLUMN=1, MAP=1, UVALUE='V_BASE')
    min_base = WIDGET_BASE(button_base, ROW=6, MAP=1, UVALUE='V_BASE',/FRAME)
        ok_base = WIDGET_BASE (button_base, COLUMN=1, MAP=1, UVALUE='Ok_BASE')
    s_min = CW_FIELD(value_base, TITLE='Min Frequency',VALUE=0.0, /FRAME)
        s_max = CW_FIELD(value_base, TITLE='Max Frequency',VALUE=0.0, /FRAME)
        ok_button = WIDGET_BUTTON ( ok_base, VALUE='Calculate', /FRAME, EVENT_PRO='EV_STDDEV_CALC')
        print_button = widget_button(ok_base,VALUE='Print',/FRAME,EVENT_PRO='EV_STDDEV_PRINT')
        cancel_button = WIDGET_BUTTON (ok_base, VALUE="Exit", /FRAME, EVENT_PRO='EV_STDDEV_EXIT')
    std_box = CW_FIELD (min_base, TITLE='Std Dev Real: ', VALUE=0.0)
    std_boxim = CW_FIELD (min_base, TITLE='Std Dev Imaginary: ', VALUE=0.0)
    avg_box = CW_FIELD (min_base, TITLE='Average Real: ', VALUE=0.0)
    avg_boxim = CW_FIELD (min_base, TITLE='Average Imaginary: ', VALUE=0.0)
    maxval_box = CW_FIELD(min_base, TITLE='Max Real Value:', VALUE=0.0)
    minval_box = CW_FIELD(min_base, TITLE='Min Real Value:', VALUE=0.0)


    state = {s_min:s_min, s_max:s_max, std_box:std_box, maxval_box:maxval_box, minval_box:minval_box,$
             avg_box:avg_box,avg_boxim:avg_boxim,std_boxim:std_boxim}
    pstate = ptr_new(state, /NO_COPY)
    WIDGET_CONTROL, stats_window, SET_UVALUE=pstate

    WIDGET_CONTROL, stats_window, /REALIZE
    WIDGET_CONTROL, stats_draw, GET_VALUE=s_drawId
    wset,s_drawId

        AUTO_SCALE

        REDISPLAY

    XMANAGER, 'Foo', stats_window
    noResize = 0
END

;=======================================================================================================;
; Name:  EV_STDDEV_EXIT                            ;
; Purpose:  Exits out of the Statistic window.                    ;
; Parameters:  Event - the event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_STDDEV_EXIT, event
      COMMON common_vars
      COMMON draw1_comm

      if(Window_Flag eq 1) then begin
         wset,draw1_id
      endif else if (Window_Flag eq 2) then begin
         wset,draw2_id
      endif else if (Window_Flag eq 3) then begin
         wset,draw3_id
      endif

      WIDGET_CONTROL, event.top, /DESTROY
END

function setCalculations,smin,smax,file_header,timeDataPoints,p_info,freq_points,shift

    ;Calculate the points that fall between the min and max paramters.  We grab all the variables
    ;and put them in an array called window_vector.

    num_of_points = file_header.points/2

    IF (p_info.domain EQ 0) THEN BEGIN
         start_pt = FIX(smin/file_header.dwell)
             end_pt = FIX(smax/file_header.dwell)

         ; change added by Tim Orr.  We want to throw an error message if the min/max specified are
         ; not in the window vector.
         IF(start_pt GT end_pt OR start_pt LT 0)  THEN BEGIN
          ;ERROR_MESSAGE, "The values specified are invalid!  Please re-enter the min/max values."
          err_result = DIALOG_MESSAGE('The values specified are invalid!  Please re-enter the min/max values.', $
                        Title = 'WARNING')
          return, COMPLEX(1)
         ENDIF

         window_vector =  [complex(FLOAT(timeDataPoints[0,start_pt:end_pt]), $
          IMAGINARY(timeDataPoints[0,start_pt:end_pt]))]
    ENDIF
    IF (p_info.domain EQ 1) THEN BEGIN
         if(p_info.xaxis eq 0) then begin
           units_per_pt = (1/file_header.dwell)/num_of_points
         endif else begin
           units_per_pt = (((1/file_header.dwell)/file_header.frequency)/num_of_points)
         endelse

         start_pt = (num_of_points/2) + FIX((smin-shift)/units_per_pt)
         end_pt = (num_of_points/2) + FIX((smax-shift)/units_per_pt)

          ; change added by Tim Orr.  We want to throw an error message if the min/max specified are
          ; not in the window vector.
         IF(start_pt GT end_pt OR start_pt LT 0)  THEN BEGIN
          ;ERROR_MESSAGE, "The values specified are invalid!  Please re-enter the min/max values."
          err_result = DIALOG_MESSAGE('The values specified are invalid!  Please re-enter the min/max values.', $
                        Title = 'WARNING')
          return, COMPLEX(1)
         ENDIF

             first_fft = fix(p_info.fft_initial/file_header.dwell)
         last_fft = fix(p_info.fft_final/file_header.dwell)-1

         N_middle = (last_fft - first_fft)/2+1
             N_end = (last_fft - first_fft)
             temp1 = freq_points[0, N_middle : N_end]
             temp2 = freq_points[0, 1: N_middle]
             temp1 = REFORM(temp1)
             temp2 = REFORM(temp2)
             actual_freq_data_points = [temp1, temp2]

             if(end_pt ge n_elements(FLOAT(actual_freq_data_points))) then begin
                window = [complex(-1,-1)]
                ;ERROR_MESSAGE,'The max/min values are out of range'
                err_result = DIALOG_MESSAGE('The max/min values are out of range.', $
                        Title = 'WARNING')
          return, COMPLEX(1)
             endif else begin
            window_vector = [complex(FLOAT(actual_freq_data_points[start_pt:end_pt]),$
               IMAGINARY(actual_freq_data_points[start_pt:end_pt]))]
         endelse
    ENDIF

    return, window_vector
end

function setUPCalculations,event

        COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=state
    WIDGET_CONTROL, (*state).s_min, GET_VALUE=smin
    WIDGET_CONTROL, (*state).s_max, GET_VALUE=smax
    smin = smin[0]
    smax = smax[0]

    ;  Correction made by Tim Orr.  Previously, the frequency domain points were being reversed if any one
    ;  of the windows was in the frequency domain.  However, we only want this to happen if the current window
    ;  selected is in the frequency domain.

    IF (Window_Flag EQ 1) THEN BEGIN
           IF (plot_info.domain EQ 1) THEN BEGIN
         smin_temp = smin
         smin = -1 * smax
         smax = -1 * smin_temp
       ENDIF
       window_vector = setCalculations(smin,smax,data_file_header,time_data_points,$
                                            plot_info,freq_data_points,point_shift)
    ENDIF ELSE IF (Window_Flag EQ 2) THEN BEGIN
           IF (middle_plot_info.domain EQ 1) THEN BEGIN
         smin_temp = smin
         smin = -1 * smax
         smax = -1 * smin_temp
       ENDIF
       window_vector = setCalculations(smin,smax,middle_data_file_header,middle_time_data_points,$
                                            middle_plot_info,middle_freq_data_points,middle_point_shift )
    ENDIF ELSE IF (Window_Flag EQ 3) THEN BEGIN
                IF (bottom_plot_info.domain EQ 1) THEN BEGIN
         smin_temp = smin
         smin = -1 * smax
         smax = -1 * smin_temp
       ENDIF
       window_vector = setCalculations(smin,smax,bottom_data_file_header,bottom_time_data_points,$
                                            bottom_plot_info,bottom_freq_data_points,bottom_point_shift )
    ENDIF

    return, window_vector
end

function average, array
  return, total(array)/n_elements(array)
end

;=======================================================================================================;
; Name:  EV_STDDEV_CALC                            ;
; Purpose:  Calculates the standard deviation, average and the min/max values for an active graph.   ;
; Parameters:  Event - The event which caused this procedure to be called.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_STDDEV_CALC, event
        WIDGET_CONTROL, event.top, GET_UVALUE=state
    WIDGET_CONTROL, (*state).s_min, GET_VALUE=smin
    WIDGET_CONTROL, (*state).s_max, GET_VALUE=smax

        window_vector = setUPCalculations(event)

        if(n_elements(float(window_vector)) ne 1) then begin

      ; Now we can simply calculate the values for the text widgets.   Calculate std. dev. and
      ; min/max values and load them into the widgets.

          ; For standard deviation, calculate for real and image seperately

      stdev_avg = STDDEV(float(window_vector))
      stdev_avgim = STDEV(imaginary(window_vector))
      avg = average(float(window_vector))
      avgim =  average(imaginary(window_vector))

      WIDGET_CONTROL, (*state).std_box, SET_VALUE=stdev_avg
      WIDGET_CONTROL, (*state).avg_box, SET_VALUE=avg
      WIDGET_CONTROL, (*state).std_boxim, SET_VALUE=stdev_avgim
      WIDGET_CONTROL, (*state).avg_boxim, SET_VALUE=avgim
      WIDGET_CONTROL, (*state).maxval_box, SET_VALUE=MAX(FLOAT(window_vector))
      WIDGET_CONTROL, (*state).minval_box, SET_VALUE=MIN(FLOAT(window_vector))
    ENDIF
END

pro setSTDSubTitle,std_real,std_im,avg_real,avg_im,min_real,max_real,smin,smax
   sreal = STRCOMPRESS(STRING(std_real),/REMOVE_ALL)
   sim   = STRCOMPRESS(STRING(std_im),/REMOVE_ALL)
   areal = STRCOMPRESS(STRING(avg_real),/REMOVE_ALL)
   aim   = STRCOMPRESS(STRING(avg_im),/REMOVE_ALL)
   minReal = STRCOMPRESS(STRING(min_real),/REMOVE_ALL)
   maxReal = STRCOMPRESS(STRING(max_real),/REMOVE_ALL)

   ;!P.SUBTITLE = 'Std Dev Real: ' + sreal + ' Std Dev Imag: '+sim + ' Avg Real: ' + areal + ' Avg Imag: ' + avg_im $
   ;             + ' Min Value: ' + minReal + ' Max Value: ' + maxReal
   xpos = 100

   fsize = 2

   XYOUTS,xpos,255,'Std Dev Real  : ' + sreal, COLOR=2,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,240,'Std Dev Imag : ' + sim,COLOR=2,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,225,'Average Real : ' + areal,COLOR=2,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,210,'Average Imag : ' + avg_im,COLOR=2,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,195,'Min Real Value: ' + minReal,COLOR=2,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,180,'Max Real Value: ' + maxReal,COLOR=2,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,165,'Min Frequency  : ' + smin,COLOR=2,/DEVICE,CHARSIZE = fsize
   XYOUTS,xpos,150,'Max Frequency : ' + smax,COLOR=2,/DEVICE,CHARSIZE = fsize

end

pro EV_STDDEV_PRINT, event
   COMMON common_vars
   COMMON draw1_comm
   COMMON common_widgets

   WIDGET_CONTROL, event.top, GET_UVALUE=state

   noResize = 1


   WIDGET_CONTROL, (*state).std_box, GET_VALUE=std_real
   WIDGET_CONTROL, (*state).avg_box, GET_VALUE=avg_real
   WIDGET_CONTROL, (*state).std_boxim, GET_VALUE=std_im
   WIDGET_CONTROL, (*state).avg_boxim, GET_VALUE=avg_im
   WIDGET_CONTROL, (*state).maxval_box, GET_VALUE=max_real
   WIDGET_CONTROL, (*state).minval_box, GET_VALUE=min_real
   WIDGET_CONTROL, (*state).s_min, GET_VALUE=smin
   WIDGET_CONTROL, (*state).s_max, GET_VALUE=smax

   if(Window_Flag eq 1) then begin
      DISPLAY_DATA
   endif else if (Window_Flag eq 2) then begin
      MIDDLE_DISPLAY_DATA
   endif else if (Window_Flag eq 3) then begin
      BOTTOM_DISPLAY_DATA
   endif

   setSTDSubTitle,std_real,std_im,avg_real,avg_im,min_real,max_real,smin,smax

   image = TVRD()
   REDISPLAY

   TVLCT,r,g,b,/GET

   mr = r[image]
   mg = g[image]
   mb = b[image]

   image3d = binaryImage(mr,mg,mb)

   current = !d.name
   set_plot, "PS"
   device, filename='stddev.ps', /inches, XSIZE=16, SCALE_FACTOR=.5, YSIZE =8.3, FONT_SIZE=20,/LANDSCAPE

   TV,image3d,TRUE=1

   device,/CLOSE
   set_plot, current
   command = defaultPrinter+' stddev.ps'
   spawn, command

   print, 'done print'

   noResize = 0
end
