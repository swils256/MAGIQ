;=======================================================================================================;
; Name:  FitmanViewOptions.pro                       ;
; Purpose:  Contains all procedures and functions that are located under the View menu in the FitmanGUI ;
;       program.                           ;
; Dependancies:  FitmanGui_Sep2000.pro, Display.pro                  ;
;=======================================================================================================;

;=======================================================================================================;
; Name: EV_VIEW_NORMAL                           ;
; Purpose:  To change the color scheme on the graphs.   Each selection will only affect the active  ;
;       window.  This procudure will display the information in color.             ;
; Parameters:  event - The event which caused this procedure to be called.          ;
; Return: None.                              ;
;=======================================================================================================;
PRO EV_VIEW_NORMAL, event
        view_normal,/TOP,/MIDDLE,/BOTTOM
END

pro view_normal,TOP=one,MIDDLE=two,BOTTOM=three
        COMMON common_vars
        COMMON common_widgets
        COMMON Draw1_comm

    current_flag = Window_Flag

    ; Set the view flags to color.
    if(keyword_set(one)) then plot_info.view = 0
    if(keyword_set(two)) then middle_plot_info.view = 0
    if(keyword_set(three)) then bottom_plot_info.view = 0

    ; Redraw windows
    Window_Flag =1
    WSET, Draw1_id
        DISPLAY_DATA
    Window_Flag =2
    WSET, Draw2_Id
    MIDDLE_DISPLAY_DATA
    Window_Flag=3
    WSET, Draw3_Id
    BOTTOM_DISPLAY_DATA

    IF (current_Flag EQ 1) THEN WSET, Draw1_Id
    IF (current_Flag EQ 2) THEN WSET, Draw2_Id

    Window_Flag =  current_flag
end

;=======================================================================================================;
; Name:  EV_VIEW_PAPER                             ;
; Purpose:  To change the color scheme of the graphs.  This procedure set the active window to "paper"  ;
;           setting, or black and white.                      ;
; Parameters:  event - the event which causes this procedure to be called.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_VIEW_PAPER, event
        COMMON common_vars
        COMMON common_widgets
    COMMON Draw1_comm

    ; Test if any graphs exist to change color.
    IF (plot_info.data_file EQ '' AND middle_plot_info.data_file EQ '' AND $
    bottom_plot_info.data_file EQ '') THEN BEGIN
       ;ERROR_MESSAGE, "No graphs to change color of.   Please load a graph first."
         err_result = DIALOG_MESSAGE('No graphs to change color of.   Please load a graph first.', $
                               Title = 'ERROR', /ERROR)
       RETURN
    ENDIF
    current_flag = Window_Flag

    ; Set the flag to indicate black & white.
    plot_info.view = 1
    middle_plot_info.view = 1
    bottom_plot_info.view = 1

    ; Redraw windows.
    Window_Flag=1
    WSET, Draw1_id
        DISPLAY_DATA
    Window_Flag =2
    WSET, Draw2_Id
    MIDDLE_DISPLAY_DATA
    Window_Flag=3
    WSET, Draw3_Id
    BOTTOM_DISPLAY_DATA

    IF (current_Flag EQ 1) THEN WSET, Draw1_Id
    IF (current_Flag EQ 2) THEN WSET, Draw2_Id

    Window_Flag =  current_flag
END

PRO EV_VIEW_PAPER_NORMAL,event
        COMMON common_vars
        COMMON common_widgets
    COMMON Draw1_comm

    ; Test if any graphs exist to change color.
    IF (plot_info.data_file EQ '' AND middle_plot_info.data_file EQ '' AND $
    bottom_plot_info.data_file EQ '') THEN BEGIN
       ;ERROR_MESSAGE, "No graphs to change color of.   Please load a graph first."
        err_result = DIALOG_MESSAGE('No graphs to change color of.   Please load a graph first.', $
                               Title = 'ERROR', /ERROR)
       RETURN
    ENDIF
    current_flag = Window_Flag

    ; Set the flag to indicate black & white.
    plot_info.view = 2
    middle_plot_info.view = 2
    bottom_plot_info.view = 2

    ; Redraw windows.
    Window_Flag=1
    WSET, Draw1_id
        DISPLAY_DATA
    Window_Flag =2
    WSET, Draw2_Id
    MIDDLE_DISPLAY_DATA
    Window_Flag=3
    WSET, Draw3_Id
    BOTTOM_DISPLAY_DATA

    IF (current_Flag EQ 1) THEN WSET, Draw1_Id
    IF (current_Flag EQ 2) THEN WSET, Draw2_Id

    Window_Flag =  current_flag

