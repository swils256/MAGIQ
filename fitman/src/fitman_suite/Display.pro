;=======================================================================================================;
; Filename:  Display.pro    										;
; Purpose:  To provide the display procedures needed for the draw windows for the Fitman GUI program.   ;
; Dependancies:  FitmanGui_sept2000.pro									;
;=======================================================================================================;

PRO DISPLAY_DATA
	  ;This procedure displays the data

  	COMMON common_vars
  	COMMON common_widgets
	COMMON plot_variables ; sharing these variables, so that the plot data can be used in other procs

        if(plot_info.data_file eq '') then begin
           return
        endif

  	first_fft = fix(plot_info.fft_initial/data_file_header.dwell)
  	last_fft = fix(plot_info.fft_final/data_file_header.dwell)-1

  	first_trace_plot1 = 0
  	first_trace_plot2 = 0

        ;if(repaint eq 0) then begin
          setUPPlot
        ;endif

     	FOR i=plot_info.first_trace, plot_info.last_trace DO BEGIN

     		plot_info.current_curve = i

     		IF (ABS(time_data_points[i,0]) GT 0 AND i LE 2) THEN BEGIN

        	IF (plot_info.domain EQ 0) THEN BEGIN

           		AUTO_SCALE

           		actual_time_data_points = REFORM(time_data_points[i, $
			fix(plot_info.time_xmin/data_file_header.dwell)+1:$
			(fix(plot_info.time_xmax/data_file_header.dwell)+1)])

           	time = point_index * data_file_header.dwell
	      	actual_time = EXTRAC(time, plot_info.time_xmin/data_file_header.dwell, $
		plot_info.time_xmax/data_file_header.dwell-plot_info.time_xmin/data_file_header.dwell)

           	WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.time_xmin
           	WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.time_xmax
           	WIDGET_CONTROL, Y_MIN, SET_VALUE = plot_info.time_ymin
           	WIDGET_CONTROL, Y_MAX, SET_VALUE = plot_info.time_ymax

                ; isAbs = false
                ; rangeIn = false
                ; ptsSub = false

                display_plot,i,plot_info.time_xmin,plot_info.time_xmax,$
                       plot_info.time_ymin,plot_info.time_ymax,'Time (s)',actual_time,$
                       actual_time_data_points,first_trace_plot1,plot_info.data_file,0,0,0,$
                       plot_color[i],0,plot_color[i],plot_info,time_data_points,reverse_flag
	ENDIF ELSE BEGIN

           ;Switch the data so that the lowest frequency information is at the beginning
           N_bottom = (last_fft - first_fft)/2+1
           N_end = (last_fft - first_fft)

           temp1 = freq_data_points[i, N_bottom : N_end]
           temp2 = freq_data_points[i, 1: N_bottom]
           temp1 = REFORM(temp1)
           temp2 = REFORM(temp2)
	   actual_freq_data_points = [temp1, temp2]

           ;Create the frequency axis in units of HZ
           bandwidth = 1/data_file_header.dwell
           delta_freq = bandwidth/ (last_fft - first_fft+1)
           temp3 = FINDGEN((last_fft - first_fft)/2+2)
           temp4 = REVERSE(temp3)
           temp5 = temp4 * (-1.0)
           temp6 = FINDGEN((last_fft - first_fft)/2+1)
           temp7 = temp6[1: (last_fft - first_fft)/2]
           freq_point_index = [temp5 , temp7]

           ; To shift the x-axis must determine how many points to shift from the current position
	   ; This value should be assigned to point_shift (below)
	   ; This value is also used to modify the XRANGE specifier of the plot command (below)
	   ; Must ensure that this works in all windows and in both Hz and PPM mode

	   IF (reverse_flag EQ 0) THEN BEGIN
		freq = ((-1*freq_point_index) -  point_shift) * delta_freq
	   ENDIF ELSE BEGIN
	   	freq = (freq_point_index -  point_shift) * delta_freq
	   ENDELSE

           help,freq

	   AUTO_SCALE

	   freq_x_axis_title = 'Frequency (Hz)'

           ;Check to see if the data is plotted in Hz or PPM
           IF (plot_info.xaxis EQ 1) THEN BEGIN
              freq = freq / data_file_header.frequency
              freq_x_axis_title = 'Frequency (ppm)'
           ENDIF

           WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.freq_xmin
           WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.freq_xmax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = plot_info.freq_ymin
           WIDGET_CONTROL, Y_MAX, SET_VALUE = plot_info.freq_ymax

           ; isAbs = false
           ; rangeIn = true
           ; ptsSub = false

           display_plot,i,plot_info.freq_xmin,plot_info.freq_xmax,$
                       plot_info.freq_ymin,plot_info.freq_ymax,freq_x_axis_title,freq,$
                       actual_freq_data_points,first_trace_plot1,plot_info.data_file,0,1,0,$
                       plot_color[i],0,plot_color[i],plot_info,time_data_points,reverse_flag

        ENDELSE

     	ENDIF

  ENDFOR
END

pro setUPPlot
        COMMON common_vars

        IF (!D.name EQ 'X' ) THEN BEGIN
  		IF(print_flag) THEN BEGIN
  			ASSIGN_COLOURS
			PRINT_SET_PLOT_REGION
  		ENDIF ELSE BEGIN
			IF (Clear_Flag EQ 0) THEN BEGIN
				ASSIGN_COLOURS
			ENDIF
			SET_PLOT_REGION
 		ENDELSE
  	ENDIF
  	IF(!D.name EQ 'MAC' ) THEN BEGIN
  		IF (print_flag) THEN BEGIN
  			ASSIGN_COLOURS
  			PRINT_SET_PLOT_REGION
  		ENDIF ELSE BEGIN
  			IF (Clear_Flag EQ 0) THEN BEGIN
  				ASSIGN_MAC_COLORS
  			ENDIF
  			SET_PLOT_REGION
  		ENDELSE
  	ENDIF

    IF(!D.name EQ 'WIN' ) THEN BEGIN
     IF (print_flag) THEN BEGIN
         ASSIGN_COLOURS
         PRINT_SET_PLOT_REGION
     ENDIF ELSE BEGIN
         IF (Clear_Flag EQ 0) THEN BEGIN
            ASSIGN_COLOURS
         ENDIF
         SET_PLOT_REGION
     ENDELSE
    ENDIF




end

; Displays plots on the screen

;==================================================================================================
;Name: display_plot
;Purpose: to display the plot on the screen
;
;Parameters:
; i             - the index of the line in the data array
; p_xmin        - the minimum x value of the plot
; p_xmax        - the max x value of the plot
; p_ymin        - the min value of the plot
; xTitle        - the title of the x-axis
; m_plot        - the x values of the plot
; actual_points - the y values of the plot
; trace_plot    - a boolean value to determine whether or not to draw the axis of the plot
; p_title       - the title of the plot
; isABS         - a flag to determine whether or not to absolute-value the offset or make it
;                 negative
; rangeIn       - a boolean value, when rangeIn=1 the Xrange of the plot is included in the
;                 call to oplot.
; ptsSub        - a boolean value, when ptsSub = 1, the offset is added to the array:
;                 actual_points[i,*], when 0 actual_points
; plotColor     - the color of the plot of type ie middle_plot_color[i]
; sameColor     - a boolean value, when 1 the imaginary and real are drawn in the same color
; offSetClr     - the offset, pass the var: middle_plot_color[i] or the appropriate var
;                 for the window.
; p_info        - the plot info structure
; timeDataPoints- the <middle/bottom/top>_time_data_points
; reverseFlag   - a flag to show if the label on x-axis should be reversed
;
;Pre-Condition: ALL OF THE PARAMETERS DESCRIBED ABOVE ARE GIVEN AND THEY HAVE THE CORRECT
;               VALUES
;
;Post-Condition: a plot is drawn on the screen
;
;Returns: none
;Author: John-Paul Lobos
;=========================================================================================


pro display_plot, i,p_xmin, p_xmax,p_ymin,p_ymax,xTitle,m_plot,actual_points,trace_plot,$
                  p_title, isABS,rangeIn,ptsSub,plotColor,sameColor, offSetClr,p_info,$
                  timeDataPoints,reverseFlag

           ;print,'in display_plot'


           COMMON common_vars

           realArr = 0
           imArr = 0
           cOffset = 0
           clr = 0

           if(isABS eq 1) then begin
               cOffset = ABS(offSetClr.offset)
           endif else begin
               cOffset= -offSetClr.offset
           endelse

           if(ptsSub eq 1) then begin
               realArr = FLOAT(actual_points[i,*])+cOffset
               imArr =  IMAGINARY(actual_points[i,*])+cOffset
           endif else begin
               realArr = FLOAT(actual_points)+cOffset
               imArr =  IMAGINARY(actual_points)+cOffset
           endelse

           if(sameColor eq 1) then begin
               clr = plotColor.creal
           endif else begin
               clr = plotColor.cimag
           endelse

           IF (trace_plot EQ 0) THEN BEGIN
                trace_plot = 1

                if(rangeIn eq 1) then begin

                  if(p_info.domain eq 1) then begin
                     if(reverseFlag eq 0) then begin
                        PLOT, [p_xmin, p_xmax],[p_ymin, p_ymax],XTITLE = xTitle, YTITLE = 'Intensity (a.u.)',$
                        color = p_info.axis_colour,XRANGE = [p_xmax, p_xmin],TITLE=p_title, /NODATA
                     endif else begin
                        PLOT, [p_xmin, p_xmax],[p_ymin, p_ymax],XTITLE = xTitle, YTITLE = 'Intensity (a.u.)',$
                        color = p_info.axis_colour,XRANGE = [p_xmin, p_xmax],TITLE=p_title, /NODATA
                     endelse
                  endif else begin
                      PLOT, [p_xmin, p_xmax],[p_ymin, p_ymax],XTITLE = xTitle, YTITLE = 'Intensity (a.u.)',$
                      color = p_info.axis_colour,XRANGE = [p_xmax, p_xmin],TITLE=p_title, /NODATA
                  endelse

                endif else begin
                   PLOT, [p_xmin, p_xmax],[p_ymin, p_ymax],XTITLE = xTitle, YTITLE = 'Intensity (a.u.)',$
                   color = p_info.axis_colour,TITLE=p_title, /NODATA
                endelse
           ENDIF

           IF ( float(timeDataPoints[i,0]) EQ 1 and imaginary(timeDataPoints[i,0])EQ 0) THEN BEGIN
                ; plot real

                ;print,m_plot

                OPLOT, m_plot, realArr, LINESTYLE=0, $
		color = plotColor.creal, THICK = offSetClr.thick

           ENDIF
           IF (float(timeDataPoints[i,0]) EQ 0 and imaginary(timeDataPoints[i,0]) EQ 1) THEN BEGIN
             ; plot imaginary

             OPLOT, m_plot, imArr, $
             LINESTYLE=0, color = clr, THICK = offSetClr.thick

	ENDIF
        IF (float(timeDataPoints[i,0]) EQ 1 and imaginary(timeDataPoints[i,0]) EQ 1) THEN BEGIN
                ; plot both real and imaginary

                OPLOT, m_plot, realArr, LINESTYLE=0, $
		color = plotColor.creal, THICK = offSetClr.thick

                OPLOT, m_plot, imArr, LINESTYLE=0, $
		color = clr, THICK = offSetClr.thick
         ENDIF
end

PRO MIDDLE_DISPLAY_DATA
	  ;This procedure displays the data

  	COMMON common_vars
  	COMMON common_widgets
        COMMON draw1_comm
 	COMMON plot_variables ; sharing these variables, so that other procs can use the plot data
	COMMON recon, middle_recon

        if(middle_plot_info.data_file eq '') then begin
           return
        endif

  	first_fft = fix(middle_plot_info.fft_initial/middle_data_file_header.dwell)
  	last_fft = fix(middle_plot_info.fft_final/middle_data_file_header.dwell)-1

  	first_trace_plot1 = 0
  	first_trace_plot2 = 0

        ;if(repaint eq 0) then begin
          setUPPlot
        ;endif



     	FOR i=middle_plot_info.first_trace,middle_plot_info.last_trace DO BEGIN

     		middle_plot_info.current_curve = i

     		IF (ABS(middle_time_data_points[i,0]) GT 0 AND i LE 2) THEN BEGIN

        	IF (middle_plot_info.domain EQ 0) THEN BEGIN
                ; time
           		AUTO_SCALE

           		middle_actual_time_data_points = REFORM(middle_time_data_points[i, $
			fix(middle_plot_info.time_xmin/middle_data_file_header.dwell)+1:$
			(fix(middle_plot_info.time_xmax/middle_data_file_header.dwell)+1)])

           	time = middle_point_index * middle_data_file_header.dwell
	      	actual_time = EXTRAC(time, middle_plot_info.time_xmin/middle_data_file_header.dwell, $
		middle_plot_info.time_xmax/middle_data_file_header.dwell-middle_plot_info.time_xmin/middle_data_file_header.dwell)

           	WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.time_xmin
           	WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.time_xmax
           	WIDGET_CONTROL, Y_MIN, SET_VALUE = middle_plot_info.time_ymin
           	WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.time_ymax

                display_plot,i,middle_plot_info.time_xmin,middle_plot_info.time_xmax,$
                       middle_plot_info.time_ymin,middle_plot_info.time_ymax,'Time (s)',actual_time,$
                       middle_actual_time_data_points,first_trace_plot1,middle_plot_info.data_file,0,0,0,$
                       middle_plot_color[i],0, middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2

	ENDIF ELSE BEGIN

           ;Switch the data so that the lowest frequency information is at the beginning
           N_middle = (last_fft - first_fft)/2+1
           N_end = (last_fft - first_fft)
           temp1 = middle_freq_data_points[i, N_middle : N_end]
           temp2 = middle_freq_data_points[i, 1: N_middle]
           temp1 = REFORM(temp1)
           temp2 = REFORM(temp2)
           middle_actual_freq_data_points = [temp1, temp2 ]

	   IF(i EQ 1) THEN BEGIN
		middle_recon = FLTARR(N_ELEMENTS(middle_actual_freq_data_points))
		middle_recon = middle_actual_freq_data_points
	   ENDIF

           ;Create the frequency axis in units of HZ
           bandwidth = 1/middle_data_file_header.dwell
           delta_freq = bandwidth/ (last_fft - first_fft+1)
           temp3 = FINDGEN((last_fft - first_fft)/2+2)
           temp4 = REVERSE(temp3)
           temp5 = temp4 * (-1.0)
           temp6 = FINDGEN((last_fft - first_fft)/2+1)
           temp7 = temp6[1: (last_fft - first_fft)/2]
           freq_point_index = [temp5 , temp7]

           ; To shift the x-axis must determine how many points to shift from the current position
	   ; This value should be assigned to point_shift (below)
	   ; This value is also used to modify the XRANGE specifier of the plot command (below)
	   ; Must ensure that this works in all windows and in both Hz and PPM mode


	   IF (reverse_flag2 EQ 0) THEN BEGIN
		middle_freq = ((-1*freq_point_index) -  middle_point_shift) * delta_freq

	   ENDIF ELSE BEGIN
	   	middle_freq = (freq_point_index -  middle_point_shift) * delta_freq
	   ENDELSE

           AUTO_SCALE


	   freq_x_axis_title = 'Frequency (Hz)'

           ;Check to see if the data is plotted in Hz or PPM
           IF (middle_plot_info.xaxis EQ 1) THEN BEGIN
              middle_freq = middle_freq / middle_data_file_header.frequency
              freq_x_axis_title = 'Frequency (ppm)'
           ENDIF

           WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.freq_xmin
           WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.freq_xmax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = middle_plot_info.freq_ymin
           WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.freq_ymax

           display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
                       middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,freq_x_axis_title,middle_freq,$
                       middle_actual_freq_data_points,first_trace_plot1,middle_plot_info.data_file,1,1,0,$
                       middle_plot_color[i],0,middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2

        ENDELSE

     	ENDIF

     	IF (ABS(middle_time_data_points[i,0]) GT 0 AND i GT 2) THEN BEGIN

		; Define plot color...cycle through available colours

        	IF (middle_plot_info.view EQ 0 OR middle_plot_info.view eq 2) THEN BEGIN
	    		middle_plot_color[i].creal = 1
	    		middle_plot_color[i].cimag = 1
        	ENDIF ELSE BEGIN
           		middle_plot_color [i].creal = 0
           		middle_plot_color [i].cimag = 0
        	ENDELSE

        	IF (middle_plot_info.domain EQ 0) THEN BEGIN
                ; time
           		AUTO_SCALE

           	middle_actual_time_data_points = REFORM(middle_time_data_points[i, $
		fix(middle_plot_info.time_xmin/middle_data_file_header.dwell):$
		fix(middle_plot_info.time_xmax/middle_data_file_header.dwell)-1])

           	time = middle_point_index * middle_data_file_header.dwell

                display_plot,i,middle_plot_info.time_xmin,middle_plot_info.time_xmax,$
                       middle_plot_info.time_ymin,middle_plot_info.time_ymax,'Time (s)',time,$
                       middle_actual_time_data_points,first_trace_plot2,'',0,0,0,$
                       middle_plot_color[i],0,middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2

        ENDIF ELSE BEGIN
           ;Switch the data so that the lowest frequency information is at the beginning

           IF (i EQ 3) AND (middle_plot_info.fft_recalc EQ 1) THEN BEGIN
              	N_middle = (last_fft - first_fft)/2+1
              	N_end = (last_fft - first_fft)
              	temp1 = middle_freq_data_points[*, N_middle : N_end]
              	temp2 = middle_freq_data_points[*, 1: N_middle]
              	actual_freq_temp = [TRANSPOSE(temp1), TRANSPOSE(temp2) ]
              	middle_actual_freq_data_points = TRANSPOSE(actual_freq_temp)

              	;Create the frequency axis in units of HZ
              	bandwidth = 1/middle_data_file_header.dwell
              	delta_freq = bandwidth/ (last_fft - first_fft)
              	temp3 = FINDGEN((last_fft - first_fft)/2+2)
              	temp4 = REVERSE(temp3)
              	temp5 = temp4 * (-1.0)
              	temp6 = FINDGEN((last_fft - first_fft)/2+1)
             	temp7 = temp6[1: (last_fft - first_fft)/2]
              	freq_point_index = [temp5 , temp7]

	        IF (reverse_flag2 EQ 0) THEN BEGIN
		   middle_freq = ((-1*freq_point_index) -  middle_point_shift) * delta_freq

	        ENDIF ELSE BEGIN
	   	   middle_freq = (freq_point_index -  middle_point_shift) * delta_freq

	        ENDELSE

                AUTO_SCALE

	        freq_x_axis_title = 'Frequency (Hz)'

                ;Check to see if the data is plotted in Hz or PPM
                IF (middle_plot_info.xaxis EQ 1) THEN BEGIN
                   middle_freq = middle_freq / middle_data_file_header.frequency
                   freq_x_axis_title = 'Frequency (ppm)'
                ENDIF

                WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.freq_xmin
                WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.freq_xmax
                WIDGET_CONTROL, Y_MIN, SET_VALUE = middle_plot_info.freq_ymin
                WIDGET_CONTROL, Y_MAX, SET_VALUE = middle_plot_info.freq_ymax


 	   ENDIF

           if(not(OBJ_VALID(compSelect))) then begin
                compSelect = obj_new('List')
           endif

           if(compSelect->isEmpty() OR compSelect->findIndex(i) ne compSelect->size()) then begin
              display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
                       middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,freq_x_axis_title,middle_freq,$
                       middle_actual_freq_data_points,first_trace_plot2,'',1,1,1,$
                       middle_plot_color[i],0,middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2
           endif

        ENDELSE

     ENDIF

  ENDFOR


