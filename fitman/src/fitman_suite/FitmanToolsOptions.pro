;=======================================================================================================;
; Name:  EV_LORENTZIAN
; Purpose:  To allow a user to generate a Lorentzian type signal for simulations.
;           The curve is generated based on the follwong parameters: ampl, damp, freq, phase
; Procedure:  Event - The event which caused this procedure to be run.
; Return:  None.
;=======================================================================================================;
PRO EV_LORENTZIAN, event
    COMMON common_vars
    COMMON common_widgets
    COMMON lorent_vars

    ;lorent_params are: 0 - amplitude, 1 - damping, 2 - frequency, 3 - phase

    ; If add_noise is not defined initialize it.
    IF N_ELEMENTS(lorent_params) EQ 0 THEN noise_present = 1

    ; If lorent_np is not defined initialize it.
    IF N_ELEMENTS(lorent_np) EQ 0 THEN lorent_np = 2048

    ; If lorent_dwell is not defined initialize it.
    IF N_ELEMENTS(lorent_dwell) EQ 0 THEN  lorent_dwell = 0.0005

    ; If lorent_acq_freq is not defined initialize it.
    IF N_ELEMENTS(lorent_acq_freq) EQ 0 THEN lorent_acq_freq = 63.8

    ; If lorent_nex is not defined initialize it.
    IF N_ELEMENTS(lorent_nex) EQ 0 THEN lorent_nex = 128


    WIDGET_CONTROL, main1, SENSITIVE=0

    lorent_base = WIDGET_BASE(COLUMN=2, MAP=1, TITLE='Lorentzian type signal generator',UVALUE=lorent_p)
    options_base = WIDGET_BASE(lorent_base, COL=1, MAP=1, UVALUE='options', /ALIGN_RIGHT)
    confirm_base = WIDGET_BASE(lorent_base, COL=1, MAP=1, UVALUE='CONFIRM')
    numTerms_field = CW_FIELD(options_base, TITLE='Number of terms in the signal :', VALUE = lorent_numTerms, /INTEGER)
    lor_label1 = WIDGET_LABEL(options_base, VALUE = '-------------------------------------------------------')
    numPoints_field = CW_FIELD(options_base, TITLE='Number of points in the signal:', VALUE = lorent_np ,/INTEGER)
    dwell_field = CW_FIELD(options_base,     TITLE='              Dwell time (sec):', VALUE = lorent_dwell ,/FLOAT)
    acq_freq_field = CW_FIELD(options_base,  TITLE='   Acquisition frequency (MHz):', VALUE = lorent_acq_freq ,/FLOAT)
    nex_field = CW_FIELD(options_base,       TITLE='        Number of acquisitions:', VALUE = lorent_nex ,/INTEGER)
    ad_noise_base = WIDGET_BASE(options_base, COL=1, MAP=1, /NONEXCLUSIVE, /FRAME, /ALIGN_RIGHT)
    ad_noise_button = WIDGET_BUTTON(ad_noise_base, VALUE = 'Add noise ', EVENT_PRO='EV_SET_ADDNOISE')
    ok_button = WIDGET_BUTTON(confirm_base, VALUE='Ok', EVENT_PRO='EV_LORENT_PARAMS')
    cancel_button = WIDGET_BUTTON(confirm_base, VALUE='Cancel', EVENT_PRO='EV_LORENT_CANCEL')

    lorent = {numTerms_field:numTerms_field, numPoints_field:numPoints_field, $
         dwell_field:dwell_field, acq_freq_field:acq_freq_field, nex_field:nex_field}
    lorent_p = ptr_new(lorent, /NO_COPY)

    WIDGET_CONTROL, lorent_base, set_UVALUE=lorent_p
    WIDGET_CONTROL, lorent_base, /REALIZE

    WIDGET_CONTROL, ad_noise_button, SET_BUTTON=noise_present

    lorent_termNumber = 1

    XMANAGER, "LORENTZIAN_MAIN", lorent_base, CLEANUP='EV_LORENT_CLEANUP'

END

;=======================================================================================================;
; Name:  EV_LORENT_CLEANUP                       ;
; Purpose:  Returns the sensitity of the main widow to 1 if a Lorentzian window is closed.   ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_LORENT_CLEANUP, event
    COMMON common_widgets

    WIDGET_CONTROL, main1, SENSITIVE =1