end
;=======================================================================================================;
; Name:  EV_CLEAR                          ;
; Purpose:  To allow a user to clear data from the screen.  This is the recommended way of clearing the ;
;           data because it wipes out all the data, and clears all structues back to default for its    ;
;           selected window.                         ;
; Parameters:  Event - The event which caused this procedure to be called.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_CLEAR, event
    COMMON common_vars
        ;Clear_Flag = 1

    IF (Window_Flag EQ 1) THEN BEGIN
                IF (plot_info.data_file EQ '') THEN RETURN

       Clear_Flag = 1 ; only set the clear_flag to true if
                ; the window needs to be cleared
                view_normal,/TOP

       IF (plot_info.data_file EQ '') THEN RETURN
       ; Draws everything black.
       plot_info.axis_colour = 0
        plot_color[0].creal = 0
        plot_color[0].cimag = 0
        plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
        plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
        plot_color[2].creal = 0  ;Plot the residual  in BLUE
        plot_color[2].cimag = 0  ;Plot the residual  in BLUE
        plot_color[1].thick = 1.25
       DISPLAY_DATA

       ; Reset variables to default values.
       point_index[0:*] = 0
     linked_param[0:*] = 0
     color_struct = {c_struct, creal:15, cimag:15, offset:0.0, thick:1.0}
     original_data[0:*] = 0
     time_data_points[*,*] = COMPLEX(0,0)
     plot_color = REPLICATE(color_struct, 999)
     comp_time_data_points[0:*,0:*] = 0
     freq_data_points[*,*] = COMPLEX(0,0)
     guess_variables_structure = {gvar_struct, name:'', gvalue:0.0}
     guess_variables = REPLICATE(guess_variables_structure, 200)
     const_variables_structure = {cvar_struct, name:'', gvalue:0.0, first_occur:0}
      const_variables = REPLICATE(const_variables_structure, 100)
     paramit_struct = {param_struct, pvalue:0.0, modifier:0.0, linked:0, var_base:0.0, $
          const_name:''}
     peak = REPLICATE(paramit_struct, 7, 999)
       plot_info =EmptyPlotInfo
       data_file_header = EmptyDataFileHeader
       guess_info = EmptyGuessInfo
       const_info = EmptyConstInfo
       Clear_Flag = 0
    ENDIF

    IF (Window_Flag EQ 2) THEN BEGIN
       IF (middle_plot_info.data_file EQ '') THEN RETURN
                componentButton,/REMOVE

       Clear_Flag = 1 ; only set clear_flag to true if
                ; the window needs to be cleared
       view_normal,/MIDDLE

       ; Draws everything black.

       middle_plot_info.axis_colour = 0
        middle_plot_color[0].creal = 0
        middle_plot_color[0].cimag = 0
        middle_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
        middle_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
        middle_plot_color[2].creal = 0  ;Plot the residual  in BLUE
        middle_plot_color[2].cimag = 0  ;Plot the residual  in BLUE
        middle_plot_color[1].thick = 1.25
       middle_plot_color[0:*].creal=0
       middle_plot_color[0:*].cimag=0
       middle_plot_info.first_trace = 0
         middle_plot_info.last_trace = 0
       MIDDLE_DISPLAY_DATA

       ; Reset variables to default values.
     middle_point_index[0:*] = 0
     middle_linked_param[0:*] = 0
     color_struct = {c_struct, creal:15, cimag:15, offset:0.0, thick:1.0}
     middle_original_data[0:*] = 0
     middle_time_data_points[*,*] = COMPLEX(0,0)
     middle_plot_color = REPLICATE(color_struct, 999)
     middle_comp_time_data_points[0:*,0:*] = 0
     middle_freq_data_points[*,*] = COMPLEX(0,0)
     guess_variables_structure = {gvar_struct, name:'', gvalue:0.0}
     middle_guess_variables = REPLICATE(guess_variables_structure, 200)
     const_variables_structure = {cvar_struct, name:'', gvalue:0.0, first_occur:0}
      middle_const_variables = REPLICATE(const_variables_structure, 100)
     paramit_struct = {param_struct, pvalue:0.0, modifier:0.0, linked:0, var_base:0.0, $
          const_name:''}
     middle_peak = REPLICATE(paramit_struct, 7, 999)
       middle_plot_info =EmptyPlotInfo
       middle_data_file_header = EmptyDataFileHeader
       middle_guess_info = EmptyGuessInfo
       middle_const_info = EmptyConstInfo
       Clear_Flag = 0

       WIDGET_CONTROL,reload_guess_button,SENSITIVE=0
                WIDGET_CONTROL,reload_const_button,SENSITIVE=0

    ENDIF
    IF (Window_Flag EQ 3) THEN BEGIN
                IF (bottom_plot_info.data_file EQ '') THEN RETURN

       Clear_Flag = 1 ; only set this to true if there is
                ; data on the window
                view_normal,/BOTTOM

       ; Draws everything black.
       bottom_plot_info.axis_colour = 0
        bottom_plot_color[0].creal = 0
        bottom_plot_color[0].cimag = 0
        bottom_plot_color[1].creal = 0  ;Plot the reconstructed curves in RED
        bottom_plot_color[1].cimag = 0  ;Plot the reconstructed curves in RED
        bottom_plot_color[2].creal = 0  ;Plot the residual  in BLUE
        bottom_plot_color[2].cimag = 0  ;Plot the residual  in BLUE
        bottom_plot_color[1].thick = 1.25

       ; Reset variables to default values.
       bottom_DISPLAY_DATA
       maxpoints = 18000
     bottom_point_index[0:*] = 0
     bottom_linked_param[0:*] = 0
     color_struct = {c_struct, creal:15, cimag:15, offset:0.0, thick:1.0}
     bottom_original_data[0:*] = 0
     bottom_time_data_points[*,*] = COMPLEX(0,0)
     plot_color = REPLICATE(color_struct, 999)
     bottom_comp_time_data_points[0:*,0:*] = 0
     bottom_freq_data_points[*,*] = COMPLEX(0,0)
     guess_variables_structure = {gvar_struct, name:'', gvalue:0.0}
     bottom_guess_variables = REPLICATE(guess_variables_structure, 200)
     const_variables_structure = {cvar_struct, name:'', gvalue:0.0, first_occur:0}
      bottom_const_variables = REPLICATE(const_variables_structure, 100)
     paramit_struct = {param_struct, pvalue:0.0, modifier:0.0, linked:0, var_base:0.0, const_name:''}
     bottom_peak = REPLICATE(paramit_struct, 7, 999)
       bottom_plot_info =EmptyPlotInfo
       bottom_data_file_header = EmptyDataFileHeader
       bottom_guess_info = EmptyGuessInfo
       bottom_const_info = EmptyConstInfo
                Clear_Flag =0
    ENDIF

    setComponents,/DISABLE
