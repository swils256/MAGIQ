;=======================================================================================================;
; Name:  FitmanUnitsOptions.pro										;
; Purpose:  To provide the procedures needed for the Units menu in the FitmanGUI program.		;
; Dependancies:   FitmanGui_Sept2000.pro, Display.pro							;
;=======================================================================================================;


;=======================================================================================================;
; Name:  EV_X_AXIS_PPM											;
; Purpose:  Switches the axis on the X axis to be shown in hertz, as opposed to PPM.                    ;
; Parameters:  event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_X_AXIS_HZ, event
     COMMON common_vars
     COMMON common_widgets
     IF (Window_Flag EQ 1) THEN BEGIN
     	IF (plot_info.xaxis EQ 1) THEN BEGIN
        	plot_info.fft_recalc = 1
        	plot_info.xaxis = 0
        	plot_info.freq_xmin = plot_info.freq_xmin * data_file_header.frequency
        	plot_info.freq_xmax = plot_info.freq_xmax * data_file_header.frequency
     	ENDIF
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN
     	IF (middle_plot_info.xaxis EQ 1) THEN BEGIN
		middle_plot_info.fft_recalc = 1
        	middle_plot_info.xaxis = 0
        	middle_plot_info.freq_xmin = middle_plot_info.freq_xmin * middle_data_file_header.frequency
        	middle_plot_info.freq_xmax = middle_plot_info.freq_xmax * middle_data_file_header.frequency
     	ENDIF
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN
     	IF (bottom_plot_info.xaxis EQ 1) THEN BEGIN
		bottom_plot_info.fft_recalc = 1
        	bottom_plot_info.xaxis = 0
        	bottom_plot_info.freq_xmin = bottom_plot_info.freq_xmin * bottom_data_file_header.frequency
        	bottom_plot_info.freq_xmax = bottom_plot_info.freq_xmax * bottom_data_file_header.frequency
     	ENDIF
     ENDIF
     		
   REDISPLAY
  
END 


;=======================================================================================================;
; Name:  EV_X_AXIS_PPM											;
; Purpose:  Switches the axis on the X axis to be shown in PPM as opposed to hertz.                     ;
; Parameters:  event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_X_AXIS_PPM, event
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1 ) THEN BEGIN
	PRINT, plot_info.fft_recalc,plot_info.xaxis,plot_info.freq_xmin,plot_info.freq_xmax
     	IF (plot_info.xaxis EQ 0) THEN BEGIN
        	plot_info.fft_recalc = 1
        	plot_info.xaxis = 1
        	plot_info.freq_xmin = plot_info.freq_xmin / data_file_header.frequency
        	plot_info.freq_xmax = plot_info.freq_xmax / data_file_header.frequency
     	ENDIF
    ENDIF
    IF (Window_Flag EQ 2) THEN BEGIN
	
    	IF (middle_plot_info.xaxis EQ 0) THEN BEGIN
        	middle_plot_info.fft_recalc = 1
        	middle_plot_info.xaxis = 1
        	middle_plot_info.freq_xmin = middle_plot_info.freq_xmin / middle_data_file_header.frequency
        	middle_plot_info.freq_xmax = middle_plot_info.freq_xmax / middle_data_file_header.frequency
     	ENDIF
    ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN
    	IF (bottom_plot_info.xaxis EQ 0) THEN BEGIN
        	bottom_plot_info.fft_recalc = 1
        	bottom_plot_info.xaxis = 1
        	bottom_plot_info.freq_xmin = bottom_plot_info.freq_xmin / bottom_data_file_header.frequency
        	bottom_plot_info.freq_xmax = bottom_plot_info.freq_xmax / bottom_data_file_header.frequency
     	ENDIF
    ENDIF	
	
    REDISPLAY
END 