END


;=======================================================================================================;
; Name:  EV_LORENT_CANCEL                         ;
; Purpose:  To destroy the Signal Generator menu and give control back to the main widget.   ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_LORENT_CANCEL, event
    COMMON common_widgets

    WIDGET_CONTROL, main1, SENSITIVE =1
    WIDGET_CONTROL, event.top, /DESTROY
END


;=======================================================================================================;
; Name:  EV_LORENT_PARAMS                         ;
; Purpose:  To obtain the parameters ampl, damp, freq and phase for each term.  This routine is a   ;
;           recursive routine.                       ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_LORENT_PARAMS, event
    COMMON lorent_vars
    COMMON common_widgets


    WIDGET_CONTROL, event.top, SENSITIVE=0

    WIDGET_CONTROL, event.top, get_UVALUE=lorent
    WIDGET_CONTROL, (*lorent).numTerms_field, get_VALUE = new_lorent_numTerms

    WIDGET_CONTROL, (*lorent).numPoints_field, get_VALUE = lorent_np
    WIDGET_CONTROL, (*lorent).dwell_field, get_VALUE = lorent_dwell
    WIDGET_CONTROL, (*lorent).acq_freq_field, get_VALUE = lorent_acq_freq
    WIDGET_CONTROL, (*lorent).nex_field, get_VALUE = lorent_nex

    IF (new_lorent_numTerms LT 1) THEN BEGIN
    	Result = DIALOG_MESSAGE('The number of terms in the signal must be greater then zero.', $
          	Title = 'WARNING')
       WIDGET_CONTROL, event.top, SENSITIVE =1
       RETURN
    ENDIF

    ;Getting rid of the parent window
    WIDGET_CONTROL, event.top, /DESTROY
    WIDGET_CONTROL, main1, SENSITIVE=0         ;Need this line in here again, since as the parent widget dies
                    ; it returns the sensitivity of main to 1.
    ; If lorent_params is not defined initialize it.
    IF N_ELEMENTS(lorent_params) EQ 0 THEN BEGIN
       lorent_params = make_array(4,new_lorent_numTerms,/FLOAT)
    ENDIF

    ; If the number of terms changed from previous session, update
    IF (lorent_numTerms NE new_lorent_numTerms) THEN BEGIN
       new_lorent_params = make_array(4,new_lorent_numTerms,/FLOAT)
       IF (new_lorent_numTerms LT lorent_numTerms) THEN $
         new_lorent_params[0:3, 0:new_lorent_numTerms-1] = lorent_params[0:3, 0:new_lorent_numTerms-1] $
       ELSE $
         new_lorent_params[0:3, 0:lorent_numTerms-1] = lorent_params[0:3, 0:lorent_numTerms-1]
       lorent_params = new_lorent_params
       lorent_numTerms = new_lorent_numTerms
    END


    lor_param_main_base = WIDGET_BASE(ROW=2, MAP=1, TITLE='Lorentzian lineshape parameters',UVALUE=lor_param_p)
    lor_param_label1 = WIDGET_LABEL(lor_param_main_base, VALUE = '  Enter parameter values for each term.                                 ')
    confirm_base = WIDGET_BASE(lor_param_main_base, ROW=1, MAP=1, UVALUE='CONFIRM')
    lor_param_base = WIDGET_BASE(lor_param_main_base, COL=2, MAP=1, TITLE='Lorentzian lineshape parameters',UVALUE=lor_param_p)


    options_base1 = WIDGET_BASE(lor_param_base, COL=1, MAP=1, UVALUE='options')
    options_base2 = WIDGET_BASE(lor_param_base, COL=1, MAP=1, UVALUE='options')


    row_labels = STRING( SINDGEN(lorent_numTerms)+1 )
    col_labels = ['Amplitude(au)', 'Damping:', 'Frequency (Hz):', 'Phase (Deg):']

    ;Load the paramaters from the table widget into "lorent_params"
    lor_param_table  = WIDGET_TABLE(options_base2, VALUE= lorent_params, ALIGNMENT = 1, $
         /EDITABLE, COLUMN_LABELS = col_labels, ROW_LABELS=row_labels, $
         EVENT_PRO='EV_LORENT_UPDATE_PAR_TABLE', FRAME = 0)

    ok_button = WIDGET_BUTTON(confirm_base, VALUE='Ok', EVENT_PRO='EV_LORENT_GENSIG')
    cancel_button = WIDGET_BUTTON(confirm_base, VALUE='Cancel', EVENT_PRO='EV_LORENT_CANCEL')


    WIDGET_CONTROL, lor_param_base, set_UVALUE=lor_param_p
    WIDGET_CONTROL, lor_param_base, /REALIZE

    XMANAGER, "Lorent_params", lor_param_base, CLEANUP='EV_LORENT_CLEANUP'