END

PRO EV_CLEAR_ALL,event
   COMMON common_vars
   curr_flag = Window_Flag

   Window_Flag = 1
   EV_CLEAR,event
   Window_Flag = 2
   EV_CLEAR,event
   Window_Flag = 3
   EV_CLEAR,event

   Window_Flag = curr_flag
end

PRO EV_OFFSET_RESET,event
   COMMON common_vars
   COMMON common_widgets
   COMMON Draw1_comm

    ; Test if any graphs exist to change color.
   IF (plot_info.data_file EQ '' AND middle_plot_info.data_file EQ '' AND $
    bottom_plot_info.data_file EQ '') THEN BEGIN
    ;ERROR_MESSAGE, "No graphs to reset.   Please load a graph first."
     err_result = DIALOG_MESSAGE('No graphs to reset.   Please load a graph first.', $
                               Title = 'ERROR', /ERROR)
    RETURN
   ENDIF

   point_shift = 0;
   middle_point_shift = 0;
   bottom_point_shift = 0;

   current_flag = Window_Flag

    ; Redraw windows.
   Window_Flag=1
   WSET, Draw1_id
   DISPLAY_DATA
   Window_Flag =2
   WSET, Draw2_Id
   MIDDLE_DISPLAY_DATA
   Window_Flag=3
   WSET, Draw3_Id
   BOTTOM_DISPLAY_DATA

   IF (current_Flag EQ 1) THEN WSET, Draw1_Id
   IF (current_Flag EQ 2) THEN WSET, Draw2_Id

   Window_Flag =  current_flag

end

PRO EV_OFFSET, event
    COMMON common_vars
        COMMON draw1_comm

    ; Test for non-existent data...
    IF ((Window_Flag EQ 1 AND plot_info.data_file EQ '') OR $
        (Window_Flag EQ 2 AND middle_plot_info.data_file EQ '') OR $
        (Window_Flag EQ 3 AND bottom_plot_info.data_file EQ '')) THEN BEGIN

       ;ERROR_MESSAGE, "Please load a data set in the window."
       err_result = DIALOG_MESSAGE('Please load a data set in the window.', $
                               Title = 'ERROR', /ERROR)
       RETURN
    ENDIF


    IF (Window_Flag EQ 1 AND plot_info.domain EQ 0) THEN plot_info.domain = 1
    IF (Window_Flag EQ 2 AND middle_plot_info.domain EQ 0) THEN middle_plot_info.domain = 1
    IF (Window_Flag EQ 3 AND bottom_plot_info.domain EQ 0) THEN bottom_plot_info.domain = 1

    ; Change Domains if not in the right one.
    IF (Window_Flag EQ 1 AND plot_info.domain EQ 0) THEN plot_info.domain = 1
    IF (Window_Flag EQ 2 AND middle_plot_info.domain EQ 0) THEN middle_plot_info =  1
    IF (Window_Flag EQ 3 AND bottom_plot_info.domain EQ 0) THEN bottom_plot_info =  1

    offsetBase = WIDGET_BASE(ROW=3, MAP=1, TITLE='Offset', TLB_FRAME_ATTR= 8)
    drawArea = WIDGET_DRAW(offsetBase, RETAIN=1, UVALUE='S_DRAW', XSIZE=820, YSIZE=300, $
                /BUTTON_EVENTS, EVENT_PRO='OFFSET_CLICK')
    optionsBase = WIDGET_BASE(offsetBase, COL=2, /BASE_ALIGN_RIGHT)
    changesBase = WIDGET_BASE(optionsBase, ROW=2, /FRAME)
    newOffsetLabel = CW_FIELD(changesBase, TITLE='New  value for selected area:', $
           /FLOATING)
    InvertButton = CW_BGROUP(changesBase,'Invert', /NONEXCLUSIVE)
    okBase = WIDGET_BASE(optionsBase, ROW=2, /BASE_ALIGN_RIGHT)
    okButton = WIDGET_BUTTON(okBase, Value = 'Ok', EVENT_PRO='EV_OOK')
    cancelButton = WIDGET_BUTTON(OkBase, VALUE = 'Cancel', EVENT_PRO='EV_OCANCEL')

    state = { InvertButton:InvertButton, newOffsetLabel:newOffsetLabel, newOffset:0.0 }
    pstate = PTR_NEW(state,/NO_COPY)
    WIDGET_CONTROL, offsetBase, SET_UVALUE=pstate


    WIDGET_CONTROL, offsetBase, /REALIZE
    WIDGET_CONTROL, drawArea, get_value= tempdraw
    WSET, tempdraw
    noResize = 1
    REDISPLAY
    XMANAGER, "Offset",offsetBase
    noResize = 0
