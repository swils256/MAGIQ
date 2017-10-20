PRO MAKEGUESS, event
    COMMON common_vars

    peakLocations = REPLICATE({name:'',phase:0.0,x:0.0,w:0.0,y:0.0, delaytime:0.0, width_gauss:0.0},300)
    peakOperations = REPLICATE({phaseOp:'', phaseVal:0.0, xOp:'',xVal:0.0,yOp:'',yVal:0.0, zOp:'', zVal:0.0,$
              delayOp:'', delayVal:0.0, widthOp:'', widthVal:0.0, xVar:'',yVar:'',zVar:'',$
              phaseVar:'',delayVar:'', widthVar:'' }, 300)
    values = strarr(300)
    PreviousFlag = Window_Flag
    PreviousDomain = middle_plot_info.domain
    clickedOnce = 0
    PreviousUnits = middle_plot_info.xaxis
    variables = REPLICATE({name:'', value:0.0}, 300)


    IF (middle_plot_info.data_file EQ '') THEN BEGIN
       ;ERROR_MESSAGE, 'Load data into middle windown first.'
       err_result = DIALOG_MESSAGE('Load data into middle windown first.', $
             Title = 'ERROR', /ERROR)
       RETURN
    ENDIF
    MakeGuess_Base = WIDGET_BASE(ROW=2, MAP=1, TITLE='Make Guess File', UVALUE='M_GUESS')
    DrawWindow = WIDGET_DRAW(MakeGuess_Base, RETAIN=1, UVALUE='DRAW1', XSIZE=840, YSIZE = 255, /BUTTON_EVENTS, /MOTION_EVENTS, EVENT_PRO = 'MakeGuess_MouseControl')
    BottomBase = WIDGET_BASE(MakeGuess_Base, COL=5, MAP=1)
    FieldBase = WIDGET_BASE(BottomBase,ROW=6, MAP=1, /FRAME)
    PullDownBase = WIDGET_BASE(BottomBase, ROW=3,MAP=1, /FRAME)
    FunctionalityBase = WIDGET_BASE(BottomBase, ROW=2, MAP=1)
    ZoomBase = WIDGET_BASE(FunctionalityBase, COL=2, MAP =1, /FRAME, /EXCLUSIVE)
    DecisionBase = WIDGET_BASE(BottomBase, ROW=3, MAP=1, /BASE_ALIGN_RIGHT)
    xValue = CW_FIELD(FieldBase, TITLE = 'Shift:', VALUE = (peakLocations[0]).x, /FLOATING, /RETURN_EVENTS, /FRAME)
    wValue = CW_FIELD(FieldBase, TITLE = 'Width:', VALUE = 0.0, /FLOATING, /RETURN_EVENTS, /FRAME)
    yValue = CW_FIELD(FieldBase, TITLE = 'Amplitude:', VALUE = (peakLocations[0]).y, /FLOATING, /RETURN_EVENTS, /FRAME)
    phaseValue = CW_FIELD(FieldBase, TITLE='Phase:',VALUE = (peakLocations[0]).phase, /FLOATING, /RETURN_EVENTS, /FRAME)
    DelayValue = CW_FIELD(FieldBase, TITLE='Delay Time:',VALUE = (peakLocations[0]).phase, /FLOATING, /RETURN_EVENTS, /FRAME)
    WidGasValue = CW_FIELD(FieldBase, TITLE='Width_Gauss:',VALUE = (peakLocations[0]).phase, /FLOATING, /RETURN_EVENTS, /FRAME)
    PullDownMenu = WIDGET_DROPLIST(PullDownBase,TITLE='Peak #', UVALUE=values, /DYNAMIC_RESIZE, EVENT_PRO='MAKE_GUESS_PULLDOWN')
    AddItemButton = WIDGET_BUTTON(PullDownBase, VALUE='Add Peak', /FRAME,EVENT_PRO='MAKE_GUESS_ADD_PEAK')
    RemoveItemButton = WIDGET_BUTTON(PullDownBase, VALUE='Remove Peak', /FRAME,EVENT_PRO='MAKE_GUESS_REMOVE_PEAK')
    ZoomOutButton = WIDGET_BUTTON(FunctionalityBase, VALUE='ZoomOut', EVENT_PRO='EV_ZOOM_OUT')
    ZoomOnButton = WIDGET_BUTTON(ZoomBase, VALUE='Zoom On', EVENT_PRO='MAKE_GUESS_ZOOMON')
    ZoomOffButton = WIDGET_BUTTON(ZoomBase, VALUE='Zoom Off', EVENT_PRO='MAKE_GUESS_ZOOMOFF')
    OkButton = WIDGET_BUTTON(DecisionBase, VALUE='Ok', EVENT_PRO='MAKE_GUESS_OK')
    CancelButton = WIDGET_BUTTON(DecisionBase, VALUE='Cancel',EVENT_PRO='MAKE_GUESS_CANCEL')
    LoadButton = WIDGET_BUTTON(DecisionBase, VALUE='Load...', EVENT_PRO='MAKE_GUESS_LOAD')
    WIDGET_CONTROL, DrawWindow, GET_VALUE=Make_Id

    WSET, Make_Id
    Window_Flag = 2
    middle_plot_info.domain = 1

        middle_plot_info.fft_recalc = 1
        middle_plot_info.xaxis = 1
        middle_plot_info.freq_xmin = middle_plot_info.freq_xmin / middle_data_file_header.frequency
        middle_plot_info.freq_xmax = middle_plot_info.freq_xmax / middle_data_file_header.frequency

    status = { peakLocations:peakLocations, Make_Id:Make_Id, zoomOn:0, PreviousFlag:PreviousFlag,$
          currentSelection:0,PreviousDomain:PreviousDomain, xmax:0.0,xmin:0.0,ymax:0.0, ymin:0.0,$
          PullDownMenu:PullDownMenu, iter:0, values:values,xValue:xValue, wValue:wValue, $
          clickedOnce:clickedOnce, yValue:yValue, phaseValue:phaseValue, previousUnits:previousUnits, $
          chi_squared:'',  noise_stdev:0.0, noise_stdev_im:0.0, WidGasValue:WidGasValue, DelayValue:DelayValue,$
          variables:variables, numOfVariables:0, peakOperations:peakOperations}
    pstate = ptr_new(status,/NO_COPY)

    WIDGET_CONTROL,MakeGuess_Base, SET_UVALUE=pstate
    WIDGET_CONTROL, MakeGuess_Base, /REALIZE
    REDISPLAY

    XMANAGER, "MakeGuess", MakeGuess_Base
