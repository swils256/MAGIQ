;=======================================================================================================;
; File:  FitmanDomainOptions.pro									;
; Purpose:   Provides all the procedures which are called when a user performs an action on the Domain  ;
;            menu.											;
; Dependancies:  FitmanGui_Sep2000, Display								;
;=======================================================================================================;
		
								
;=======================================================================================================;
; Name:  EV_TIME											;
; Purpose:   To allow a user to view the data set in the time domain.   This occurs when the user       ;
;            selects the Time button under the Domain menu.                                             ;
; Parameters: event - The event which caused this procedure to be called.                               ;
; Return:  None.                                                                                        ;
;=======================================================================================================;
PRO EV_TIME, event 
     	COMMON common_vars
     	COMMON common_widgets

     	IF ((Window_Flag EQ 1) AND (plot_info.data_file NE '')) THEN BEGIN
      		plot_info.domain = 0				; Set domain to 0 to represent time domain
		o_xmax=plot_info.time_xmax 
        	DISPLAY_DATA
     	ENDIF
     	IF ((Window_Flag EQ 2) AND (middle_plot_info.data_file NE '')) THEN BEGIN
     		middle_plot_info.domain = 0			; Set domain to 0 to represent time domain
		o_xmax2=middle_plot_info.time_xmax 
     		MIDDLE_DISPLAY_DATA
     	ENDIF
     	IF ((Window_Flag EQ 3) AND (bottom_plot_info.data_file NE '')) THEN BEGIN
     		bottom_plot_info.domain = 0			; Set domain to 0 to represent time domain
		o_xmax3=bottom_plot_info.time_xmax 
     		BOTTOM_DISPLAY_DATA
     	ENDIF  
     
END 
													
;=======================================================================================================;
; Name: EV_FREQUENCY								       			;
; Purpose:  This procedure is called whenever a user presses the Frequency button under the Domain menu.;
;	    Like, EV_TIME, it affects how the graph will be viewed.   This procedure, however, will set ;
;	    the graph to have FREQUENCY along the X axis, as opposed to time.  	       			;
; Paramters:  event - The event which caused this procedure to be called.         			;
; Return: None.    											;
;=======================================================================================================;
PRO EV_FREQUENCY, event 
     	COMMON common_vars
     	COMMON common_widgets

	; Domain = 1 means the frequency domain
	IF ((Window_Flag EQ 1) AND (plot_info.data_file NE '')) THEN BEGIN
     		plot_info.domain = 1
		o_xmax=plot_info.freq_xmax 
		redisplay
     	ENDIF
     	IF ((Window_Flag EQ 2) AND (middle_plot_info.data_file NE '')) THEN BEGIN
     		middle_plot_info.domain = 1
		o_xmax2=middle_plot_info.freq_xmax 
		redisplay
    	ENDIF
     	IF ((Window_Flag EQ 3) AND (bottom_plot_info.data_file NE '')) THEN BEGIN
     		bottom_plot_info.domain = 1
		o_xmax3=bottom_plot_info.freq_xmax 
     		REDISPLAY
     	ENDIF 
END 
	
