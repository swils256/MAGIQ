;---------------------------------------------------------------------------------------------------------------------------------------;
; Name: TIME_SUBTRACT													                ;
; Purpose:   Given two data sets, this fuction will subtract the two data sets in the time domain (as opposed to the frequency domain)  ;
;            and will put the resulting data set in the third window.   It will then display it to the third window.   The data set is  ;
;            also allowed to be modified by a scaling factor which is changed by a slider.                                              ;
;            The header files is the exact same as plot_info's, so we simply copy it's elements into the third window's data_file_header;
; Return:  Returns a new data set (the subtraction of the two input data sets).   Unfortunately, most of the variables were global, so  ;
;	   the data ;set is placed in global variables as well.                                                                         ;
;---------------------------------------------------------------------------------------------------------------------------------------;

PRO TIME_SUBTRACT, s_factor
	COMMON common_vars
	COMMON common_widgets
	COMMON Draw1_Comm
	
	Window_Flag = 3
	WSET, Draw3_Id
	
	; Set up the middle data_header file.
	bottom_data_file_header.points = data_file_header.points
	bottom_data_file_header.components = data_file_header.components
	bottom_data_file_header.dwell = data_file_header.dwell
	bottom_data_file_header.frequency = data_file_header.frequency
	bottom_data_file_header.scans= data_file_header.scans
	bottom_data_file_header.acq_type = data_file_header.acq_type
	bottom_data_file_header.increment = data_file_header.increment
	bottom_data_file_header.empty = data_file_header.empty
	bottom_data_file_header.comment1 = data_file_header.comment1
	bottom_data_file_header.comment2 = data_file_header.comment2
	bottom_data_file_header.comment3 = data_file_header.comment3
	bottom_data_file_header.comment4 = data_file_header.comment4
	bottom_plot_info.data_file = 'N/A'
	
	;Define variables ppm and hertz
	bottom_guess_variables[0].name = 'PPM'
	bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
	bottom_guess_variables[1].name = 'HERTZ'
	bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency
	bottom_guess_info.number_variables = 2
	bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
	
	; First window's data is stored in time_data_points, and the third is in bottom_time_data_points.
	; Then, display data in the third window
	bottom_time_data_points[0,*] = original_data  - (middle_original_data*s_factor)
	bottom_original_data = REFORM(bottom_time_data_points[0,*])
	AUTO_SCALE
	WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
	WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
	WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
	WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
	WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
	bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * bottom_data_file_header.dwell)
	WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
	
	;Display only the real part of the time domain signal
	bottom_time_data_points[0,0] = complex(1,0)
	bottom_plot_info.domain = 1
	;BOTTOM_DISPLAY_DATA
	
	REDISPLAY
END

;--------------------------------------------------------------------------------------------------------------------------------------;
; Name:  FREQ_SUBTRACT 														       ;
; Purpose:  This method subtracts two sets of data that are in the frequency domain.   The data gets set in the 3rd window of the GUI. ;
;    	    It will have the resulting graph drawn in the third window (the bottom one).         				       ;
;           The data_header is copied straight from plot_info because in any two graphs that are "subtractable", the two data headers, ;
; 	    and the resulting header should be identical.   Thus is it ok to simply fill in the values from the first or second window.;
; Return:  A transformed graph, drawn in the third window.   Unfortunately, the dataset is evquivelent to global, so all modifications ;
;          were made from COMMON block variables.                        						 	       ;
;--------------------------------------------------------------------------------------------------------------------------------------;

PRO FREQ_SUBTRACT, s_factor
	COMMON common_vars
	COMMON common_widgets
	COMMON Draw1_Comm
	
	; Set up drawing for third window
	Window_Flag = 3
	WSET, Draw3_Id
	print, "FREQ_SUBTRACT"
	
	; Set up the middle data_header file.
	bottom_data_file_header.points = data_file_header.points
	bottom_data_file_header.components = data_file_header.components
	bottom_data_file_header.dwell = data_file_header.dwell
	bottom_data_file_header.frequency = data_file_header.frequency
	bottom_data_file_header.scans= data_file_header.scans
	bottom_data_file_header.acq_type = data_file_header.acq_type
	bottom_data_file_header.increment = data_file_header.increment
	bottom_data_file_header.empty = data_file_header.empty
	bottom_plot_info.data_file = 'N/A'
	bottom_data_file_header.comment1 = data_file_header.comment1
	bottom_data_file_header.comment2 = data_file_header.comment2
	bottom_data_file_header.comment3 = data_file_header.comment3
	bottom_data_file_header.comment4 = data_file_header.comment4

	;Define variables ppm and hertz
	bottom_guess_variables[0].name = 'PPM'
	bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
	bottom_guess_variables[1].name = 'HERTZ'
	bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency
	bottom_guess_info.number_variables = 2
	bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
	
	; First window's data is stored in time_data_points, and the third is in bottom_time_data_points.
	; Convert time domain data into freq. domain data, subtract, and convert back to time domain.
	; Then, redisplay data in the second window
	;bottom_plot_info.domain = 1
	help, bottom_time_data_points
	print, "SCALE FACTOR", s_factor
	bottom_time_data_points[0,*] = original_data - (middle_original_data*s_factor)
	bottom_original_data = REFORM(bottom_time_data_points[0,*])
	
	AUTO_SCALE
	WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
	WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
	WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
	WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
	WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
	bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * bottom_data_file_header.dwell)
	WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
	
	;Display only the real part of the time domain signal
	bottom_time_data_points[0,0] = complex(1,0)
	bottom_plot_info.domain =1
	REDISPLAY