END

pro MAKE_GUESS_LOAD, event

    COMMON common_vars
    loc = 1
    flag = 0
    counter =0
    WIDGET_CONTROL, event.top, GET_UVALUE=state
    line = ''    ;variable for reading in lines of code of variable lengths
    realv = ''
    imagv = ''

    ;Pick a file to read
    guess_file = DIALOG_PICKFILE(/READ, PATH=defaultpath, FILTER = '*.ges')
    filename = STRSPLIT(guess_file, '.',/EXTRACT)

    IF (filename[N_ELEMENTS(filename)-1] NE 'ges' AND $
    filename[N_ELEMENTS(filename)-1] NE 'out') THEN RETURN
    openr, unit, guess_file, /GET_LUN    ;opens guess file
    PRINT, "phile opened..."
    ;Determine if Guess File is valid
    repeat begin
          test = 0
          IF (NOT EOF(unit)) THEN BEGIN
               readf, unit, line
               upper_line = STRUPCASE(line)
       ENDIF ELSE BEGIN
         CLOSE, unit
         FREE_LUN, unit
               RETURN
          ENDELSE
          IF STRMID(upper_line,0,27) EQ "****_GUESS_FILE_BEGINS_****" THEN test = 1
    endrep until test EQ 1 ;looks for guess file identification.

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

          if (STRMID(upper_line,0,25) EQ "****_GUESS_FILE_ENDS_****") THEN BEGIN
           CLOSE, unit
         FREE_LUN, unit

       ; Now update all the elements in the Make Guess File menu...
       FOR i=1, (*state).iter DO (*state).values[i]= i
       WIDGET_CONTROL, (*state).PullDownMenu, SET_VALUE=(*state).values[0:(*state).iter]


       RETURN

            ENDIF ELSE BEGIN
           if (STRMID(upper_line,0,1) NE ';') THEN BEGIN

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
         WHILE(((M = STRPOS(upper_line, '  '))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
       tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF (tokens[valid_tokens[0]] EQ 'NUMBER_PEAKS') THEN BEGIN
                 (*state).iter =  tokens[valid_tokens[1]]
              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'SHIFT_UNITS') THEN BEGIN
                 ;middle_guess_info.shift_units =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'REFERENCE_FREQUENCY') THEN BEGIN
                                  trash =  tokens[valid_tokens[1]]
              ; value not read into guess_info.frequency becasue this value is obtained from the data file

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'CHI_SQUARED') THEN BEGIN
                 (*state).chi_squared =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'NOISE_STDEV_REAL') THEN BEGIN
                 (*state).noise_stdev =  tokens[valid_tokens[1]]

              ENDIF

              IF (tokens[valid_tokens[0]] EQ 'NOISE_STDEV_IMAG') THEN BEGIN
                 (*state).noise_stdev_im =  tokens[valid_tokens[1]]

              ENDIF
           ENDIF

           IF (section EQ 'variables') THEN BEGIN

              ;Replace all tabs with spaces
         WHILE(((M = STRPOS(upper_line, '  '))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
       tokens = STRSPLIT(upper_line, (' '), /EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF(N_ELEMENTS(valid_tokens) GT 1) THEN BEGIN

                 (*state).numOfVariables = (*state).numOfVariables + 1
        (*state).variables[(*state).numOfVariables -1].name = tokens[valid_tokens[0]]
                 middle_token_to_parse = tokens[valid_tokens[1]]
                 PARSE

                 (*state).variables[(*state).numOfVariables-1].value = FLOAT(middle_param_value)
              ENDIF

           ENDIF

           IF (section EQ 'peaks') THEN BEGIN


              ;Replace all tabs with spaces
         WHILE(((M = STRPOS(upper_line, '  '))) NE -1) DO STRPUT, upper_line, ' ', M

              ;Read tokens
              ;tokens = STR_SEP(upper_line, (' '), /REMOVE_ALL)
       tokens = STRSPLIT(upper_line, (' '), EXTRACT)

              valid_tokens = WHERE(tokens NE '')

              IF(N_ELEMENTS(valid_tokens) EQ 7) THEN BEGIN
                   counter = counter + 1

                 FOR M = 1, 6 DO BEGIN
                    ;Parse each token to resolve the guess file
           middle_token_to_parse = tokens[valid_tokens[M]]
                    middle_param_value = 0.0
           length = STRLEN(middle_token_to_parse)

           ; To take away the negative sign on a token.  If we remove a single element from the
           ; token rather than the negative, that is ok too.
           value = STRMID(middle_token_to_parse, 1, length)
                    IF (strpos(value,'+') NE -1 OR (strpos(value, '-') GT 0) OR $
         strpos(value,'*') NE -1 OR strpos(value, '/') NE -1) THEN BEGIN


         length = STRLEN(middle_token_to_parse)
         PRINT, middle_token_to_parse, "   Length:", length
         IF ( strpos(value,'+') NE -1) THEN value = strpos(value,'+')+1
         IF (strpos(value,'*')  NE -1 ) THEN value = strpos(value,'*')+1
         IF (strpos(value, '-') NE -1) THEN value = strpos(value, '-')+1
         IF (strpos(value, '/') NE -1) THEN value = strpos(value, '/')+1

         IF (M EQ 1) THEN BEGIN
          (*state).peakOperations[counter -1].xOp = STRMID(middle_token_to_parse, value, 1)
          var = STRMID(middle_token_to_parse, value+1,length-value+1)
          FOR i=0, (*state).numOfVariables DO BEGIN
              IF (var EQ (*state).variables[i].name) THEN BEGIN
                 (*state).peakOperations[counter -1].xVal = (*state).variables[i].value
                 BREAK
              ENDIF
          ENDFOR

          (*state).peakOperations.xVar = var
          IF ((*state).peakOperations[counter -1].xOp EQ '+') THEN $
              (*state).peakLocations[counter-1].x= FLOAT(STRMID(middle_token_to_parse, 0, value)) + (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].xOp EQ '-') THEN $
              (*state).peakLocations[counter-1].x = FLOAT(STRMID(middle_token_to_parse, 0, value)) - (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].xOp EQ '*') THEN $
              (*state).peakLocations[counter-1].x = FLOAT(STRMID(middle_token_to_parse, 0, value)) * (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].xOp EQ '/') THEN $
              (*state).peakLocations[counter-1].x = FLOAT(STRMID(middle_token_to_parse, 0, value)) / (*state).variables[i].value

         ENDIF
         IF (M EQ 2) THEN BEGIN
          (*state).peakOperations[counter -1].yOp = STRMID(middle_token_to_parse, value, 1)
          var = STRMID(middle_token_to_parse, value+1,length-value+1)
          FOR i=0, (*state).numOfVariables DO BEGIN
              IF (var EQ (*state).variables[i].name) THEN BEGIN
                 (*state).peakOperations[counter -1].yVal =(*state).variables[i].value
                 BREAK
              ENDIF
          ENDFOR

          (*state).peakOperations.yVar = var
          IF ((*state).peakOperations[counter -1].yOp EQ '+') THEN $
              (*state).peakLocations[counter-1].y = FLOAT(STRMID(middle_token_to_parse, 0, value)) + (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].yOp EQ '-') THEN $
              (*state).peakLocations[counter-1].y = FLOAT(STRMID(middle_token_to_parse, 0, value)) - (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].yOp EQ '*') THEN $
              (*state).peakLocations[counter-1].y = FLOAT(STRMID(middle_token_to_parse, 0, value)) * (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].yOp EQ '/') THEN $
              (*state).peakLocations[counter-1].y = FLOAT(STRMID(middle_token_to_parse, 0, value)) / (*state).variables[i].value

         ENDIF
         IF (M EQ 3) THEN BEGIN
          (*state).peakOperations[counter -1].zOp = STRMID(middle_token_to_parse, value, 1)
          var = STRMID(middle_token_to_parse, value+1,length-value+1)
          FOR i=0, (*state).numOfVariables DO BEGIN
              IF (var EQ (*state).variables[i].name) THEN BEGIN
                 (*state).peakOperations[counter -1].zVal =(*state).variables[i].value
                 BREAK
              ENDIF
          ENDFOR

          (*state).peakOperations.zVar = var
          IF ((*state).peakOperations[counter -1].zOp EQ '+') THEN $
              (*state).peakLocations[counter-1].w = FLOAT(STRMID(middle_token_to_parse, 0, value)) + (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].zOp EQ '-') THEN $
              (*state).peakLocations[counter-1].w = FLOAT(STRMID(middle_token_to_parse, 0, value)) - (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].zOp EQ '*') THEN $
              (*state).peakLocations[counter-1].w = FLOAT(STRMID(middle_token_to_parse, 0, value)) * (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].zOp EQ '/') THEN $
              (*state).peakLocations[counter-1].w = FLOAT(STRMID(middle_token_to_parse, 0, value)) / (*state).variables[i].value

         ENDIF
         IF (M EQ 4) THEN BEGIN
          (*state).peakOperations[counter -1].phaseOp = STRMID(middle_token_to_parse, value, 1)
          var = STRMID(middle_token_to_parse, value+1,length-value+1)
          FOR i=0, (*state).numOfVariables DO BEGIN
              IF (var EQ (*state).variables[i].name) THEN BEGIN
                 (*state).peakOperations[counter -1].phaseVal=(*state).variables[i].value
                 BREAK
              ENDIF
          ENDFOR

          (*state).peakOperations.phaseVar = var
          IF ((*state).peakOperations[counter -1].phaseOp EQ '+') THEN $
              (*state).peakLocations[counter-1].phase = FLOAT(STRMID(middle_token_to_parse, 0, value)) + (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].phaseOp EQ '-') THEN $
              (*state).peakLocations[counter-1].phase = FLOAT(STRMID(middle_token_to_parse, 0, value)) - (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].phaseOp EQ '*') THEN $
              (*state).peakLocations[counter-1].phase = FLOAT(STRMID(middle_token_to_parse, 0, value)) * (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].phaseOp EQ '/') THEN $
              (*state).peakLocations[counter-1].phase = FLOAT(STRMID(middle_token_to_parse, 0, value)) / (*state).variables[i].value

         ENDIF
         IF (M EQ 5) THEN BEGIN
          (*state).peakOperations[counter -1].delayOp = STRMID(middle_token_to_parse, value, 1)
          var = STRMID(middle_token_to_parse, value+1,length-value+1)
          FOR i=0, (*state).numOfVariables DO BEGIN
              IF (var EQ (*state).variables[i].name) THEN BEGIN
                 (*state).peakOperations[counter -1].delayVal =(*state).variables[i].value
                 BREAK
              ENDIF
          ENDFOR

          (*state).peakOperations.delayVar = var
          IF ((*state).peakOperations[counter -1].delayOp EQ '+') THEN $
              (*state).peakLocations[counter-1].delaytime = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) + (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].delayOp EQ '-') THEN $
              (*state).peakLocations[counter-1].delaytime = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) - (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].delayOp EQ '*') THEN $
              (*state).peakLocations[counter-1].delaytime = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) * (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].delayOp EQ '/') THEN $
              (*state).peakLocations[counter-1].delaytime = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) / (*state).variables[i].value
         ENDIF
         IF (M EQ 6) THEN BEGIN
          (*state).peakOperations[counter -1].widthOp = STRMID(middle_token_to_parse, value, 1)
              var = STRMID(middle_token_to_parse, value+1,length-value+1)
          FOR i=0, (*state).numOfVariables DO BEGIN
              IF (var EQ (*state).variables[i].name) THEN BEGIN
                 (*state).peakOperations[counter -1].widthVal =(*state).variables[i].value
                 BREAK
              ENDIF
          ENDFOR

          (*state).peakOperations.widthVar = var
          IF ((*state).peakOperations[counter -1].widthOp EQ '+') THEN $
              (*state).peakLocations[counter-1].width_gauss = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) + (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].widthOp EQ '-') THEN $
              (*state).peakLocations[counter-1].width_gauss = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) - (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].widthOp EQ '*') THEN $
              (*state).peakLocations[counter-1].width_gauss = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) * (*state).variables[i].value
          IF ((*state).peakOperations[counter -1].widthOp EQ '/') THEN $
              (*state).peakLocations[counter-1].width_gauss = $
                 FLOAT(STRMID(middle_token_to_parse, 0, value)) / (*state).variables[i].value

         ENDIF

       ENDIF ELSE BEGIN
         If (M EQ 1) THEN (*state).peakLocations[counter-1].x = middle_token_to_parse
         IF (M EQ 2) THEN (*state).peakLocations[counter-1].y = middle_token_to_parse
         If (M EQ 3) THEN (*state).peakLocations[counter-1].w = middle_token_to_parse
         IF (M EQ 4) THEN (*state).peakLocations[counter-1].phase = middle_token_to_parse
         If (M EQ 5) THEN (*state).peakLocations[counter-1].delaytime = middle_token_to_parse
         IF (M EQ 6) THEN (*state).peakLocations[counter-1].width_gauss= middle_token_to_parse
       ENDELSE

    ENDFOR

    PRINT, "Peak information:",(*state).peakLocations[counter-1], "Counter",Counter
        ENDIF ELSE BEGIN


              ENDELSE

           ENDIF



        ENDIF
     ENDIF
     ENDELSE
  ENDWHILE

  CLOSE, unit
  FREE_LUN, unit