END

PRO OFFSET_CLICK, event

    WIDGET_CONTROL, event.top, GET_UVALUE=pstate
    IF (event.press EQ 1) THEN BEGIN
       ; Convert the coordinates from device to data
       datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
       (*pstate).newOffset= STRTRIM(datac[0],2)
    ENDIF
END

PRO EV_OCANCEL, event
    COMMON draw1_comm
    COMMON common_vars

    IF (Window_Flag EQ 1) THEN WSET, draw1_id
    IF (Window_Flag EQ 2) THEN WSET, draw2_id
    IF (Window_Flag EQ 3) THEN WSET, draw3_id
    WIDGET_CONTROL, event.top, /DESTROY


END

function getDeltaPointShift,prev_shift,new_shift
  ds = 0
  if(prev_shift ge 0 AND new_shift ge 0) then begin
         ds = new_shift-prev_shift
         ds = -ds
         print,"+ve"
   endif else if(prev_shift lt 0 AND new_shift lt 0) then begin
         ds = abs(new_shift)-abs(prev_shift)
         print,"-ve"
   endif else if((prev_shift ge 0 AND new_shift lt 0) OR $
                 (prev_shift lt 0 AND new_shift ge 0)) then begin
         ds = abs(new_shift) + abs(prev_shift)
         print, ds
         if(abs(prev_shift) gt abs(new_shift)) then ds = -ds
         print,ds
         print,"both"
   endif
   return, ds
end