END


;=======================================================================================================
; Name:  EV_LORENT_UPDATE_PAR_TABLE
; Purpose:  Updates the parameter array for the Lorentzian lineshape.
; Parameters:  event - The event which called this procedure.
; Return:  None.
;=======================================================================================================
PRO EV_LORENT_UPDATE_PAR_TABLE, event
    COMMON lorent_vars

    WIDGET_CONTROL, event.id, GET_VALUE = lorent_params
print, lorent_params
END



;=======================================================================================================
;Name: EV_LORENT_GENSIG
;Purpose: Generate signal basedon user given parameters.
;=======================================================================================================
PRO EV_LORENT_GENSIG, event
    COMMON common_vars
    COMMON common_widgets
    COMMON lorent_vars
    COMMON generated_data, gen_headerLines, gen_data

    gen_headerLines = {generated_headerLines, line1:0, line2:0, line3:0.0, line4:0.0, $
                                                  line5:0, line6:'', line7:'', line8:'',  $
                   line9:'', line10:'', line11:0, line12:''}

    ; Sample data to fit to
        X = FINDGEN(lorent_np)*lorent_dwell
    Print, 'x definition = ',  X[0:10]

    gen_data = 0
    FOR i = 0, lorent_numTerms-1 DO BEGIN
          gen_data = gen_data + lorent_params[0,i]*EXP(COMPLEX(-1*!Pi*X*lorent_params[1,i], 2*!Pi*lorent_params[2,i]*X-(lorent_params[3,i]*!Pi/180)))
    ENDFOR

    FOR i = lorent_np-1, 1, -1 DO BEGIN
          gen_data[i] = gen_data[i-1]
    ENDFOR

    ;ADDING NOISE TO CURVE
    IF (noise_present) THEN BEGIN
           N = FIX(3*Randomu(s,lorent_np))-1
          Ni = FIX(3*Randomu(s+1,lorent_np))-1
           FOR i=0, lorent_np-1 DO gen_data[i] = gen_data[i] + N[i] * 0.3*Randomu(s,1)
          FOR i=0, lorent_np-1 DO gen_data[i] = gen_data[i] + COMPLEX(0.0, Ni[i] * 0.3*Randomu(s+1,1))
    ENDIF

    gen_data[0]=0

    ;Initializing the header
    gen_headerLines.line1 = lorent_np
    gen_headerLines.line2 = 1
    gen_headerLines.line3 = lorent_dwell
    gen_headerLines.line4 = lorent_acq_freq
    gen_headerLines.line5 = lorent_nex
    gen_headerLines.line6 = 'Not used'
    gen_headerLines.line7 = 'Not used'
    gen_headerLines.line8 = 'Not used'
    gen_headerLines.line9 = 'Not used'
    gen_headerLines.line10 = 'fitMAN generated'
    gen_headerLines.line11 = 0
    gen_headerLines.line12 = 'EMPTY'

    ;Insert data into
    data_source = 'generated'   ;Used to distingush the data source in EV_DATA
    EV_DATA

    WIDGET_CONTROL, main1, SENSITIVE=1
    WIDGET_CONTROL, event.top, /DESTROY

END