END



pro MAKE_GUESS_REMOVE_PEAK, event
    WIDGET_CONTROL, event.top, GET_UVALUE=status

    ;If there are no elements in the list, or 1 peak when you try to remove, just return.
    IF ((*status).iter EQ 0 OR ((*status).iter EQ 1 AND (*status).currentSelection EQ 0) ) THEN return

    ;If we are at the last element in a list
    IF ((*status).iter EQ (*status).currentSelection+1) THEN BEGIN
       (*status).iter = (*status).iter -1
       (*status).currentSelection = (*status).currentSelection -1
    ENDIF ELSE BEGIN

       FOR i = (*status).currentSelection, (*status).iter-1 DO BEGIN
         (*status).values[i] = i+1
         (*status).peakLocations[i] = (*status).peakLocations[i+1]
       ENDFOR

       (*status).iter = (*status).iter-1

    ENDELSE

    WIDGET_CONTROL, (*status).PullDownMenu, SET_VALUE=(*status).values[0:(*status).iter]

    ; Update the text field widgets
    WIDGET_CONTROL, (*status).xValue, SET_VALUE=(*status).peakLocations[(*status).currentSelection].x
    WIDGET_CONTROL, (*status).yValue, SET_VALUE=(*status).peakLocations[(*status).currentSelection].y
    WIDGET_CONTROL, (*status).wValue, SET_VALUE=(*status).peakLocations[(*status).currentSelection].w
    WIDGET_CONTROL, (*status).phaseValue, SET_VALUE=(*status).peakLocations[(*status).currentSelection].phase
    WIDGET_CONTROL, (*status).delayValue, SET_VALUE=(*status).peakLocations[(*status).currentSelection].delaytime
    WIDGET_CONTROL, (*status).widGasValue, SET_VALUE=(*status).peakLocations[(*status).currentSelection].widthgauss