PRO EV_OOK, event
    COMMON common_vars
    COMMON draw1_comm
        COMMON common_widgets

    WIDGET_CONTROL, event.top, GET_UVALUE=pstate
    WIDGET_CONTROL, (*pstate).InvertButton, GET_VALUE=invert

    IF (Window_Flag EQ 1) THEN BEGIN

       num_of_points = data_file_header.points/2
       ; Now set the new offset by calculating the starting position of the click

       IF (plot_info.xaxis EQ 0) THEN unit_per_pt = (1/data_file_header.dwell)/num_of_points
          IF (plot_info.xaxis EQ 1) THEN unit_per_pt = ((1/data_file_header.dwell)/data_file_header.frequency)/num_of_points

       pt = FIX((*pstate).newOffset/unit_per_pt)

       ;We also need to have the value they want that point to be, which is taken from
       ;the label.
       WIDGET_CONTROL, (*pstate).newOffsetLabel, GET_VALUE=value_pt
       value_pt=FIX(value_pt/unit_per_pt)
       cur_value_pt=0
                value_pt = value_pt - cur_value_pt
                last_shift = point_shift
       point_shift = (pt - value_pt) + point_shift
       cur_value_pt = point_shift

                mu = 1
                if(plot_info.xaxis EQ 1)then mu=1/data_file_header.frequency

                if(plot_info.isZoomed) then begin
                   ds = getDeltaPointShift(last_shift,point_shift)

          plot_info.freq_xmin = plot_info.x1+(ds*mu)
          plot_info.freq_xmax = plot_info.x2+(ds*mu)
               plot_info.x1 = plot_info.x1+(ds*mu)
                   plot_info.x2 = plot_info.x2+(ds*mu)

               WIDGET_CONTROL, X_MIN, SET_VALUE = plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE = plot_info.x2
                endif

    ENDIF
    IF (Window_Flag EQ 2) THEN BEGIN

       num_of_points = middle_data_file_header.points/2
       ; Now set the new offset by calculating the starting position of the click

       IF (middle_plot_info.xaxis EQ 0) THEN unit_per_pt = (1/middle_data_file_header.dwell)/num_of_points
          IF (middle_plot_info.xaxis EQ 1) THEN unit_per_pt = ((1/middle_data_file_header.dwell)/middle_data_file_header.frequency)/num_of_points

       pt = FIX((*pstate).newOffset/unit_per_pt)

       ;We also need to have the value they want that point to be, which is taken from
       ;the label.
       WIDGET_CONTROL, (*pstate).newOffsetLabel, GET_VALUE=value_pt
       value_pt=FIX(value_pt/unit_per_pt)

       middle_cur_value_pt=0
       value_pt = value_pt - middle_cur_value_pt
       last_shift = middle_point_shift

                middle_point_shift = (pt - value_pt) + middle_point_shift
       middle_cur_value_pt = middle_point_shift

                mu = 1
                if(middle_plot_info.xaxis EQ 1)then mu=1/middle_data_file_header.frequency

                if(middle_plot_info.isZoomed) then begin
                   ds = getDeltaPointShift(last_shift,middle_point_shift)

          middle_plot_info.freq_xmin = middle_plot_info.x1+(ds*mu)
          middle_plot_info.freq_xmax = middle_plot_info.x2+(ds*mu)
               middle_plot_info.x1 = middle_plot_info.x1+(ds*mu)
                   middle_plot_info.x2 = middle_plot_info.x2+(ds*mu)

               WIDGET_CONTROL, X_MIN, SET_VALUE = middle_plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE = middle_plot_info.x2
                endif

    ENDIF
    IF (Window_Flag EQ 3) THEN BEGIN

     num_of_points = bottom_data_file_header.points/2
       ; Now set the new offset by calculating the starting position of the click

       IF (bottom_plot_info.xaxis EQ 0) THEN unit_per_pt = (1/bottom_data_file_header.dwell)/num_of_points
          IF (bottom_plot_info.xaxis EQ 1) THEN unit_per_pt = ((1/bottom_data_file_header.dwell)/bottom_data_file_header.frequency)/num_of_points

       pt = FIX((*pstate).newOffset/unit_per_pt)

       ;We also need to have the value they want that point to be, which is taken from
       ;the label.
       WIDGET_CONTROL, (*pstate).newOffsetLabel, GET_VALUE=value_pt
       value_pt=FIX(value_pt/unit_per_pt)
       bottom_cur_value_pt=0
       value_pt = value_pt - bottom_cur_value_pt
       last_shift = bottom_point_shift
                bottom_point_shift = (pt - value_pt) + bottom_point_shift
       bottom_cur_value_pt = bottom_point_shift

                mu = 1
                if(bottom_plot_info.xaxis EQ 1)then mu=1/bottom_data_file_header.frequency

                if(bottom_plot_info.isZoomed) then begin
                   ds = getDeltaPointShift(last_shift,bottom_point_shift)

          bottom_plot_info.freq_xmin = bottom_plot_info.x1+(ds*mu)
          bottom_plot_info.freq_xmax = bottom_plot_info.x2+(ds*mu)
               bottom_plot_info.x1 = bottom_plot_info.x1+(ds*mu)
                   bottom_plot_info.x2 = bottom_plot_info.x2+(ds*mu)

               WIDGET_CONTROL, X_MIN, SET_VALUE = bottom_plot_info.x1
               WIDGET_CONTROL, X_MAX, SET_VALUE = bottom_plot_info.x2
                endif

    ENDIF

    IF (invert) THEN BEGIN
       IF((plot_info.domain EQ 1) AND (Window_Flag EQ 1)) THEN BEGIN

         IF (reverse_flag) THEN BEGIN
          reverse_flag =0
         ENDIF ELSE BEGIN
          reverse_flag = 1
         ENDELSE
       ENDIF
       IF((middle_plot_info.domain EQ 1) AND (Window_Flag EQ 2)) THEN BEGIN

         IF (reverse_flag2) THEN BEGIN
          reverse_flag2 =0
         ENDIF ELSE BEGIN
          reverse_flag2 = 1
         ENDELSE
       ENDIF
       IF((bottom_plot_info.domain EQ 1) AND (Window_Flag EQ 3)) THEN BEGIN

         IF (reverse_flag3) THEN BEGIN
          reverse_flag3 =0
         ENDIF ELSE BEGIN
          reverse_flag3 = 1
         ENDELSE
       ENDIF


    ENDIF
    IF (Window_Flag EQ 1) THEN WSET, draw1_id
    IF (Window_Flag EQ 2) THEN WSET, draw2_id
    IF (Window_Flag EQ 3) THEN WSET, draw3_id

    WIDGET_CONTROL, event.top, /destroy
    REDISPLAY
END

PRO offset_Event, event

END

;===========================================================================================;
; component selector code starts here
; Date: 04/26/2002 Author: John-Paul Lobos                                                   ;
;===========================================================================================;

