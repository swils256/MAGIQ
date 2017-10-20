;=======================================================================================================;
; Name:  FitmanGroupOptions										;
; Purpose:  These functions are used by the FitmanGUI for the options in the "Group" menu heading.      ;
; Dependancies:  FitmanGUI_Sept2000.pro, Display.pro							;
;=======================================================================================================;

;=======================================================================================================;
; Name:  EV_G_NONE											;
; Purpose: This parameter displays the graph with no groupings.   It is called when the user selects    ;
; 	   None under the group menu.									;
; Parameters:  Event - The event which caused this procedure to be called.				;
; Return:  None.											;
;=======================================================================================================;
PRO EV_G_NONE, event
     	COMMON common_vars
     	COMMON common_widgets

     	IF (Window_Flag EQ 1) THEN BEGIN
     		plot_info.fft_recalc = 1
      		plot_info.first_trace = 0        
     		plot_info.grouping = 0  
     		REDISPLAY  
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
     		middle_plot_info.fft_recalc = 1
     		middle_plot_info.first_trace =0
     		middle_plot_info.last_trace = 0
     		REDISPLAY
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
     		bottom_plot_info.fft_recalc = 1
     		bottom_plot_info.first_trace =0
     		bottom_plot_info.last_trace = 0
     		REDISPLAY
     	ENDIF
END

;=======================================================================================================;
; Name:  EV_G_SHIFT 											;
; Purpose:  Groups a dataset's information by shift, then produces a graph to display to the active     ;
;           window.   This procedure is selected when a user picks By Shift under the Groups menu.  	;
; Parameters:  Event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_G_SHIFT, event
     	COMMON common_vars
     	COMMON common_widgets

     	IF (Window_Flag EQ 1) THEN BEGIN
     		plot_info.fft_recalc = 1
     		plot_info.first_trace = 0        
     		plot_info.grouping = 1
     		REDISPLAY  
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
     		middle_plot_info.fft_recalc = 1
     		middle_plot_info.first_trace = 0        
     		middle_plot_info.grouping = 1
     		REDISPLAY  
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
     		bottom_plot_info.fft_recalc = 1
     		bottom_plot_info.first_trace = 0        
     		bottom_plot_info.grouping = 1
     		REDISPLAY  
     	ENDIF

END

;=======================================================================================================;
; Name:  EV_G_EXPON 											;
; Purpose:  Groups a dataset's information by exponental dampening.  It will change the active draw     ;
;           widget.   This procedure is selected when a user picks By Exponential Dampening option. 	;
; Parameters:  Event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_G_EXPON, event
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN
     	plot_info.fft_recalc = 1
     	plot_info.first_trace = 0        
     	plot_info.grouping = 2  
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN
     	middle_plot_info.fft_recalc = 1
     	middle_plot_info.first_trace = 0        
     	middle_plot_info.grouping = 2  
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN
     	bottom_plot_info.fft_recalc = 1
     	bottom_plot_info.first_trace = 0        
     	bottom_plot_info.grouping = 2  
     	REDISPLAY  
     ENDIF     
END

;=======================================================================================================;
; Name:  EV_G_AMP   											;
; Purpose:  Groups a dataset's information by amplitude and redraws the new graph in the active draw    ;
;           widget.   This procedure is selected when a user picks By Amplitude under the Groups menu.	;
; Parameters:  Event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_G_AMP, event
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN				; First Draw Widget is active
     	plot_info.fft_recalc = 1
     	plot_info.first_trace = 0        
     	plot_info.grouping = 3
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN				; Second Draw Widget is active
     	middle_plot_info.fft_recalc = 1
     	middle_plot_info.first_trace = 0        
     	middle_plot_info.grouping = 3
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN				; Third Draw Widget is active
     	bottom_plot_info.fft_recalc = 1
     	bottom_plot_info.first_trace = 0        
     	bottom_plot_info.grouping = 3
     	REDISPLAY  
     ENDIF
END


;=======================================================================================================;
; Name:  EV_G_PHASE 											;
; Purpose:  Groups a dataset's information by phase, then produces a graph to display to the active     ;
;           window.   This procedure is selected when a user picks By Phase under the Groups menu.  	;
; Parameters:  Event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_G_PHASE, event
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN
     	plot_info.fft_recalc = 1
     	plot_info.first_trace = 0        
     	plot_info.grouping = 4
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN
     	middle_plot_info.fft_recalc = 1
     	middle_plot_info.first_trace = 0        
     	middle_plot_info.grouping = 4
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN
     	bottom_plot_info.fft_recalc = 1
     	bottom_plot_info.first_trace = 0        
     	bottom_plot_info.grouping = 4
     	REDISPLAY  
     ENDIF     
     
END

;=======================================================================================================;
; Name:  EV_G_DELAY 											;
; Purpose:  Groups a dataset's information by delay time then draws a graph in the active draw          ;
;           widget.   This procedure is selected when a user picks By Shift under the Groups menu.  	;
; Parameters:  Event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_G_DELAY, event
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN
     	plot_info.fft_recalc = 1
     	plot_info.first_trace = 0        
     	plot_info.grouping = 5
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN
 	middle_plot_info.fft_recalc = 1
     	middle_plot_info.first_trace = 0        
     	middle_plot_info.grouping = 5
     	REDISPLAY  
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN
 	bottom_plot_info.fft_recalc = 1
     	bottom_plot_info.first_trace = 0        
     	bottom_plot_info.grouping = 5
     	REDISPLAY  
     ENDIF     	
     	
END

;=======================================================================================================;
; Name:  EV_G_GAUSS 											;
; Purpose:  Groups a dataset's information by gaussian dampening, then draws the graph in the active    ;
;           window.   This procedure is selected when a user picks By gausian dampening option.     	;
; Parameters:  Event - The event which called this procedure.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_G_GAUSS, event
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN
     	plot_info.fft_recalc = 1
     	plot_info.first_trace = 0        
     	plot_info.grouping = 6  
     	REDISPLAY
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN
     	middle_plot_info.fft_recalc = 1
     	middle_plot_info.first_trace = 0        
     	middle_plot_info.grouping = 6  
     	REDISPLAY
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN
     	bottom_plot_info.fft_recalc = 1
     	bottom_plot_info.first_trace = 0        
     	bottom_plot_info.grouping = 6  
     	REDISPLAY
     ENDIF     
     
END