end
;===========================================================================================;
; Name:  Make_Guess_Add_Peak                                   ;
; Purpose: The peak pulldown menu starts empty.  By clicking on the "Add Peak" button, this ;
;          function will add a peak into the menu.                                          ;
; Parameters: event - The event which called this procedure.              ;
; Return: None.                             ;
;===========================================================================================;
pro MAKE_GUESS_ADD_PEAK, event
    WIDGET_CONTROL, event.top, GET_UVALUE=state

    (*state).values[(*state).iter]=(*state).iter+1
    WIDGET_CONTROL, (*state).PullDownMenu, SET_VALUE=(*state).values[0:(*state).iter]
    (*state).iter = (*state).iter + 1

end

;===========================================================================================;
; Name:  Make_Guess_Pulldown, event                                                         ;
; Purpose: This procedure is called whenever a user clicks on an element in the droplist.   ;
;          It will do 2 things.   Update the peak to be the selected value, and secondly,   ;
;          will put the appropriate peak information into the text fields.                  ;
; Parameters:  event - The event which called this procedure.                               ;
; Return:  None.                            ;
;===========================================================================================;
pro MAKE_GUESS_PULLDOWN, event
    WIDGET_CONTROL, event.top, GET_UVALUE=state

    ; Get the current selection from the droplist.
    WIDGET_CONTROL, (*state).PullDownMenu, GET_UVALUE=values
    (*state).currentSelection = WIDGET_INFO ((*state).PullDownMenu, /DROPLIST_SELECT)

    ; Save the phase
    WIDGET_CONTROL, (*state).phaseValue, GET_VALUE=temp
    ;(*state).peakLocations[(*state).currentSelection].phase=temp[0]

    ; Update the text field widgets
    WIDGET_CONTROL, (*state).xValue, SET_VALUE=(*state).peakLocations[(*state).currentSelection].x
    WIDGET_CONTROL, (*state).yValue, SET_VALUE=(*state).peakLocations[(*state).currentSelection].y
    WIDGET_CONTROL, (*state).wValue, SET_VALUE=(*state).peakLocations[(*state).currentSelection].w
    WIDGET_CONTROL, (*state).phaseValue,SET_VALUE=(*state).peakLocations[(*state).currentSelection].phase
    WIDGET_CONTROL, (*state).delayValue, SET_VALUE=(*state).peakLocations[(*state).currentSelection].delaytime
    WIDGET_CONTROL, (*state).widGasValue, SET_VALUE=(*state).peakLocations[(*state).currentSelection].width_gauss

    ;print, (*state).peakLocations[(*state).currentSelection].phase
    ;help,  (*state).peakLocations[(*state).currentSelection].phase