END

;---------------------------------------------------------------------------------------------------------------------------------------;
; Name: FREQ_ADD													                ;
; Purpose:   Given two data sets, this fuction will add the two data sets in the time domain (as opposed to the frequency domain)       ;
;            and will put the resulting data set in the third window.   It will then display it to the third window.   The data set is  ;
;            also allowed to be modified by a scaling factor which is changed by a slider.                                              ;
;            The header files is the exact same as plot_info's, so we simply copy it's elements into the third window's data_file_header;
; Return:  Returns a new data set (the subtraction of the two input data sets).   Unfortunately, most of the variables were global, so  ;
;	   the data ;set is placed in global variables as well.                                                                         ;
;---------------------------------------------------------------------------------------------------------------------------------------;

PRO FREQ_ADD, s_factor
	COMMON common_vars
	COMMON common_widgets
	COMMON Draw1_Comm
	
	; Set up drawing for third window
	Window_Flag = 3
	WSET, Draw3_Id
	print, "FREQ_ADD"
	
	; Set up the middle data_header file.
	bottom_data_file_header.points = data_file_header.points
	bottom_data_file_header.components = data_file_header.components
	bottom_data_file_header.dwell = data_file_header.dwell
	bottom_data_file_header.frequency = data_file_header.frequency
	bottom_data_file_header.scans= data_file_header.scans
	bottom_data_file_header.acq_type = data_file_header.acq_type
	bottom_data_file_header.increment = data_file_header.increment
	bottom_data_file_header.empty = data_file_header.empty
	bottom_plot_info.data_file = 'N/A'
	bottom_data_file_header.comment1 = data_file_header.comment1
	bottom_data_file_header.comment2 = data_file_header.comment2
	bottom_data_file_header.comment3 = data_file_header.comment3
	bottom_data_file_header.comment4 = data_file_header.comment4
	
	;Define variables ppm and hertz
	bottom_guess_variables[0].name = 'PPM'
	bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
	bottom_guess_variables[1].name = 'HERTZ'
	bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency
	bottom_guess_info.number_variables = 2
	bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
	
	; First window's data is stored in time_data_points, and the third is in bottom_time_data_points.
	; Convert time domain data into freq. domain data, subtract, and convert back to time domain.
	; Then, redisplay data in the second window
	;bottom_plot_info.domain = 1
	help, bottom_time_data_points
	print, "SCALE FACTOR", s_factor
	bottom_time_data_points[0,*] = original_data + (middle_original_data*s_factor)
	bottom_original_data = REFORM(bottom_time_data_points[0,*])
	
	AUTO_SCALE
	WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
	WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
	WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
	WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
	WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
	bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * bottom_data_file_header.dwell)
	WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
	
	;Display only the real part of the time domain signal
	bottom_time_data_points[0,0] = complex(1,0)
	bottom_plot_info.domain = 1
	REDISPLAY
END


;---------------------------------------------------------------------------------------------------------------------------------------;
; Name: TIME_ADD													                ;
; Purpose:   Given two data sets, this fuction will subtract the two data sets in the time domain (as opposed to the frequency domain)	;
;	     and will put the resulting data set in the third window.   It will then display it to the third window. The data set is	;
;	     also allowed to be modified by a scaling factor which is changed by a slider.                              		;
;            The header files is the exact same as plot_info's, so we simply copy it's elements into the third window's data_file_header;
; Return:  Returns a new data set (the subtraction of the two input data sets).   Unfortunately, most of the variables were global, so  ;
;	   the data ;set is placed in global variables as well.                                                                         ;
;---------------------------------------------------------------------------------------------------------------------------------------;