END


PRO BOTTOM_DISPLAY_DATA
	  ;This procedure displays the data

  	COMMON common_vars
  	COMMON common_widgets
	COMMON plot_variables ; sharing these variables so that other procedures can use te data

        if(bottom_plot_info.data_file eq '') then begin
           return
        endif

  	first_fft = fix(bottom_plot_info.fft_initial/bottom_data_file_header.dwell)
  	last_fft = fix(bottom_plot_info.fft_final/bottom_data_file_header.dwell)-1

  	first_trace_plot1 = 0
  	first_trace_plot2 = 0

        ;if(repaint eq 0) then begin
          setUPPlot
        ;endif

     	FOR i=bottom_plot_info.first_trace, bottom_plot_info.last_trace DO BEGIN

     		bottom_plot_info.current_curve = i

     		IF (ABS(bottom_time_data_points[i,0]) GT 0 AND i LE 2) THEN BEGIN

        	IF (bottom_plot_info.domain EQ 0) THEN BEGIN

           		AUTO_SCALE

           		bottom_actual_time_data_points = REFORM(bottom_time_data_points[i, $
			fix(bottom_plot_info.time_xmin/bottom_data_file_header.dwell)+1:$
			(fix(bottom_plot_info.time_xmax/bottom_data_file_header.dwell)+1)])

           	time = bottom_point_index * bottom_data_file_header.dwell
	      	actual_time = EXTRAC(time, bottom_plot_info.time_xmin/bottom_data_file_header.dwell, $
	       bottom_plot_info.time_xmax/bottom_data_file_header.dwell-bottom_plot_info.time_xmin/bottom_data_file_header.dwell)

           	WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
           	WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
           	WIDGET_CONTROL, Y_MIN, SET_VALUE = bottom_plot_info.time_ymin
           	WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax

                display_plot,i,bottom_plot_info.time_xmin,bottom_plot_info.time_xmax,$
                          bottom_plot_info.time_ymin,bottom_plot_info.time_ymax,'Time (s)',actual_time,$
                          bottom_actual_time_data_points,first_trace_plot1,bottom_plot_info.data_file,0,0,0,$
                          bottom_plot_color[i],0,bottom_plot_color[i],bottom_plot_info,bottom_time_data_points,reverse_flag3
	ENDIF ELSE BEGIN

           ;Switch the data so that the lowest frequency information is at the beginning
           N_bottom = (last_fft - first_fft)/2+1
           N_end = (last_fft - first_fft)
           temp1 = bottom_freq_data_points[i, N_bottom : N_end]
           temp2 = bottom_freq_data_points[i, 1: N_bottom]
           temp1 = REFORM(temp1)
           temp2 = REFORM(temp2)
           bottom_actual_freq_data_points = [temp1, temp2 ]

           ;Create the frequency axis in units of HZ
           bandwidth = 1/bottom_data_file_header.dwell
           delta_freq = bandwidth/ (last_fft - first_fft+1)
           temp3 = FINDGEN((last_fft - first_fft)/2+2)
           temp4 = REVERSE(temp3)
           temp5 = temp4 * (-1.0)
           temp6 = FINDGEN((last_fft - first_fft)/2+1)
           temp7 = temp6[1: (last_fft - first_fft)/2]
           freq_point_index = [temp5 , temp7]

           ; To shift the x-axis must determine how many points to shift from the current position
	   ; This value should be assigned to point_shift (below)
	   ; This value is also used to modify the XRANGE specifier of the plot command (below)
	   ; Must ensure that this works in all windows and in both Hz and PPM mode

	   IF (reverse_flag3 EQ 0) THEN BEGIN
		bottom_freq = ((-1*freq_point_index) -  bottom_point_shift) * delta_freq

	   ENDIF ELSE BEGIN
	   	bottom_freq = (freq_point_index -  bottom_point_shift) * delta_freq

	   ENDELSE

           AUTO_SCALE

	   freq_x_axis_title = 'Frequency (Hz)'

           ;Check to see if the data is plotted in Hz or PPM
           IF (bottom_plot_info.xaxis EQ 1) THEN BEGIN
              bottom_freq = bottom_freq / bottom_data_file_header.frequency
              freq_x_axis_title = 'Frequency (ppm)'
           ENDIF

           WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.freq_xmin
           WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.freq_xmax
           WIDGET_CONTROL, Y_MIN, SET_VALUE = bottom_plot_info.freq_ymin
           WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.freq_ymax

           display_plot,i,bottom_plot_info.freq_xmin,bottom_plot_info.freq_xmax,$
                          bottom_plot_info.freq_ymin,bottom_plot_info.freq_ymax,freq_x_axis_title,bottom_freq,$
                          bottom_actual_freq_data_points,first_trace_plot1,bottom_plot_info.data_file,0,1,0,$
                          bottom_plot_color[i],0,bottom_plot_color[i],bottom_plot_info,bottom_time_data_points,reverse_flag3
        ENDELSE


     ENDIF

  ENDFOR


END
;==========================================================================================================
PRO READ_FITMAN_DATA

  ;This procedure reads the parameters from the data file's procpar file that are
  ;required for the dw.pro main procedure.

  COMMON common_vars

  parms = ''	;variable for reading in lines of code of variable lengths
  realv = ''
  imagv = ''


  IF(imported_data_filename EQ "") THEN BEGIN
	;Open dialog part for data read
	IF (NoInput_Flag EQ 0) THEN BEGIN
  		;Pick a file to read
	  	IF (!d.name EQ 'X') THEN $
  			data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.dat', /MUST_EXIST)
	  	IF (!d.name EQ 'MAC') THEN $
    			data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.dat', /MUST_EXIST)
	  	IF (!D.name EQ 'WIN') THEN $
    			data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.dat', /MUST_EXIST)
	ENDIF ELSE BEGIN
		data_file = plot_info.data_file
	ENDELSE
   ENDIF ELSE BEGIN
         ;Import part for data read
         data_file = imported_data_filename 
   ENDELSE

  IF (data_file EQ '') THEN BEGIN
	error_flag = 1
	RETURN
  ENDIF

  plot_info.data_file = data_file
  openr, unit, plot_info.data_file, /GET_LUN	;opens data file

  ;Read header information

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.points = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.components = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.dwell = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.frequency = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.scans = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.comment1 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.comment2 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.comment3 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.comment4 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.acq_type = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.increment = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  data_file_header.empty = (STRMID(parms, 0))

  index = ((data_file_header.points/2))

  FOR i = 1, index DO BEGIN

     repeat begin
        null_string = 1
        readf, unit, realv
        if realv EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.


     repeat begin
        null_string = 1
        readf, unit, imagv
        if imagv EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.

    time_data_points[0, i] = COMPLEX(FLOAT(STRMID(realv,0)), FLOAT(STRMID(imagv,0)))

  ENDFOR

  CLOSE, unit
  FREE_LUN, unit


  ;Define variables ppm and hertz
  guess_variables[0].name = 'PPM'
  guess_variables[0].gvalue = data_file_header.frequency/1000000
  guess_variables[1].name = 'HERTZ'
  guess_variables[1].gvalue = 1000000/data_file_header.frequency

  guess_info.number_variables = 2
  guess_info.frequency = data_file_header.frequency*1000000


END

PRO MIDDLE_READ_FITMAN_DATA
  ;This procedure reads the parameters from the data file's procpar file that are
  ;required for the dw.pro main procedure.

  COMMON common_vars

  parms = ''	;variable for reading in lines of code of variable lengths
  realv = ''
  imagv = ''

  ;Pick a file to read

	
  IF(imported_data_filename EQ "") THEN BEGIN
	;Open dialog part for data read
	 IF (NoInput_Flag EQ 0) THEN BEGIN
		IF (!D.name EQ 'X') THEN $
	       		data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath,FILTER = '*.dat', /MUST_EXIST)
	      	IF (!D.name EQ 'MAC') THEN $
	       		data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.dat', /MUST_EXIST)
	      	IF (!D.name EQ 'WIN') THEN $
      		 	data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.dat', /MUST_EXIST)
	  ENDIF ELSE BEGIN
		data_file = middle_plot_info.data_file
	  ENDELSE
   ENDIF ELSE BEGIN
         ;Import part for data read
         data_file = imported_data_filename 
   ENDELSE

  IF (data_file EQ '') THEN BEGIN
	error_flag = 1
	RETURN
  ENDIF
  middle_plot_info.data_file = data_file
  openr, unit, middle_plot_info.data_file, /GET_LUN	;opens data file


  ;Read header information

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.points = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.components = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.dwell = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.frequency = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.scans = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.comment1 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.comment2 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.comment3 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.comment4 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.acq_type = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.increment = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  middle_data_file_header.empty = (STRMID(parms, 0))

  index = ((middle_data_file_header.points/2))

  FOR i = 1, index DO BEGIN

     repeat begin
        null_string = 1
        readf, unit, realv
        if realv EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.


     repeat begin
        null_string = 1
        readf, unit, imagv
        if imagv EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.

    middle_time_data_points[0, i] = COMPLEX(FLOAT(STRMID(realv,0)), FLOAT(STRMID(imagv,0)))

  ENDFOR

  CLOSE, unit
  FREE_LUN, unit

  ;Define variables ppm and hertz
  middle_guess_variables[0].name = 'PPM'
  middle_guess_variables[0].gvalue = middle_data_file_header.frequency/1000000
  middle_guess_variables[1].name = 'HERTZ'
  middle_guess_variables[1].gvalue = 1000000/middle_data_file_header.frequency

  middle_guess_info.number_variables = 2
  middle_guess_info.frequency = middle_data_file_header.frequency*1000000
END


PRO BOTTOM_READ_FITMAN_DATA
  ;This procedure reads the parameters from the data file's procpar file that are
  ;required for the dw.pro main procedure.

  COMMON common_vars

  parms = ''	;variable for reading in lines of code of variable lengths
  realv = ''
  imagv = ''


  IF(imported_data_filename EQ "") THEN BEGIN
	;Open dialog part for data read
  	IF (NoInput_Flag EQ 0) THEN BEGIN
	  	IF (!D.name EQ 'X') THEN $
		       data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath,FILTER = '*.dat', /MUST_EXIST)
	      	IF (!D.name EQ 'MAC') THEN $
       			data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.dat', /MUST_EXIST)
      		IF (!D.name EQ 'WIN') THEN $
       			data_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.dat', /MUST_EXIST)
  	ENDIF ELSE BEGIN
		data_file = bottom_plot_info.data_file
  	ENDELSE
   ENDIF ELSE BEGIN
         ;Import part for data read
         data_file = imported_data_filename 
   ENDELSE

  IF (data_file EQ '') THEN BEGIN
	error_flag = 1
	RETURN
  ENDIF

  bottom_plot_info.data_file = data_file
  openr, unit, bottom_plot_info.data_file, /GET_LUN	;opens data file

  ;Read header information

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.points = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.components = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.dwell = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.frequency = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.scans = FIX(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.comment1 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.comment2 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.comment3 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.comment4 = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.acq_type = (STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.increment = FLOAT(STRMID(parms, 0))

  repeat begin
     null_string = 1
     readf, unit, parms
     if parms EQ "" THEN null_string = 0
  endrep until null_string ;reads next line of file.

  bottom_data_file_header.empty = (STRMID(parms, 0))

  index = ((bottom_data_file_header.points/2))

  FOR i = 1, index DO BEGIN

     repeat begin
        null_string = 1
        readf, unit, realv
        if realv EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.


     repeat begin
        null_string = 1
        readf, unit, imagv
        if imagv EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.

    bottom_time_data_points[0, i] = COMPLEX(FLOAT(STRMID(realv,0)), FLOAT(STRMID(imagv,0)))

  ENDFOR

  CLOSE, unit
  FREE_LUN, unit

  ;Define variables ppm and hertz
  bottom_guess_variables[0].name = 'PPM'
  bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
  bottom_guess_variables[1].name = 'HERTZ'
  bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency

  bottom_guess_info.number_variables = 2
  bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
END

;==========================================================================================================
PRO GENERATE_FREQUENCY

  COMMON common_vars
  COMMON draw1_comm

  IF (Window_Flag EQ 1) THEN BEGIN
     plot_info.domain = 1

     ; Convert data to the frequency domain

     first_fft = fix(plot_info.fft_initial/data_file_header.dwell)+1
     last_fft = fix(plot_info.fft_final/data_file_header.dwell)

     for i=0, plot_info.traces DO BEGIN

     	actual_time_data_points = REFORM(time_data_points[i, first_fft:last_fft])


        ; correction made by Tim Orr.  Although forcing the number of points to be Fourier transformed
        ; reduces the time for the FFT algorithm to complete, padding the time_data array with zeros
        ; changes the shape of the graph.  As such, the code previously present that did this was
        ; removed.

        points_to_FFT = N_ELEMENTS(actual_time_data_points)

	; FFT the data
	freq_data_points[i,1:N_ELEMENTS(actual_time_data_points)] = FFT(actual_time_data_points)

     ENDFOR

   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
     middle_plot_info.domain = 1

     ; Convert data to the frequency domain

     first_fft = fix(middle_plot_info.fft_initial/middle_data_file_header.dwell)+1
     last_fft = fix(middle_plot_info.fft_final/middle_data_file_header.dwell)

     ; Variable back_substitute added for back extrapolation set to 0 for back extraplolation 2 for none
     back_substitute = extrapToZero
     fft_initial_temp = middle_plot_info.fft_initial

     for i=0, middle_plot_info.traces DO BEGIN

       	; Check to see if back extrapolation requested
	; Added for back extrapolation
       	IF ((i EQ 0) AND (middle_plot_info.traces GT 0) AND (first_fft GT 1) AND (back_substitute EQ 0)) THEN BEGIN
	   specified_first_fft = first_fft
	   first_fft = 1

	   middle_plot_info.fft_initial = 0
	   back_substitute = 1
       	ENDIF

	middle_actual_time_data_points = REFORM(middle_time_data_points[i, first_fft:last_fft])

        ; If back extrapolation requested, substitute the points between 1 and specified_first_fft
	; for curve 0 with the respective data points from curve 2

       	IF ((i EQ 0) AND (back_substitute EQ 1)) THEN BEGIN
           middle_actual_time_data_points[first_fft-1:specified_first_fft-2] = REFORM(middle_time_data_points[1,first_fft:specified_first_fft-1])
       	ENDIF

        points_to_FFT = N_ELEMENTS(middle_actual_time_data_points)

	; FFT the data
	; correction made by Tim Orr to ensure that plot is not shifted after being Fourier-transformed

	if(i eq 0) then middle_temp = (middle_actual_time_data_points)

     	if(i ne 2 or extrapToZero eq 2) then begin
        middle_freq_data_points[i,1:N_ELEMENTS(middle_actual_time_data_points)] = $
		FFT(middle_actual_time_data_points)
        endif else begin
        middle_freq_data_points[i,1:N_ELEMENTS(middle_actual_time_data_points)] = $
	    FFT(middle_temp-middle_time_data_points[1,1:N_ELEMENTS(middle_actual_time_data_points)])
        endelse

     ENDFOR

     middle_plot_info.fft_initial = fft_initial_temp

   ENDIF

   IF (Window_Flag EQ 3) THEN BEGIN
     bottom_plot_info.domain = 1

     ; Convert data to the frequency domain

     first_fft = fix(bottom_plot_info.fft_initial/bottom_data_file_header.dwell)+1
     last_fft = fix(bottom_plot_info.fft_final/bottom_data_file_header.dwell)

     for i=0, bottom_plot_info.traces DO BEGIN
	bottom_actual_time_data_points = REFORM(bottom_time_data_points[i, first_fft:last_fft])

	; correction made by Tim Orr to ensure that plot did not shift.  The FFT finals which are
	; not base-2 will not be padded with zeroes.
        points_to_FFT = N_ELEMENTS(bottom_actual_time_data_points)

	; FFT the data
     	bottom_freq_data_points[i,1:N_ELEMENTS(bottom_actual_time_data_points)] = $
		FFT(bottom_actual_time_data_points)
     ENDFOR
   ENDIF
END

;======================================================================================================

PRO PHASE_TIME_DOMAIN_DATA

   COMMON common_vars

   IF (Window_Flag EQ 1) THEN BEGIN
   	phase_applied =  (plot_info.phase/180.0)*!PI - plot_info.current_phase
        plot_info.traces =3
   	plot_info.current_phase = (plot_info.phase/180)*!PI

   	display_holder = time_data_points[0:plot_info.traces,0]

   	data_magnitude = ABS(time_data_points[0:plot_info.traces,*])
   	data_phase = ATAN(imaginary(time_data_points[0:plot_info.traces,*]), float(time_data_points[0:plot_info.traces,*])) - phase_applied

   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)

   	time_data_points[0:plot_info.traces, *] = complex(data_real, data_imag)

   	time_data_points[0:plot_info.traces,0] = display_holder

   	data_magnitude = ABS(original_data)
   	data_phase = ATAN(imaginary(original_data), float(original_data)) - phase_applied

   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)


   	original_data = complex(data_real, data_imag)

   	;Reassign plot identifier from above
   	original_data[0] =time_data_points[0,0]
   ENDIF

   IF (Window_Flag EQ 2) THEN BEGIN

	;IF (guess_just_read EQ 1) THEN BEGIN
	;   phase_applied =  0  - middle_plot_info.current_phase
   	;   guess_just_read = 0
	;'ENDIF ELSE BEGIN
	   phase_applied =  (middle_plot_info.phase/180.0)*!PI - middle_plot_info.current_phase
   	;ENDELSE


   	middle_plot_info.current_phase = (middle_plot_info.phase/180)*!PI

   	display_holder = middle_time_data_points[0:middle_plot_info.traces,0]

   	data_magnitude = ABS(middle_time_data_points[0:middle_plot_info.traces,*])
   	data_phase = ATAN(imaginary(middle_time_data_points[0:middle_plot_info.traces,*]), float(middle_time_data_points[0:middle_plot_info.traces,*])) - phase_applied

   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)

   	middle_time_data_points[0:middle_plot_info.traces, *] = complex(data_real, data_imag)

   	middle_time_data_points[0:middle_plot_info.traces,0] = display_holder


   	data_magnitude = ABS(middle_original_data)
   	data_phase = ATAN(imaginary(middle_original_data), float(middle_original_data)) - phase_applied

   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)


   	middle_original_data = complex(data_real, data_imag)

   	;Reassign plot identifier from above
   	middle_original_data[0] = middle_time_data_points[0,0]

   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
   	phase_applied =  (bottom_plot_info.phase/180.0)*!PI - bottom_plot_info.current_phase

   	bottom_plot_info.current_phase = (bottom_plot_info.phase/180)*!PI

   	display_holder = bottom_time_data_points[0:bottom_plot_info.traces,0]

   	data_magnitude = ABS(bottom_time_data_points[0:bottom_plot_info.traces,*])
   	data_phase = ATAN(imaginary(bottom_time_data_points[0:bottom_plot_info.traces,*]), float(bottom_time_data_points[0:bottom_plot_info.traces,*])) - phase_applied

   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)

   	bottom_time_data_points[0:bottom_plot_info.traces, *] = complex(data_real, data_imag)

   	bottom_time_data_points[0:bottom_plot_info.traces,0] = display_holder


   	data_magnitude = ABS(bottom_original_data)
   	data_phase = ATAN(imaginary(bottom_original_data), float(bottom_original_data)) - phase_applied

   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)


   	bottom_original_data = complex(data_real, data_imag)

   	;Reassign plot identifier from above
   	bottom_original_data[0] = bottom_time_data_points[0,0]
   ENDIF