;===========================================================================================;
;  Name:  GET_METABOLITE_VALUES (function)                                                  ;
;  Purpose:  To allow the retrieval of metabolite information from the constraints file.    ;
;            This function only gets those values from the middle_peak array that have a    ;
;            valid metabolite name (i.e. const_name).  This was initially written for       ;
;            FitmanSimulationOptions.pro, but was needed in order to dynamically generate   ;
;            the names of each metabolite beside each checkbox.                             ;
;  By:  Tim Orr, Co-Op Student                                                              ;
;  Date:  November 12, 2002 (but this function was created in September sometime)           ;
;  Parameters:  None                                                                        ;
;  Return:  metabolite_array - an array containing the metabolite information (based on     ;
;                              the structure defined in temp_structure.                     ;
;===========================================================================================;
FUNCTION GET_METABOLITE_VALUES
    COMMON common_vars

    ; replicating the same structure as param_struct
    temp_structure = {param_struct, pvalue:0.0, modifier:0.0, linked:0, var_base:0.0, $
           const_name:''}

    ; the array of interest is extracted, and the number of metabolites with valid names
        ; are counted.  A metabolite array is created based on this count, and the necessary
        ; information associated with each metabolite is stored in metabolite_array.
    amplitude_array = middle_peak[3,*]
    amplitude_array = REFORM(amplitude_array)
    metabolite_count = WHERE(amplitude_array.const_name NE '')
    metabolite_count = FIX(metabolite_count)
    metabolite_array = REPLICATE(temp_structure, N_ELEMENTS(metabolite_count))
    FOR I=0, FIX(N_ELEMENTS(metabolite_count))-1 DO BEGIN
       metabolite_array[I] = amplitude_array[metabolite_count[I]]
    ENDFOR

    return, metabolite_array
END

;=============================================================================================;
; Name: EV_CompSelect                                                                         ;
; Purpose: To handle the event when the user selects 'Component Selector' from the view       ;
;          menu.                                                                              ;
; Pre-condtion  : event must have a value                                                     ;
; Post-condition: Sets up and displays the componet selector window                           ;
;                                                                                             ;
; Param: event, the event that called the procedure                                           ;
; Return: None                                                                                ;
;=============================================================================================;

pro EV_CompSelect, event
    COMMON common_vars
    COMMON comp_vars,compLines,dBase,colNum,labels,fields,lines
        compSelect = -1

    ; Test for non-existent data...
    IF ((Window_Flag EQ 2 AND middle_plot_info.data_file EQ '')) THEN BEGIN

       ;ERROR_MESSAGE, "Please load a data set/constraints/guess in the middle window."
       err_result = DIALOG_MESSAGE('Please load a data set/constraints/guess in the middle window.', $
                               Title = 'ERROR', /ERROR)
       RETURN
    ENDIF

    if(middle_plot_info.last_trace lt 3) then begin
       ;ERROR_MESSAGE,'Please Select the Last Option Under Display'
       err_result = DIALOG_MESSAGE('Please select the last option under Display.', $
                               Title = 'ERROR', /ERROR)
       return
    endif

    IF (Window_Flag EQ 2 AND middle_plot_info.domain EQ 0) THEN middle_plot_info =  1

    ; Set up the GUI for the window
    compBase = WIDGET_BASE(ROW=3, MAP=1, TITLE='Component Select', TLB_FRAME_ATTR= 8)
    dBase = widget_base(compBase,COL =2,/FRAME)
    drawArea = WIDGET_DRAW(dBase, RETAIN=1, UVALUE='S_DRAW', XSIZE=750, YSIZE=370, $
                /BUTTON_EVENTS, EVENT_PRO='compSelect_Click')
    tBase = widget_base(compBase,COLUMN=3)

    ; getting all the metabolite information - Tim Orr, Nov. 12, 2002
    metabolites = GET_METABOLITE_VALUES()
    lines = STRARR(n_elements(metabolites))
    labels = STRARR(n_elements(metabolites))
    fields = INTARR(n_elements(labels))

    for i = 0, n_elements(labels)-1 do begin
       labels[i] = metabolites[i].const_name ; extracting the name of each metabolite and storing
                                        ; it in the labels array
    endfor

    colNum = (n_elements(labels)/8.5)

    selBase = widget_base(tBase,/EXCLUSIVE,/ROW,/FRAME)
    selButton = widget_button(selBase,VALUE='Select Component(s)',UVALUE='sel',EVENT_PRO='EV_SEL')
    deselButton = widget_button(selBase,VALUE='De-Select Component(s)',UVALUE='desel',EVENT_PRO='EV_SEL')
    allButton = WIDGET_BUTTON(tBase,Value='Select All Components',UVALUE='all',EVENT_PRO='compSelect_ALL')
    b = widget_button(tBase,VALUE='Change Component Names',EVENT_PRO="EV_CHANGE_COMP_DIALOG")

    okBase = WIDGET_BASE(compBase, COLUMN=3, /BASE_ALIGN_CENTER)
    okButton = WIDGET_BUTTON(okBase, Value = 'Ok',UVALUE='one',EVENT_PRO='compSelect_OK')
        printButton = WIDGET_BUTTON(okBase,Value='Print and Ok',EVENT_PRO='printComp')
    cancelButton = WIDGET_BUTTON(OkBase, VALUE = 'Cancel', EVENT_PRO='EV_OCANCEL')

        list = obj_new('List')

    ; set up state vars
    state = {lineNum:-1L,isSel:1,list:list,isAll:0}
    pstate = PTR_NEW(state,/NO_COPY)
    WIDGET_CONTROL, compBase, SET_UVALUE=pstate

    ; display the dialog
    WIDGET_CONTROL, compBase, /REALIZE
    WIDGET_CONTROL, drawArea, get_value= tempdraw
    WSET, tempdraw

    !P.MULTI = [0,0,0]

    trace = 0

        AUTO_SCALE

        ; plot the component graph on the draw area

    for i = 3,middle_plot_info.last_trace do begin
       display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
                    middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,'Frequency',$
                    middle_freq,middle_actual_freq_data_points,trace,'',1,1,1,$
                    middle_plot_color[i],0, middle_plot_color[i],middle_plot_info,$
                    middle_time_data_points,reverse_flag2

    endfor

        ;WIDGET_CONTROL,compLines,/DESTROY
        createCheckBoxes

    XMANAGER, "compSelect",compBase
end

pro createCheckBoxes
   COMMON comp_vars

   compLines = CW_BGROUP(dBase,labels,/NONEXCLUSIVE,COL=colNum,/FRAME)

end

pro EV_CHANGE_COMP_DIALOG,event
   COMMON comp_vars

   compBase = WIDGET_BASE(ROW=2, MAP=1, TITLE='Change Component Names', TLB_FRAME_ATTR= 8)
   txtBase = widget_base(compBase,COL=2,/FRAME)

   for i = 0, n_elements(labels)-1 do begin
       fields[i] = widget_text( txtBase,VALUE=labels[i],/EDITABLE)
   endfor

   bBase = widget_base(compBase,COL=2)
   okButton = widget_button(bBase,VALUE='OK',EVENT_PRO='EV_CHANGE_COMP_OK')
   cancelButton = widget_button(bBase,VALUE='Cancel',EVENT_PRO='EV_OCANCEL')

   WIDGET_CONTROL, compBase, /REALIZE
   XMANAGER, "change_comp",compBase
end


pro EV_CHANGE_COMP_OK,event
   COMMON comp_vars

   WIDGET_CONTROL,compLines,/DESTROY

   for i = 0, n_elements(labels)-1 do begin
     WIDGET_CONTROL,fields[i],GET_VALUE=v
     labels[i] = v
   endfor

   createCheckBoxes


   WIDGET_CONTROL, event.top, /DESTROY
end

pro CompSelect_EVENT,event
   COMMON comp_vars
   COMMON common_vars
   WIDGET_CONTROL,compLines,GET_VALUE=val

   WIDGET_CONTROL, event.top, GET_UVALUE=pstate

   size = n_elements(val)

   for i = 0, size-1 do begin
      index = (*pstate).list->findIndex(i+3)
      ;print, index

      if(val[i] eq 1) then begin
         if(index eq (*pstate).list->size()) then begin
           (*pstate).list->add,(i+3)
         endif
      endif else if(val[i] eq 0) then begin
         if(index ne (*pstate).list->size()) then begin
           (*pstate).list->delete,index
         endif
      endif
   endfor

   for i = 3,middle_plot_info.last_trace do begin

      if((*pstate).list->isEmpty() OR (*pstate).list->findIndex(i) eq (*pstate).list->size()) then begin
         pColor = middle_plot_color[i]
      endif else begin
         pColor = middle_plot_color[0]
      endelse

      display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
           middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,'Frequency',$
           middle_freq,middle_actual_freq_data_points,1,'',1,1,1,pColor,1,$
           middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2
   endfor

end

;==================================================================================;
; Name: contains
; Purpose: given an array, and data element of the same type as the array, this
;          function determines if the array contains the data element or contains
;          elements less than that data element.
; Param - fArr: an array of values
; Param - datum: a value of the same type as fArr
;
; Pre-condition: fArr contains at least one element, datum has a value that is the
;                same type as fArr
; Post-condition: returns a 1 if the datum is contained in fArr or is greater than
;                 elements in fArr. returns 0 otherwise
;
; Returns: a integer value of 0 or 1.
; Date: 04/26/2002 Author: John-Paul Lobos
;==================================================================================;

function contains, fArr, datum
    ret = 0
   for i = 0,n_elements(fArr)-1 do begin
     ;print, fArr[i],datum
     if((fArr[i] lt datum) OR (fArr[i] eq datum)) then begin
        ret = 1
        break
     endif

   endfor

   return, ret
end

;==================================================================================
; Name: compSelect_Click
; Purpose: Handles the user's mouse clicks on the Component Selector dialog
; Param - event: the event that called this method
;
; Pre-Condition: the component selector has been created and the data is being
;                collected from the middle window.
; Post-Condition: if the user clicks on the graph, this method determines which
;                 component the user wants to select. It highlights the component
;                 on the graph and stores which component that has been selected in
;                 (*pstate).lineNum
;
; Returns: none
; Date: 04/26/2002 Author: John-Paul Lobos
; Known Bug: the user must select just above the line they want.
;===================================================================================

pro compSelect_Click, event
    COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=pstate
    if (event.press EQ 1) then begin

    ;refresh the draw area
    for i = 3,middle_plot_info.last_trace do begin

      if((*pstate).list->isEmpty() OR (*pstate).list->findIndex(i) eq (*pstate).list->size()) then begin
         pColor = middle_plot_color[i]
      endif else begin
         pColor = middle_plot_color[0]
      endelse

      display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
           middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,'Frequency',$
           middle_freq,middle_actual_freq_data_points,1,'',1,1,1,pColor,1,$
           middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2
    endfor

    datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)

    x = float(strtrim(datac[0],2))
    y = float(strtrim(datac[1],2))

    ; find which line the user selected
    for i = 3,middle_plot_info.last_trace do begin

      realArr = FLOAT(middle_actual_freq_data_points[i,*]) + ABS(middle_plot_color[i].offset)

      if(contains(realArr,y) eq 1) then begin
         ; store the line number and highlight it on the graph

         if((*pstate).isSel eq 1) then begin
         ; the user wants to select the lines

            if((*pstate).list->isEmpty() OR (*pstate).list->findIndex(i) eq (*pstate).list->size()) then begin
            ; the line does not exist in the list so add it

               (*pstate).lineNum = i

               (*pstate).list->add,i
               (*pstate).list->print

                display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
                    middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,'Frequency',$
                    middle_freq,middle_actual_freq_data_points,1,'',1,1,1,$
                    middle_plot_color[0],1, middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2
             endif
         endif else begin
         ; the user wants to de-select lines

             index = (*pstate).list->findIndex(i)

             if(index ne (*pstate).list->size()) then begin
             ; the line exists in the list so delete it

                (*pstate).list->delete,index
                (*pstate).list->print

                display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
                    middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,'Frequency',$
                    middle_freq,middle_actual_freq_data_points,1,'',1,1,1,$
                    middle_plot_color[i],0, middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2
                (*pstate).isAll = 0
             endif
         endelse

         break
      endif

    endfor

    endif