PRO TIME_ADD, s_factor
	COMMON common_vars
	COMMON common_widgets
	COMMON Draw1_Comm
	
	Window_Flag = 3
	WSET, Draw3_Id
	print, "inside TIME_ADD"
	
	; Set up the middle data_header file.
	bottom_data_file_header.points = data_file_header.points
	bottom_data_file_header.components = data_file_header.components
	bottom_data_file_header.dwell = data_file_header.dwell
	bottom_data_file_header.frequency = data_file_header.frequency
	bottom_data_file_header.scans= data_file_header.scans
	bottom_data_file_header.acq_type = data_file_header.acq_type
	bottom_data_file_header.increment = data_file_header.increment
	bottom_data_file_header.empty = data_file_header.empty
	bottom_plot_info.data_file = 'N/A'
	bottom_data_file_header.comment1 = data_file_header.comment1
	bottom_data_file_header.comment2 = data_file_header.comment2
	bottom_data_file_header.comment3 = data_file_header.comment3
	bottom_data_file_header.comment4 = data_file_header.comment4
	
	;Define variables ppm and hertz
	bottom_guess_variables[0].name = 'PPM'
	bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
	bottom_guess_variables[1].name = 'HERTZ'
	bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency
	bottom_guess_info.number_variables = 2
	bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
	
	; First window's data is stored in time_data_points, and the third is in bottom_time_data_points.
	; Convert time domain data into freq. domain data, subtract, and convert back to time domain.
	; Then, display data in the third window
	bottom_time_data_points[0,*] = original_data + (middle_original_data*s_factor)
	bottom_original_data = REFORM(bottom_time_data_points[0,*])
	
	AUTO_SCALE
	WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
	WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
	WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
	WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
	WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
	bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * bottom_data_file_header.dwell)
	WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
	
	;Display only the real part of the time domain signal
	bottom_time_data_points[0,0] = complex(1,0)
	bottom_plot_info.domain = 1
	
	;BOTTOM_DISPLAY_DATA
	REDISPLAY
END


;---------------------------------------------------------------------------------------------------------------------------------------;
; Name: FREQ_ALIGN													                ;
; Purpose:   Given two data sets, this fuction will manually align and add the two data sets in the frequency domain and will put the   ;
;            resulting data set in the third window.   It will then display it to the third window.   The data set is also allowed to   ;
;	     be modified by a scaling factor which is changed by a slider.                                              		;
;            The header files is the exact same as plot_info's, so we simply copy it's elements into the third window's data_file_header;
; Return:  Returns a new data set (the sum of the two input data sets).   Unfortunately, most of the variables were global, so          ;
;	   the data ;set is placed in global variables as well.                                                                         ;
;---------------------------------------------------------------------------------------------------------------------------------------;

PRO FREQ_ALIGN, s_factor, w_factor
	COMMON common_vars
	COMMON common_widgets
	COMMON Draw1_Comm
	
	; Set up drawing for third window
	Window_Flag = 3	
	WSET, Draw3_Id
	print, "FREQ_ALIGN"
	
	; Set up the middle data_header file.
	bottom_data_file_header.points = data_file_header.points
	bottom_data_file_header.components = data_file_header.components
	bottom_data_file_header.dwell = data_file_header.dwell
	bottom_data_file_header.frequency = data_file_header.frequency
	bottom_data_file_header.scans= data_file_header.scans
	bottom_data_file_header.acq_type = data_file_header.acq_type
	bottom_data_file_header.increment = data_file_header.increment
	bottom_data_file_header.empty = data_file_header.empty
	bottom_plot_info.data_file = 'N/A'
	bottom_data_file_header.comment1 = data_file_header.comment1
	bottom_data_file_header.comment2 = data_file_header.comment2
	bottom_data_file_header.comment3 = data_file_header.comment3
	bottom_data_file_header.comment4 = data_file_header.comment4
	
	;Define variables ppm and hertz
	bottom_guess_variables[0].name = 'PPM'
	bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
	bottom_guess_variables[1].name = 'HERTZ'
	bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency
	bottom_guess_info.number_variables = 2
	bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
	
	; First window's data is stored in time_data_points, and the third is in bottom_time_data_points.
	; Convert time domain data into freq. domain data, subtract, and convert back to time domain.
	; Then, redisplay data in the second window
	;bottom_plot_info.domain = 1
	
	; Create the array with the multiplication algorithm
	; w = frequency shift, n = point number, t = time interval
	w = DOUBLE (w_factor)
	n = DINDGEN(N_ELEMENTS(middle_original_data))
	t = DOUBLE (middle_data_file_header.dwell)
	num = DOUBLE (2) * !PI * w * n * t
	
	shifter = dcomplex(cos(num), (-1) * sin(num))
	shifter = SHIFT(shifter, 1)
	
	help, w, n, t, num, shifter
	
	; Shifted data does not look like original data
	; But the shifting still works - this is a problem with the display
	
	help, bottom_time_data_points
	print, "SCALE FACTOR", s_factor
	bottom_time_data_points[0,*] = original_data + ((middle_original_data*shifter)*s_factor)
	bottom_original_data = REFORM(bottom_time_data_points[0,*])
	bottom_original_data[0] = middle_original_data[0]
	
	AUTO_SCALE
	WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
	WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
	WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
	WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
	WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
	bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * bottom_data_file_header.dwell)
	WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
	
	;Display only the real part of the time domain signal	
	bottom_time_data_points[0,0] = complex(1,0)
	bottom_plot_info.domain = 1
	REDISPLAY