end
;==========================================================================================;
;  Name:  MakeGuess_MouseControl                                                           ;
;  Purpose:  Called whenever the mouse moves over/clicks button in the draw window area.   ;
;            This will allow for the mouse to zoom in if the zoom feature is activated, or ;
;            if not activated, allows the user to set a peak value.                        ;
;  Parameters:  event - The event which called this procedure.                             ;
;  Return:  None.                                                                          ;
;==========================================================================================;
pro MakeGuess_MouseControl, event
    COMMON common_widgets
    COMMON common_vars
    WIDGET_CONTROL, event.top, GET_UVALUE=status

    If ((*status).zoomOn) THEN BEGIN
       IF (event.type EQ 0) THEN BEGIN
               ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
               (*status).xmax = datac[0]
         (*status).ymax = datac[1]
            ENDIF
       IF (event.type EQ 1) THEN BEGIN
         ; Convert the coordinates from device to data
               datac = convert_coord(event.x, event.y, /DEVICE, /TO_DATA)
         (*status).xmin = datac[0]
         (*status).ymin = datac[1]

         middle_plot_info.x1 = (*status).xmin
           middle_plot_info.y2 = (*status).ymax
           middle_plot_info.x2 = (*status).xmax
           middle_plot_info.y1 = (*status).ymin

         middle_plot_info.freq_auto_scale_y = 0
               middle_plot_info.freq_auto_scale_x = 0
               middle_plot_info.fft_recalc = 1

             middle_plot_info.freq_xmin = middle_plot_info.x1
             middle_plot_info.freq_xmax = middle_plot_info.x2
             middle_plot_info.freq_ymin = middle_plot_info.y1
             middle_plot_info.freq_ymax = middle_plot_info.y2

           AUTO_SCALE
         MIDDLE_DISPLAY_DATA

       ENDIF
    ENDIF ELSE BEGIN
         ; First click is on the top of the peak.  This gets shift and amplitude.
         ; Second click is on the left base of the peak.  This is used to determine
         ; the width.  Will be a simple calculation of (shift-y)*2.  Symmetry is assumed
         ; for the peak.  This will give an approximate value
         IF (event.type EQ 0 AND (*status).clickedOnce EQ 1) THEN BEGIN
          datac = CONVERT_COORD(event.x, event.y, /DEVICE, /TO_DATA)
          diff =(*status).peakLocations[(*status).currentSelection].x - datac[0]
          (*status).peakLocations[(*status).currentSelection].w = ABS(diff*2)
          WIDGET_CONTROL,(*status).wValue, SET_VALUE=ABS(diff*2)
          (*status).clickedOnce = 0
          return
         ENDIF
         IF (event.type EQ 0 AND (*status).clickedOnce EQ 0) THEN BEGIN
          datac = CONVERT_COORD(event.x, event.y, /DEVICE, /TO_DATA)
          (*status).peakLocations[(*status).currentSelection].x = datac[0]
          (*status).peakLocations[(*status).currentSelection].y = datac[1]
          WIDGET_CONTROL, (*status).xValue, SET_VALUE=datac[0]
          WIDGET_CONTROL, (*status).yValue, SET_VALUE=datac[1]
          (*status).clickedOnce = 1
         ENDIF
    ENDELSE