;=======================================================================================================;
; Name:  INSERT_DATA                             ;
; Purpose:  To insert the generated data in the active window.             ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO INSERT_DATA
  COMMON common_vars
  COMMON common_widgets
  COMMON generated_data

  ;Top window
  IF (window_flag EQ 1) THEN BEGIN
    data_file_header.points = gen_headerLines.line1*2
    data_file_header.components = gen_headerLines.line2
    data_file_header.dwell = gen_headerLines.line3
    data_file_header.frequency = gen_headerLines.line4
    data_file_header.scans = gen_headerLines.line5
    data_file_header.comment1 = gen_headerLines.line6
    data_file_header.comment2 = gen_headerLines.line7
    data_file_header.comment3 = gen_headerLines.line8
    data_file_header.comment4 = gen_headerLines.line9
    data_file_header.acq_type = gen_headerLines.line10
    data_file_header.increment = gen_headerLines.line11
    data_file_header.empty = gen_headerLines.line12

    index = ((data_file_header.points/2))

    time_data_points[0, 0:index-1] = gen_data[0:index-1]

    ;Define variables ppm and hertz
    guess_variables[0].name = 'PPM'
    guess_variables[0].gvalue = data_file_header.frequency/1000000
    guess_variables[1].name = 'HERTZ'
    guess_variables[1].gvalue = 1000000/data_file_header.frequency

    guess_info.number_variables = 2
    guess_info.frequency = data_file_header.frequency*1000000
    plot_info.data_file = 'generated_data'
  ENDIF

  ;Middle window
  IF (window_flag EQ 2) THEN BEGIN
    middle_data_file_header.points = gen_headerLines.line1*2
    middle_data_file_header.components = gen_headerLines.line2
    middle_data_file_header.dwell = gen_headerLines.line3
    middle_data_file_header.frequency = gen_headerLines.line4
    middle_data_file_header.scans = gen_headerLines.line5
    middle_data_file_header.comment1 = gen_headerLines.line6
    middle_data_file_header.comment2 = gen_headerLines.line7
    middle_data_file_header.comment3 = gen_headerLines.line8
    middle_data_file_header.comment4 = gen_headerLines.line9
    middle_data_file_header.acq_type = gen_headerLines.line10
    middle_data_file_header.increment = gen_headerLines.line11
    middle_data_file_header.empty = gen_headerLines.line12

    index = ((middle_data_file_header.points/2))

    middle_time_data_points[0, 0:index-1] = gen_data[0:index-1]

    ;Define variables ppm and hertz
    middle_guess_variables[0].name = 'PPM'
    middle_guess_variables[0].gvalue = middle_data_file_header.frequency/1000000
    middle_guess_variables[1].name = 'HERTZ'
    middle_guess_variables[1].gvalue = 1000000/middle_data_file_header.frequency

    middle_guess_info.number_variables = 2
    middle_guess_info.frequency = middle_data_file_header.frequency*1000000
    middle_plot_info.data_file = 'generated_data'
  ENDIF

  ;Bottom window
  IF (window_flag EQ 3) THEN BEGIN
    bottom_data_file_header.points = gen_headerLines.line1*2
    bottom_data_file_header.components = gen_headerLines.line2
    bottom_data_file_header.dwell = gen_headerLines.line3
    bottom_data_file_header.frequency = gen_headerLines.line4
    bottom_data_file_header.scans = gen_headerLines.line5
    bottom_data_file_header.comment1 = gen_headerLines.line6
    bottom_data_file_header.comment2 = gen_headerLines.line7
    bottom_data_file_header.comment3 = gen_headerLines.line8
    bottom_data_file_header.comment4 = gen_headerLines.line9
    bottom_data_file_header.acq_type = gen_headerLines.line10
    bottom_data_file_header.increment = gen_headerLines.line11
    bottom_data_file_header.empty = gen_headerLines.line12

    index = ((bottom_data_file_header.points/2))

    bottom_time_data_points[0, 0:index-1] = gen_data[0:index-1]

    ;Define variables ppm and hertz
    bottom_guess_variables[0].name = 'PPM'
    bottom_guess_variables[0].gvalue = bottom_data_file_header.frequency/1000000
    bottom_guess_variables[1].name = 'HERTZ'
    bottom_guess_variables[1].gvalue = 1000000/bottom_data_file_header.frequency

    bottom_guess_info.number_variables = 2
    bottom_guess_info.frequency = bottom_data_file_header.frequency*1000000
    bottom_plot_info.data_file = 'generted_data'
  ENDIF


END



;=======================================================================================================;
; Name:  EV_SET_ADDNOISE
; Purpose:  To set the "add noise" flag.
; Procedure:  Event - The event which caused this procedure to be run.
; Return:  None.
;=======================================================================================================;
PRO EV_SET_ADDNOISE, event
    COMMON lorent_vars

  IF (noise_present EQ 0) THEN noise_present = 1 ELSE noise_present = 0


END