END

;===================================================================================================================


PRO MIDDLE_READ_GUESS_FILE,RELOAD_OUTPUT=reloadOut


  COMMON common_vars


  line = ''	;variable for reading in lines of code of variable lengths
  realv = ''
  imagv = ''

  ;Pick a file to read
  if middle_plot_info.read_file_type EQ 0 THEN filter_type = '*.ges'
  if middle_plot_info.read_file_type EQ 1 THEN filter_type = '*.out'

  if(reloadGC ne 1 and not (keyword_set(reloadOut))) then begin
     middle_plot_info.guess_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = filter_type)
  endif

  filename = STRSPLIT(middle_plot_info.guess_file, '.',/EXTRACT)

  IF (filename[N_ELEMENTS(filename)-1] NE 'ges' AND $
	filename[N_ELEMENTS(filename)-1] NE 'out') THEN RETURN

  openr, unit, middle_plot_info.guess_file, /GET_LUN	;opens guess file

  WIDGET_CONTROL, /HOURGLASS
  middle_guess_info.number_variables = 0
  ;Determine if Guess File is valid
  repeat begin
     middle_guess_info.guess_file_label = 0
     IF (NOT EOF(unit)) THEN BEGIN
        readf, unit, line
        upper_line = STRUPCASE(line)
     ENDIF ELSE BEGIN
	CLOSE, unit
	FREE_LUN, unit
        RETURN
     ENDELSE

     IF STRMID(upper_line,0,27) EQ "****_GUESS_FILE_BEGINS_****" THEN middle_guess_info.guess_file_label = 1
  endrep until middle_guess_info.guess_file_label ;looks for guess file identification.

  ;Read in one LINE at a time until the end of the Guess file section

  WHILE (NOT EOF(unit)) DO BEGIN
     section_just_defined = 'no'

     ;Read in the next line
     repeat begin
        null_string = 1
        readf, unit, line
        if line EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.

     upper_line = STRUPCASE(line)
     temp_string = STRCOMPRESS(STRUPCASE(line),/REMOVE_ALL)
     ;print,upper_line

     if (STRMID(upper_line,0,25) EQ "****_GUESS_FILE_ENDS_****") THEN BEGIN
     	CLOSE, unit
	FREE_LUN, unit
        RETURN

     ENDIF ELSE BEGIN

     if (STRMID(temp_string,0,1) NE ';') THEN BEGIN

        if (STRMID(upper_line,0,1) EQ '[') THEN BEGIN

           if(STRMID(upper_line,0,12) EQ '[PARAMETERS]') THEN section = 'parameters'
           if(STRMID(upper_line,0,11) EQ '[VARIABLES]') THEN section = 'variables'
           if(STRMID(upper_line,0,7) EQ '[PEAKS]') THEN section = 'peaks'

           section_just_defined = 'yes'

        ENDIF

        ; Read in the parameter section of the Guess file
        IF (section_just_defined EQ 'no') THEN BEGIN

           IF (section EQ 'parameters') THEN BEGIN

              ;Replace all tabs with spaces
 		   WHILE(((M = STRPOS(upper_line, '	'))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
		tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF (tokens[valid_tokens[0]] EQ 'NUMBER_PEAKS') THEN BEGIN
                 middle_guess_info.num_peaks =  tokens[valid_tokens[1]]
              ENDIF
	      ;IF (middle_plot_info.const_file EQ '') THEN BEGIN
              ;	middle_plot_info.num_linked_groups = middle_guess_info.num_peaks
		;middle_const_info.number_peaks = middle_guess_info.num_peaks
		;ENDIF
              IF (tokens[valid_tokens[0]] EQ 'SHIFT_UNITS') THEN BEGIN
                 middle_guess_info.shift_units =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'REFERENCE_FREQUENCY') THEN BEGIN
                                  trash =  tokens[valid_tokens[1]]
              ; value not read into guess_info.frequency becasue this value is obtained from the data file

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'CHI_SQUARED') THEN BEGIN
                 middle_guess_info.chi_squared =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'NOISE_STDEV_REAL') THEN BEGIN
                 middle_guess_info.std_real =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'NOISE_STDEV_IMAG') THEN BEGIN
                 middle_guess_info.std_imag =  tokens[valid_tokens[1]]

              ENDIF
           ENDIF



           IF (section EQ 'variables') THEN BEGIN

              ;Replace all tabs with spaces
 		   WHILE(((M = STRPOS(upper_line, '	'))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
	 	tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF(N_ELEMENTS(valid_tokens) GT 1) THEN BEGIN

                 middle_guess_info.number_variables = middle_guess_info.number_variables + 1

                 middle_guess_variables[middle_guess_info.number_variables-1].name = tokens[valid_tokens[0]]

                 middle_token_to_parse = tokens[valid_tokens[1]]
                 PARSE

                 middle_guess_variables[middle_guess_info.number_variables-1].gvalue = middle_param_value
              ENDIF

           ENDIF

           IF (section EQ 'peaks') THEN BEGIN


              ;Replace all tabs with spaces
 		   WHILE(((M = STRPOS(upper_line, '	'))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
		tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF(N_ELEMENTS(valid_tokens) EQ 7) THEN BEGIN

                 FOR M = 1, 6 DO BEGIN
                    ;Parse each token to resolve the guess file
		    middle_token_to_parse = tokens[valid_tokens[M]]
                    middle_param_value = 0.0

                    PARSE

                    middle_peak[M, tokens[valid_tokens[0]]].pvalue = middle_param_value
                 ENDFOR

              ENDIF ELSE BEGIN
                 print, 'Error reading peak information'
                 print, 'More than 7 elements on a peak line'

              ENDELSE

           ENDIF



        ENDIF
     ENDIF
     ENDELSE
  ENDWHILE

  CLOSE, unit
  FREE_LUN, unit

END

;===================================================================================================================


PRO MIDDLE_READ_CONSTRAINTS_FILE
  COMMON common_vars

  line = ''	;variable for reading in lines of code of variable lengths
  realv = ''
  imagv = ''

  middle_const_info.number_variables = 0
  test ='_'
  ;Pick a file to read

  if(reloadGC ne 1) then begin
     middle_plot_info.const_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.cst')
  endif

  filename = STRSPLIT(middle_plot_info.const_file, '.', /EXTRACT)

	IF (filename[N_ELEMENTS(filename)-1] NE 'cst' AND $
		filename[N_ELEMENTS(filename)-1] NE 'out') THEN RETURN

  IF (middle_plot_info.data_file EQ '') THEN RETURN
  openr, unit, middle_plot_info.const_file, /GET_LUN	;opens constraints file

  WIDGET_CONTROL, /HOURGLASS
  ;Determine if Constraints File is valid
  repeat begin
     middle_const_info.const_file_label = 0
     IF (NOT EOF(unit)) THEN BEGIN
        readf, unit, line
        upper_line = STRUPCASE(line)
     ENDIF ELSE BEGIN
        CLOSE, unit
	FREE_LUN, unit
	RETURN
     ENDELSE

     IF STRMID(upper_line,0,33) EQ "****_CONSTRAINTS_FILE_BEGINS_****" THEN middle_const_info.const_file_label = 1
  endrep until middle_const_info.const_file_label ;looks for guess file identification.

  ;Read in one LINE at a time until the end of the Guess file section

  WHILE (NOT EOF(unit)) DO BEGIN

     section_just_defined = 'no'

     ;Read in the next line
     repeat begin
        null_string = 1
        readf, unit, line
        if line EQ "" THEN null_string = 0
     endrep until null_string ;reads next line of file.

     upper_line = STRUPCASE(line)

     if (STRMID(upper_line,0,31) EQ "****_CONSTRAINTS_FILE_ENDS_****") THEN BEGIN
        	foo =  0
	for i = 0, 4059 do begin
	  for j = 0, 2 do begin
		if ( foo EQ 1) then break
		if ( time_data_points[j,i] NE middle_time_data_points[j,i]) THEN foo = 1
	ENDFOR
	ENDFOR

  	CLOSE, unit
  	FREE_LUN, unit

        RETURN

     ENDIF ELSE BEGIN

     if (STRMID(upper_line,0,1) NE ';') THEN BEGIN

        if (STRMID(upper_line,0,1) EQ '[') THEN BEGIN

           if(STRMID(upper_line,0,12) EQ '[PARAMETERS]') THEN section = 'parameters'
           if(STRMID(upper_line,0,11) EQ '[VARIABLES]') THEN section = 'variables'
           if(STRMID(upper_line,0,7) EQ '[PEAKS]') THEN section = 'peaks'

           section_just_defined = 'yes'

        ENDIF

        ; Read in the parameter section of the constraints file
        IF (section_just_defined EQ 'no') THEN BEGIN

           IF (section EQ 'parameters') THEN BEGIN

              ;Replace all tabs with spaces
 		   WHILE(((M = STRPOS(upper_line, '	'))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
		tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF (tokens[valid_tokens[0]] EQ 'NUMBER_PEAKS') THEN BEGIN
                 middle_const_info.number_peaks =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'SHIFT_UNITS') THEN BEGIN
                middle_const_info.shift_units =  tokens[valid_tokens[1]]
              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'OUTPUT_SHIFT_UNITS') THEN BEGIN
                 middle_const_info.output_shift_units =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'NOISE_POINTS') THEN BEGIN
                 middle_const_info.noise_points =  tokens[valid_tokens[1]]
              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'FIXED_NOISE') THEN BEGIN
                 middle_const_info.fixed_noise =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'ALAMBDA_INC') THEN BEGIN
                 middle_const_info.alambda_inc =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'ALAMBDA_DEC') THEN BEGIN
                 middle_const_info.alambda_dec =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'FWHM_EXP_WEIGHTING') THEN BEGIN
                 middle_const_info.fwhm_exp_weighting =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'TOLERENCE') THEN BEGIN
                 middle_const_info.tolerence =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'MAXIMUM_ITERATIONS') THEN BEGIN
                 middle_const_info.maximum_iterations =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'MINIMUM_ITERATIONS') THEN BEGIN
                 middle_const_info.minimum_iterations =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'NOISE_EQUAL') THEN BEGIN
                 middle_const_info.noise_equal =  1

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'RANGE') THEN BEGIN
                 middle_const_info.range_min =  tokens[valid_tokens[1]]
                 middle_const_info.range_max =  tokens[valid_tokens[2]]
              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'QRT_SIN_WEIGHTING_RANGE') THEN BEGIN
                 middle_const_info.qrt_sin_weighting_range1 =  tokens[valid_tokens[1]]
                 middle_const_info.qrt_sin_weighting_range2 =  tokens[valid_tokens[2]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'FREQUENCY_RANGE') THEN BEGIN
                 middle_const_info.freq_range1 =  tokens[valid_tokens[1]]
                 middle_const_info.freq_range2 =  tokens[valid_tokens[2]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'DOMAIN') THEN BEGIN
                 middle_const_info.domain =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'OUTPUT_FILE_SYSTEM') THEN BEGIN
                 middle_const_info.output_file_system =  tokens[valid_tokens[1]]

              ENDIF
           ENDIF

           IF (section EQ 'variables') THEN BEGIN

              ;Replace all tabs with spaces
 		   WHILE(((M = STRPOS(upper_line, '	'))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
		tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF(N_ELEMENTS(valid_tokens) GT 1) THEN BEGIN

                 middle_const_info.number_variables = middle_const_info.number_variables + 1

                 middle_const_variables[middle_const_info.number_variables-1].name = tokens[valid_tokens[0]]

                 middle_token_to_parse = tokens[valid_tokens[1]]

                 PARSE

                 middle_const_variables[middle_const_info.number_variables-1].gvalue = middle_param_value

              ENDIF

           ENDIF



           IF (section EQ 'peaks') THEN BEGIN
; *****Start CHANGES

              ;Replace all tabs with spaces
 		   WHILE(((M = STRPOS(upper_line, '	'))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
		tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF(N_ELEMENTS(valid_tokens) GE 7 AND STRMID(tokens[valid_tokens[0]], 0, 1) NE ";") THEN BEGIN
                 middle_param_index = 0
                 middle_current_peak = tokens[valid_tokens[0]]

                 FOR M = 1, N_ELEMENTS(valid_tokens)-1 DO BEGIN
                    ;Parse each token to resolve the guess file
                    middle_token_to_parse = tokens[valid_tokens[M]]

                    middle_param_value = 0.0
                    middle_item_parsed = 0


                    PARSE_CONSTRAINTS

                    IF (middle_item_parsed EQ 1) THEN BEGIN

                       ;Make sure the amplitude modifier can not be 0.0
                       IF (middle_param_index EQ 3) AND (middle_param_value EQ 0.0) THEN BEGIN
				print, 'middle_param_value', middle_param_value
				 middle_param_value = 1.0
		       ENDIF

                       middle_peak[middle_param_index, tokens[valid_tokens[0]]].modifier = middle_param_value

                       IF middle_link_value EQ -2 THEN BEGIN
                          middle_link_value = tokens[valid_tokens[0]]
                       ENDIF

                       middle_peak[middle_param_index, tokens[valid_tokens[0]]].linked = middle_link_value
print, 'link_value', middle_peak[middle_param_index, tokens[valid_tokens[0]]].linked,  middle_peak[middle_param_index, tokens[valid_tokens[0]]].modifier
                    ENDIF

                 ENDFOR

              ENDIF ELSE BEGIN

		IF (STRMID(tokens[valid_tokens[0]], 0, 1) NE ";") THEN BEGIN
                    print, 'Error reading peak information'
		ENDIF

              ENDELSE
; ******END CHANGES
           ENDIF



        ENDIF
     ENDIF
     ENDELSE
  ENDWHILE


  CLOSE, unit
  FREE_LUN, unit

END

;===================================================================================================================

PRO PARSE

   COMMON common_vars

   IF (Window_Flag EQ 1) THEN BEGIN
   	action = INTARR(4)
   	element_structure = {elem_struct, action:0, evalue:0.0}
   	element = REPLICATE(element_structure, 10)

   	number_elements = 1
   	element[number_elements-1].action = 0
   	param_value = 0.0

   	WHILE STRLEN(token_to_parse) GT 0 DO BEGIN
      		action_type = -1
      		action[0] = STRPOS(token_to_parse, '+')
      		action[1] = STRPOS(token_to_parse, '-')
      		action[2] = STRPOS(token_to_parse, '*')
      		action[3] = STRPOS(token_to_parse, '/')

      		max_pos = STRLEN(token_to_parse)
      		FOR i = 0, 3 DO BEGIN
        		IF (action[i] GT 0) AND (action[i] LT max_pos) THEN BEGIN
            			; If sign is associated with the exponential operator 'e' then skip it
            			expon_check = STRMID(token_to_parse, action[i]-1, 1)
            			IF (expon_check NE 'E') THEN BEGIN
               				max_pos = action[i]
               				action_type = i
            			ENDIF

         		ENDIF
      		ENDFOR
      	;If no action found then check if string is a variable
      	IF max_pos EQ STRLEN(token_to_parse) THEN BEGIN
         	i = 0
         	found = 0
         	WHILE (i LE guess_info.number_variables) AND (found EQ 0) DO BEGIN
            		IF token_to_parse EQ guess_variables[i].name THEN BEGIN
               			element[number_elements-1].evalue = guess_variables[i].gvalue
               			found = 1
               			;remove last element from token_to_parse
               			token_to_parse = STRMID(token_to_parse, max_pos+1, STRLEN(token_to_parse)-max_pos+1)
            		ENDIF
            		i = i+1
         	ENDWHILE
      	ENDIF

      	;If no action found and param_value is still zero then sting is a pure number
      	IF (max_pos EQ STRLEN(token_to_parse)) AND (param_value EQ 0) THEN BEGIN
         	param_value = token_to_parse
         	RETURN
      	ENDIF

      	;Parse out the next action
      	IF action_type GE 0 THEN BEGIN
         	number_elements = number_elements+1
         	element[number_elements-2].evalue = STRMID(token_to_parse, 0, max_pos)
         	element[number_elements-1].action = action_type

         	;remove last element from token_to_parse
         	token_to_parse = STRMID(token_to_parse, max_pos+1, STRLEN(token_to_parse)-max_pos+1)
      	ENDIF

	ENDWHILE

   	;Now all the elements of the token_to_parse have been separated
   	;Therefore, we must combine them into a single parameter
   	;For now, combine in order, not following order of operations

   	FOR i = 0, number_elements-1 DO BEGIN
         	IF element[i].action EQ 0 THEN param_value = param_value + element[i].evalue
      		IF element[i].action EQ 1 THEN param_value = param_value - element[i].evalue
      		IF element[i].action EQ 2 THEN param_value = param_value * element[i].evalue
      		IF element[i].action EQ 3 THEN param_value = param_value / element[i].evalue
	ENDFOR


   ENDIF

   IF (Window_Flag EQ 2) THEN BEGIN
   	action = INTARR(4)
   	element_structure = {elem_struct, action:0, evalue:0.0}
   	element = REPLICATE(element_structure, 10)

   	number_elements = 1
   	element[number_elements-1].action = 0
   	middle_param_value = 0.0

   	WHILE STRLEN(middle_token_to_parse) GT 0 DO BEGIN
      		action_type = -1
      		action[0] = STRPOS(middle_token_to_parse, '+')
      		action[1] = STRPOS(middle_token_to_parse, '-')
      		action[2] = STRPOS(middle_token_to_parse, '*')
      		action[3] = STRPOS(middle_token_to_parse, '/')

      		max_pos = STRLEN(middle_token_to_parse)
      		FOR i = 0, 3 DO BEGIN
        		IF (action[i] GT 0) AND (action[i] LT max_pos) THEN BEGIN
            			; If sign is associated with the exponential operator 'e' then skip it
            			expon_check = STRMID(middle_token_to_parse, action[i]-1, 1)
            			IF (expon_check NE 'E') THEN BEGIN
               				max_pos = action[i]
               				action_type = i
            			ENDIF

         		ENDIF
      		ENDFOR
      	;If no action found then check if string is a variable
      	IF max_pos EQ STRLEN(middle_token_to_parse) THEN BEGIN
         	i = 0
         	found = 0
         	WHILE (i LE middle_guess_info.number_variables) AND (found EQ 0) DO BEGIN
            		IF middle_token_to_parse EQ middle_guess_variables[i].name THEN BEGIN
               			element[number_elements-1].evalue = middle_guess_variables[i].gvalue
               			found = 1
               			;remove last element from token_to_parse
               			middle_token_to_parse = STRMID(middle_token_to_parse, max_pos+1, STRLEN(middle_token_to_parse)-max_pos+1)
            		ENDIF
            		i = i+1
         	ENDWHILE
      	ENDIF

      	;If no action found and param_value is still zero then sting is a pure number
      	IF (max_pos EQ STRLEN(middle_token_to_parse)) AND (middle_param_value EQ 0) THEN BEGIN
         	middle_param_value = middle_token_to_parse
         	RETURN
      	ENDIF

      	;Parse out the next action
      	IF action_type GE 0 THEN BEGIN
         	number_elements = number_elements+1
         	element[number_elements-2].evalue = STRMID(middle_token_to_parse, 0, max_pos)
         	element[number_elements-1].action = action_type

         	;remove last element from token_to_parse
         	middle_token_to_parse = STRMID(middle_token_to_parse, max_pos+1, STRLEN(middle_token_to_parse)-max_pos+1)
      	ENDIF

	ENDWHILE

   	;Now all the elements of the token_to_parse have been separated
   	;Therefore, we must combine them into a single parameter
   	;For now, combine in order, not following order of operations

   	FOR i = 0, number_elements-1 DO BEGIN
         	IF element[i].action EQ 0 THEN middle_param_value = middle_param_value + element[i].evalue
      		IF element[i].action EQ 1 THEN middle_param_value = middle_param_value - element[i].evalue
      		IF element[i].action EQ 2 THEN middle_param_value = middle_param_value * element[i].evalue
      		IF element[i].action EQ 3 THEN middle_param_value = middle_param_value / element[i].evalue
	ENDFOR
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
   	action = INTARR(4)
   	element_structure = {elem_struct, action:0, evalue:0.0}
   	element = REPLICATE(element_structure, 10)

   	number_elements = 1
   	element[number_elements-1].action = 0
   	bottom_param_value = 0.0

   	WHILE STRLEN(bottom_token_to_parse) GT 0 DO BEGIN
      		action_type = -1
      		action[0] = STRPOS(bottom_token_to_parse, '+')
      		action[1] = STRPOS(bottom_token_to_parse, '-')
      		action[2] = STRPOS(bottom_token_to_parse, '*')
      		action[3] = STRPOS(bottom_token_to_parse, '/')

      		max_pos = STRLEN(bottom_token_to_parse)
      		FOR i = 0, 3 DO BEGIN
        		IF (action[i] GT 0) AND (action[i] LT max_pos) THEN BEGIN
            			; If sign is associated with the exponential operator 'e' then skip it
            			expon_check = STRMID(bottom_token_to_parse, action[i]-1, 1)
            			IF (expon_check NE 'E') THEN BEGIN
               				max_pos = action[i]
               				action_type = i
            			ENDIF

         		ENDIF
      		ENDFOR
      	;If no action found then check if string is a variable
      	IF max_pos EQ STRLEN(bottom_token_to_parse) THEN BEGIN
         	i = 0
         	found = 0
         	WHILE (i LE bottom_guess_info.number_variables) AND (found EQ 0) DO BEGIN
            		IF bottom_token_to_parse EQ bottom_guess_variables[i].name THEN BEGIN
               			element[number_elements-1].evalue = bottom_guess_variables[i].gvalue
               			found = 1
               			;remove last element from token_to_parse
               			bottom_token_to_parse = STRMID(bottom_token_to_parse, max_pos+1, STRLEN(bottom_token_to_parse)-max_pos+1)
            		ENDIF
            		i = i+1
         	ENDWHILE
      	ENDIF

      	;If no action found and param_value is still zero then sting is a pure number
      	IF (max_pos EQ STRLEN(bottom_token_to_parse)) AND (bottom_param_value EQ 0) THEN BEGIN
         	bottom_param_value = bottom_token_to_parse
         	RETURN
      	ENDIF

      	;Parse out the next action
      	IF action_type GE 0 THEN BEGIN
         	number_elements = number_elements+1
         	element[number_elements-2].evalue = STRMID(bottom_token_to_parse, 0, max_pos)
         	element[number_elements-1].action = action_type

         	;remove last element from token_to_parse
         	bottom_token_to_parse = STRMID(bottom_token_to_parse, max_pos+1, STRLEN(bottom_token_to_parse)-max_pos+1)
      	ENDIF

	ENDWHILE

   	;Now all the elements of the token_to_parse have been separated
   	;Therefore, we must combine them into a single parameter
   	;For now, combine in order, not following order of operations

   	FOR i = 0, number_elements-1 DO BEGIN
         	IF element[i].action EQ 0 THEN bottom_param_value = bottom_param_value + element[i].evalue
      		IF element[i].action EQ 1 THEN bottom_param_value = bottom_param_value - element[i].evalue
      		IF element[i].action EQ 2 THEN bottom_param_value = bottom_param_value * element[i].evalue
      		IF element[i].action EQ 3 THEN bottom_param_value = bottom_param_value / element[i].evalue
   	ENDFOR
   ENDIF

END

;===================================================================================================================

PRO PARSE_CONSTRAINTS

   COMMON common_vars


   IF (Window_Flag EQ 1) THEN BEGIN

	   action = INTARR(4)
	   element_structure = {elem_struct, action:0, evalue:0.0}
	   element = REPLICATE(element_structure, 10)

	   number_elements = 1
	   element[number_elements-1].action = 0

    	param_value = 0.0

   	parse_position = 0
   	variable_exists = 0
   	i = 0
   	item_parsed = 1

   	WHILE STRLEN(token_to_parse) GT 0 DO BEGIN
      		action_type = -1
      		;Check the first character in the string to parse for { or @
       		IF (STRMID(token_to_parse, parse_position, 1) EQ '>') OR (STRMID(token_to_parse, parse_position, 1) EQ '<') THEN BEGIN

         		;Further parsing is not required since the parameter limits are not needed to display the data
         		item_parsed = 0
         		RETURN
      		ENDIF
      		IF STRMID(token_to_parse, parse_position, 1) EQ '@' THEN BEGIN
         		param_index = param_index + 1
         		link_value = -1
         		parse_position = parse_position + 1
         		;Further parsing is not required since the value of this parameter is
         		;now taken directly from the guess file (the peak modifier term)
         		RETURN
      		ENDIF
      		IF STRMID(token_to_parse, parse_position, 1) EQ '{' THEN BEGIN
         		param_index = param_index + 1
         		;First find the position of the closing bracket
         		closing_position = STRPOS(token_to_parse, '}')
         		;Read in the variable name
         		variable_name = STRMID(token_to_parse, parse_position+1, closing_position-1)
         	        ;Check to see if variable name has already been read in
         		WHILE (i LE current_peak) AND (variable_exists EQ 0) DO BEGIN
            			IF peak[param_index, i].const_name EQ variable_name THEN BEGIN
                			link_value = peak[param_index,i].linked
                			variable_exists = 1
                		ENDIF
		 		i = i + 1
         		ENDWHILE
               		IF variable_exists EQ 0 THEN BEGIN
                     		const_info.number_link_variables = const_info.number_link_variables + 1
            			peak[param_index, current_peak].const_name = variable_name
            			link_value = -2
         		ENDIF
      			;Now parse the rest of the string
         		token_to_parse = STRMID(token_to_parse, closing_position+1, STRLEN(token_to_parse)-closing_position)

         		WHILE STRLEN(token_to_parse) GT 0 DO BEGIN
            			action[0] = STRPOS(token_to_parse, '+')
            			action[1] = STRPOS(token_to_parse, '-')
            			action[2] = STRPOS(token_to_parse, '*')
            			action[3] = STRPOS(token_to_parse, '/')
				max_pos = STRLEN(token_to_parse)
            			FOR i = 0, 3 DO BEGIN
               				IF (action[i] GE 0) AND (action[i] LT max_pos) THEN BEGIN
                  				max_pos = action[i]
                  				action_type = i
               				ENDIF
            			ENDFOR

            		;If no action found then check if string is a variable
            		IF max_pos EQ STRLEN(token_to_parse) THEN BEGIN
               			i = 0
               			found = 0
               			WHILE (i LE const_info.number_variables) AND (found EQ 0) DO BEGIN
                  			IF token_to_parse EQ const_variables[i].name THEN BEGIN
                     				element[number_elements-1].evalue = const_variables[i].gvalue
                     				found = 1
                 				;remove last element from token_to_parse
                     				token_to_parse = STRMID(token_to_parse, max_pos+1, STRLEN(token_to_parse)-max_pos+1)
                 	 		ENDIF
                  			i = i+1
               			ENDWHILE
            		ENDIF

            		;If no action found and param_value is still zero then string is a pure number
            		IF (max_pos EQ STRLEN(token_to_parse)) AND (param_value EQ 0) THEN BEGIN
               			param_value = token_to_parse
               			RETURN
            		ENDIF

            		;Parse out the next action
            		IF action_type GE 0 THEN BEGIN
               			number_elements = number_elements+1
               			param_value = -1
               			element[number_elements-2].evalue = STRMID(token_to_parse, 0, max_pos)
               			element[number_elements-1].action = action_type
            		ENDIF

            		;remove last element from token_to_parse
            		token_to_parse = STRMID(token_to_parse, max_pos+1, STRLEN(token_to_parse)-max_pos+1)
         ENDWHILE
      ENDIF

      ;Now all the elements of the token_to_parse have been separated
      ;Therefore, we must combine them into a single parameter
      ;For now, combine in order, not following order of operations

      IF (element[0].evalue EQ 0) AND ((element[1].action EQ 2) OR (element[1].action EQ 3)) THEN BEGIN
         param_value = 1.0
      ENDIF ELSE BEGIN
         param_value = 0.0
      ENDELSE

      FOR i = 0, number_elements-2 DO BEGIN
         IF element[i].action EQ 0 THEN param_value = param_value + element[i].evalue
         IF element[i].action EQ 1 THEN param_value = param_value - element[i].evalue
         IF element[i].action EQ 2 THEN param_value = param_value * element[i].evalue
         IF element[i].action EQ 3 THEN param_value = param_value / element[i].evalue
      ENDFOR
    ENDWHILE
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
        action = INTARR(4)
        element_structure = {elem_struct, action:0, evalue:0.0}
        element = REPLICATE(element_structure, 10)


        number_elements = 0
        element[number_elements].action = 0

      	middle_param_value = 0.0

   	parse_position = 0
   	variable_exists = 0
   	i = 0
   	middle_item_parsed = 1

   	WHILE STRLEN(middle_token_to_parse) GT 0 DO BEGIN
      		action_type = -1
      		;Check the first character in the string to parse for { or @
       		IF (STRMID(middle_token_to_parse, parse_position, 1) EQ '>') OR (STRMID(middle_token_to_parse, parse_position, 1) EQ '<') THEN BEGIN

         		;Further parsing is not required since the parameter limits are not needed to display the data
         		middle_item_parsed = 0
         		RETURN
      		ENDIF
      		IF STRMID(middle_token_to_parse, parse_position, 1) EQ '@' THEN BEGIN
         		middle_param_index = middle_param_index + 1
         		middle_link_value = -1
         		parse_position = parse_position + 1
         		;Further parsing is not required since the value of this parameter is
         		;now taken directly from the guess file (the peak modifier term)
         		RETURN
      		ENDIF
      		IF STRMID(middle_token_to_parse, parse_position, 1) EQ '{' THEN BEGIN
         		middle_param_index = middle_param_index + 1
         		;First find the position of the closing bracket
         		closing_position = STRPOS(middle_token_to_parse, '}')
         		;Read in the variable name
         		variable_name = STRMID(middle_token_to_parse, parse_position+1, closing_position-1)
         	        ;Check to see if variable name has already been read in
         		WHILE (i LE middle_current_peak) AND (variable_exists EQ 0) DO BEGIN
            			IF middle_peak[middle_param_index, i].const_name EQ variable_name THEN BEGIN
                			middle_link_value = middle_peak[middle_param_index,i].linked
                			variable_exists = 1
                		ENDIF
		 		i = i + 1
         		ENDWHILE
               		IF variable_exists EQ 0 THEN BEGIN
                     		middle_const_info.number_link_variables = middle_const_info.number_link_variables + 1
            			middle_peak[middle_param_index, middle_current_peak].const_name = variable_name
            			middle_link_value = -2
         		ENDIF
      			;Now parse the rest of the string
         		middle_token_to_parse = STRMID(middle_token_to_parse, closing_position+1, STRLEN(middle_token_to_parse)-closing_position)
;********************START NEW CODE**************

;The only code above this point that was changed was ( number_elements = 0 element[number_elements].action = 0) at the top

        pos = INTARR(30)
	places_used = 0


			; Identify all operations within the token
			FOR l = 0, STRLEN(middle_token_to_parse)-1 DO BEGIN

				IF STRMID(middle_token_to_parse, l, 1) EQ '+' THEN BEGIN
					pos[l] = 0
				ENDIF ELSE BEGIN
					pos[l] =-1
				ENDELSE
				IF STRMID(middle_token_to_parse, l, 1) EQ '-' THEN BEGIN
					pos[l] = 1
				ENDIF
				IF STRMID(middle_token_to_parse, l, 1) EQ '*' THEN BEGIN
					pos[l] = 2
				ENDIF
				IF STRMID(middle_token_to_parse, l, 1) EQ '/' THEN BEGIN
					pos[l] = 3
				ENDIF

			ENDFOR

         		WHILE STRLEN(middle_token_to_parse) GT 0 DO BEGIN
				; Seperate the first varible or constant

				first_op = -1
				start_index = -1
				end_index = -1


				FOR l = 0, N_ELEMENTS(pos)-1 DO BEGIN

					IF pos[l] GE 0 AND first_op EQ -1 THEN BEGIN
						first_op = pos[places_used + l]
						start_index = l+1
					ENDIF
					IF pos[l] GE 0 AND first_op NE -1 AND end_index EQ -1 THEN BEGIN
						end_index = l-1
					ENDIF

				ENDFOR

				; Isolate the first token and identify it
				temp_token = STRMID(middle_token_to_parse, start_index, end_index-start_index+1)

				found = 0
				m = 0

              			WHILE (m LE middle_const_info.number_variables) AND (found EQ 0) DO BEGIN
                  			IF temp_token EQ middle_const_variables[m].name THEN BEGIN
						number_elements = number_elements + 1
                     				element[number_elements].evalue = middle_const_variables[m].gvalue
						element[number_elements].action = first_op
                     				found = 1
                     				;remove last element from token_to_parse
                     				middle_token_to_parse = STRMID(middle_token_to_parse, end_index+1, STRLEN(middle_token_to_parse)-end_index+1)
                 	 		ENDIF
                  			m = m+1
               			ENDWHILE

				; If no variable was found, token must be a pure number

				IF found EQ 0 THEN BEGIN
					number_elements = number_elements + 1
                     			element[number_elements].evalue = temp_token
					element[number_elements].action = first_op
               				middle_token_to_parse = STRMID(middle_token_to_parse, end_index+1, STRLEN(middle_token_to_parse)-end_index+1)
            			ENDIF

				places_used = places_used + (end_index - start_index + 1) + 1

			ENDWHILE

      ENDIF

      ;Now all the elements of the token_to_parse have been separated
      ;Therefore, we must combine them into a single parameter
      ;For now, combine in order, not following order of operations

      ; Value initialization solution

      IF (element[0].evalue EQ 0) AND ((element[1].action EQ 2) OR (element[1].action EQ 3)) THEN BEGIN
         middle_param_value = 1.0
      ENDIF ELSE BEGIN
         middle_param_value = 0.0
      ENDELSE

      ; end Value initialization solution

      FOR i = 0, number_elements DO BEGIN
         IF element[i].action EQ 0 THEN middle_param_value = middle_param_value + element[i].evalue
         IF element[i].action EQ 1 THEN middle_param_value = middle_param_value - element[i].evalue
print, 'multiplication_value', middle_param_value, element[i].evalue
         IF element[i].action EQ 2 THEN middle_param_value = middle_param_value * element[i].evalue
         IF element[i].action EQ 3 THEN middle_param_value = middle_param_value / element[i].evalue
      ENDFOR

    ENDWHILE

;*********************************END REVISION************************

   ENDIF



   IF (Window_Flag EQ 3) THEN BEGIN
        action = INTARR(4)
        element_structure = {elem_struct, action:0, evalue:0.0}
        element = REPLICATE(element_structure, 10)

        number_elements = 1
        element[number_elements-1].action = 0

      	bottom_param_value = 0.0

   	parse_position = 0
   	variable_exists = 0
   	i = 0
   	bottom_item_parsed = 1

   	WHILE STRLEN(bottom_token_to_parse) GT 0 DO BEGIN
      		action_type = -1
      		;Check the first character in the string to parse for { or @
       		IF (STRMID(bottom_token_to_parse, parse_position, 1) EQ '>') OR (STRMID(bottom_token_to_parse, parse_position, 1) EQ '<') THEN BEGIN

         		;Further parsing is not required since the parameter limits are not needed to display the data
         		bottom_item_parsed = 0
         		RETURN
      		ENDIF
      		IF STRMID(bottom_token_to_parse, parse_position, 1) EQ '@' THEN BEGIN
         		bottom_param_index = bottom_param_index + 1
         		bottom_link_value = -1
         		parse_position = parse_position + 1
         		;Further parsing is not required since the value of this parameter is
         		;now taken directly from the guess file (the peak modifier term)
         		RETURN
      		ENDIF
      		IF STRMID(bottom_token_to_parse, parse_position, 1) EQ '{' THEN BEGIN
         		bottom_param_index = bottom_param_index + 1
         		;First find the position of the closing bracket
         		closing_position = STRPOS(bottom_token_to_parse, '}')
         		;Read in the variable name
         		variable_name = STRMID(bottom_token_to_parse, parse_position+1, closing_position-1)
         	        ;Check to see if variable name has already been read in
         		WHILE (i LE bottom_current_peak) AND (variable_exists EQ 0) DO BEGIN
            			IF bottom_peak[bottom_param_index, i].const_name EQ variable_name THEN BEGIN
                			bottom_link_value = bottom_peak[bottom_param_index,i].linked
                			variable_exists = 1
                		ENDIF
		 		i = i + 1
         		ENDWHILE
               		IF variable_exists EQ 0 THEN BEGIN
                     		bottom_const_info.number_link_variables = bottom_const_info.number_link_variables + 1
            			bottom_peak[bottom_param_index, bottom_current_peak].const_name = variable_name
            			bottom_link_value = -2
         		ENDIF
      			;Now parse the rest of the string
         		bottom_token_to_parse = STRMID(bottom_token_to_parse, closing_position+1, STRLEN(bottom_token_to_parse)-closing_position)

         		WHILE STRLEN(bottom_token_to_parse) GT 0 DO BEGIN
            			action[0] = STRPOS(bottom_token_to_parse, '+')
            			action[1] = STRPOS(bottom_token_to_parse, '-')
            			action[2] = STRPOS(bottom_token_to_parse, '*')
            			action[3] = STRPOS(bottom_token_to_parse, '/')
				max_pos = STRLEN(bottom_token_to_parse)
            			FOR i = 0, 3 DO BEGIN
               				IF (action[i] GE 0) AND (action[i] LT max_pos) THEN BEGIN
                  				max_pos = action[i]
                  				action_type = i
               				ENDIF
            			ENDFOR

            		;If no action found then check if string is a variable
            		IF max_pos EQ STRLEN(bottom_token_to_parse) THEN BEGIN
               			i = 0
               			found = 0
               			WHILE (i LE bottom_const_info.number_variables) AND (found EQ 0) DO BEGIN
                  			IF bottom_token_to_parse EQ bottom_const_variables[i].name THEN BEGIN
                     				element[number_elements-1].evalue = bottom_const_variables[i].gvalue
                     				found = 1
                     				;remove last element from token_to_parse
                     				bottom_token_to_parse = STRMID(bottom_token_to_parse, max_pos+1, STRLEN(bottom_token_to_parse)-max_pos+1)
                 	 		ENDIF
                  			i = i+1
               			ENDWHILE
            		ENDIF

            		;If no action found and param_value is still zero then string is a pure number
            		IF (max_pos EQ STRLEN(bottom_token_to_parse)) AND (bottom_param_value EQ 0) THEN BEGIN
               			bottom_param_value = bottom_token_to_parse
               			RETURN
            		ENDIF

            		;Parse out the next action
            		IF action_type GE 0 THEN BEGIN
               			number_elements = number_elements+1
               			bottom_param_value = -1
               			element[number_elements-2].evalue = STRMID(bottom_token_to_parse, 0, max_pos)
               			element[number_elements-1].action = action_type
            		ENDIF

            		;remove last element from token_to_parse
            		bottom_token_to_parse = STRMID(bottom_token_to_parse, max_pos+1, STRLEN(bottom_token_to_parse)-max_pos+1)
         ENDWHILE
      ENDIF

      ;Now all the elements of the token_to_parse have been separated
      ;Therefore, we must combine them into a single parameter
      ;For now, combine in order, not following order of operations

      IF (element[0].evalue EQ 0) AND ((element[1].action EQ 2) OR (element[1].action EQ 3)) THEN BEGIN
         bottom_param_value = 1.0
      ENDIF ELSE BEGIN
         bottom_param_value = 0.0
      ENDELSE

      FOR i = 0, number_elements-2 DO BEGIN
         IF element[i].action EQ 0 THEN bottom_param_value = bottom_param_value + element[i].evalue
         IF element[i].action EQ 1 THEN bottom_param_value = bottom_param_value - element[i].evalue
         IF element[i].action EQ 2 THEN bottom_param_value = bottom_param_value * element[i].evalue
         IF element[i].action EQ 3 THEN bottom_param_value = bottom_param_value / element[i].evalue
      ENDFOR
    ENDWHILE
   ENDIF

END
;===================================================================================================================

PRO GENERATE_FIT_CURVE

  COMMON common_vars

     IF (Window_Flag EQ 1) THEN BEGIN
     	NUM_LINKED_GROUPS

     	; Place original data in temporary storage
     	comp_time_data_points = time_data_points

     	G_FWHM_C = !PI / (4*ALOG10(2))
     	TIME = point_index * data_file_header.dwell

     	real_pts = 0.0
     	imag_pts = 0.0
     	FOR I = 1, guess_info.num_peaks DO BEGIN
        	EXPON_LOR = exp(DOUBLE(-1.0 * !PI * (peak[2, I].pvalue + plot_info.expon_filter) * ABS(TIME + peak[5, I].pvalue)))
        	EXPON_GAU = exp(DOUBLE(-1.0 * !PI * G_FWHM_C * (peak[6, I].pvalue + plot_info.gauss_filter) * (peak[6, I].pvalue + plot_info.gauss_filter) * ABS(TIME + peak[5, I].pvalue) * ABS(TIME + peak[5, I].pvalue)))
        	EXPON = EXPON_LOR * EXPON_GAU
		COSIN = cos(DOUBLE(2.0 * !PI * peak[1, I].pvalue * (TIME + peak[5, I].pvalue)+ peak[4, I].pvalue))
        	SININ = sin(DOUBLE(2.0 * !PI * peak[1, I].pvalue * (TIME + peak[5, I].pvalue)+ peak[4, I].pvalue))

        	; Generate individual peaks
        	one_real = (peak[3, I].pvalue * COSIN * EXPON)
        	one_imag = (peak[3, I].pvalue * SININ * EXPON)
               	comp_time_data_points[I+1, 1:N_ELEMENTS(one_real)] = COMPLEX(one_real, one_imag)
        	; Compile data for the total reconstruction
        	real_pts = DOUBLE(real_pts + (peak[3, I].pvalue * COSIN * EXPON))
        	imag_pts = DOUBLE(imag_pts + (peak[3, I].pvalue * SININ * EXPON))
     	ENDFOR

     	; Return original data to data matrix
     	time_data_points = comp_time_data_points

     	; Place the fit curve into the data matrix
     	time_data_points[1, 1:N_ELEMENTS(real_pts)] = COMPLEX(real_pts, imag_pts)

     	GENERATE_GROUPS
     ENDIF

     IF (Window_Flag EQ 2) THEN BEGIN
        NUM_LINKED_GROUPS

     	; Place original data in temporary storage
     	middle_comp_time_data_points = middle_time_data_points

     	G_FWHM_C = !PI / (4*ALOG(2))
     	TIME = middle_point_index * middle_data_file_header.dwell

     	real_pts = 0.0
     	imag_pts = 0.0

     	FOR I = 1, middle_guess_info.num_peaks DO BEGIN
        	EXPON_LOR = exp(DOUBLE(-1.0 * !PI * (middle_peak[2, I].pvalue + middle_plot_info.expon_filter) * ABS(TIME + middle_peak[5, I].pvalue)))
        	EXPON_GAU = exp(DOUBLE(-1.0 * !PI * G_FWHM_C * (middle_peak[6, I].pvalue + middle_plot_info.gauss_filter) * $
						(middle_peak[6, I].pvalue + middle_plot_info.gauss_filter) * $
						ABS(TIME + middle_peak[5, I].pvalue) * ABS(TIME + middle_peak[5, I].pvalue)))
        	EXPON = EXPON_LOR * EXPON_GAU
		COSIN = cos(DOUBLE(2.0 * !PI * middle_peak[1, I].pvalue * (TIME + middle_peak[5, I].pvalue)+ middle_peak[4, I].pvalue))
        	SININ = sin(DOUBLE(2.0 * !PI * middle_peak[1, I].pvalue * (TIME + middle_peak[5, I].pvalue)+ middle_peak[4, I].pvalue))

        	; Generate individual peaks
        	one_real = (middle_peak[3, I].pvalue * COSIN * EXPON)
        	one_imag = (middle_peak[3, I].pvalue * SININ * EXPON)
              	middle_comp_time_data_points[I+1, 1:N_ELEMENTS(one_real)] = COMPLEX(one_real, one_imag)

        	; Compile data for the total reconstruction
        	real_pts = DOUBLE(real_pts + (middle_peak[3, I].pvalue * COSIN * EXPON))
        	imag_pts = DOUBLE(imag_pts + (middle_peak[3, I].pvalue * SININ * EXPON))
     	ENDFOR

     	; Return original data to data matrix
     	middle_time_data_points = middle_comp_time_data_points

     	; Place the fit curve into the data matrix
     	middle_time_data_points[1, 1:N_ELEMENTS(real_pts)] = COMPLEX(real_pts, imag_pts)

     	GENERATE_GROUPS
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN
        NUM_LINKED_GROUPS

     	; Place original data in temporary storage
     	bottom_comp_time_data_points = bottom_time_data_points

     	G_FWHM_C = !PI / (4*ALOG10(2))
     	TIME = bottom_point_index * bottom_data_file_header.dwell

     	real_pts = 0.0
     	imag_pts = 0.0

     	FOR I = 1, bottom_guess_info.num_peaks DO BEGIN
        	EXPON_LOR = exp(DOUBLE(-1.0 * !PI * (bottom_peak[2, I].pvalue + bottom_plot_info.expon_filter) * ABS(TIME + bottom_peak[5, I].pvalue)))
        	EXPON_GAU = exp(DOUBLE(-1.0 * !PI * G_FWHM_C * (bottom_peak[6, I].pvalue + bottom_plot_info.gauss_filter) * $
					(bottom_peak[6, I].pvalue + bottom_plot_info.gauss_filter) * $
					ABS(TIME + bottom_peak[5, I].pvalue) * ABS(TIME + bottom_peak[5, I].pvalue)))
        	EXPON = EXPON_LOR * EXPON_GAU
		COSIN = cos(DOUBLE(2.0 * !PI * bottom_peak[1, I].pvalue * (TIME + bottom_peak[5, I].pvalue)+ bottom_peak[4, I].pvalue))
        	SININ = sin(DOUBLE(2.0 * !PI * bottom_peak[1, I].pvalue * (TIME + bottom_peak[5, I].pvalue)+ bottom_peak[4, I].pvalue))

        	; Generate individual peaks
        	one_real = (bottom_peak[3, I].pvalue * COSIN * EXPON)
        	one_imag = (bottom_peak[3, I].pvalue * SININ * EXPON)
              	bottom_comp_time_data_points[I+1, 1:N_ELEMENTS(one_real)] = COMPLEX(one_real, one_imag)

        	; Compile data for the total reconstruction
        	real_pts = DOUBLE(real_pts + (bottom_peak[3, I].pvalue * COSIN * EXPON))
        	imag_pts = DOUBLE(imag_pts + (bottom_peak[3, I].pvalue * SININ * EXPON))
     	ENDFOR

     	; Return original data to data matrix
     	bottom_time_data_points = bottom_comp_time_data_points

      ; Place the fit curve into the data matrix
	bottom_time_data_points[1, 1:N_ELEMENTS(real_pts)] = COMPLEX(real_pts, imag_pts)
     	GENERATE_GROUPS
     ENDIF

END

;===================================================================================================================

PRO CONVERT_TO_HERTZ
 COMMON common_vars

   if (Window_Flag EQ 1) THEN BEGIN
   ;Check to see if the peak information is in PPM or HERTZ
   IF(guess_info.shift_units EQ 'PPM') THEN BEGIN

      peak[1, *].pvalue = peak[1, *].pvalue * guess_info.frequency/1000000
      guess_info.shift_units = 'HERTZ'

   ENDIF

   IF(const_info.shift_units EQ 'PPM') THEN BEGIN

      peak[1, *].modifier = peak[1, *].modifier * guess_info.frequency/1000000
      const_info.shift_units = 'HERTZ'

   ENDIF
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   ;Check to see if the peak information is in PPM or HERTZ
   	IF(middle_guess_info.shift_units EQ 'PPM') THEN BEGIN
      		middle_peak[1, *].pvalue = middle_peak[1, *].pvalue * middle_guess_info.frequency/1000000
      		middle_guess_info.shift_units = 'HERTZ'
   	ENDIF
   	IF(middle_const_info.shift_units EQ 'PPM') THEN BEGIN
      		middle_peak[1, *].modifier = middle_peak[1, *].modifier * middle_guess_info.frequency/1000000
      		middle_const_info.shift_units = 'HERTZ'
   	ENDIF
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   ;Check to see if the peak information is in PPM or HERTZ
   IF(bottom_guess_info.shift_units EQ 'PPM') THEN BEGIN
      		bottom_peak[1, *].pvalue = bottom_peak[1, *].pvalue * bottom_guess_info.frequency/1000000
      		bottom_guess_info.shift_units = 'HERTZ'
   	ENDIF
   	IF(bottom_const_info.shift_units EQ 'PPM') THEN BEGIN
      		bottom_peak[1, *].modifier = bottom_peak[1, *].modifier * bottom_guess_info.frequency/1000000
      		bottom_const_info.shift_units = 'HERTZ'
   	ENDIF
   ENDIF

END

;===================================================================================================================

PRO GENERATE_RESIDUAL

   COMMON common_vars
      IF (Window_Flag EQ 1) THEN $
   	time_data_points[2,1:N_ELEMENTS(point_index)-1] = time_data_points[0,1:N_ELEMENTS(point_index)-1] - time_data_points[1,1:N_ELEMENTS(point_index)-1]
      IF (Window_Flag EQ 2) THEN $
         middle_time_data_points[2,1:N_ELEMENTS(middle_point_index)-1] = middle_time_data_points[0,1:N_ELEMENTS(middle_point_index)-1] - middle_time_data_points[1,1:N_ELEMENTS(middle_point_index)-1]
      IF (Window_Flag EQ 3) THEN $
         bottom_time_data_points[2,1:N_ELEMENTS(bottom_point_index)-1] = bottom_time_data_points[0,1:N_ELEMENTS(bottom_point_index)-1] - bottom_time_data_points[1,1:N_ELEMENTS(bottom_point_index)-1]


END

;===================================================================================================================

PRO UPDATE_FIELDS

   COMMON common_vars
   COMMON common_widgets

   IF (Window_Flag EQ 1) THEN BEGIN
   	WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
   	minp = ymin
   	WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
   	maxp = ymax

   	yrange = ymax-ymin

   	WIDGET_CONTROL, C_CURVE, SET_VALUE = plot_info.current_curve
   	WIDGET_CONTROL, CURVE_OFF, SET_VALUE = plot_color[plot_info.current_curve].offset*100/yrange
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   	WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
   	minp = ymin
   	WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
   	maxp = ymax

   	yrange = ymax-ymin

   	WIDGET_CONTROL, C_CURVE, SET_VALUE = middle_plot_info.current_curve
   	WIDGET_CONTROL, CURVE_OFF, SET_VALUE = middle_plot_color[middle_plot_info.current_curve].offset*100/yrange
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
   	WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
   	minp = ymin
   	WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
   	maxp = ymax

   	yrange = ymax-ymin

   	WIDGET_CONTROL, C_CURVE, SET_VALUE = bottom_plot_info.current_curve
   	WIDGET_CONTROL, CURVE_OFF, SET_VALUE = bottom_plot_color[bottom_plot_info.current_curve].offset*100/yrange
   ENDIF

END

;===================================================================================================================

PRO GENERATE_NEW_DATA

   COMMON common_vars


   IF (Window_Flag EQ 1) THEN BEGIN
   	G_FWHM_C = !PI / (4*ALOG10(2))
   	TIME = point_index * data_file_header.dwell

   	EXPON_LOR = exp(DOUBLE(-1.0 * !PI * (plot_info.expon_filter) * ABS(TIME + plot_info.delay_time)))
   	EXPON_GAU = exp(DOUBLE(-1.0 * !PI * G_FWHM_C * (plot_info.gauss_filter) * (plot_info.gauss_filter) * ABS(TIME + plot_info.delay_time) * ABS(TIME + plot_info.delay_time)))

   	EXPON = EXPON_LOR * EXPON_GAU

   	real_data = FLOAT(original_data[1:N_ELEMENTS(point_index)]) * EXPON
   	imag_data = IMAGINARY(original_data[1:N_ELEMENTS(point_index)]) * EXPON

   	time_data_points[0,1:N_ELEMENTS(real_data)] = complex(real_data, imag_data)
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   	G_FWHM_C = !PI / (4*ALOG10(2))
   	TIME = middle_point_index * middle_data_file_header.dwell

   	EXPON_LOR = exp(DOUBLE(-1.0 * !PI * (middle_plot_info.expon_filter) * ABS(TIME + middle_plot_info.delay_time)))
   	EXPON_GAU = exp(DOUBLE(-1.0 * !PI * G_FWHM_C * (middle_plot_info.gauss_filter) * (middle_plot_info.gauss_filter) * ABS(TIME + middle_plot_info.delay_time) * ABS(TIME + middle_plot_info.delay_time)))

   	EXPON = EXPON_LOR * EXPON_GAU

   	real_data = FLOAT(middle_original_data[1:N_ELEMENTS(middle_point_index)]) * EXPON
   	imag_data = IMAGINARY(middle_original_data[1:N_ELEMENTS(middle_point_index)]) * EXPON

   	middle_time_data_points[0,1:N_ELEMENTS(real_data)] = complex(real_data, imag_data)
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
   	G_FWHM_C = !PI / (4*ALOG10(2))
   	TIME = bottom_point_index * bottom_data_file_header.dwell

   	EXPON_LOR = exp(DOUBLE(-1.0 * !PI * (bottom_plot_info.expon_filter) * ABS(TIME + bottom_plot_info.delay_time)))
   	EXPON_GAU = exp(DOUBLE(-1.0 * !PI * G_FWHM_C * (bottom_plot_info.gauss_filter) * (bottom_plot_info.gauss_filter) * ABS(TIME + bottom_plot_info.delay_time) * ABS(TIME + bottom_plot_info.delay_time)))

   	EXPON = EXPON_LOR * EXPON_GAU

   	real_data = FLOAT(bottom_original_data[1:N_ELEMENTS(bottom_point_index)]) * EXPON
   	imag_data = IMAGINARY(bottom_original_data[1:N_ELEMENTS(bottom_point_index)]) * EXPON

   	bottom_time_data_points[0,1:N_ELEMENTS(real_data)] = complex(real_data, imag_data)
   ENDIF
END

;===================================================================================================================

PRO UPDATE_LINKS

   COMMON common_vars

   IF (WIndow_Flag EQ 1) THEN BEGIN
   	IF (const_info.const_file_label NE 0) THEN BEGIN

	 FOR i=1, guess_info.num_peaks DO BEGIN
	    FOR j=1, 6 DO BEGIN
	       IF (peak[j,i].linked NE -1) THEN BEGIN

              IF (j EQ 3) THEN BEGIN
	            IF (peak[j,i].linked EQ i) THEN BEGIN
	                peak[j,i].var_base = peak[j,i].pvalue / peak[j,i].modifier
			  ENDIF

                  peak[j, i].pvalue = peak[j, peak[j,i].linked].var_base * peak[j,i].modifier

   		    ENDIF ELSE BEGIN
	            IF (peak[j,i].linked EQ i) THEN BEGIN
	                peak[j,i].var_base = peak[j,i].pvalue - peak[j,i].modifier
	 		  ENDIF

                  peak[j, i].pvalue = peak[j, peak[j,i].linked].var_base + peak[j,i].modifier
               ENDELSE

            ENDIF
         ENDFOR
      ENDFOR
     ENDIF
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   	IF (middle_const_info.const_file_label NE 0) THEN BEGIN

	 FOR i=1, middle_guess_info.num_peaks DO BEGIN
	    FOR j=1, 6 DO BEGIN
	       	IF (middle_peak[j,i].linked NE -1) THEN BEGIN

              		IF (j EQ 3) THEN BEGIN
	            		IF (middle_peak[j,i].linked EQ i) THEN BEGIN
	                		middle_peak[j,i].var_base = middle_peak[j,i].pvalue / middle_peak[j,i].modifier
		    		ENDIF
                  		middle_peak[j, i].pvalue = middle_peak[j, middle_peak[j,i].linked].var_base * middle_peak[j,i].modifier
   		    	ENDIF ELSE BEGIN
	            	IF (middle_peak[j,i].linked EQ i) THEN BEGIN
	                	middle_peak[j,i].var_base = middle_peak[j,i].pvalue - middle_peak[j,i].modifier
	 		ENDIF

                  	middle_peak[j, i].pvalue = middle_peak[j, middle_peak[j,i].linked].var_base + middle_peak[j,i].modifier
               ENDELSE

            ENDIF
         ENDFOR
      ENDFOR
     ENDIF
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
   	IF (bottom_const_info.const_file_label NE 0) THEN BEGIN

	 FOR i=1, bottom_guess_info.num_peaks DO BEGIN
	    FOR j=1, 6 DO BEGIN
	       	IF (bottom_peak[j,i].linked NE -1) THEN BEGIN

              		IF (j EQ 3) THEN BEGIN
	            		IF (bottom_peak[j,i].linked EQ i) THEN BEGIN
	                		bottom_peak[j,i].var_base = bottom_peak[j,i].pvalue / bottom_peak[j,i].modifier
		    		ENDIF
                  		bottom_peak[j, i].pvalue = bottom_peak[j, bottom_peak[j,i].linked].var_base * bottom_peak[j,i].modifier
   		    	ENDIF ELSE BEGIN
	            	IF (bottom_peak[j,i].linked EQ i) THEN BEGIN
	                	bottom_peak[j,i].var_base = bottom_peak[j,i].pvalue - bottom_peak[j,i].modifier
	 		ENDIF

                  	bottom_peak[j, i].pvalue = bottom_peak[j, bottom_peak[j,i].linked].var_base + bottom_peak[j,i].modifier
               ENDELSE

            ENDIF
         ENDFOR
      ENDFOR
     ENDIF
   ENDIF

END

;===================================================================================================================

PRO GENERATE_GROUPS

   COMMON common_vars

   IF (Window_Flag EQ 1) THEN BEGIN
   	;Generate curves to display based on the linking information
   	FOR i = 1, guess_info.num_peaks DO BEGIN
      		IF (i EQ 1) THEN time_data_points[3:*, 1:*] = 0.0
      			FOR j = 1, plot_info.num_linked_groups DO BEGIN
        			IF (peak[plot_info.grouping, i].linked EQ linked_param[j]) THEN BEGIN
          				time_data_points[j+2, 1:N_ELEMENTS(point_index)] = time_data_points[j+2, 1:N_ELEMENTS(point_index)] + comp_time_data_points[i+1, 1:N_ELEMENTS(point_index)]

          			ENDIF
              		ENDFOR
       	ENDFOR

   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   	; Generate curves to display based on the linking information
   	FOR i = 1, middle_guess_info.num_peaks DO BEGIN
      		IF (i EQ 1) THEN middle_time_data_points[3:*, 1:*] = 0.0
      			FOR j = 1, middle_plot_info.num_linked_groups DO BEGIN
        			IF (middle_peak[middle_plot_info.grouping, i].linked EQ middle_linked_param[j]) THEN BEGIN
          				middle_time_data_points[j+2, 1:N_ELEMENTS(middle_point_index)] = $
					middle_time_data_points[j+2, 1:N_ELEMENTS(middle_point_index)] + $
					middle_comp_time_data_points[i+1, 1:N_ELEMENTS(middle_point_index)]
          			ENDIF
              		ENDFOR
       	ENDFOR
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
   	; Generate curves to display based on the linking information
   	FOR i = 1, bottom_guess_info.num_peaks DO BEGIN
      		IF (i EQ 1) THEN bottom_time_data_points[3:*, 1:*] = 0.0
      			FOR j = 1, bottom_plot_info.num_linked_groups DO BEGIN
        			IF (bottom_peak[bottom_plot_info.grouping, i].linked EQ bottom_linked_param[j]) THEN BEGIN
          				bottom_time_data_points[j+2, 1:N_ELEMENTS(bottom_point_index)] = $
					bottom_time_data_points[j+2, 1:N_ELEMENTS(bottom_point_index)] + $
					bottom_comp_time_data_points[i+1, 1:N_ELEMENTS(bottom_point_index)]
          			ENDIF
              		ENDFOR
       	ENDFOR
   ENDIF

END

;===================================================================================================================

PRO NUM_LINKED_GROUPS
   	COMMON common_vars
   	IF (Window_Flag EQ 1) THEN BEGIN
     	; If constraints file has been read in, determine how many linked groups exist
     		IF (const_info.const_file_label EQ 1) THEN BEGIN

        	plot_info.num_linked_groups = 1
        	linked_param[1] = peak[plot_info.grouping,1].linked

        	FOR i = 2, const_info.number_peaks DO BEGIN
            		exists = 0

           		j = 1
           		WHILE (j LE plot_info.num_linked_groups) AND (exists NE 1) DO BEGIN
              			IF (peak[plot_info.grouping,i].linked EQ linked_param[j]) THEN exists = 1
              			j = j + 1
           		ENDWHILE

           		IF (exists EQ 0) THEN BEGIN
              			plot_info.num_linked_groups = plot_info.num_linked_groups + 1
              			linked_param[plot_info.num_linked_groups] = peak[plot_info.grouping, i].linked
           		ENDIF

        	ENDFOR

    		ENDIF
   	ENDIF
   	IF (Window_Flag EQ 2) THEN BEGIN
     		; If constraints file has been read in, determine how many linked groups exist
     		IF (middle_const_info.const_file_label EQ 1) THEN BEGIN

        		middle_plot_info.num_linked_groups = 1
        		middle_linked_param[1] = middle_peak[middle_plot_info.grouping,1].linked

        		FOR i = 2, middle_const_info.number_peaks DO BEGIN
           			exists = 0

           			j = 1
           			WHILE (j LE middle_plot_info.num_linked_groups) AND (exists NE 1) DO BEGIN
              				IF (middle_peak[middle_plot_info.grouping,i].linked EQ $
					middle_linked_param[j]) THEN exists = 1
              				j = j + 1
           			ENDWHILE

           			IF (exists EQ 0) THEN BEGIN
              				middle_plot_info.num_linked_groups = $
					middle_plot_info.num_linked_groups + 1
              				middle_linked_param[middle_plot_info.num_linked_groups] = $
					middle_peak[middle_plot_info.grouping, i].linked
           			ENDIF

        		ENDFOR

     			ENDIF ELSE BEGIN
				middle_plot_info.num_linked_groups = middle_const_info.number_peaks
     			ENDELSE

   	ENDIF
   	IF (Window_Flag EQ 3) THEN BEGIN
     		; If constraints file has been read in, determine how many linked groups exist
     		IF (bottom_const_info.const_file_label EQ 1) THEN BEGIN

        		bottom_plot_info.num_linked_groups = 1
        		bottom_linked_param[1] = bottom_peak[bottom_plot_info.grouping,1].linked

        		FOR i = 2, bottom_const_info.number_peaks DO BEGIN
           			exists = 0
           			j = 1
           			WHILE (j LE bottom_plot_info.num_linked_groups) AND (exists NE 1) DO BEGIN
              				IF (bottom_peak[bottom_plot_info.grouping,i].linked EQ $
					bottom_linked_param[j]) THEN exists = 1
              				j = j + 1
           			ENDWHILE

           			IF (exists EQ 0) THEN BEGIN
              				bottom_plot_info.num_linked_groups = $
					bottom_plot_info.num_linked_groups + 1
              				bottom_linked_param[bottom_plot_info.num_linked_groups] = $
					bottom_peak[bottom_plot_info.grouping, i].linked
           			ENDIF

        		ENDFOR

     		ENDIF


   	ENDIF


END
;=======================================================================================================;
; Name:   REDISPLAY											;
; Purpose:  To totally recalculate the fit, curve, groups and everything associated with the graph.     ;
;           Sometimes, this fuction is needed, but it is slower than just calling DISPLAY_DATA.		;
; Paramters:  None.											;
; Return: None.												;
;=======================================================================================================;
PRO REDISPLAY

   COMMON common_vars
   COMMON common_widgets

   IF (Window_Flag EQ 1) THEN BEGIN
   	;Rephase the original data to zero phase to match the reconstructed data below
   	temp_phase = plot_info.phase
   	temp_traces = plot_info.traces

   	plot_info.phase = 0.0
   	plot_info.traces = 0
   	WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = plot_info.phase
   	PHASE_TIME_DOMAIN_DATA
   	plot_info.phase = temp_phase
   	WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = plot_info.phase
   	plot_info.traces = temp_traces

   	;Regenerate the reconstructed spectrum...this means that original phase will be restored
   	;therefore must rephase the original data to match (done above)
   	GENERATE_FIT_CURVE
   	GENERATE_NEW_DATA
   	PHASE_TIME_DOMAIN_DATA
   	GENERATE_RESIDUAL

   	IF (plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
   	DISPLAY_DATA
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   	;Rephase the original data to zero phase to match the reconstructed data below
   	temp_phase = middle_plot_info.phase
   	temp_traces = middle_plot_info.traces
print, "*** FFT1  1 = ", middle_plot_info.fft_initial
	middle_plot_info.fft_recalc = 1
   	middle_plot_info.phase = 0.0
   	middle_plot_info.traces = 0
   	WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
   	PHASE_TIME_DOMAIN_DATA
   	middle_plot_info.phase = temp_phase
   	WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = middle_plot_info.phase
   	middle_plot_info.traces = temp_traces

   	;Regenerate the reconstructed spectrum...this means that original phase will be restored
   	;therefore must rephase the original data to match (done above)
print, "*** FFT1 =   2", middle_plot_info.fft_initial
   	GENERATE_FIT_CURVE
   	GENERATE_NEW_DATA
   	PHASE_TIME_DOMAIN_DATA
   	GENERATE_RESIDUAL

print, "*** FFT1 =   3", middle_plot_info.fft_initial
   	IF (middle_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
   	MIDDLE_DISPLAY_DATA
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
   	;Rephase the original data to zero phase to match the reconstructed data below
   	temp_phase = bottom_plot_info.phase
   	temp_traces = bottom_plot_info.traces

   	bottom_plot_info.phase = 0.0
   	bottom_plot_info.traces = 0
   	WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = bottom_plot_info.phase
   	PHASE_TIME_DOMAIN_DATA
   	bottom_plot_info.phase = temp_phase
   	WIDGET_CONTROL, PHASE_SLIDER, SET_VALUE = bottom_plot_info.phase
   	bottom_plot_info.traces = temp_traces

   	;Regenerate the reconstructed spectrum...this means that original phase will be restored
   	;therefore must rephase the original data to match (done above)
   	GENERATE_FIT_CURVE
   	GENERATE_NEW_DATA
   	PHASE_TIME_DOMAIN_DATA
   	GENERATE_RESIDUAL

   	IF (bottom_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
   	BOTTOM_DISPLAY_DATA
   ENDIF


END

;===================================================================================================================

PRO AUTO_SCALE

   	COMMON common_vars
        COMMON common_widgets
   	IF (Window_Flag EQ 1 ) THEN BEGIN
   		;Generate x-axis
   		point_index = FINDGEN(data_file_header.points/2)

   		IF (plot_info.domain EQ 0) AND (plot_info.time_auto_scale_x EQ 1) AND $
		(plot_info.current_curve EQ 0) THEN BEGIN
			time = point_index * data_file_header.dwell
			time = [0, time]

      			plot_info.time_xmin = time[0]
      			plot_info.time_xmax = MAX(time)
   		ENDIF

   		IF (plot_info.domain EQ 0) AND (plot_info.time_auto_scale_y EQ 1) AND $
		(plot_info.current_curve EQ 0) THEN BEGIN
      			plot_info.time_ymin = MIN(time_data_points[0,*]) + 0.1*MIN(time_data_points[0,*])
      			plot_info.time_ymax = MAX(time_data_points[0,*]) + 0.3*MAX(time_data_points[0,*])
   		ENDIF

   		IF (plot_info.domain EQ 1) AND (plot_info.freq_auto_scale_x EQ 1) AND $
		(plot_info.current_curve EQ 0) THEN BEGIN
      			IF (plot_info.xaxis EQ 0) THEN BEGIN
         			plot_info.freq_xmin = MIN(freq)
         			plot_info.freq_xmax = MAX(freq)
      			ENDIF ELSE BEGIN
        			plot_info.freq_xmin = MIN(freq)/data_file_header.frequency
         			plot_info.freq_xmax = MAX(freq)/data_file_header.frequency
      			ENDELSE
   		ENDIF

   		IF (plot_info.domain EQ 1) AND (plot_info.freq_auto_scale_y EQ 1) AND $
		(plot_info.current_curve EQ 0) THEN BEGIN
	 		plot_info.freq_ymin = MIN(actual_freq_data_points) + 0.1*MIN(actual_freq_data_points)
	 		plot_info.freq_ymax = MAX(actual_freq_data_points) + 0.3*MAX(actual_freq_data_points)
   		ENDIF

   		; Set offset of the residual so that it appears at the top
   		; First determine the maximum value in the residual

   		IF (plot_info.domain EQ 0) AND (plot_info.time_auto_scale_y EQ 1) AND $
		(plot_info.current_curve EQ 2) THEN BEGIN
      			max_residual_value = MAX(time_data_points[2,*])
      			plot_color[2].offset = -1*(plot_info.time_ymax -max_residual_value)
   		ENDIF

   		IF (plot_info.domain EQ 1) AND (plot_info.freq_auto_scale_y EQ 1) AND $
		(plot_info.current_curve EQ 2) THEN BEGIN
      			max_residual_value = MAX(actual_freq_data_points)
      			plot_color[2].offset = -1*(plot_info.freq_ymax -max_residual_value)
   		ENDIF

   		IF (plot_info.domain EQ 1) AND (plot_info.current_curve EQ 3) THEN BEGIN
			max_curve_value = MAX(FLOAT(actual_freq_data_points[3, *]))
      			set = 0
      			WHILE (set EQ 0) DO BEGIN
         			y_range = plot_info.freq_ymax - plot_info.freq_ymin - max_curve_value
         			IF (plot_info.last_trace GT 3) THEN BEGIN
            				curve_increment = y_range / (plot_info.last_trace-2)
         			ENDIF ELSE BEGIN
            				curve_increment = y_range
         			ENDELSE
         			;Set the offset for all curves to be plotted
         			curve_OK = 1
         			curve_index = 2

				WHILE (curve_OK EQ 1) AND (curve_index LT plot_info.last_trace) DO BEGIN
            				curve_index = curve_index + 1
                			plot_color[curve_index].offset = $
					-1*(plot_info.freq_ymax - max_curve_value - (curve_increment*(curve_index-3)))

            				;Check that the trace falls within the plot area
            				curve_plot_max = MAX(FLOAT(actual_freq_data_points[curve_index, $
					*]) - plot_color[curve_index].offset)
            				IF (curve_plot_max GT plot_info.freq_ymax) THEN BEGIN
               					additional_offset = curve_plot_max - plot_info.freq_ymax
               					max_curve_value = max_curve_value + (additional_offset*1.10)
               					curve_OK = 0
            				ENDIF

            				IF (curve_index EQ plot_info.last_trace) THEN set = 1
         			ENDWHILE

      			ENDWHILE
   		ENDIF
	ENDIF
   	IF (Window_Flag EQ 2 ) THEN BEGIN
   		;Generate x-axis
   		middle_point_index = FINDGEN(middle_data_file_header.points/2)

   		IF (middle_plot_info.domain EQ 0) AND (middle_plot_info.time_auto_scale_x EQ 1) AND $
		(middle_plot_info.current_curve EQ 0) THEN BEGIN
			time = middle_point_index * middle_data_file_header.dwell
			time = [0, time]
      			middle_plot_info.time_xmin = time[0]
      			middle_plot_info.time_xmax = MAX(time)
   		ENDIF

   		IF (middle_plot_info.domain EQ 0) AND (middle_plot_info.time_auto_scale_y EQ 1) AND $
		(middle_plot_info.current_curve EQ 0) THEN BEGIN
      			middle_plot_info.time_ymin = MIN(middle_time_data_points[0,$
			*]) + 0.1*MIN(middle_time_data_points[0,*])
      			middle_plot_info.time_ymax = MAX(middle_time_data_points[0,$
			*]) + 0.3*MAX(middle_time_data_points[0,*])
   		ENDIF

   		IF (middle_plot_info.domain EQ 1) AND (middle_plot_info.freq_auto_scale_x EQ 1) AND $
		(middle_plot_info.current_curve EQ 0) THEN BEGIN
			IF (middle_plot_info.xaxis EQ 0) THEN BEGIN
         			middle_plot_info.freq_xmin = MIN(middle_freq)
         			middle_plot_info.freq_xmax = MAX(middle_freq)
      			ENDIF ELSE BEGIN
        			middle_plot_info.freq_xmin = MIN(middle_freq)/middle_data_file_header.frequency
         			middle_plot_info.freq_xmax = MAX(middle_freq)/middle_data_file_header.frequency
      			ENDELSE
   		ENDIF

   		IF (middle_plot_info.domain EQ 1) AND (middle_plot_info.freq_auto_scale_y EQ 1) AND $
		(middle_plot_info.current_curve EQ 0) THEN BEGIN
			middle_plot_info.freq_ymin = $
			MIN(middle_actual_freq_data_points) + 0.1*MIN(middle_actual_freq_data_points)
	 		middle_plot_info.freq_ymax = $
			MAX(middle_actual_freq_data_points) + 0.3*MAX(middle_actual_freq_data_points)
   		ENDIF

   		; Set offset of the residual so that it appears at the top
   		; First determine the maximum value in the residual

   		IF (middle_plot_info.domain EQ 0) AND (middle_plot_info.time_auto_scale_y EQ 1) AND $
		(middle_plot_info.current_curve EQ 2) THEN BEGIN
      			max_residual_value = MAX(middle_time_data_points[2,*])
      			middle_plot_color[2].offset = -1*(middle_plot_info.time_ymax -max_residual_value)
		ENDIF

   		IF (middle_plot_info.domain EQ 1) AND (middle_plot_info.freq_auto_scale_y EQ 1) AND $
		(middle_plot_info.current_curve EQ 2) THEN BEGIN
      			max_residual_value = MAX(middle_actual_freq_data_points)
      			middle_plot_color[2].offset = -1*(middle_plot_info.freq_ymax -max_residual_value)
   		ENDIF

   		IF (middle_plot_info.domain EQ 1) AND (middle_plot_info.current_curve EQ 3) THEN BEGIN
			max_curve_value = MAX(FLOAT(middle_actual_freq_data_points[3, *]))
      			set = 0
      		;	WHILE (set EQ 0) DO BEGIN

         			y_range = $
				middle_plot_info.freq_ymax - middle_plot_info.freq_ymin - max_curve_value
         			IF (middle_plot_info.last_trace GT 3) THEN BEGIN
                                      if(not(noOffset)) then begin
            				curve_increment = y_range / (middle_plot_info.last_trace-2)
                                      endif else if(noOffset) then begin
                                        curve_increment = 0
                                      endif
         			ENDIF ELSE BEGIN
            				curve_increment = y_range
         			ENDELSE
                                ;print, curve_increment

				;Set the offset for all curves to be plotted
         			curve_OK = 1
         			curve_index = 2

         			WHILE (curve_OK EQ 1) AND (curve_index LT middle_plot_info.last_trace) DO BEGIN
            				curve_index = curve_index + 1
                			;middle_plot_color[curve_index].offset = $
					;-1*(middle_plot_info.freq_ymax - max_curve_value - (curve_increment*(curve_index-3)))
                                        middle_plot_color[curve_index].offset = $
					-1*(curve_increment*(curve_index-3))


	            			;Check that the trace falls within the plot area
        	    			curve_plot_max = $
					MAX(FLOAT(middle_actual_freq_data_points[curve_index, *]) - middle_plot_color[curve_index].offset)
            				IF (curve_plot_max GT middle_plot_info.freq_ymax) THEN BEGIN
               					additional_offset = curve_plot_max - middle_plot_info.freq_ymax
               					max_curve_value = max_curve_value + (additional_offset*1.10)
               					curve_OK = 0
						print, "Curve ok reset"
            				ENDIF
                                        ;curve_index = curve_index + 1
            				IF (curve_index EQ middle_plot_info.last_trace) THEN set = 1
         			ENDWHILE
                                print, middle_plot_info.last_trace
      		;	ENDWHILE
   		ENDIF
   	ENDIF
   	IF (Window_Flag EQ 3 ) THEN BEGIN
     		;Generate x-axis
   		bottom_point_index = FINDGEN(bottom_data_file_header.points/2)

   		IF (bottom_plot_info.domain EQ 0) AND (bottom_plot_info.time_auto_scale_x EQ 1) AND $
			(bottom_plot_info.current_curve EQ 0) THEN BEGIN
			time = bottom_point_index * bottom_data_file_header.dwell
			time = [0, time]

      			bottom_plot_info.time_xmin = time[0]
      			bottom_plot_info.time_xmax = MAX(time)
   		ENDIF

   		IF (bottom_plot_info.domain EQ 0) AND (bottom_plot_info.time_auto_scale_y EQ 1) AND $
			(bottom_plot_info.current_curve EQ 0) THEN BEGIN
      			bottom_plot_info.time_ymin = $
			MIN(bottom_time_data_points[0,*]) + 0.1*MIN(bottom_time_data_points[0,*])
      			bottom_plot_info.time_ymax = $
			MAX(bottom_time_data_points[0,*]) + 0.3*MAX(bottom_time_data_points[0,*])
   		ENDIF

   		IF (bottom_plot_info.domain EQ 1) AND (bottom_plot_info.freq_auto_scale_x EQ 1) AND $
		(bottom_plot_info.current_curve EQ 0) THEN BEGIN
      			IF (bottom_plot_info.xaxis EQ 0) THEN BEGIN
         			bottom_plot_info.freq_xmin = MIN(bottom_freq)
         		bottom_plot_info.freq_xmax = MAX(bottom_freq)
      		ENDIF ELSE BEGIN
        		bottom_plot_info.freq_xmin = MIN(bottom_freq)/bottom_data_file_header.frequency
         		bottom_plot_info.freq_xmax = MAX(bottom_freq)/bottom_data_file_header.frequency
      		ENDELSE
   	ENDIF

   	IF (bottom_plot_info.domain EQ 1) AND (bottom_plot_info.freq_auto_scale_y EQ 1) AND $
	(bottom_plot_info.current_curve EQ 0) THEN BEGIN
	 	bottom_plot_info.freq_ymin = $
		MIN(bottom_actual_freq_data_points) + 0.1*MIN(bottom_actual_freq_data_points)
	 	bottom_plot_info.freq_ymax = $
		MAX(bottom_actual_freq_data_points) + 0.3*MAX(bottom_actual_freq_data_points)
   	ENDIF

   	; Set offset of the residual so that it appears at the top
   	; First determine the maximum value in the residual

   	IF (bottom_plot_info.domain EQ 0) AND (bottom_plot_info.time_auto_scale_y EQ 1) AND $
	(bottom_plot_info.current_curve EQ 2) THEN BEGIN
      		max_residual_value = MAX(bottom_time_data_points[2,*])
      		bottom_plot_color[2].offset = -1*(bottom_plot_info.time_ymax -max_residual_value)
   	ENDIF

   	IF (bottom_plot_info.domain EQ 1) AND (bottom_plot_info.freq_auto_scale_y EQ 1) AND $
	(bottom_plot_info.current_curve EQ 2) THEN BEGIN
      		max_residual_value = MAX(bottom_actual_freq_data_points)
      		bottom_plot_color[2].offset = -1*(bottom_plot_info.freq_ymax -max_residual_value)
   	ENDIF

   	IF (bottom_plot_info.domain EQ 1) AND (bottom_plot_info.current_curve EQ 3) THEN BEGIN
		max_curve_value = MAX(FLOAT(bottom_actual_freq_data_points[3, *]))
      		set = 0
      		WHILE (set EQ 0) DO BEGIN
         		y_range = bottom_plot_info.freq_ymax - bottom_plot_info.freq_ymin - max_curve_value
         		IF (bottom_plot_info.last_trace GT 3) THEN BEGIN
            			curve_increment = y_range / (bottom_plot_info.last_trace-2)
         		ENDIF ELSE BEGIN
            			curve_increment = y_range
         		ENDELSE
         		;Set the offset for all curves to be plotted
         		curve_OK = 1
         		curve_index = 2
         		WHILE (curve_OK EQ 1) AND (curve_index LT bottom_plot_info.last_trace) DO BEGIN
            			curve_index = curve_index + 1
                		bottom_plot_color[curve_index].offset = $
				-1*(bottom_plot_info.freq_ymax - max_curve_value - (curve_increment*(curve_index-3)))

            			;Check that the trace falls within the plot area
            			curve_plot_max = MAX(FLOAT(bottom_actual_freq_data_points[curve_index, $
				*]) - bottom_plot_color[curve_index].offset)
            			IF (curve_plot_max GT bottom_plot_info.freq_ymax) THEN BEGIN
               				additional_offset = curve_plot_max - bottom_plot_info.freq_ymax
               				max_curve_value = max_curve_value + (additional_offset*1.10)
               				curve_OK = 0
            			ENDIF

            			IF (curve_index EQ bottom_plot_info.last_trace) THEN set = 1
         		ENDWHILE

      		ENDWHILE
   	ENDIF
   ENDIF

END


pro windowRedraw
   COMMON common_vars
   COMMON common_widgets
   COMMON draw1_comm

   ;repaint = 1

   Window_Flag = 1
   wset,draw1_id
   DISPLAY_DATA

   Window_Flag = 3
   wset,draw3_id
   BOTTOM_DISPLAY_DATA

   Window_Flag = 2
   wset,draw2_id
   ;repaint = 0
end

pro reSize
    COMMON common_vars
    COMMON common_widgets
    COMMON draw1_comm

    vindex = getViewIndex()

    if(noResize ne 1) then begin

         WIDGET_CONTROL,TOP_DRAW,YSIZE    = (winSize[0,vindex]*yScale)
         WIDGET_CONTROL,MIDDLE_DRAW,YSIZE = (winSize[1,vindex]*yScale)
         WIDGET_CONTROL,BOTTOM_DRAW,YSIZE = (winSize[2,vindex]*yScale)

         windowRedraw
    endif

    if(middle_plot_info.last_trace ge 3) then begin
           !P.MULTI = [0, 1, 2]
    endif else begin
           !P.MULTI = [0, 0, 0]
    endelse
    ;print, 'resize'
end

;===============================================================================================================;
; Name:   ASSIGN_COLORS												;
; Purpose:  To allocate and assign the colours used in the graphs.   This version is used in the UNIX verson.	;
; Parameters:  None.												;
; Return:  None.												;
;===============================================================================================================;
PRO SET_PLOT_REGION

   COMMON common_vars
   COMMON common_widgets
   COMMON draw1_comm
   COMMON DrawNoise ; needs to adopt variables to ensure the plot is drawn correctly

   IF (Window_Flag EQ 1) THEN BEGIN
      IF (plot_info.view EQ 0) THEN BEGIN ; Set plot area for normal viewing
        !P.MULTI=[0,0,0]
       	!P.BACKGROUND = 0
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF (plot_info.view EQ 1) THEN BEGIN; Set plot area form paper output
      	!P.MULTI = [0, 0, 0]
      	!P.BACKGROUND = 15
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF(plot_info.view eq 2) then begin
         !P.MULTI=[0,0,0]
         !P.BACKGROUND = 2
         !X.CHARSIZE = 1.2
      	 !Y.CHARSIZE = 1.2
      	 !P.CHARSIZE = 1.2
      	 !Y.STYLE = 9
      	 !X.STYLE = 9
      	 !X.MARGIN = [12, 3]
      	 !Y.MARGIN = [4, 2]
	 !Y.TICKLEN = -.01
      endif
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN

	IF (middle_plot_info.view EQ 0) THEN BEGIN ; Set plot area for normal viewing

	IF (noise_flag ne 1) THEN reSize ; only "resize" the middle window if noise
					 ; characterization is not taking place

      	!P.BACKGROUND = 0
      	!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF (middle_plot_info.view EQ 1) THEN BEGIN; Set plot area form paper output
        reSize

      	!P.BACKGROUND = 15
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF(middle_plot_info.view eq 2) then begin
         reSize
         !P.BACKGROUND = 2
         !X.CHARSIZE = 1.2
      	 !Y.CHARSIZE = 1.2
      	 !P.CHARSIZE = 1.2
      	 !Y.STYLE = 9
      	 !X.STYLE = 9
      	 !X.MARGIN = [12, 3]
      	 !Y.MARGIN = [4, 2]
	 !Y.TICKLEN = -.01
      endif
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
      IF (bottom_plot_info.view EQ 0) THEN BEGIN ; Set plot area for normal viewing
      	!P.MULTI=[0,0,0]
      	!P.BACKGROUND = 0
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF (bottom_plot_info.view EQ 1) THEN BEGIN; Set plot area form paper output
        !P.MULTI=[0,0,0]
      	!P.BACKGROUND = 15
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF(bottom_plot_info.view eq 2) then begin
         !P.MULTI=[0,0,0]
         !P.BACKGROUND = 2
         !X.CHARSIZE = 1.2
      	 !Y.CHARSIZE = 1.2
      	 !P.CHARSIZE = 1.2
      	 !Y.STYLE = 9
      	 !X.STYLE = 9
      	 !X.MARGIN = [12, 3]
      	 !Y.MARGIN = [4, 2]
	 !Y.TICKLEN = -.01
      endif
   ENDIF

END


;===============================================================================================================;
; Name:   PRINT_SET_PLOT_REGION											;
; Purpose:  To set the values for each plot region in each window.  This is used for when we want to print.    	;
; Parameters:  None.												;
; Return:  None.												;
;===============================================================================================================;
PRO PRINT_SET_PLOT_REGION

   COMMON common_vars

   IF (Window_Flag EQ 1) THEN BEGIN
      IF (plot_info.view EQ 0) THEN BEGIN ; Set plot area for normal viewing
;        !P.MULTI=[0,0,0]
       	!P.BACKGROUND = 0
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF (plot_info.view EQ 1) THEN BEGIN; Set plot area form paper output
      	;!P.MULTI = [0, 0, 0]
      	!P.BACKGROUND = 15
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 5
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
      IF (middle_plot_info.view EQ 0) THEN BEGIN ; Set plot area for normal viewing
;      	!P.MULTI = [0, 1, 2]
      	!P.BACKGROUND = 0
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF (middle_plot_info.view EQ 1) THEN BEGIN; Set plot area form paper output
;      	!P.MULTI = [0, 1, 2]
      	!P.BACKGROUND = 15
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN
      IF (bottom_plot_info.view EQ 0) THEN BEGIN ; Set plot area for normal viewing
;      	!P.MULTI=[0,0,0]
      	!P.BACKGROUND = 0
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF

      IF (bottom_plot_info.view EQ 1) THEN BEGIN; Set plot area form paper output
;        !MULTI=[0,0,0]
      	!P.BACKGROUND = 15
      	;!P.CLIP = 1
      	!X.CHARSIZE = 1.2
      	!Y.CHARSIZE = 1.2
      	!P.CHARSIZE = 1.2
      	!Y.STYLE = 9
      	!X.STYLE = 9
      	!X.MARGIN = [12, 3]
      	!Y.MARGIN = [4, 2]
	!Y.TICKLEN = -.01
      ENDIF
   ENDIF

END

;=======================================================================================================;
; Name:  DO_MULTI_ZOOM											;
; Purpose:  To preform a zoom on all three windows at the same time, using the same values to zoom by.	;
; Parameters:  None.											;
; Return: None.												;
;=======================================================================================================;
PRO DO_MULTI_ZOOM
     COMMON common_vars
     COMMON common_widgets
     COMMON Draw1_comm

	;print, "Inside Multi-Zoom"

	IF (plot_info.domain EQ 0) THEN BEGIN
       		plot_info.time_auto_scale_y =0
       		plot_info.time_auto_scale_x =0
       	ENDIF ELSE BEGIN
       		plot_info.freq_auto_scale_y =0
       		plot_info.freq_auto_scale_x =0
       	ENDELSE
	IF (middle_plot_info.domain EQ 0) THEN BEGIN
       		middle_plot_info.time_auto_scale_y =0
       		middle_plot_info.time_auto_scale_x =0
       	ENDIF ELSE BEGIN
       		middle_plot_info.freq_auto_scale_y =0
       		middle_plot_info.freq_auto_scale_x =0
       	ENDELSE
       	IF (bottom_plot_info.domain EQ 0) THEN BEGIN
       		bottom_plot_info.time_auto_scale_y =0
       		bottom_plot_info.time_auto_scale_x =0
       	ENDIF ELSE BEGIN
       		bottom_plot_info.freq_auto_scale_y =0
       		bottom_plot_info.freq_auto_scale_x =0
       	ENDELSE

        plot_info.fft_recalc = 1
        middle_plot_info.fft_recalc = 1
        bottom_plot_info.fft_recalc = 1

        IF (plot_info.domain EQ 0) AND (plot_info.x1 LT 0) THEN plot_info.x1 = 0
        IF (plot_info.domain EQ 0) AND (plot_info.x2 GT $
	(data_file_header.points/2-1)*data_file_header.dwell) THEN plot_info.x2 = $
	(data_file_header.points/2-1)*data_file_header.dwell

        IF (plot_info.domain EQ 0) THEN plot_info.time_xmin = plot_info.x1 ELSE plot_info.freq_xmin = $
	plot_info.x2
        IF (plot_info.domain EQ 0) THEN plot_info.time_xmax = plot_info.x2 ELSE plot_info.freq_xmax = $
	plot_info.x1
        IF (plot_info.domain EQ 0) THEN plot_info.time_ymin = plot_info.y1 ELSE plot_info.freq_ymin = $
	plot_info.y1
        IF (plot_info.domain EQ 0) THEN plot_info.time_ymax = plot_info.y2 ELSE plot_info.freq_ymax = $
	plot_info.y2

        IF (middle_plot_info.domain EQ 0) AND (middle_plot_info.x1 LT 0) THEN middle_plot_info.x1 = 0
        IF (middle_plot_info.domain EQ 0) AND (middle_plot_info.x2 GT $
	(middle_data_file_header.points/2-1)*middle_data_file_header.dwell) THEN $
        middle_plot_info.x2 = (middle_data_file_header.points/2-1)*middle_data_file_header.dwell

        IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_xmin = $
	middle_plot_info.x1 ELSE middle_plot_info.freq_xmin = middle_plot_info.x2

	IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_xmax = $
	middle_plot_info.x2 ELSE middle_plot_info.freq_xmax = middle_plot_info.x1
        IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_ymin = $
	middle_plot_info.y1 ELSE middle_plot_info.freq_ymin = middle_plot_info.y1
        IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_ymax = $
	middle_plot_info.y2 ELSE middle_plot_info.freq_ymax = middle_plot_info.y2

        IF (bottom_plot_info.domain EQ 0) AND (bottom_plot_info.x1 LT 0) THEN bottom_plot_info.x1 = 0
        IF (bottom_plot_info.domain EQ 0) AND (bottom_plot_info.x2 GT $
	(bottom_data_file_header.points/2-1)*bottom_data_file_header.dwell) THEN $
        bottom_plot_info.x2 = (bottom_data_file_header.points/2-1)*bottom_data_file_header.dwell

        IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_xmin = $
	bottom_plot_info.x1 ELSE bottom_plot_info.freq_xmin = bottom_plot_info.x2
        IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_xmax = $
	bottom_plot_info.x2 ELSE bottom_plot_info.freq_xmax = bottom_plot_info.x1
        IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_ymin = $
	bottom_plot_info.y1 ELSE bottom_plot_info.freq_ymin = bottom_plot_info.y1
        IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_ymax = $
	bottom_plot_info.y2 ELSE bottom_plot_info.freq_ymax = bottom_plot_info.y2





 	Window_Flag = 1
 	WSET, Draw1_Id
	DISPLAY_DATA

	Window_Flag = 2
	WSET, Draw2_Id

	MIDDLE_DISPLAY_DATA

	Window_Flag = 3
	WSET, DRAW3_Id

 	BOTTOM_DISPLAY_DATA

END

;===============================================================================================================;
; Name:   ASSIGN_COLORS												;
; Purpose:  To allocate and assign the colours used in the graphs.   This version is used in the UNIX verson.	;
; Parameters:  None.												;
; Return:  None.												;
;===============================================================================================================;
PRO ASSIGN_COLOURS

	COMMON common_vars


   IF (Window_Flag EQ 1) THEN BEGIN

   	IF (plot_info.view EQ 0) THEN BEGIN
		;loadct, 39
  		;stretch, 0, plot_info.max_colours
  		;device, /pcolor
   		TVLCT, Red, Green, Blue
		;device, /pseudo_color
	        ; Color scheme:  black, light green, yellow, white, blue, red, grey

		plot_info.axis_colour = 2
   		plot_color[0].creal = 3
   		plot_color[0].cimag = 1
   		plot_color[1].creal = 5  ;Plot the reconstructed curves in RED
   		plot_color[1].cimag = 5  ;Plot the reconstructed curves in RED
   		plot_color[2].creal = 4  ;Plot the residual  in BLUE
   		plot_color[2].cimag = 4  ;Plot the residual  in BLUE
   		plot_color[1].thick = 1.25
   	ENDIF
   	IF (plot_info.view EQ 1) THEN BEGIN
		loadct, 0
  		stretch, 0, plot_info.max_colours
  		;device, /pseudo_color
  		; Load in a standard color table to use for plotting lines
		plot_info.axis_colour = 0
   		plot_color[0].creal = 7
   		plot_color[0].cimag = 12
   		plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		plot_color[2].creal = 7  ;Plot the residual  in BLUE
   		plot_color[2].cimag = 12  ;Plot the residual  in BLUE
   		plot_color[1].thick = 1.25

   	ENDIF

        if(plot_info.view eq 2) then begin
              LOADCT,0
              TVLCT, Red, Green, Blue

              plot_info.axis_colour = 0
              plot_color[0].creal = 3
   	      plot_color[0].cimag = 1
   	      plot_color[1].creal = 5  ;Plot the reconstructed curves in RED
   	      plot_color[1].cimag = 5  ;Plot the reconstructed curves in RED
   	      plot_color[2].creal = 4  ;Plot the residual  in BLUE
   	      plot_color[2].cimag = 4  ;Plot the residual  in BLUE
   	      plot_color[1].thick = 1.25
        endif
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   	IF (middle_plot_info.view EQ 0) THEN BEGIN
                TVLCT, Red, Green, Blue

	        ;stretch, 0, middle_plot_info.max_colours
		;device, /pseudo_color
		; Color scheme:  black, light green, yellow, white, blue, red, grey
  		middle_plot_info.axis_colour = 2
   		middle_plot_color[0].creal = 3
   		middle_plot_color[0].cimag = 1
   		middle_plot_color[1].creal = 5  ;Plot the reconstructed curves in RED
   		middle_plot_color[1].cimag = 5  ;Plot the reconstructed curves in RED
   		middle_plot_color[2].creal = 4  ;Plot the residual  in BLUE
   		middle_plot_color[2].cimag = 4  ;Plot the residual  in BLUE
   	ENDIF
   	IF (middle_plot_info.view EQ 1) THEN BEGIN
		LOADCT,0
 		stretch, 0, middle_plot_info.max_colours
		;device, /pseudo_color
		middle_plot_info.axis_colour = 0
     		middle_plot_color[0].creal = 0;7
   		middle_plot_color[0].cimag = 0;12
   		middle_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		middle_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		middle_plot_color[2].creal = 0;7  ;Plot the residual  in BLUE
   		middle_plot_color[2].cimag = 0  ;Plot the residual  in BLUE
   		middle_plot_color[1].thick = 1.25
	ENDIF

        if(middle_plot_info.view eq 2) then begin
              LOADCT,0
              TVLCT, Red, Green, Blue
              ;stretch, 0, middle_plot_info.max_colours

              middle_plot_info.axis_colour = 0
              middle_plot_color[0].creal = 3
   	      middle_plot_color[0].cimag = 1
   	      middle_plot_color[1].creal = 5  ;Plot the reconstructed curves in RED
   	      middle_plot_color[1].cimag = 5  ;Plot the reconstructed curves in RED
   	      middle_plot_color[2].creal = 4  ;Plot the residual  in BLUE
   	      middle_plot_color[2].cimag = 4  ;Plot the residual  in BLUE
   	      middle_plot_color[1].thick = 1.25
        endif
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN

   	IF (bottom_plot_info.view EQ 0) THEN BEGIN
		TVLCT, Red, Green, Blue
		; Color scheme:  black, light green, yellow, white, blue, red, grey

  		bottom_plot_info.axis_colour = 2
   		bottom_plot_color[0].creal = 3
   		bottom_plot_color[0].cimag = 1
   		bottom_plot_color[1].creal = 5  ;Plot the reconstructed curves in RED
   		bottom_plot_color[1].cimag = 5  ;Plot the reconstructed curves in RED
   		bottom_plot_color[2].creal = 4  ;Plot the residual  in BLUE
   		bottom_plot_color[2].cimag = 4  ;Plot the residual  in BLUE
   		bottom_plot_color[1].thick = 1.25
   	ENDIF

   	IF (bottom_plot_info.view EQ 1) THEN BEGIN
		bottom_plot_info.axis_colour = 0
  		; Load in a standard color table to use for plotting lines
		loadct, 0
  		stretch, 0, bottom_plot_info.max_colours

		bottom_plot_color[0].creal = 7
   		bottom_plot_color[0].cimag = 12
   		bottom_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		bottom_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		bottom_plot_color[2].creal = 7  ;Plot the residual  in BLUE
   		bottom_plot_color[2].cimag = 0  ;Plot the residual  in BLUE
   		bottom_plot_color[1].thick = 1.25
	ENDIF

        if(bottom_plot_info.view eq 2) then begin
              LOADCT,0
              TVLCT, Red, Green, Blue
              bottom_plot_info.axis_colour = 0
              bottom_plot_color[0].creal = 3
   	      bottom_plot_color[0].cimag = 1
   	      bottom_plot_color[1].creal = 5  ;Plot the reconstructed curves in RED
   	      bottom_plot_color[1].cimag = 5  ;Plot the reconstructed curves in RED
   	      bottom_plot_color[2].creal = 4  ;Plot the residual  in BLUE
   	      bottom_plot_color[2].cimag = 4  ;Plot the residual  in BLUE
   	      bottom_plot_color[1].thick = 1.25
        endif


   ENDIF


END

;===============================================================================================================;
; Name:   ASSIGN_MAC_COLORS											;
; Purpose:  To allocate and assign the colours used in the graphs.   This version is used in the MAC verson.	;
; Parameters:  None.												;
; Return:  None.												;
;===============================================================================================================;
PRO ASSIGN_MAC_COLORS

	COMMON common_vars


   	IF (Window_Flag EQ 1) THEN BEGIN

   		IF (plot_info.view EQ 0) THEN BEGIN
			loadct, 39
  			stretch, 0, plot_info.max_colours
  			device, /pseudo_color
   			print,  plot_info.max_colours
			plot_info.axis_colour = 29
   			plot_color[0].creal = 11
   			plot_color[0].cimag = 9
   			plot_color[1].creal = 15  ;Plot the reconstructed curves in RED
   			plot_color[1].cimag = 15  ;Plot the reconstructed curves in RED
   			plot_color[2].creal = 3  ;Plot the residual  in BLUE
   			plot_color[2].cimag = 3  ;Plot the residual  in BLUE
   			plot_color[1].thick = 1.25
   		ENDIF
   		IF (plot_info.view EQ 1) THEN BEGIN
			loadct, 0
  			stretch, 0, plot_info.max_colours
  			device, /pseudo_color
  			; Load in a standard color table to use for plotting lines
			plot_info.axis_colour = 0
   			plot_color[0].creal = 7
   			plot_color[0].cimag = 12
   			plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   			plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   			plot_color[2].creal = 7  ;Plot the residual  in BLUE
   			plot_color[2].cimag = 12  ;Plot the residual  in BLUE
   			plot_color[1].thick = 1.25

   		ENDIF
   ENDIF
   IF (Window_Flag EQ 2) THEN BEGIN
   	IF (middle_plot_info.view EQ 0) THEN BEGIN
		LOADCT, 39
	        stretch, 0, middle_plot_info.max_colours
		device, /pseudo_color

		; Color scheme:  black, light green, yellow, white, blue, red, grey
  		middle_plot_info.axis_colour = 29
   		middle_plot_color[0].creal =11
   		middle_plot_color[0].cimag = 9
   		middle_plot_color[1].creal = 15  ;Plot the reconstructed curves in RED
   		middle_plot_color[1].cimag = 15  ;Plot the reconstructed curves in RED
   		middle_plot_color[2].creal = 3  ;Plot the residual  in BLUE
   		middle_plot_color[2].cimag = 3  ;Plot the residual  in BLUE
   		middle_plot_color[1].thick = 1.25
   	ENDIF
   	IF (middle_plot_info.view EQ 1) THEN BEGIN
		LOADCT,0
 		stretch, 0, bottom_plot_info.max_colours
		device, /pseudo_color
		middle_plot_info.axis_colour = 0
     		middle_plot_color[0].creal = 7
   		middle_plot_color[0].cimag = 12
   		middle_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		middle_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		middle_plot_color[2].creal = 7  ;Plot the residual  in BLUE
   		middle_plot_color[2].cimag = 0  ;Plot the residual  in BLUE
   		middle_plot_color[1].thick = 1.25
	ENDIF
   ENDIF
   IF (Window_Flag EQ 3) THEN BEGIN

   	IF (bottom_plot_info.view EQ 0) THEN BEGIN

		LOADCT, 39
		stretch, 0, bottom_plot_info.max_colours
		device, /pseudo_color

		; Color scheme:  black, light green, yellow, white, blue, red, grey

  		bottom_plot_info.axis_colour = 29
   		bottom_plot_color[0].creal = 11
   		bottom_plot_color[0].cimag = 9
   		bottom_plot_color[1].creal = 15  ;Plot the reconstructed curves in RED
   		bottom_plot_color[1].cimag = 15  ;Plot the reconstructed curves in RED
   		bottom_plot_color[2].creal = 3  ;Plot the residual  in BLUE
   		bottom_plot_color[2].cimag = 3  ;Plot the residual  in BLUE
   		bottom_plot_color[1].thick = 1.25
   	ENDIF

   	IF (bottom_plot_info.view EQ 1) THEN BEGIN
   		TVLCT, Red, Green, Blue
		bottom_plot_info.axis_colour = 0
  		; Load in a standard color table to use for plotting lines
		loadct, 0
  		stretch, 0, bottom_plot_info.max_colours
     		device, /pseudo_color

		bottom_plot_color[0].creal = 7
   		bottom_plot_color[0].cimag = 12
   		bottom_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		bottom_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		bottom_plot_color[2].creal = 7  ;Plot the residual  in BLUE
   		bottom_plot_color[2].cimag = 0  ;Plot the residual  in BLUE
   		bottom_plot_color[1].thick = 1.25
	ENDIF

   ENDIF


END
;===============================================================================================================;
; Name:  ASSIGN_PRINT_COLOURS											;
; Purpose:   All the graphs need to be reassigned a colour table when it comes time to print.  This procedure   ;
;	     sets up the colors for the printing.   								;
; Parameters:  None.												;
; Return:  None.												;
;===============================================================================================================;
PRO ASSIGN_PRINT_COLOURS

   	COMMON common_vars

   	IF (plot_info.view EQ 0 OR middle_plot_info.view EQ 0 $
  	    OR bottom_plot_info.view EQ 0) THEN BEGIN

		TVLCT, Red, Green, Blue

		plot_info.view = 0
		middle_plot_info.view = 0
		bottom_plot_info.view = 0

   		plot_info.axis_colour = 5
   		plot_color[0].creal = 11
   		plot_color[0].cimag = 9
   		plot_color[1].creal = 3  ;Plot the reconstructed curves in RED
   		plot_color[1].cimag = 3  ;Plot the reconstructed curves in RED
   		plot_color[2].creal = 2  ;Plot the residual  in BLUE
   		plot_color[2].cimag = 2  ;Plot the residual  in BLUE
   		plot_color[1].thick = 1.25
		middle_plot_info.axis_colour = 15
   		middle_plot_color[0].creal = 11
   		middle_plot_color[0].cimag = 9
   		middle_plot_color[1].creal = 14  ;Plot the reconstructed curves in RED
   		middle_plot_color[1].cimag = 14  ;Plot the reconstructed curves in RED
   		middle_plot_color[2].creal = 6  ;Plot the residual  in BLUE
   		middle_plot_color[2].cimag = 6  ;Plot the residual  in BLUE
   		middle_plot_color[1].thick = 1.25
		bottom_plot_info.axis_colour = 15
   		bottom_plot_color[0].creal = 11
   		bottom_plot_color[0].cimag = 9
   		bottom_plot_color[1].creal = 14  ;Plot the reconstructed curves in RED
   		bottom_plot_color[1].cimag = 14  ;Plot the reconstructed curves in RED
   		bottom_plot_color[2].creal = 6  ;Plot the residual  in BLUE
   		bottom_plot_color[2].cimag = 6  ;Plot the residual  in BLUE
   		bottom_plot_color[1].thick = 1.25
   	ENDIF
   	IF (plot_info.view EQ 1) THEN BEGIN
		loadct, 0
  		stretch, 0, plot_info.max_colours
      		plot_info.axis_colour = 0

		; Load in a standard color table to use for plotting lines
   		plot_color[0].creal = 7
   		plot_color[0].cimag = 12
   		plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		plot_color[2].creal = 7  ;Plot the residual  in BLUE
   		plot_color[2].cimag = 12  ;Plot the residual  in BLUE
   		plot_color[1].thick = 1.25
		middle_plot_color[0].creal = 7
   		middle_plot_color[0].cimag = 12
   		middle_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		middle_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		middle_plot_color[2].creal = 7  ;Plot the residual  in BLUE
   		middle_plot_color[2].cimag = 12  ;Plot the residual  in BLUE
   		middle_plot_color[1].thick = 1.25
		bottom_plot_color[0].creal = 7
   		bottom_plot_color[0].cimag = 12
   		bottom_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
   		bottom_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
   		bottom_plot_color[2].creal = 7  ;Plot the residual  in BLUE
   		bottom_plot_color[2].cimag = 12  ;Plot the residual  in BLUE
   		bottom_plot_color[1].thick = 1.25
	ENDIF


END







