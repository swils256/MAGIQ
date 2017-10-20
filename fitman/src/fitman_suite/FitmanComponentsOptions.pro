;=======================================================================================================================================;
; Name:  FitmanComponentsOptions.pro													;
; Purpose:  Contains all procedures and/or functions that are called from the Components part of the FitmanGUI menu.   			;
; Dependancies:  FitmanGui_Sep2000.pro, Display.pro											;
;=======================================================================================================================================;


;======================================================================================================================================;
; Name:  EV_REAL														       ;
; Purpose:  This procedure is called whenever a user presses the Real button under the Component heading.  It allows a user to view the;
;	    real component of the peaks ONLY.                      								       ;
; Parameters:  event - The event which triggered this procedure to be called.							       ;
; Return:  None.  														       ;
;======================================================================================================================================;
PRO EV_REAL, event 
     COMMON common_vars
     COMMON common_widgets
     
     IF (Window_Flag EQ 1) THEN BEGIN							; If Top Draw Window Is Active
      	FOR i = 0, plot_info.traces DO BEGIN
         time_data_points[i,0] = complex(1,0)         
      	ENDFOR
      	DISPLAY_DATA
     ENDIF
     IF (Window_Flag EQ 2) THEN BEGIN							; If Middle Draw Window Is Active
     	FOR i = 0, middle_plot_info.traces DO BEGIN
     		middle_time_data_points[i,0] = complex(1,0)
     	ENDFOR
     	MIDDLE_DISPLAY_DATA  
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN							; If Bottom Draw Window Is Active
     	FOR i = 0, bottom_plot_info.traces DO BEGIN
     		bottom_time_data_points[i,0] = complex(1,0)
     	ENDFOR
     	BOTTOM_DISPLAY_DATA  
     ENDIF

END 

;======================================================================================================================================;
; Name:  EV_IMAG 														       ;
; Purpose:  This procedure is called whenever a user presses the Imaginary button under the Component heading. It allows a user to view;
;           the imaginary componeny of the peaks ONLY.										       ;
; Parameters:  event - The event which triggered this procedure to be called.                          				       ;
; Return:  None.        													       ;
;======================================================================================================================================;
PRO EV_IMAG, event 
     COMMON common_vars
     COMMON common_widgets

      IF (Window_Flag EQ 1) THEN BEGIN							; If Top Draw Window Is Active
      	FOR i = 0, plot_info.traces DO BEGIN
          	time_data_points[i,0] = complex(0,1)    
      	ENDFOR           
     	DISPLAY_DATA  
      ENDIF
      IF (Window_Flag EQ 2) THEN BEGIN							; If Middle Draw Window Is Active
      	FOR i = 0, middle_plot_info.traces DO BEGIN
          	middle_time_data_points[i,0] = complex(0,1)    
      	ENDFOR           
	MIDDLE_DISPLAY_DATA  
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN							; If Bottom Draw Window Is Active
      	FOR i = 0, bottom_plot_info.traces DO BEGIN
          	bottom_time_data_points[i,0] = complex(0,1)    
      	ENDFOR           
	BOTTOM_DISPLAY_DATA  
     ENDIF

END 

;======================================================================================================================================;
; Name: EV_BOTH															       ;
; Purpose:  This procedure is called whenever a user presses the "Real and Imaginary" button under the Component menu. It allows a user;
;           to view the real and imaginary graphs together on the same plot. 					   		       ;
; Parameters:  event - The event which triggered this procedure to be called. 							       ;
; Return: None.															       ;
;======================================================================================================================================;
PRO EV_BOTH, event 
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN							; If Top Draw Window Is Active
      	FOR i = 0, plot_info.traces DO BEGIN
         	time_data_points[i,0] = complex(1,1)
        ENDFOR           
      	DISPLAY_DATA  
     ENDIF
     
     IF (Window_Flag EQ 2) THEN BEGIN							; If Middle Draw Window Is Active
     	FOR i = 0, middle_plot_info.traces DO BEGIN
     		middle_time_data_points[i,0] = complex(1,1)
     	ENDFOR
     	MIDDLE_DISPLAY_DATA
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN							; If Bottom Draw Window Is Active
     	FOR i = 0, bottom_plot_info.traces DO BEGIN
     		bottom_time_data_points[i,0] = complex(1,1)
     	ENDFOR
     	BOTTOM_DISPLAY_DATA
     ENDIF

END 

; (Note from JP) I realize I could rewrite this section to have a general method
; that sets the *time_data_points[i,0] .. but blah.  

PRO EV_showMag, event 
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN							; If Top Draw Window Is Active
      	FOR i = 0, plot_info.traces DO BEGIN
         	time_data_points[i,0] = complex(2,2)
        ENDFOR           
      	DISPLAY_DATA  
     ENDIF
     
     IF (Window_Flag EQ 2) THEN BEGIN							; If Middle Draw Window Is Active
     	FOR i = 0, middle_plot_info.traces DO BEGIN
     		middle_time_data_points[i,0] = complex(2,2)
     	ENDFOR
     	MIDDLE_DISPLAY_DATA
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN							; If Bottom Draw Window Is Active
     	FOR i = 0, bottom_plot_info.traces DO BEGIN
     		bottom_time_data_points[i,0] = complex(2,2)
     	ENDFOR
     	BOTTOM_DISPLAY_DATA
     ENDIF

END 

PRO EV_showPhase, event 
     COMMON common_vars
     COMMON common_widgets

     IF (Window_Flag EQ 1) THEN BEGIN							; If Top Draw Window Is Active
      	FOR i = 0, plot_info.traces DO BEGIN
         	time_data_points[i,0] = complex(3,3)
        ENDFOR           
      	DISPLAY_DATA  
     ENDIF
     
     IF (Window_Flag EQ 2) THEN BEGIN							; If Middle Draw Window Is Active
     	FOR i = 0, middle_plot_info.traces DO BEGIN
     		middle_time_data_points[i,0] = complex(3,3)
     	ENDFOR
     	MIDDLE_DISPLAY_DATA
     ENDIF
     IF (Window_Flag EQ 3) THEN BEGIN							; If Bottom Draw Window Is Active
     	FOR i = 0, bottom_plot_info.traces DO BEGIN
     		bottom_time_data_points[i,0] = complex(3,3)
     	ENDFOR
     	BOTTOM_DISPLAY_DATA
     ENDIF

END 