end

;==================================================================================
; Name: compSelect_OK
; Purpose: handles the button events for component selector
; Param - event: the event that called the method
;
; Pre-condition: either allButton or okButton has been pressed in component selector
; Post-condition: if allButton was pressed then compSelect = -1 and all the components
;                 are displayed in the middle window. if okButton was pressed then
;                 the component that has been selected by the user is displayed
;                 in the middle window and compSelect = (*pstate).lineNum
;
; Returns: none
; Date: 04/26/2002 Author: John-Paul Lobos
;==================================================================================

pro compSelect_OK,event
        COMMON common_vars
        COMMON comp_vars
    COMMON draw1_comm

    WIDGET_CONTROL, event.top, GET_UVALUE=pstate
    WIDGET_CONTROL, event.id,GET_UVALUE = uval

    compSelect = obj_new('List')

        if(uval eq 'one' and not((*pstate).isAll)) then begin
           s = (*pstate).list->size()

           for i = 0, s-1 do begin
              m = (*pstate).list->get(i)
              compSelect->add,(*m).data
           endfor
        endif

        if(n_elements(lines) gt n_elements(labels)) then begin
          lineLabels = STRARR(n_elements(lines))

          for i = 0, n_elements(lines)-1 do begin
             if(i lt n_elements(labels)) then begin
                lineLabels[i] = labels[i]
             endif else begin
                lineLabels[i] = lines[i]
             endelse
          endfor
        endif else begin
          lineLabels = labels
        endelse

        openw, unit, 'FitComponent.cfg', /GET_LUN

        for i = 0, n_elements(lineLabels)-1 do begin
           printf,unit,lineLabels[i]
        endfor

        close,unit
        free_lun,unit

        ; set the graphics context back to the middle window
    WSET, draw2_id
        WIDGET_CONTROL, event.top, /destroy
        REDISPLAY