end

;=====================================================================================================;
;  Name:  MAKE_GUESS_CANCEL                               ;
;  Purpose:  To destroy the widgets when a user decides to cancel the Make Guess File menu.           ;
;  Parameters:  event - The event which caused this procedure to be called.                       ;
;  Return:  None.                               ;
;=====================================================================================================;
pro MAKE_GUESS_CANCEL, event
    COMMON common_vars
    COMMON Draw1_comm
    WIDGET_CONTROL, event.top, GET_UVALUE=status

    middle_plot_info.domain = (*status).previousDomain
    Window_Flag=(*status).PreviousFlag

    IF ((*status).previousFlag EQ 1) THEN WSET, Draw1_Id
    IF ((*status).previousFlag EQ 2) THEN WSET, Draw2_Id
    IF ((*status).previousFlag EQ 3) THEN WSET, Draw3_Id

    middle_plot_info.fft_recalc = 1
        middle_plot_info.xaxis = (*status).PreviousUnits
        middle_plot_info.freq_xmin = middle_plot_info.freq_xmin / middle_data_file_header.frequency
        middle_plot_info.freq_xmax = middle_plot_info.freq_xmax / middle_data_file_header.frequency
    PRINT, (*status).peakOperations[0:14]
    Print,"-------------------"
    PRINT, (*status).peakLocations[0:14]
    WIDGET_CONTROL, event.top, /DESTROY
END

