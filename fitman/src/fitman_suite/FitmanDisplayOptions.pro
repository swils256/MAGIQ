;=======================================================================================================;
; Name: FitmanDisplayOptions.pro									;
; 


;=======================================================================================================;



;=======================================================================================================;
; Name EV_DISPLAY_DATA								       			;
; Purpose:  This procedure is called when the user presses the Acquire Data button under the display   	;
;	    Menu.   It simply resets the first and last traces and redisplays the data.			;
; Parameters:  event - The event that triggered this procedure to be called. 				;
; Return:  None.										       	;
;=======================================================================================================;
PRO EV_DISPLAY_DATA, event
     	COMMON common_vars
     	COMMON common_widgets
     
        componentButton,/REMOVE 
     	IF (Window_Flag EQ 1) THEN BEGIN      
      		plot_info.first_trace = 0      
      		plot_info.last_trace = 0
      		DISPLAY_DATA  
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
      		middle_plot_info.first_trace = 0      
      		middle_plot_info.last_trace = 0
      		MIDDLE_DISPLAY_DATA  
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
      		bottom_plot_info.first_trace = 0      
      		bottom_plot_info.last_trace = 0
      		BOTTOM_DISPLAY_DATA  
     	ENDIF		
END

;=======================================================================================================;
; Name EV_DISPLAY_RECON									       		;
; Purpose:  This is called when a user clicks on the Reconstruction button under the Display menu.   It ;
;           sets the first and last traces to 1 and redraws the graph.					;
; Parameters:  event - The event that triggered this procedure to be called. 				;
; Return:  None.											;
;=======================================================================================================;
PRO EV_DISPLAY_RECON, event
     	COMMON common_vars
     	COMMON common_widgets

        componentButton,/REMOVE  
     	IF (Window_Flag EQ 1) THEN BEGIN
     		plot_info.first_trace = 1      
      		plot_info.last_trace = 1
      		DISPLAY_DATA
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
     		middle_plot_info.first_trace = 1
     		middle_plot_info.last_trace = 1
     		MIDDLE_DISPLAY_DATA
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
     		bottom_plot_info.first_trace = 1
     		bottom_plot_info.last_trace = 1
     		BOTTOM_DISPLAY_DATA
     	ENDIF    
END

;=======================================================================================================;
; Name: EV_DISPLAY_RESIDUAL										;
; Purpose: This is called when a user clicks on the Display Residual button under the Display menu.   It;
;	    sets the first and last traces to 2 and displays the data again.  				;
; Parameters  event - The event that triggered this procedure to be called.				;
; Return:  None.											;
;=======================================================================================================;
PRO EV_DISPLAY_RESIDUAL, event
    	COMMON common_vars
     	COMMON common_widgets

        componentButton,/REMOVE   
     	IF (Window_Flag EQ 1) THEN BEGIN
     		plot_info.first_trace = 2      
     		plot_info.last_trace = 2
     		DISPLAY_DATA  
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
     		middle_plot_info.first_trace = 2
     		middle_plot_info.last_trace = 2
     		MIDDLE_DISPLAY_DATA
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
     		bottom_plot_info.first_trace = 2
     		bottom_plot_info.last_trace = 2
     		BOTTOM_DISPLAY_DATA
     	ENDIF     
END

;=======================================================================================================;
; NAME:  EV_DISPLAY_BOTH										;
; Purpose: This procedure is selected when a user selects the data & reconstruction label from the      ;
;          display menu.   It will draw the data graph and the reconstructed data only.   This is appear;
;          and work for the middle window only.       							;
; Parameters:  Event - the event which triggered this event.						;
; Return:  None.											;
;=======================================================================================================;
PRO EV_DISPLAY_BOTH, event
     	COMMON common_vars
     	COMMON common_widgets
     	
        componentButton,/REMOVE     

     	IF (Window_Flag EQ 1) THEN BEGIN      
      		plot_info.first_trace = 0      
      		plot_info.last_trace = 1
      		DISPLAY_DATA  
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
     		middle_plot_info.first_trace = 0
     		middle_plot_info.last_trace = 1
     		MIDDLE_DISPLAY_DATA
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
     		bottom_plot_info.first_trace = 0
     		bottom_plot_info.last_trace = 1
     		BOTTOM_DISPLAY_DATA
     	ENDIF  
END
													
;=======================================================================================================;
; Name:  EV_DISPLAY_THREE										;
; Purpose:  This procedure is called when the user selects Data & Reconstruction & Residual from the    ;
;           menu bar located under the Display menu.  It will, in the middle window, display the data   ;
;	    line, residual line, and the reconstruction line. 						;
; Parameters:  event - the event which caused this procedure to be called.				;
; Return - None.											;
;=======================================================================================================;
PRO EV_DISPLAY_THREE, event
     	COMMON common_vars
     	COMMON common_widgets
      
        componentButton,/REMOVE 
     	IF (Window_Flag EQ 1) THEN BEGIN
      		plot_info.first_trace = 0      
      		plot_info.last_trace = 2
      		DISPLAY_DATA  
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
     		middle_plot_info.first_trace = 0
     		middle_plot_info.last_trace = 2
     		MIDDLE_DISPLAY_DATA
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
     		bottom_plot_info.first_trace = 0
     		bottom_plot_info.last_trace = 2
     		BOTTOM_DISPLAY_DATA
     	ENDIF
END

;=======================================================================================================;
; Name:  EV_DISPLAY_FOUR										;
; Purpose: This procedure is called when the user selects Data & Reconstruction & Residual & Components ;
;	   from the menu bar located under the Display Menu.  It will draw all four graphs in the middle;
;  	   window.  											;
; Parameters:  Event - The event which caused this event to happen.					;
; Return:  None.											;
;=======================================================================================================;
PRO EV_DISPLAY_FOUR, event
     	COMMON common_vars
     	COMMON common_widgets

     	IF (Window_Flag EQ 1) THEN BEGIN
      		plot_info.fft_recalc = 1
      		plot_info.first_trace = 0      
      		plot_info.last_trace = plot_info.num_linked_groups + 2
      		DISPLAY_DATA  
     	ENDIF
     	IF (Window_Flag EQ 2) THEN BEGIN
      		middle_plot_info.fft_recalc = 1
      		middle_plot_info.first_trace = 0      
      		middle_plot_info.last_trace = middle_plot_info.num_linked_groups + 2
      		MIDDLE_DISPLAY_DATA  
     	ENDIF
     	IF (Window_Flag EQ 3) THEN BEGIN
      		bottom_plot_info.fft_recalc = 1
      		bottom_plot_info.first_trace = 0      
      		bottom_plot_info.last_trace = bottom_plot_info.num_linked_groups + 2
      		BOTTOM_DISPLAY_DATA  
     	ENDIF  
     	componentButton,/ADD         
END