end

pro compSelect_ALL, event
   COMMON common_vars

   WIDGET_CONTROL, event.top, GET_UVALUE=pstate

   size = (*pstate).list->size()

   ; empty the list first
   for i =0, size-1 do begin
     (*pstate).list->delete,0
   endfor

   ; select all
   for i = 3,middle_plot_info.last_trace do begin
          (*pstate).list->add,i

          display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
           middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,'Frequency',$
           middle_freq,middle_actual_freq_data_points,1,'',1,1,1,middle_plot_color[0],1,$
           middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2
   endfor

   (*pstate).isAll = 1
end

;==================================================================================
;
;
;
;
;
;==================================================================================

pro EV_SEL, event
   WIDGET_CONTROL,event.top,GET_UVALUE=pstate
   WIDGET_CONTROL, event.id,GET_UVALUE = uval

   case uval of
      'sel': (*pstate).isSel = 1
      'desel': (*pstate).isSel = 0
   endcase

end

pro printComp,event
  COMMON common_vars
  COMMON draw1_comm

  WIDGET_CONTROL,event.top,GET_UVALUE=pstate
  current = !d.name

  trace = 0

  set_plot, "PS"
  !P.MULTI = [0,0,0]
  device, filename='graphs.ps', /inches, XSIZE=16, SCALE_FACTOR=.5, YSIZE =8.3, FONT_SIZE=20,/LANDSCAPE

  for i = 3,middle_plot_info.last_trace do begin
       if((*pstate).list->isEmpty() OR (*pstate).list->findIndex(i) ne (*pstate).list->size()) then begin

              display_plot,i,middle_plot_info.freq_xmin,middle_plot_info.freq_xmax,$
                       middle_plot_info.freq_ymin,middle_plot_info.freq_ymax,freq_x_axis_title,middle_freq,$
                       middle_actual_freq_data_points,trace,'',1,1,1,$
                       middle_plot_color[i],0,middle_plot_color[i],middle_plot_info,middle_time_data_points,reverse_flag2
       endif
  endfor

  device,/close
  command = defaultPrinter+' graphs.ps'
  spawn, command

  set_plot, current

  compSelect = obj_new('List')

  if(not((*pstate).list->isEmpty())) then begin
    s = (*pstate).list->size()

    for i = 0, s-1 do begin
       m = (*pstate).list->get(i)
       compSelect->add,(*m).data
    endfor

  endif

  WSET, draw2_id
  WIDGET_CONTROL, event.top, /destroy
  REDISPLAY

  ;compSelect_OK,event
end

pro EV_EXTRAP,event
   COMMON draw1_comm

   if(extrapToZero eq 0) then begin
       extrapToZero = 2
   endif else begin
       extrapToZero = 0
   endelse

   GENERATE_FREQUENCY
   MIDDLE_DISPLAY_DATA
end