;====================================================================================================;
;  Name:  MAKE_GUESS_OK                              ;
;  Purpose:  To write all the given information on peaks into a file, with the name selected by a    ;
;            user.  It will convert all units from degrees to radians before writing it out to file. ;
;  Parameters:  event - The event which triggered this procedure to be called.                       ;
;  Return:  None.                              ;
;====================================================================================================;
pro MAKE_GUESS_OK, event
    COMMON common_vars
    WIDGET_CONTROL, event.top, GET_UVALUE=status

    ; Save the phase
    WIDGET_CONTROL, (*status).phaseValue, GET_VALUE=temp
    (*status).peakLocations[(*status).currentSelection].phase= temp[0]
    toRadian = !PI/180

    GuessFile = DIALOG_PICKFILE(/WRITE, PATH=defaultpath)
        GuessFile = GuessFile + '.ges'
        OPENW, unit, GuessFile, /GET_LUN
    PRINT, GuessFile
    PRINTF, unit, "****_Guess_File_Begins_****  <--- Do not remove this line"
    PRINTF, unit, ""
    PRINTF, unit, "[Parameters]"
    PRINTF, unit, "NUMBER_PEAKS    ",(*status).iter
    PRINTF, unit, "SHIFT_UNITS PPM"
    IF ((*status).chi_squared NE '') THEN PRINTF, unit, "CHI_SQUARED      ",(*status).chi_squared
    IF ((*status).noise_stdev NE 0.0) THEN PRINTF, unit, "NOISE_STDEV_REAL    ",(*status).noise_stdev
    IF ((*status).noise_stdev_im NE 0.0) THEN PRINTF, unit, "NOISE_STDEV_IMAG     ",(*status).noise_stdev_im
    PRINTF, unit, ""
    PRINTF, unit, "[Variables]"
    FOR I = 0, (*status).numOfVariables-1 DO BEGIN
       PRINTF, unit, (*status).variables[I].name, "   ", (*status).variables[I].value
    ENDFOR
    PRINTF, unit, ""
    PRINTF, unit, "[Peaks]"
    PRINTF, unit, ""
    PRINTF, unit, "; Peak#    Shift          Width_L(Hz)      Amplitude          Phase(rad)      Delay_Time(s)  Width_Gauss(Hz)"
    FOR i = 0, (*status).iter DO BEGIN
       IF ((*status).peakOperations[i].xOp EQ '+') THEN (*status).peakLocations[i].x = (*status).peakLocations[i].x - (*status).peakOperations[i].xVal
       IF ((*status).peakOperations[i].xOp EQ '-') THEN (*status).peakLocations[i].x = (*status).peakLocations[i].x + (*status).peakOperations[i].xVal
       IF ((*status).peakOperations[i].xOp EQ '*') THEN (*status).peakLocations[i].x = (*status).peakLocations[i].x / (*status).peakOperations[i].xVal
       IF ((*status).peakOperations[i].xOp EQ '/') THEN (*status).peakLocations[i].x = (*status).peakLocations[i].x * (*status).peakOperations[i].xVal

       IF ((*status).peakOperations[i].yOp EQ '+') THEN (*status).peakLocations[i].y = (*status).peakLocations[i].y - (*status).peakOperations[i].yVal
       IF ((*status).peakOperations[i].yOp EQ '-') THEN (*status).peakLocations[i].y = (*status).peakLocations[i].y + (*status).peakOperations[i].yVal
       IF ((*status).peakOperations[i].yOp EQ '*') THEN (*status).peakLocations[i].y = (*status).peakLocations[i].y / (*status).peakOperations[i].yVal
       IF ((*status).peakOperations[i].yOp EQ '/') THEN (*status).peakLocations[i].y = (*status).peakLocations[i].y * (*status).peakOperations[i].yVal

       IF ((*status).peakOperations[i].zOp EQ '+') THEN (*status).peakLocations[i].w = (*status).peakLocations[i].w - (*status).peakOperations[i].zVal
       IF ((*status).peakOperations[i].zOp EQ '-') THEN (*status).peakLocations[i].w = (*status).peakLocations[i].w + (*status).peakOperations[i].zVal
       IF ((*status).peakOperations[i].zOp EQ '*') THEN (*status).peakLocations[i].w = (*status).peakLocations[i].w / (*status).peakOperations[i].zVal
       IF ((*status).peakOperations[i].zOp EQ '/') THEN (*status).peakLocations[i].w = (*status).peakLocations[i].w * (*status).peakOperations[i].zVal

       IF ((*status).peakOperations[i].phaseOp EQ '+') THEN $
         (*status).peakLocations[i].phase = (*status).peakLocations[i].phase - (*status).peakOperations[i].phaseVal
       IF ((*status).peakOperations[i].phaseOp EQ '-') THEN $
         (*status).peakLocations[i].phase = (*status).peakLocations[i].phase + (*status).peakOperations[i].phaseVal
       IF ((*status).peakOperations[i].phaseOp EQ '*') THEN $
         (*status).peakLocations[i].phase = (*status).peakLocations[i].phase / (*status).peakOperations[i].phaseVal
       IF ((*status).peakOperations[i].phaseOp EQ '/') THEN $
         (*status).peakLocations[i].phase = (*status).peakLocations[i].phase * (*status).peakOperations[i].phaseVal

       IF ((*status).peakOperations[i].delayOp EQ '+') THEN $
         (*status).peakLocations[i].delay = (*status).peakLocations[i].delay - (*status).peakOperatiors[i].delayVal
       IF ((*status).peakOperations[i].delayOp EQ '-') THEN $
         (*status).peakLocations[i].delay = (*status).peakLocations[i].delay + (*status).peakOperations[i].delayVal
       IF ((*status).peakOperations[i].delayOp EQ '*') THEN $
         (*status).peakLocations[i].delay = (*status).peakLocations[i].delay / (*status).peakOperations[i].delayVal
       IF ((*status).peakOperations[i].delayOp EQ '/') THEN $
         (*status).peakLocations[i].delay = (*status).peakLocations[i].delay * (*status).peakOperations[i].delayVal

       IF ((*status).peakOperations[i].widthOp EQ '+') THEN $
         (*status).peakLocations[i].width = (*status).peakLocations[i].width - (*status).peakOperations[i].widthVal
       IF ((*status).peakOperations[i].widthOp EQ '-') THEN $
         (*status).peakLocations[i].width = (*status).peakLocations[i].width + (*status).peakOperations[i].widthVal
       IF ((*status).peakOperations[i].widthOp EQ '*') THEN $
         (*status).peakLocations[i].width = (*status).peakLocations[i].width / (*status).peakOperations[i].widthVal
       IF ((*status).peakOperations[i].widthOp EQ '/') THEN $
         (*status).peakLocations[i].width = (*status).peakLocations[i].width * (*status).peakOperations[i].widthVal
    ENDFOR

    FOR i=0, (*status).iter-1 DO BEGIN
       statement = ''

       IF ((*status).peakOperations[i].xOp NE '') THEN statement = STRING(i) +'    '+STRING((*status).peakLocations[i].x) +'+'+STRING((*status).peakOperations[i].xVar)
       IF ((*status).peakOperations[i].xOp EQ '') THEN statement =  STRING(i) +'    '+STRING((*status).peakLocations[i].x)
       IF ((*status).peakOperations[i].yOp NE '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].y)+'+'+STRING((*status).peakOperations[i].yVar)
       IF ((*status).peakOperations[i].yOp EQ '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].y)
       IF ((*status).peakOperations[i].zOp NE '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].w)+'+'+STRING((*status).peakOperations[i].zVar)
       IF ((*status).peakOperations[i].zOp EQ '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].w)
       IF ((*status).peakOperations[i].phaseOp NE '') THEN statement =  statement + '    '+STRING((*status).peakLocations[i].phase)+'+'+STRING((*status).peakOperations[i].phaseVar)
       IF ((*status).peakOperations[i].phaseOp EQ '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].phase)
       IF ((*status).peakOperations[i].delayOp NE '') THEN statement =  statement + '    '+STRING((*status).peakLocations[i].delaytime)+'+'+STRING((*status).peakOperations[i].delayVar)
       IF ((*status).peakOperations[i].delayOp EQ '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].delaytime)
       IF ((*status).peakOperations[i].widthOp NE '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].width_gauss)+'+'+STRING((*status).peakOperations[i].widthVar)
       IF ((*status).peakOperations[i].widthOp EQ '') THEN statement = statement + ' '+STRING((*status).peakLocations[i].width_gauss)


       PRINTF, unit, statement
       PRINTF, unit, ''
    ENDFOR
    PRINTF,unit,"****_Guess_File_Ends_****  <--- Do not remove this line"

    CLOSE, unit
    FREE_LUN, unit
    WIDGET_CONTROL, event.top, /DESTROY
    PRINT, 'done'

end

;====================================================================================================;
;  Name:  MAKE_GUESS_ZOOMON                              ;
;  Purpose:  The procedure simply sets a flag that tells when the zoom button has been turned on.    ;
;  Parameters:  event - The event which triggered this procedure to be called.                       ;
;  Return:  None.                              ;
;====================================================================================================;
pro MAKE_GUESS_ZOOMON, event
    WIDGET_CONTROL, event.top, GET_UVALUE=status
    (*status).zoomOn=1
end

;====================================================================================================;
;  Name:  MAKE_GUESS_ZOOMOFF                             ;
;  Purpose:  The procedure simply sets a flag that tells when the zoom button has been turned off.   ;
;  Parameters:  event - The event which triggered this procedure to be called.                       ;
;  Return:  None.                              ;
;====================================================================================================;
pro MAKE_GUESS_ZOOMOFF, event
    WIDGET_CONTROL, event.top, GET_UVALUE=status
    (*status).zoomOn =0
end