END

;---------------------------------------------------------------------------------------------------------------------------------------;
; Name: FREQ_ALIGN_AUTO													                ;
; Purpose:   Given two data sets, this fuction will automatically align and add the two data sets in the frequency domain and will put  ;	     the resulting data set in the third window. It will then display it to the third window. The data set is also allowed to   ;
;	     be modified by a scaling factor which is changed by a slider.                                              		;
;            The header files is the exact same as plot_info's, so we simply copy it's elements into the third window's data_file_header;
; Return:  Returns a new data set (the sum of the two input data sets).   Unfortunately, most of the variables were global, so          ;
;	   the data ;set is placed in global variables as well.                                                                         ;
;---------------------------------------------------------------------------------------------------------------------------------------;

PRO FREQ_ALIGN_AUTO, s_factor
	COMMON common_vars
	COMMON common_widgets
	COMMON Draw1_Comm
	
	; Set up drawing for third window
	Window_Flag = 3	
	WSET, Draw3_Id
	print, "FREQ_ALIGN_AUTO"
	
	; Set up the middle data_header file.
	bottom_data_file_header.points = data_file_header.points
	bottom_data_file_header.components = data_file_header.components
	bottom_data_file_header.dwell = data_file_header.dwell
	bottom_data_file_header.frequency = data_file_header.frequency
	bottom_data_file_header.scans= data_file_header.scans
	bottom_data_file_header.acq_type = data_file_header.acq_type
	bottom_data_file_header.increment = data_file_header.increment
	bottom_data_file_header.empty = data_file_header.empty
	bottom_plot_info.data_file = 'N/A'
	bottom_data_file_header.comment1 = data_file_header.comment1
	bottom_data_file_header.comment2 = data_file_header.comment2
	bottom_data_file_header.comment3 = data_file_header.comment3
	bottom_data_file_header.comment4 = data_file_header.comment4
	
	;Define variables ppm and hertz
	bottom_guess_variables[0].name = 'PPM'
	bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
	bottom_guess_variables[1].name = 'HERTZ'
	bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency
	bottom_guess_info.number_variables = 2
	bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
	
	; First window's data is stored in time_data_points, and the third is in bottom_time_data_points.
	; Convert time domain data into freq. domain data, subtract, and convert back to time domain.
	; Then, redisplay data in the second window
	;bottom_plot_info.domain = 1

	; Calculate the shift value
  	first_fft = fix(plot_info.fft_initial/data_file_header.dwell)
  	last_fft = fix(plot_info.fft_final/data_file_header.dwell)-1

	FOR i=plot_info.first_trace, plot_info.last_trace DO BEGIN
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
		freq_point_index = [temp5, temp7]

                ; To shift the x-axis must determine how many points to shift from the current position
		; This value should be assigned to point_shift (below)
	        ; This value is also used to modify the XRANGE specifier of the plot command (below)
		; Must ensure that this works in all windows and in both Hz and PPM mode
			
	        IF (reverse_flag EQ 0) THEN BEGIN
			freq = ((-1*freq_point_index) -  point_shift) * delta_freq		
	        ENDIF ELSE BEGIN
			freq = (freq_point_index -  point_shift) * delta_freq
	        ENDELSE	
	ENDFOR
	
  	first_fft = fix(middle_plot_info.fft_initial/middle_data_file_header.dwell)
  	last_fft = fix(middle_plot_info.fft_final/middle_data_file_header.dwell)-1

	FOR i=middle_plot_info.first_trace, middle_plot_info.last_trace DO BEGIN
		;Switch the data so that the lowest frequency information is at the beginning
	        N_bottom = (last_fft - first_fft)/2+1
      	        N_end = (last_fft - first_fft)

	        temp1 = middle_freq_data_points[i, N_bottom : N_end]
		temp2 = middle_freq_data_points[i, 1: N_bottom]
	        temp1 = REFORM(temp1)
		temp2 = REFORM(temp2)
		actual_middle_freq_data_points = [temp1, temp2]

	        ;Create the frequency axis in units of HZ
        	bandwidth = 1/middle_data_file_header.dwell
  	        delta_freq = bandwidth/ (last_fft - first_fft+1)
		temp3 = FINDGEN((last_fft - first_fft)/2+2)
	        temp4 = REVERSE(temp3)
         	temp5 = temp4 * (-1.0)
		temp6 = FINDGEN((last_fft - first_fft)/2+1)
  		temp7 = temp6[1: (last_fft - first_fft)/2]
		freq_point_index = [temp5, temp7]

                ; To shift the x-axis must determine how many points to shift from the current position
		; This value should be assigned to point_shift (below)
	        ; This value is also used to modify the XRANGE specifier of the plot command (below)
		; Must ensure that this works in all windows and in both Hz and PPM mode
			
	        IF (reverse_flag EQ 0) THEN BEGIN
			freq = ((-1*freq_point_index) -  point_shift) * delta_freq
	        ENDIF ELSE BEGIN
			freq = (freq_point_index -  point_shift) * delta_freq
	        ENDELSE	
	ENDFOR	
	
	; Convert the points to hertz
	bandwidth = double(1 / middle_data_file_header.dwell)
	hzperpt = double(bandwidth / middle_data_file_header.points)

	; Calculate the points for the subset
	first = fix(double(3.9 * data_file_header.frequency / hzperpt))
	second = fix(double(5.2 * data_file_header.frequency / hzperpt))
	
	first_a = fix(double(3.9 * data_file_header.frequency / hzperpt))
	second_a = fix(double(5.2 * data_file_header.frequency / hzperpt))

	print, max(actual_freq_data_points, j)
	print, j
	
	help, first, second, first_a, second_a

	; Select the subset	
	top_subset = REAL_PART(actual_freq_data_points[first:second])
	middle_subset = REAL_PART(actual_middle_freq_data_points[first_a:second_a])
	
	help, actual_freq_data_points, actual_middle_freq_data_points	
	help, top_subset, middle_subset
	
	lag = INDGEN(SIZE(top_subset, /N_ELEMENTS) * 2.0 - 3.0) - (SIZE(top_subset, /N_ELEMENTS) - 2.0)
	
	result = C_CORRELATE(top_subset, middle_subset, lag)

	print, MAX(result, j)
	print, lag[j]
	
	help, result, lag, bandwidth, hzperpt
	
	; Create the array with the multiplication algorithm
	; w = frequency shift, n = point number, t = time interval
	w = DOUBLE (hzperpt * lag[j] * 2)
	n = DINDGEN(N_ELEMENTS(middle_original_data))
	t = DOUBLE (middle_data_file_header.dwell)
	num = DOUBLE (2) * !PI * w * n * t
	
	shifter = dcomplex(cos(num), (-1) * sin(num))
	shifter = SHIFT(shifter, 1)
	
	help, w, n, t, num, shifter

	; Shifted data does not look like original data
	; But the shifting still works - this is a problem with the display
	
	help, bottom_time_data_points
	print, "SCALE FACTOR", s_factor
	bottom_time_data_points[0,*] = original_data + ((middle_original_data*shifter)*s_factor)
	bottom_original_data = REFORM(bottom_time_data_points[0,*])
	bottom_original_data[0] = middle_original_data[0]
	
	AUTO_SCALE
	WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.time_xmin
	WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.time_xmax
	WIDGET_CONTROL, Y_MAX, SET_VALUE = bottom_plot_info.time_ymax
	WIDGET_CONTROL, Y_MIN, SET_VALUE = -1.0 * bottom_plot_info.time_ymin
	WIDGET_CONTROL, INITIAL, SET_VALUE = bottom_plot_info.fft_initial
	bottom_plot_info.fft_final = float(bottom_data_file_header.points/2 * bottom_data_file_header.dwell)
	WIDGET_CONTROL, FINAL, SET_VALUE = bottom_plot_info.fft_final
	
	;Display only the real part of the time domain signal	
	bottom_time_data_points[0,0] = complex(1,0)
	bottom_plot_info.domain = 1
	REDISPLAY
END