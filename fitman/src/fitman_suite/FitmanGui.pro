;=======================================================================================================;
; Program:  FitmanGUI
; Purpose:  Front-end program for ultra-fitman, hlsvd & subpeak.   Used to produce graphs based on data
;       from MR machine.  Allows various function to manipulate graphs. Meant as visualization tool.
;       See documentation for more details.
; Type: Widget based.
;
; Original Code:  Rob Bartha
; Updates & Addition of new features:   Geoff Herbynchuk 2001
;                                       Csaba Kiss 2005
;										Ming-Ho Yee 2008
;										Dickson Wong 2016
;=======================================================================================================;
PRO FitmanGui_sep2000

    ABOUT_FITMAN, 10

END

;=======================================================================================================;
; Name:  ABOUT_FITMAN
; Purpose:  Displays the about information.
; Parameters:  wait_sec - Number of seconds to display the window.
; Return:  None.
;=======================================================================================================;
PRO ABOUT_FITMAN, wait_sec

    About_base = WIDGET_BASE(COL=1, TITLE='About FitmanGUI', UVALUE='blah')

    About_text_base = WIDGET_BASE(About_base, ROW=19, /FRAME)
    text01 =  WIDGET_LABEL(About_text_base, VALUE='FitMAN_SUITE - Copyright 1999-2005, Version 1.7.1')
    text01a = WIDGET_LABEL(About_text_base, VALUE='    Raw file conversion supported under: SunOS, Linux, MacOS, Win32')
    text01b = WIDGET_LABEL(About_text_base,VALUE='')
    text02= WIDGET_LABEL(About_text_base, VALUE='Fitman:   Rob Bartha, John Potwarka, and Dick Drost')
    text03= WIDGET_LABEL(About_text_base, VALUE='Robarts Research Institute and Lawson Health Research Institute')
    text04= WIDGET_LABEL(About_text_base, VALUE=' ')
    text05= WIDGET_LABEL(About_text_base, VALUE='FitMAN_SUITE: Rob Bartha')
    text06= WIDGET_LABEL(About_text_base, VALUE='Robarts Research Institute.')
    text07= WIDGET_LABEL(About_text_base, VALUE=' ')
    text08= WIDGET_LABEL(About_text_base, VALUE=' ')
    text09= WIDGET_LABEL(About_text_base, VALUE='Use of FitMAN software should be acknowledged in all publications as provided by Dr. Rob Bartha and')
    text10= WIDGET_LABEL(About_text_base, VALUE='Dr. Dick Drost and sited as:')
    text11= WIDGET_LABEL(About_text_base, VALUE='Bartha R, Drost DJ, Williamson PC.  Factors affecting the quantification of short echo in vivo')
    text12= WIDGET_LABEL(About_text_base, VALUE='1H MR spectra: prior knowledge, peak elimination, and filtering.  NMR Biomed 1999; 12: 205-216')
    text13= WIDGET_LABEL(About_text_base, VALUE=' ')
    text14= WIDGET_LABEL(About_text_base, VALUE='Use of the HSVD routines for water subtraction should be sited as:')
    text15= WIDGET_LABEL(About_text_base, VALUE=' ')
    text16= WIDGET_LABEL(About_text_base, VALUE='van den Boogaart A, van Ormondt D, Pijnappel WWF, de Beer R, Ala-Korpela M.  In Mathematics in Signal')
    text17= WIDGET_LABEL(About_text_base, VALUE='Processing III, JG McWhirter Ed., 1994, pp 175-195, Clarendon Press, Oxford')

    About_button_base = WIDGET_BASE(About_base, ROW=1, /ALIGN_CENTER)
    about_ok_button = WIDGET_BUTTON(About_button_base, Value='   OK   ', /ALIGN_CENTER, EVENT_PRO='ABOUT_OK_EVENT' )

    WIDGET_CONTROL, About_base, /REALIZE
    WIDGET_CONTROL, about_ok_button, TIMER = wait_sec

    XMANAGER, 'ABOUT_FITMAN', About_base
    
END

;=======================================================================================================;
; Name:  ABOUT_OK_EVENT
; Purpose:  Called when OK button is pressed in the About window.
; Parameters:  event - The event that called this procedure.
; Return:  None.
;=======================================================================================================;
PRO ABOUT_OK_EVENT, event
    WIDGET_CONTROL, event.top, /DESTROY
END

;=======================================================================================================;
; Name:  MAIN
; Purpose:  Main program.
; Parameters:  None.
; Return:  None.
;=======================================================================================================;
PRO MAIN 

    ;Define common variables that will be passed between widgets.

    FitmanGui_sep2000

    COMMON common_vars, data_file_header, data_source, time_data_points, freq_data_points, plot_info, point_index, $
    guess_info, guess_variables, const_variables, peak, plot_color, original_data, token_to_parse, $
    param_value, const_info, link_value, item_parsed, linked_param, comp_time_data_points, window_flag,$
    param_index, current_peak, actual_freq_data_points, freq, middle_data_file_header, $
    middle_time_data_points, middle_freq_data_points, middle_plot_info, middle_point_index, $
    middle_guess_info, middle_guess_variables, middle_const_variables, middle_peak, middle_plot_color, $
    middle_original_data, middle_token_to_parse, middle_param_value, defaultpath, Clear_Flag,$
    middle_const_info, middle_link_value, middle_item_parsed, middle_linked_param, $
    middle_comp_time_data_points, middle_param_index, middle_current_peak, $
    middle_actual_freq_data_points, middle_freq, bottom_data_file_header, bottom_time_data_points, $
    bottom_freq_data_points, bottom_plot_info, bottom_point_index, bottom_guess_info, $
    bottom_guess_variables, bottom_const_variables, bottom_peak, bottom_plot_color, $
    bottom_original_data, bottom_token_to_parse, bottom_param_value, bottom_const_info, $
    bottom_link_value, bottom_item_parsed, bottom_linked_param, bottom_comp_time_data_points, $
    bottom_param_index, bottom_current_peak, bottom_actual_freq_data_points, bottom_freq, print_flag, $
    error_flag, undo_array, EmptyDataFileHeader, EmptyPlotInfo, EmptyGuessInfo, EmptyConstInfo, Red, $
    Green, Blue, NoInput_Flag, guess_just_read, Scale_Flag, o_xmax,o_xmax2, o_xmax3, defaultPrinter, $
    reverse_flag, reverse_flag2, reverse_flag3, point_shift, cur_value_pt, middle_cur_value_pt, $
    bottom_cur_value_pt, middle_point_shift, bottom_point_shift, reload_guess_button, reload_const_button, $
    original_SF, use_orig_SF, calc_SF_only, hlsvdpath,compSelect,xScale,yScale,reloadGC,repaint,printPlot,LUT, $
    eig, Amp, HSVD_purpose, error_window_ID, imported_data_filename, import_file_type

    COMMON common_widgets, x_max, x_min, y_max, y_min, INITIAL, FINAL, PHASE_SLIDER, C_CURVE, $
    CURVE_OFF, EXPON_FILTER, main1, GAUSS_FILTER, Scaling_Slider, button2, button3, button4,button10, $
    button11, button12,button13, button14, button15, button16, button17, button18, button19, button20,$
    button21, button22, menu4, menu5, fit_button, TOP_DRAW,MIDDLE_DRAW,BOTTOM_DRAW,$
    menu1,menu2,menu3,menu6,menu7,modeMenu,statsMenu,simulationMenu,fit_sub_button,save_button,print_button,$
    imgSaveButton, convert_button,remove_button,views,reload_output,noOffset,compBase,compButton,  $
    compBase2,mulPhase, noise_button, create_noise, xmin_field, xmax_field, error_base, convert_main_base

    COMMON DRAW1_Comm, DRAW1_Id, DRAW2_Id, DRAW3_Id,noResize,windowSizes,winSize,isDrag,extrapToZero
    COMMON DrawNoise, n_drawId, noise_flag ; variables used in the "Characterize Noise" Option
    COMMON plot_variables, actual_time_data_points, middle_actual_time_data_points, bottom_actual_time_data_points, actual_time, time

    ;Common variables used during Lorentzian line genaration under "Tools"
    COMMON lorent_vars, lorent_numTerms, lorent_params, lorent_np, lorent_termNumber, lorent_dwell, $
             lorent_acq_freq, lorent_nex, noise_present
    lorent_numTerms = 1


    noise_flag = 0
    ; When true, if the plot is in the middle view (Window_Flag = 2), it will be
    ; displayed in the Noise Characterization window.  If false, all plots will be
    ; re-drawn as to ensure that the proper plot is in the middle view (proc: reSize)

    imported_data_filename = ""
    import_file_type=""
    data_source = 'file'
    calc_SF_only = 0
    use_orig_SF = 0
    original_SF = 0
    point_shift = 0
    cur_value_pt = 0
    middle_cur_value_pt = 0
    bottom_cur_value_pt = 0
    middle_point_shift = 0
    bottom_point_shift = 0
    reverse_flag = 0
    reverse_flag2 = 0
    reverse_flag3 = 0
    NoInput_Flag = 0
    guess_just_read = 0
        extrapToZero = 0
        mulPhase = 0

        compSelect = obj_new('List')

        reloadGC = 0
        repaint = 0
        noResize = 0
        printPlot = 0
        isDrag = 0
        noOffset = 0

    data_file_header = {Data_header, points:0, components:0, dwell:0.0, frequency:0.0, scans:0, $
         comment1:'', comment2:'', comment3:'', comment4:'', acq_type:'', increment:0.0, $
         empty:''}
    middle_data_file_header = {Data_header, points:0, components:0, dwell:0.0, frequency:0.0, scans:0, $
         comment1:'', comment2:'', comment3:'', comment4:'', acq_type:'', increment:0.0, $
         empty:''}
    bottom_data_file_header = {Data_header, points:0, components:0, dwell:0.0, frequency:0.0, scans:0, $
         comment1:'', comment2:'', comment3:'', comment4:'', acq_type:'', increment:0.0, $
         empty:''}
    plot_info = {plot_information, domain:0, fft_initial:0.0, fft_final:0.0, data_file:'', $
         time_ymax:0.0, time_ymin:0.0, time_xmax:0.0, time_xmin:0.0, freq_ymax:0.0, $
         freq_ymin:0.0, freq_xmax:0.0, freq_xmin:0.0, first_freq:0, phase:0.0, display:0,$
         guess_file:'', traces:0, current_phase:0.0, first_trace:0, last_trace:0, $
         current_curve:0, grouping:3, expon_filter:0.0, gauss_filter:0.0, delay_time:0.0, $
         read_file_type:0, const_file:'', num_linked_groups:0, max_colours:15, $
         time_auto_scale_x:1, time_auto_scale_y:1, freq_auto_scale_x:1, freq_auto_scale_y:1,$
         view:0, axis_colour:15, xaxis:0, fft_recalc:1, cursor_active:0, x1:0.0, y1:0.0, $
         x2:0.0, y2:0.0,mz_cursor_active:0, sx:0.0,sy:0.0,dx:0.0,dy:0.0, isZoomed:0, down:0}
    middle_plot_info = REPLICATE (plot_info, 1)
    bottom_plot_info = REPLICATE (plot_info, 1)

    guess_info = {guess_information, frequency:0.0, num_peaks:0, shift_units:'', chi_squared:0.0, $
         std_real:0.0, std_imag:0.0, guess_file_label:0, number_variables:0}
    middle_guess_info = REPLICATE(guess_info, 1)
    bottom_guess_info = REPLICATE(guess_info, 1)

    const_info = {const_information, const_file_label:0, number_peaks:0, shift_units:'', $
         output_shift_units:'', noise_points:0, fixed_noise:0, alambda_inc:0.0, $
         alambda_dec:0.0, fwhm_exp_weighting:0.0, tolerence:0.0, maximum_iterations:0, $
         minimum_iterations:0, noise_equal:0, range_min:0, range_max:0, $
         qrt_sin_weighting_range1:0, qrt_sin_weighting_range2:0, freq_range1:0, $
         freq_range2:0, domain:'', output_file_system:'', number_variables:0, $
         number_link_variables:0}
    middle_const_info = REPLICATE(const_info,1)
    bottom_const_info = REPLICATE(const_info,1)
    EmptyDataFileHeader = REPLICATE(data_file_header,1)
    EmptyPlotInfo = REPLICATE(plot_info,1)
    EmptyGuessInfo = REPLICATE(guess_info,1)
    EmptyConstInfo = REPLICATE(const_info,1)
    Clear_Flag = 0
    o_xmax = 0
    o_xmax2 = 0
    o_xmax3 = 0

    maxpoints = 18000
    point_index = fltarr(maxpoints)
    middle_point_index = fltarr(maxpoints)
    bottom_point_index = fltarr(maxpoints)
    linked_param = intarr(999)
    middle_linked_param = intarr(maxpoints)
    bottom_linked_param = intarr(maxpoints)
    color_struct = {c_struct, creal:15, cimag:15, offset:0.0, thick:1.0}
    original_data = complexarr(maxpoints)
    middle_original_data = complexarr(maxpoints)
    bottom_original_data = complexarr(maxpoints)
    time_data_points = complexarr(4, maxpoints)
    middle_time_data_points = complexarr(999,maxpoints)
    bottom_time_data_points = complexarr(4,maxpoints)
    plot_color = REPLICATE(color_struct, 999)
    middle_plot_color = REPLICATE(color_struct, 999)
    bottom_plot_color = REPLICATE(color_struct, 999)
    comp_time_data_points = complexarr(4, maxpoints)
    middle_comp_time_data_points = complexarr(999,maxpoints)
    bottom_comp_time_data_points = complexarr(3,maxpoints)
    freq_data_points = complexarr(4, maxpoints)
    middle_freq_data_points = complexarr(999, maxpoints)
    bottom_freq_data_points = complexarr(4, maxpoints)
    guess_variables_structure = {gvar_struct, name:'', gvalue:0.0}
    guess_variables = REPLICATE(guess_variables_structure, 200)
    middle_guess_variables = REPLICATE(guess_variables_structure, 200)
    bottom_guess_variables = REPLICATE(guess_variables_structure, 200)
    const_variables_structure = {cvar_struct, name:'', gvalue:0.0, first_occur:0}
    const_variables = REPLICATE(const_variables_structure, 100)
    middle_const_variables = REPLICATE(const_variables_structure, 100)

    bottom_const_variables = REPLICATE(const_variables_structure, 100)
    paramit_struct = {param_struct, pvalue:0.0, modifier:0.0, linked:0, var_base:0.0, const_name:''}
    peak = REPLICATE(paramit_struct, 7, 999)
    middle_peak = REPLICATE(paramit_struct, 7, 999)
    bottom_peak = REPLICATE(paramit_struct, 7, 999)

    Scale_Flag = 0
    mz_cursor_active=0
    window_flag =1
    print_flag = 0
    error_flag = 0
    undo_array = fltarr(3,4)

    print, 'Operating system ID = ', !d.name
    IF (!d.name EQ 'X') THEN defaultpath ='~/Fitman'
    IF (!d.name EQ 'X') THEN hlsvdpath ='~/'
    IF (!d.name EQ 'X') THEN defaultPrinter='lpr'

    IF (!d.name EQ 'WIN') THEN defaultpath ='.'
    IF (!d.name EQ 'WIN') THEN hlsvdpath ='.'
    IF (!d.name EQ 'WIN') THEN defaultPrinter='lpt1'


    ; Load in a standard color table to use for plotting lines.  If in Unix, we must do instructions
    ; to get colors to work.

    IF (!d.name EQ 'X') THEN BEGIN
       ;device,retain=2,pseudo=8         ; 8 bit display with backing store
        
       ;changed by jd, May 7, 2009
       device,retain=2,Decomposed=0,TRUE_COLOR=24
       
       ;device,retain=2,Decomposed=0,TRUE_COLOR=16 ; Reduced from 24 to 16 so that .SAV file runs with proper colours
       
       window,/free,/pixmap,colors=-5  ; Create window to allocate colors
       plot,[0]                         ; Might not be needed, but won't hurt
       wdelete,!d.window                ; Delete the window
       device,set_character_size=[6,9]  ; Set the vector font size
       print, 'Number of colors allocated is ', !d.n_colors
    ENDIF

    ; Define our own color table since loatct can create problems.
    ; 3 color tables have to be defined.  1 for each window.

     IF (!D.name EQ 'X') THEN BEGIN
       Red = intarr(9)
       Green = intarr(9)
     Blue = intarr(9)
     Red =   [0, 0,   255, 255, 30,  255, 100, 238, 205]
     Green = [0, 255, 255, 255, 144, 0,   100, 233, 201]
     Blue =  [0, 127, 255, 0,   255, 0,   100, 233, 201]

       TVLCT, Red,Green, Blue

       ;Open and load configuration file.
     ;Get the default pathname.
        name = "Fitman.cfg"
     openr, unit, name, /GET_LUN ;opens data file

     ;Read header information
       readf, unit, defaultpath
     CLOSE, unit
     FREE_LUN, unit

       ; Get default printer.
       name = "Printer.cfg"
       openr, unit, name, /GET_LUN

                ; Read info
       readf, unit, defaultPrinter
       CLOSE, unit
       FREE_LUN, unit

                name = "Fitman2.cfg"
     openr, unit, name, /GET_LUN ;opens data file
       readf, unit, hlsvdpath
     CLOSE, unit
     FREE_LUN, unit
    ENDIF

    IF (!D.Name EQ 'MAC') THEN LOADCT, 39

    IF (!d.name EQ 'WIN') THEN BEGIN
        ;device,retain=2                ; display with backing store
        device,retain=2,Decomposed=0     ; Reduced from 24 to 16 so that .SAV file runs with proper colours
        window,/free,/pixmap,colors=-5   ; Create window to allocate colors
        plot,[0]                         ; Might not be needed, but won't hurt
        wdelete,!d.window                ; Delete the window
        device,set_character_size=[4.5,7]    ; Set the vector font size
        print, 'Number of colors allocated is ', !d.n_colors


        ; Define our own color table since loatct can create problems.
        ; 3 color tables have to be defined.  1 for each window.
        Red = intarr(9)
        Green = intarr(9)
        Blue = intarr(9)
        Red =   [0, 0,   255, 255, 30,  255, 100, 238, 205]
        Green = [0, 255, 255, 255, 144, 0,   100, 233, 201]
        Blue =  [0, 127, 255, 0,   255, 0,   100, 233, 201]

        TVLCT, Red,Green, Blue

        ;Open and load configuration file.
        ;Get the default pathname.
        name = "Fitman.cfg"
        openr, unit, name, /GET_LUN ;opens data file

        ;Read header information
        readf, unit, defaultpath
        CLOSE, unit
        FREE_LUN, unit

        ; Get default printer.
        name = "Printer.cfg"
        openr, unit, name, /GET_LUN

        ; Read info
        readf, unit, defaultPrinter
        CLOSE, unit
        FREE_LUN, unit

        name = "Fitman2.cfg"
        openr, unit, name, /GET_LUN ;opens data file
        readf, unit, hlsvdpath
        CLOSE, unit
        FREE_LUN, unit
    ENDIF



    ;Widget_base creates the window in which you can place other widgets
    ;such as a drawing window, buttons, sliders, etc.

        Device, GET_SCREEN_SIZE=scrSize

        xscr = scrSize[0]
    IF (xscr GT 1500) THEN xscr = xscr/2
        yscr = scrSize[1]

        if(float(xscr) ne 1280 and float(yscr) ne 1024) then begin
           pixelOffset = 0
        endif else begin
           pixelOffset = 0
        endelse

        xScale = (float(xscr)+pixelOffset)/float(1280)
        yScale = (float(yscr)+pixelOffset)/float(1024)

        windowSizes = INTARR(3,6)

        for i = 0, 2 do begin
          windowSizes[i,0]=812*xScale
          windowSizes[i,1]=812*xScale
          windowSizes[i,2]=406;*yScale
          windowSizes[i,4]=270;*yScale
          if(i ne 1) then begin
             windowSizes[i,3] = 270;*yScale
             windowSizes[i,5] = 203;*yScale
          endif
        endfor

        windowSizes[1,3] = 540;*yScale
        windowSizes[1,5] = 406;*yScale

        winSize = INTARR(3,6)

        for i = 0, 2 do begin
           for j = 0, 5 do begin
             winSize[i,j] = windowSizes[i,j]
           endfor
        endfor

    MAIN1 = WIDGET_BASE(COLUMN=2, MAP=1, TITLE='fitMAN Suite v1.7.1', UVALUE='MAIN1', MBAR=bar, $
    /TLB_SIZE_EVENTS)
    status = WIDGET_LABEL(MAIN1, VALUE = '', /DYNAMIC_RESIZE)

    BASE2 = WIDGET_BASE ( MAIN1, COLUMN=1, MAP=1, SPACE=1, UVALUE='BASE3', EVENT_PRO = 'OPEN_EV',SCR_YSIZE=832*yScale,$
                            /SCROLL,X_SCROLL_SIZE=208*xScale)
        DRAWBASE = WIDGET_BASE (MAIN1, ROW=4, MAP=1, SPACE=1, UVALUE='DRAWBASE')


    ;Create a drawing window to display images or spectra or pretty pictures.
    ;We allow different hieghts depending on the OS used.

        sizeX = 820*xScale
        sizeBTY = 270*yScale
        sizeMY = 270*yScale

        ;sizeBTY = 203*xScale
        ;sizeMY = 406*xScale

    IF ( !d.name EQ 'X') THEN BEGIN
       TOP_DRAW = WIDGET_DRAW(DRAWBASE, RETAIN=1, UVALUE='DRAW1', XSIZE=sizeX, YSIZE =sizeBTY , $
         /BUTTON_EVENTS, /MOTION_EVENTS, EVENT_PRO = 'MOUSE_EV')

                ;middle_base = widget_base(DRAWBASE,COL=2)
     MIDDLE_DRAW = WIDGET_DRAW(DRAWBASE, RETAIN=1, UVALUE='DRAW2', XSIZE=sizeX, YSIZE=sizeMY, $
         /BUTTON_EVENTS, /MOTION_EVENTS, EVENT_PRO = 'MOUSE_EV2')
                ;compBase2 = widget_base(middle_base,/NONEXCLUSIVE)

     BOTTOM_DRAW = WIDGET_DRAW( DRAWBASE, RETAIN=1, UVALUE='DRAW3', XSIZE=sizeX, YSIZE=sizeBTY, $
         /BUTTON_EVENTS, /MOTION_EVENTS, EVENT_PRO = 'MOUSE_EV3')
    ENDIF ELSE BEGIN
       TOP_DRAW = WIDGET_DRAW( DRAWBASE, RETAIN=1, UVALUE='DRAW1', XSIZE=820, YSIZE=220, $
         /BUTTON_EVENTS, /MOTION_EVENTS, EVENT_PRO = 'MOUSE_EV')
     MIDDLE_DRAW = WIDGET_DRAW( DRAWBASE, RETAIN=1, UVALUE='DRAW2', XSIZE=820, YSIZE=310, $
         /BUTTON_EVENTS, /MOTION_EVENTS, EVENT_PRO = 'MOUSE_EV2')
     BOTTOM_DRAW = WIDGET_DRAW( DRAWBASE, RETAIN=1, UVALUE='DRAW3', XSIZE=820, YSIZE=220, $
         /BUTTON_EVENTS, /MOTION_EVENTS, EVENT_PRO = 'MOUSE_EV3')
    ENDELSE


    ;Create a Menu item to load in data
    menu1 = WIDGET_BUTTON(bar, VALUE='File', /MENU)
    button1 = WIDGET_BUTTON(menu1, VALUE='Data', UVALUE='DATA', EVENT_PRO = 'EV_DATA')
    delFileButton = WIDGET_BUTTON(menu1,VALUE="Delete File",EVENT_PRO = 'EV_DELFILE')
    import_data = WIDGET_BUTTON(menu1, VALUE='Import Data', /MENU)
    import_supp = WIDGET_BUTTON(import_data, VALUE='Import Suppressed Data', UVALUE='SUPP', EVENT_PRO = 'EV_CONVERT')
    import_unsupp = WIDGET_BUTTON(import_data, VALUE='Import Unsuppressed Data', UVALUE='UNSUPP', EVENT_PRO = 'EV_CONVERT')
    button2 = WIDGET_BUTTON(menu1, VALUE='Guess', UVALUE='GUESS', EVENT_PRO = 'EV_GUESS')
    reload_guess_button = WIDGET_BUTTON(menu1, VALUE='Reload Guess File', EVENT_PRO = 'EV_RGUESS')
    reload_const_button = WIDGET_BUTTON(menu1, VALUE='Reload Constraint File', EVENT_PRO = 'EV_RCONST')
    make_guess_button = WIDGET_BUTTON(menu1, VALUE='Make Guess File', EVENT_PRO = 'MAKEGUESS')
    button3 = WIDGET_BUTTON(menu1, VALUE='Constraints', UVALUE='CONST', EVENT_PRO = 'EV_CONST')
    button4 = WIDGET_BUTTON(menu1, VALUE='Output', UVALUE='OUT', EVENT_PRO = 'EV_OUT')
    reload_output = WIDGET_BUTTON(menu1,VALUE='Reload Output File',EVENT_PRO = 'EV_OUT_RELOAD')
    fit_button = WIDGET_BUTTON(menu1, VALUE='Generate Fit', UVALUE='GEN_FIT', EVENT_PRO = 'EV_FIT')
    save_button = WIDGET_BUTTON(menu1, VALUE='Save Active Window', UVALUE='SAVE',/SEPARATOR, $
             EVENT_PRO = 'EV_SAVE')
    imgSaveButton = widget_button(menu1,VALUE='Save Window to Image File',EVENT_PRO='EV_SVIMG')
    print_button = WIDGET_BUTTON(menu1, VALUE='Print Graphs', UVALUE='PRINT', EVENT_PRO='EV_PRINT')
    convert_button = WIDGET_BUTTON(menu1, VALUE='Convert raw data', UVALUE='CONVERT', $
             EVENT_PRO='EV_CONVERT')
    ;*********adding CSI convert function by Alex Li on Nov 14, 2005******************
    convert_buttoncsi = WIDGET_BUTTON(menu1, VALUE='Convert CSI raw data', UVALUE='CONVERTCSI', $
       EVENT_PRO='EV_CONVERTCSI')
    ;******end of convert_buttoncsi******************
    button5 = WIDGET_BUTTON(menu1, VALUE='Exit Fitman GUI', UVALUE='EXIT', /SEPARATOR, $
               EVENT_PRO = 'EV_EXIT')

    ;Create a Menu item to allow the viewing of data in the Time of Frequency Domains
    menu2 = WIDGET_BUTTON(bar, VALUE='Domain', /MENU)
    button5 = WIDGET_BUTTON(menu2, VALUE='Time', UVALUE='TIME', EVENT_PRO = 'EV_TIME')
    button6 = WIDGET_BUTTON(menu2, VALUE='Frequency', UVALUE='FREQUENCY', EVENT_PRO = 'EV_FREQUENCY')

    ;Create a Menu item to allow vieing of the Real or imaginary components of the points
    menu3 = WIDGET_BUTTON(bar, VALUE='Components', /MENU)
    button7 = WIDGET_BUTTON(menu3, VALUE='Real', UVALUE='REAL', EVENT_PRO='EV_REAL')
    button8 = WIDGET_BUTTON(menu3, VALUE='Imaginary', UVALUE='IMAGINARY', EVENT_PRO='EV_IMAG')
    button9 = WIDGET_BUTTON(menu3, VALUE='Real And Imaginary', UVALUE='BOTH', EVENT_PRO='EV_BOTH')
        buttonM = widget_button(menu3, VALUE='Magnitude',UVALUE='MAG',EVENT_PRO='EV_showMag')
        buttonP = widget_button(menu3,VALUE='Phase',UVALUE='PHASE',EVENT_PRO='EV_showPhase')

    ;Create a Menu item to allow the viewing of reaDisp
    menu4 = WIDGET_BUTTON(bar, VALUE='Display', /MENU)
    button10 = WIDGET_BUTTON(menu4, VALUE='Acquired Data', UVALUE='DISPLAY_DATA', $
       EVENT_PRO = 'EV_DISPLAY_DATA')
    button11 = WIDGET_BUTTON(menu4, VALUE='Reconstruction', UVALUE='DISPLAY_RECON', $
       EVENT_PRO = 'EV_DISPLAY_RECON')
    button12 = WIDGET_BUTTON(menu4, VALUE='Residual', UVALUE='DISPLAY_RESIDUAL', $
       EVENT_PRO = 'EV_DISPLAY_RESIDUAL')
    button13 = WIDGET_BUTTON(menu4, VALUE='Data & Reconstruction', UVALUE='DISPLAY_BOTH', $
       EVENT_PRO = 'EV_DISPLAY_BOTH')
    button14 = WIDGET_BUTTON(menu4, VALUE='Data & Reconstruction & Residual ', UVALUE='DISPLAY_THRE',$
        EVENT_PRO = 'EV_DISPLAY_THREE')
    button15 = WIDGET_BUTTON(menu4, VALUE='Data & Reconstruction & Residual & Components ', $
       UVALUE='DISPLAY_FOUR', EVENT_PRO = 'EV_DISPLAY_FOUR')

    ;Create a Menu item to allow the grouping of components for display purposes
    menu5 = WIDGET_BUTTON(bar, VALUE='Group', /MENU)
    button16 = WIDGET_BUTTON(menu5, VALUE='None', UVALUE='G_NONE', EVENT_PRO = 'EV_G_NONE')
    button17 = WIDGET_BUTTON(menu5, VALUE='By Shift', UVALUE='G_SHIFT', EVENT_PRO = 'EV_G_SHIFT')
    button18 = WIDGET_BUTTON(menu5, VALUE='By Exponential Damping', UVALUE='G_EXPON', $
       EVENT_PRO = 'EV_G_EXPON')
    button19 = WIDGET_BUTTON(menu5, VALUE='By Amplitude', UVALUE='G_AMP', EVENT_PRO = 'EV_G_AMP')
    button20 = WIDGET_BUTTON(menu5, VALUE='By Phase', UVALUE='G_PHASE', EVENT_PRO = 'EV_G_PHASE')
    button21 = WIDGET_BUTTON(menu5, VALUE='By Delay Time', UVALUE='G_DELAY', EVENT_PRO = 'EV_G_DELAY')
    button22 = WIDGET_BUTTON(menu5, VALUE='By Gaussian Damping', UVALUE='G_GAUSS', $
       EVENT_PRO = 'EV_G_GAUSS')

    ;Create a Menu item to change the manner is which data is viewed for papers
    menu6 = WIDGET_BUTTON(bar, VALUE='View', /MENU)
    button23 = WIDGET_BUTTON(menu6, VALUE='Colour', UVALUE='VIEW_NORMAL', EVENT_PRO = 'EV_VIEW_NORMAL')
    button24 = WIDGET_BUTTON(menu6, VALUE='Black and White', UVALUE='VIEW_PAPER', $
       EVENT_PRO = 'EV_VIEW_PAPER')
        buttonVP = widget_button(menu6,VALUE='Color: White Background',EVENT_PRO='EV_VIEW_PAPER_NORMAL')
        ;component selector 04/26/02
        button27 = widget_button(menu6,VALUE='Component Selector',EVENT_PRO='EV_CompSelect')
    offsetButton = WIDGET_BUTTON(menu6, VALUE='Offset Modification', EVENT_PRO = 'EV_OFFSET')
        resetOffsetButton = WIDGET_BUTTON(menu6, VALUE='Reset Offset Modification', EVENT_PRO = 'EV_OFFSET_RESET')
    ;extrapButton = WIDGET_BUTTON(menu6,VALUE='Data Extrapolation to Time 0',EVENT_PRO='EV_EXTRAP')
        multispecButton = WIDGET_BUTTON(menu6,VALUE='Mult-Spectrum Viewer',EVENT_PRO='EV_MutliSpecViewer')
        clearButton = WIDGET_BUTTON(menu6, VALUE='Clear Window', UVALUE='CLEAR', EVENT_PRO='EV_CLEAR',$
       /SEPARATOR)
        clearAllButton = WIDGET_BUTTON(menu6, VALUE='Clear All Windows', UVALUE='CLEARALL', EVENT_PRO='EV_CLEAR_ALL')


    ; Create a Menu item to set the mode in which we can modify the subtraction
    modeMenu = WIDGET_BUTTON(bar, VALUE="Arithmetic", /MENU)
    auto_button = WIDGET_BUTTON(modeMenu, VALUE='Subtract: Auto-Scale', UVALUE = 'SCALING_MODE', $
          EVENT_PRO = 'EV_SCALING')
    calc_SF_button = WIDGET_BUTTON(modeMenu, VALUE='Subtract: Calculate Scale Factor', UVALUE = 'ORIG_MODE', $
            EVENT_PRO = 'EV_CALC_ORIG_SCALING')
    orig_SF_button = WIDGET_BUTTON(modeMenu, VALUE='Subtract: Use Saved Scale Factor', UVALUE = 'SAVED_MODE', $
            EVENT_PRO = 'EV_SUB_SAVED_SCALING')
    manual_button = WIDGET_BUTTON(modeMenu, VALUE='Subtract: Manual/No Scale', UVALUE="SUBTRACT", $
            EVENT_PRO = 'EV_SUBTRACT')
    add_button = widget_button(modeMenu, VALUE='Add: Manual/No Scale', UVALUE='ADD',$
                EVENT_PRO='EV_ADD', /SEPARATOR)
    align_button = widget_button(modeMenu, VALUE='Add: Manual Align', UVALUE='ALIGN',$
                     EVENT_PRO='EV_ALIGN')
    align_button2 = widget_button(modeMenu, VALUE='Add: Automatic Align', UVALUE='ALIGN_AUTO',$
                     EVENT_PRO='EV_ALIGN_AUTO')
    fit_sub_button = WIDGET_BUTTON(modeMenu, VALUE='HSVD Fit', UVALUE="FITSUB", $
           EVENT_PRO = 'EV_FITSUB', /SEPARATOR)
    remove_button = WIDGET_BUTTON(modeMenu, VALUE='HSVD Water Removal', UVALUE='REMOVE', $
       EVENT_PRO='EV_FITSUB')


    ;Create a menu to select modifications on selecting various statistical info about the graph.
    statsMenu = WIDGET_BUTTON(bar, VALUE='Statistics', /MENU)
    stddev_button = WIDGET_BUTTON(statsMenu, VALUE ='Standard Deviation', EVENT_PRO='EV_STDDEV')

    ; Create a new Menu for options
    optionsMenu = WIDGET_BUTTON(bar, VALUE='Options', /MENU)
    default_dir = WIDGET_BUTTON(optionsMenu, VALUE='Set Default Directory', EVENT_PRO = 'EV_SETDIR')
    default_ptr = WIDGET_BUTTON(optionsMenu, VALUE='Set Default Printer', EVENT_PRO = 'EV_SETPTR')
    ; new button added 04/29/02
    ;removed 11/16/05 - routine implemented in idl.  No need for external files
    ;default_hlsvd = widget_button(optionsMenu,VALUE='Set Default HLSVD Directory',EVENT_PRO='EV_setHLSVDPath')

    ;Create a Menu item to change the x-axis from Hz to PPM
    menu7 = WIDGET_BUTTON(bar, VALUE='Units', /MENU)
    button25 = WIDGET_BUTTON(menu7, VALUE='Hertz', UVALUE='X_AXIS_HZ', EVENT_PRO = 'EV_X_AXIS_HZ')
    button26 = WIDGET_BUTTON(menu7, VALUE='PPM', UVALUE='X_AXIS_PPM', EVENT_PRO = 'EV_X_AXIS_PPM')

    ;Create a menu to perform multiple simulations on a particular graph of choice.
    simulationMenu = WIDGET_BUTTON(bar, VALUE='Simulations', /MENU)
    noise_button = WIDGET_BUTTON(simulationMenu, VALUE ='Characterize Noise', EVENT_PRO='EV_NOISE')
    create_noise = WIDGET_BUTTON(simulationMenu, VALUE = 'Run Noise Simulations', EVENT_PRO='EV_SIMULATE')

    ; Create a menu for misc tools
    toolsMenu = WIDGET_BUTTON(bar, VALUE='Tools', /MENU)
    tools_sigGen = WIDGET_BUTTON(toolsMenu, VALUE='Signal generator', /MENU)
    tools_Lorent = WIDGET_BUTTON(tools_sigGEN, VALUE='Lorentzian lineshape', EVENT_PRO = 'EV_LORENTZIAN')

    ; Create a new Help for help
    helpMenu = WIDGET_BUTTON(bar, VALUE='Help', /MENU)
    help_about = WIDGET_BUTTON(helpMenu, VALUE='About', EVENT_PRO = 'HELP_ABOUT_EVENT')



    WIDGET_CONTROL, create_noise, SENSITIVE=0
    menu8=0
        ;menu8 = widget_button(bar,VALUE='Help',/MENU)
        ;button28 = widget_button(menu8,VALUE='About FitmanGUI 2000')
        ;button29 = widget_button(menu8,VALUE='Fitman Help Topics',EVENT_PRO='EV_HELP')

        btnsizeX = 8*xScale

    ;Create buttons to set the x and y range of plotted data
        datBase = widget_base(BASE2,ROW=2)
    Y_MIN = CW_Field( BASE2, TITLE = 'Y Min', UVALUE='YMIN', VALUE = plot_info.time_ymin, /FLOATING, $
       /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)
    Y_MAX = CW_Field( BASE2, TITLE = 'Y Max', UVALUE='YMAX', VALUE = plot_info.time_ymax, /FLOATING, $
       /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)
    X_MIN = CW_Field( BASE2, TITLE = 'X Min', UVALUE='XMIN', VALUE = plot_info.time_xmin, /FLOATING, $
       /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)
    X_MAX = CW_Field( BASE2, TITLE = 'X Max', UVALUE='XMAX', VALUE = plot_info.time_xmax, /FLOATING, $
       /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)

        btnbase = widget_base(BASE2,ROW=2)

    X_SCALE_BUTTON = WIDGET_BUTTON(BASE2, VALUE = 'Auto Scale X', UVALUE = 'X_AUTO_SCALE', /FRAME, $
       EVENT_PRO = 'EV_X_AUTO_SCALE')
    Y_SCALE_BUTTON = WIDGET_BUTTON(BASE2, VALUE = 'Auto Scale Y', UVALUE = 'Y_AUTO_SCALE', /FRAME, $
       EVENT_PRO = 'EV_Y_AUTO_SCALE')
    ZOOM_OUT = WIDGET_BUTTON (BASE2, VALUE = ' Zoom out', UVALUE='ZOOM_ZOOM', /FRAME, $
       EVENT_PRO = 'EV_ZOOM_OUT')
    UNDO = WIDGET_BUTTON (BASE2, VALUE = 'Undo', UVALUE='UNDO', /FRAME, EVENT_PRO = 'EV_UNDO')

        fftBase = widget_base(BASE2,ROW=2)

    INITIAL = CW_Field( BASE2, TITLE = 'FT1 (s)', UVALUE='FFT_INITIAL', VALUE = plot_info.fft_initial,$
       /FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)
    FINAL = CW_Field( BASE2, TITLE = 'FT2 (s)', UVALUE='FFT_FINAL', VALUE = plot_info.fft_final, $
       /FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)
    EXPON_FILTER = CW_Field( BASE2, TITLE = 'EF (Hz)', UVALUE='E_FILTER', VALUE = plot_info.fft_final,$
       /FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)
    GAUSS_FILTER = CW_Field( BASE2, TITLE = 'GF (Hz)', UVALUE='G_FILTER', VALUE = plot_info.fft_final, $
       /FLOATING, /RETURN_EVENTS, XSIZE=btnsizeX, /FRAME)
    PHASE_SLIDER = CW_FSLIDER(BASE2, TITLE = 'Phase (Degrees)', /DRAG, UVALUE = 'PH_SLIDER', $
       VALUE = plot_info.phase, MAXIMUM = 360.0, MINIMUM = -360, /FRAME, /EDIT)

    C_CURVE = CW_Field( BASE2, TITLE = 'Curve', UVALUE='CCURVE', VALUE = plot_info.current_curve, $
       /INTEGER, /RETURN_EVENTS, XSIZE=4, /FRAME)
    CURVE_OFF = CW_FSLIDER(BASE2, TITLE = 'Curve Offset (%)', /DRAG, UVALUE = 'CURVE_O', VALUE = 0, $
                MAXIMUM = 50.0, MINIMUM = -50, /FRAME, /EDIT)
    SCALING_SLIDER = CW_FSLIDER(BASE2, TITLE = 'Scaling Factor', /DRAG, UVALUE = 'SCALE', VALUE = 1.0, $
       MAXIMUM = 5.0, MINIMUM = -5.0, /FRAME, /EDIT)
    LABEL_ZOOM = WIDGET_LABEL(Base2, VALUE='All Window Zoom')
    ZOOM_CURSOR_BASE = WIDGET_BASE(BASE2,/EXCLUSIVE, /ROW, /FRAME)
    MZ_CUR_ON = WIDGET_BUTTON(ZOOM_CURSOR_BASE, VALUE = 'ON', EVENT_PRO = 'EV_MZ_CUR_ON')
    MZ_CUR_OFF = WIDGET_BUTTON(ZOOM_CURSOR_BASE, VALUE = 'OFF', EVENT_PRO = 'EV_MZ_CUR_OFF')

        extrapButton= CW_BGROUP(BASE2,['Extrap 0'],/NONEXCLUSIVE,/ROW,/FRAME,$
                                UVALUE='extrap')
        WIDGET_CONTROL,extrapButton,SET_VALUE=[1]

        LABEL_PHASE = WIDGET_LABEL(Base2, VALUE='All Window Phase')
        PHASE_BASE = WIDGET_BASE(BASE2,/EXCLUSIVE,/ROW,/FRAME)
        phaseOn = WIDGET_BUTTON(PHASE_BASE, VALUE = 'On', EVENT_PRO = 'EV_MULPAHSE',UVALUE='ON')
        phaseOff = WIDGET_BUTTON(PHASE_BASE, VALUE = 'Off', EVENT_PRO = 'EV_MULPAHSE',UVALUE='OFF')

        bBase = widget_base(DRAWBASE,COL=2)
        views = CW_BGROUP(bBASE,['Top View','Middle View','Bottom View'],/NONEXCLUSIVE,/ROW,/FRAME,$
                          UVALUE='views')
        compBase = widget_base(bBase,/NONEXCLUSIVE)

        WIDGET_CONTROL,views,SET_VALUE=[1,1,1]


    setComponents,/DISABLE
        WIDGET_CONTROL,reload_guess_button,SENSITIVE=0
        WIDGET_CONTROL,reload_const_button,SENSITIVE=0

    IF (!D.Name EQ 'MAC') THEN BEGIN
       ; Destroy ability to use various functions due to the fact they call UNIX commands.
       WIDGET_CONTROL, Fit_Button, Sensitive = 0
       WIDGET_CONTROL, Fit_Sub_button, Sensitive = 0
       WIDGET_CONTROL, Convert_button, Sensitive = 0
       WIDGET_CONTROL, Remove_button, Sensitive = 0
    ENDIF

    WIDGET_CONTROL, MAIN1, /REALIZE

    ;If you want to draw something in the window DRAW1, you must tell the computer
    ;that the widget is there and that it should draw the value "DRAW1_Id" in that window.

    WIDGET_CONTROL, TOP_DRAW, GET_VALUE=DRAW1_Id
    WIDGET_CONTROL, MIDDLE_DRAW, GET_VALUE=DRAW2_Id
    WIDGET_CONTROL, BOTTOM_DRAW, GET_VALUE=DRAW3_Id
    ; Create a structure of data for the application

    ;u = obj_new('Stack')

    state = {status:status,views:views}

    ; Create a pointer to the state structure and put that pointer into the uvalue
    ; of the top level base

    pstate = ptr_new(state, /NO_COPY)
    widget_control, main1, SET_UVALUE = pstate

    WSET, DRAW2_ID
    Window_Flag = 2
    XMANAGER, 'FITMAN', MAIN1 ;, EVENT_HANDLER='DEMO_EVENT'

    RETALL   ;frees all variables, memory, etc. before exitting the program.

END



;=======================================================================================================;
pro EV_MULPAHSE,event
   COMMON common_widgets

   WIDGET_CONTROL,event.id,GET_UVALUE=uval

   case uval of
    'ON': begin
       mulPhase = 1
         end
        'OFF': begin
           mulPhase = 0
         end
   endcase
end


;=======================================================================================================;
pro componentButton,ADD=a,REMOVE=rem
   COMMON common_widgets
   COMMON common_vars

   if(keyword_set(a)) then begin
      compButton = widget_button(compBase,VALUE="No Offset",EVENT_PRO="EV_COMP_OFFSET")
   endif else if(keyword_set(rem)) then begin
      if(middle_plot_info.last_trace ge 3) then begin
        WIDGET_CONTROL,compButton,/DESTROY
      endif
   endif

end



;=======================================================================================================;
pro EV_COMP_OFFSET,event
   COMMON common_vars
   COMMON common_widgets
   COMMON draw1_comm

   noOffset = not(noOffset)

   prevDrawID = draw2_id

   case (Window_Flag) of
      1: prevDrawID = draw1_id
      2: prevDrawID = draw2_id
      3: prevDrawID = draw3_id
   endcase

   noResize = 1
   prevWinFlag = Window_Flag

   Window_Flag = 1
   wset,draw1_id
   DISPLAY_DATA

   Window_Flag = 2
   wset,draw2_id
   MIDDLE_DISPLAY_DATA

   Window_Flag = 3
   wset,draw3_id
   BOTTOM_DISPLAY_DATA

   Window_Flag = prevWinFlag
   wset,prevDrawID

   noResize = 0

end



;=======================================================================================================;
function isView,ONE=un,TWO=deux,THREE=trois
   COMMON common_widgets
   isv = 0
   count = 0

   WIDGET_CONTROL,views,GET_VALUE=values

   count = n_elements(where(values eq 1))

   if(keyword_set(un))then begin
      isv = count eq 1
   endif else if(keyword_set(deux))then begin
      isv = count eq 2
   endif else if(keyword_set(trois))then begin
      isv = count eq 3
   endif

   return, isv
end



;=======================================================================================================;
function getViewIndex
   COMMON common_vars
   vindex = 0
   pone = 0

   if(middle_plot_info.last_trace ge 3)then begin
     pone = 1
   endif

   if(isView(/ONE)) then begin
      vindex = pone
   endif else if(isView(/TWO))then begin
      vindex = 2 + pone
   endif else if(isView(/THREE)) then begin
      vindex = 4 + pone
   endif

   return, vindex
end



;=======================================================================================================;
pro FITMAN_EVENT, event
   COMMON common_vars
   COMMON common_widgets
   COMMON draw1_comm

   WIDGET_CONTROL,event.id,GET_UVALUE=uval
   WIDGET_CONTROL,views,GET_VALUE=val


   if((*uval).views ne views) then begin
      noResize = 1
      onePos = where(val eq 1)
      vindex = getViewIndex()

      for i = 0, 2 do begin
         arr = where(onePos eq i)
         if(arr[0] ne -1 ) then begin
           winSize[i,vindex] = windowSizes[i,vindex]*yScale

           if(middle_plot_info.last_trace ge 3) then begin
             winSize[i,vindex-1] = windowSizes[i,vindex-1]*yScale
           endif else begin
             winSize[i,vindex+1] = windowSizes[i,vindex+1]*yScale
           endelse
         endif else begin
           winSize[i,vindex] = 5*yScale

           if(middle_plot_info.last_trace ge 3) then begin
              winSize[i,vindex-1] = 5*yScale
           endif else begin
              winSize[i,vindex+1] = 5*yScale
           endelse
         endelse
      endfor

      if(val[0] eq 1 AND val[1] eq 0 AND val[2] eq 1 AND middle_plot_info.last_trace ge 3) then begin
        winSize[0,vindex] = 406*yScale
        winSize[2,vindex] = 406*yScale
      endif

      ; resize
      WIDGET_CONTROL,TOP_DRAW,YSIZE=winSize[0,vindex]
      WIDGET_CONTROL,MIDDLE_DRAW,YSIZE = winSize[1,vindex]
      WIDGET_CONTROL,BOTTOM_DRAW,YSIZE = winSize[2,vindex]

      ; repaint
      prevDrawID = draw2_id

      case (Window_Flag) of
         1: prevDrawID = draw1_id
         2: prevDrawID = draw2_id
         3: prevDrawID = draw3_id
      endcase

      prevWinFlag = Window_Flag

      Window_Flag = 1
      wset,draw1_id
      DISPLAY_DATA

      Window_Flag = 2
      wset,draw2_id
      MIDDLE_DISPLAY_DATA

      Window_Flag = 3
      wset,draw3_id
      BOTTOM_DISPLAY_DATA

      Window_Flag = prevWinFlag
      wset,prevDrawID

      noResize = 0
   endif else if(uval eq 'extrap') then begin
      EV_EXTRAP,event
   endif
end

;=======================================================================================================;
; Name: OPEN_EV                              
; Purpose:  This procedure is called whenever an action happens where any of the buttons are located.   
;       (Autosetting x axis, y axis, etc.                    
; Parameters:  event - the event that triggered this procedure to be called.          
; Return:  None.                                       
;=======================================================================================================;
PRO OPEN_EV, event

    COMMON common_vars
    COMMON common_widgets

    WIDGET_CONTROL, Event.Id, GET_UVALUE=Ev, /HOURGLASS

    CASE Ev OF

    'YMAX': BEGIN              ; When the YMAX label must be changed
          IF (Window_Flag EQ 1) THEN BEGIN
             IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_y = 0 ELSE $
          plot_info.freq_auto_scale_y = 0
             plot_info.fft_recalc = 1
             WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
             IF (plot_info.domain EQ 0) THEN plot_info.time_ymax = YMAX ELSE $
          plot_info.freq_ymax = YMAX
             DISPLAY_DATA
         ENDIF
         IF (Window_Flag EQ 2) THEN BEGIN
         IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_y = 0 ELSE $
          middle_plot_info.freq_auto_scale_y = 0
             middle_plot_info.fft_recalc = 1
             WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
             IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_ymax = YMAX ELSE $
          middle_plot_info.freq_ymax = YMAX
             MIDDLE_DISPLAY_DATA
         ENDIF
         IF (Window_Flag EQ 3) THEN BEGIN
         IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_y = 0 ELSE $
          bottom_plot_info.freq_auto_scale_y = 0
             bottom_plot_info.fft_recalc = 1
             WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
             IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_ymax = YMAX ELSE $
         bottom_plot_info.freq_ymax = YMAX
             BOTTOM_DISPLAY_DATA
         ENDIF
    END
    'YMIN': BEGIN              ; When the YMIN label must be changed
         IF (Window_Flag EQ 1) THEN BEGIN
             IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_y = 0 ELSE $
          plot_info.freq_auto_scale_y = 0
             plot_info.fft_recalc = 1
             WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
             IF (plot_info.domain EQ 0) THEN plot_info.time_ymin = YMIN ELSE $
          plot_info.freq_ymin = YMIN
             DISPLAY_DATA
         ENDIF
         IF (Window_Flag EQ 2) THEN BEGIN
         IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_y = 0 ELSE $
          middle_plot_info.freq_auto_scale_y = 0
                middle_plot_info.fft_recalc = 1
                WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
             IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_ymin = YMIN ELSE $
           middle_plot_info.freq_ymin = YMIN
             MIDDLE_DISPLAY_DATA
          ENDIF
         IF (Window_Flag EQ 3) THEN BEGIN
         IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_y = 0 ELSE $
          bottom_plot_info.freq_auto_scale_y = 0
             bottom_plot_info.fft_recalc = 1
             WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
             IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_ymin = YMINN ELSE $
          bottom_plot_info.freq_ymin = YMIN
             BOTTOM_DISPLAY_DATA
         ENDIF
    END
    'XMAX' : BEGIN             ; When the XMAX label must be changed
        IF (Window_Flag EQ 1) THEN BEGIN
         IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_x = 0 ELSE $
         plot_info.freq_auto_scale_x = 0
         plot_info.fft_recalc = 1
         WIDGET_CONTROL, X_MAX, GET_VALUE = XMAX
         IF (plot_info.domain EQ 0) THEN plot_info.time_xmax = XMAX ELSE plot_info.freq_xmax = XMAX
         DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN
         IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_x = 0 ELSE $
         middle_plot_info.freq_auto_scale_x = 0
         middle_plot_info.fft_recalc = 1
         WIDGET_CONTROL, X_MAX, GET_VALUE = XMAX
         IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_xmax = XMAX ELSE $
         middle_plot_info.freq_xmax = XMAX
         MIDDLE_DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN
         IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_x = 0 ELSE $
         bottom_plot_info.freq_auto_scale_x = 0
         bottom_plot_info.fft_recalc = 1
         WIDGET_CONTROL, X_MAX, GET_VALUE = XMAX
         IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_xmax = XMAX ELSE $
          bottom_plot_info.freq_xmax = XMAX
         BOTTOM_DISPLAY_DATA
        ENDIF
   END
  'XMIN' : BEGIN              ; When the XMIN label must be changed
      IF (Window_Flag EQ 1) THEN BEGIN
         IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_x = 0 ELSE $
         plot_info.freq_auto_scale_x = 0
         plot_info.fft_recalc = 1
         WIDGET_CONTROL, X_MIN, GET_VALUE = XMIN
         IF (plot_info.domain EQ 0) THEN plot_info.time_xmin = XMIN ELSE plot_info.freq_xmin = XMIN
          DISPLAY_DATA
      ENDIF
      IF (Window_Flag EQ 2) THEN BEGIN
       IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_x = 0 ELSE $
         middle_plot_info.freq_auto_scale_x = 0
         middle_plot_info.fft_recalc = 1
         WIDGET_CONTROL, X_MIN, GET_VALUE = XMIN
         IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_xmin = XMIN ELSE $
         middle_plot_info.freq_xmin = XMIN
          MIDDLE_DISPLAY_DATA
      ENDIF
      IF (Window_Flag EQ 3) THEN BEGIN
       IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_x = 0 ELSE $
         bottom_plot_info.freq_auto_scale_x = 0
         bottom_plot_info.fft_recalc = 1
         WIDGET_CONTROL, X_MIN, GET_VALUE = XMIN
         IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_xmin = XMIN ELSE $
         bottom_plot_info.freq_xmin = XMIN
          BOTTOM_DISPLAY_DATA
      ENDIF
   END
  'FFT_INITIAL' : BEGIN           ; When the FFT_INITIAL label must be changed
        IF (Window_Flag EQ 1) THEN BEGIN
          plot_info.fft_recalc = 1
         WIDGET_CONTROL, INITIAL, GET_VALUE = FFT_INITIAL
         plot_info.fft_initial = FFT_INITIAL

         GENERATE_FREQUENCY
         DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN
       middle_plot_info.fft_recalc = 1
         WIDGET_CONTROL, INITIAL, GET_VALUE = FFT_INITIAL
         middle_plot_info.fft_initial = FFT_INITIAL
print, "FFT1  in initial 1 = ", middle_plot_info.fft_initial
         GENERATE_FREQUENCY
         MIDDLE_DISPLAY_DATA
print, "FFT1  in initial 2 = ", middle_plot_info.fft_initial
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN
       bottom_plot_info.fft_recalc = 1
         WIDGET_CONTROL, INITIAL, GET_VALUE = FFT_INITIAL
         bottom_plot_info.fft_initial = FFT_INITIAL

         GENERATE_FREQUENCY
         BOTTOM_DISPLAY_DATA
        ENDIF

   END

  'FFT_FINAL' : BEGIN          ; When the FFT_FINAL label must be changed
        IF (Window_Flag EQ 1) THEN BEGIN
         plot_info.fft_recalc = 1
         WIDGET_CONTROL, FINAL, GET_VALUE = FFT_FINAL
         plot_info.fft_final = FFT_FINAL
          GENERATE_FREQUENCY
           DISPLAY_DATA
        ENDIF
    IF (Window_Flag EQ 2) THEN BEGIN
         middle_plot_info.fft_recalc = 1
         WIDGET_CONTROL, FINAL, GET_VALUE = FFT_FINAL
         middle_plot_info.fft_final = FFT_FINAL
print, middle_plot_info.fft_final
          GENERATE_FREQUENCY
           MIDDLE_DISPLAY_DATA
print, middle_plot_info.fft_final
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN
         bottom_plot_info.fft_recalc = 1
         WIDGET_CONTROL, FINAL, GET_VALUE = FFT_FINAL
         bottom_plot_info.fft_final = FFT_FINAL
          GENERATE_FREQUENCY
           BOTTOM_DISPLAY_DATA
        ENDIF
   END

  'E_FILTER' : BEGIN              ; When the exponential filter label must
    IF (Window_Flag EQ 1) THEN BEGIN     ; be updated
          plot_info.fft_recalc = 1
          WIDGET_CONTROL, EXPON_FILTER, GET_VALUE = E_FILTER
          plot_info.expon_filter = E_FILTER
       REDISPLAY
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN
          middle_plot_info.fft_recalc = 1
          WIDGET_CONTROL, EXPON_FILTER, GET_VALUE = E_FILTER
          middle_plot_info.expon_filter = E_FILTER
       REDISPLAY
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN
          bottom_plot_info.fft_recalc = 1
          WIDGET_CONTROL, EXPON_FILTER, GET_VALUE = E_FILTER
          bottom_plot_info.expon_filter = E_FILTER
       REDISPLAY
        ENDIF
   END

  'G_FILTER' : BEGIN          ; When the Gaussian Filter must be updated
        IF (Window_Flag EQ 1) THEN BEGIN
         plot_info.fft_recalc = 1
         WIDGET_CONTROL, GAUSS_FILTER, GET_VALUE = G_FILTER
         plot_info.gauss_filter = G_FILTER
         REDISPLAY
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN
         middle_plot_info.fft_recalc = 1
         WIDGET_CONTROL, GAUSS_FILTER, GET_VALUE = G_FILTER
         middle_plot_info.gauss_filter = G_FILTER
         REDISPLAY
        ENDIF
    IF (Window_Flag EQ 3) THEN BEGIN
         bottom_plot_info.fft_recalc = 1
         WIDGET_CONTROL, GAUSS_FILTER, GET_VALUE = G_FILTER
         bottom_plot_info.gauss_filter = G_FILTER
         REDISPLAY
     ENDIF

   END
  'PH_SLIDER' : BEGIN      ; When updates must be made to Phase Slider
    curr_flag = Window_Flag
    if(mulPhase) then Window_Flag = 1
    IF (Window_Flag EQ 1) THEN BEGIN
         WIDGET_CONTROL, PHASE_SLIDER, GET_VALUE = PH_SLIDER
         plot_info.phase = PH_SLIDER
         plot_info.fft_recalc = 1

         PHASE_TIME_DOMAIN_DATA
         IF (plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
         DISPLAY_DATA
    ENDIF
    if(mulPhase) then Window_Flag = 2
    IF (Window_Flag EQ 2) THEN BEGIN
         WIDGET_CONTROL, PHASE_SLIDER, GET_VALUE = PH_SLIDER
         middle_plot_info.phase = PH_SLIDER
         middle_plot_info.fft_recalc = 1

         PHASE_TIME_DOMAIN_DATA
         IF (middle_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
         MIDDLE_DISPLAY_DATA
     ENDIF
     if(mulPhase) then Window_Flag = 3
     IF (Window_Flag EQ 3) THEN BEGIN
         WIDGET_CONTROL, PHASE_SLIDER, GET_VALUE = PH_SLIDER
         bottom_plot_info.phase = PH_SLIDER
         bottom_plot_info.fft_recalc = 1

         PHASE_TIME_DOMAIN_DATA
         IF (bottom_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
         BOTTOM_DISPLAY_DATA
     ENDIF

   END
  'CCURVE' : BEGIN   ; When the curve label must be changed
        IF (Window_Flag EQ 1) THEN BEGIN
          WIDGET_CONTROL, C_CURVE, GET_VALUE = CCURVE
           current_curve = CCURVE

         ; Update display fields
         IF (current_curve LE plot_info.traces) THEN BEGIN
               plot_info.current_curve=current_curve
              UPDATE_FIELDS
         ENDIF ELSE BEGIN
               WIDGET_CONTROL, C_CURVE, SET_VALUE = plot_info.current_curve
            ENDELSE
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN
          WIDGET_CONTROL, C_CURVE, GET_VALUE = CCURVE
           current_curve = CCURVE

         ; Update display fields
         IF (current_curve LE middle_plot_info.traces) THEN BEGIN
               middle_plot_info.current_curve=current_curve
              UPDATE_FIELDS
         ENDIF ELSE BEGIN
               WIDGET_CONTROL, C_CURVE, SET_VALUE = middle_plot_info.current_curve
            ENDELSE
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN
          WIDGET_CONTROL, C_CURVE, GET_VALUE = CCURVE
           current_curve = CCURVE
        ; Update display fields
        IF (current_curve LE bottom_plot_info.traces) THEN BEGIN
            bottom_plot_info.current_curve=current_curve
            UPDATE_FIELDS
        ENDIF ELSE BEGIN
            WIDGET_CONTROL, C_CURVE, SET_VALUE = bottom_plot_info.current_curve
        ENDELSE
     ENDIF
   END

  'CURVE_O' : BEGIN          ; When the curve offset slider must be
        IF (Window_Flag EQ 1) THEN BEGIN      ; modified
          WIDGET_CONTROL, CURVE_OFF, GET_VALUE = CURVE_O
         offset = CURVE_O
         WIDGET_CONTROL, C_CURVE, GET_VALUE = CCURVE
         curve = CCURVE

         WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
         minp = ymin
         WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
         maxp = ymax

         yrange = ymax-ymin

         plot_color[curve].offset = (offset/100)*yrange
          DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN
          WIDGET_CONTROL, CURVE_OFF, GET_VALUE = CURVE_O
         offset = CURVE_O
         WIDGET_CONTROL, C_CURVE, GET_VALUE = CCURVE
         curve = CCURVE
         WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
         minp = ymin
         WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
         maxp = ymax

         yrange = ymax-ymin

         middle_plot_color[curve].offset = (offset/100)*yrange

          MIDDLE_DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN
          WIDGET_CONTROL, CURVE_OFF, GET_VALUE = CURVE_O
         offset = CURVE_O
         WIDGET_CONTROL, C_CURVE, GET_VALUE = CCURVE
         curve = CCURVE

         WIDGET_CONTROL, Y_MIN, GET_VALUE = YMIN
         minp = ymin
         WIDGET_CONTROL, Y_MAX, GET_VALUE = YMAX
         maxp = ymax
         yrange = ymax-ymin
         bottom_plot_color[curve].offset = (offset/100)*yrange

          BOTTOM_DISPLAY_DATA
        ENDIF
   END

  'extrap': begin
      EV_EXTRAP,event
   end

   ENDCASE
END

;=======================================================================================================;
; Name:  EX_V_AUTO_SCALE                              ;
; Purpose:  When a user selectsthe autoscale x axis button, the procedure will reset the x axis only,   ;
;       and re-display the data.                              ;
; Parameters:  event - The event that triggered the procedure to be called.             ;
; Return:  None.                                            ;
;=======================================================================================================;
PRO EV_X_AUTO_SCALE, event
        COMMON common_vars
        COMMON common_widgets
        IF (Window_Flag EQ 1) THEN BEGIN   ; If the top draw window is active
         plot_info.fft_recalc = 1
     IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_x = 1 ELSE $
         plot_info.freq_auto_scale_x = 1
     DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN   ; If the middle draw window is active
     middle_plot_info.fft_recalc = 1
         IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_x = 1 ELSE $
         middle_plot_info.freq_auto_scale_x = 1
            MIDDLE_DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN   ; If the bottom draw window is active
     bottom_plot_info.fft_recalc = 1
         IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_x = 1 ELSE $
         bottom_plot_info.freq_auto_scale_x = 1
            BOTTOM_DISPLAY_DATA
        ENDIF
END

;=======================================================================================================;
; Name: EV_Y_AUTO_SCALE                            ;
; Purpose:  When a user selects the autoscale y axis button, the procedure will reset the y axis only,  ;
;           and redisplay the data.                              ;
; Paramters:  event - The event that riggered the procedure to be called.          ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_Y_AUTO_SCALE, event
        COMMON common_vars
        COMMON common_widgets

        IF (Window_Flag EQ 1) THEN BEGIN   ; If the top draw window is active
         plot_info.fft_recalc = 1
         IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_y = 1 ELSE $
          plot_info.freq_auto_scale_y = 1
             DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN   ; If the middle draw window is active
          middle_plot_info.fft_recalc = 1
          IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_y = 1 ELSE $
         middle_plot_info.freq_auto_scale_y = 1
          MIDDLE_DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN   ; If the third draw window is active
          bottom_plot_info.fft_recalc = 1
          IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_y = 1 ELSE $
          bottom_plot_info.freq_auto_scale_y = 1
          BOTTOM_DISPLAY_DATA
        ENDIF
END


;=======================================================================================================;
; Name:  EV_ZOOM_OUT                             ;
; Purpose:  Called when a user selects the "Zoom Out" button.   It will redraw the active draw widget   ;
;           normally, that is, the way it appears without being zoomed in on.          ;
; Parameters:  event - The event that called this procedure.                 ;
; Return:  None.                                   ;
;=======================================================================================================;
PRO EV_ZOOM_OUT, event
        COMMON common_vars
        COMMON DRAW1_Comm


    IF (plot_info.mz_cursor_active OR middle_plot_info.mz_cursor_active OR $
       bottom_plot_info.mz_cursor_active) THEN BEGIN

       temp_window_flag = Window_Flag
       WSET, Draw1_Id
       Window_Flag=1
       plot_info.fft_recalc = 1
       IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_x = 1 ELSE $
         plot_info.freq_auto_scale_x = 1
          IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_y = 1 ELSE $
         plot_info.freq_auto_scale_y = 1
       plot_info.isZoomed = 0
       DISPLAY_DATA

       WSET, Draw2_Id
       Window_Flag=2
       middle_plot_info.fft_recalc = 1
          IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_x = 1 ELSE $
         middle_plot_info.freq_auto_scale_x = 1
          IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_y = 1 ELSE $
         middle_plot_info.freq_auto_scale_y = 1
       middle_plot_info.isZoomed = 0
       MIDDLE_DISPLAY_DATA

       WSET, Draw3_Id
       Window_Flag=3
       bottom_plot_info.fft_recalc = 1
          IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_x = 1 ELSE $
         bottom_plot_info.freq_auto_scale_x = 1
          IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_y = 1 ELSE $
         bottom_plot_info.freq_auto_scale_y = 1
       bottom_plot_info.isZoomed= 0
       BOTTOM_DISPLAY_DATA

       IF (temp_window_flag EQ 1) THEN WSET, Draw1_Id
       IF (temp_window_flag EQ 2) THEN WSET, Draw2_Id
       IF (temp_window_flag EQ 3) THEN WSET, Draw3_Id

       Window_Flag = temp_window_flag

       RETURN
    ENDIF
    ; Simply autoscale x then autoscale y.   Then redraw the scene.
    IF (Window_Flag EQ 1) THEN BEGIN
          plot_info.fft_recalc = 1
          IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_x = 1 ELSE $
         plot_info.freq_auto_scale_x = 1
          IF (plot_info.domain EQ 0) THEN plot_info.time_auto_scale_y = 1 ELSE $
         plot_info.freq_auto_scale_y = 1
       plot_info.isZoomed = 0
       DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 2) THEN BEGIN
       middle_plot_info.fft_recalc = 1
          IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_x = 1 ELSE $
         middle_plot_info.freq_auto_scale_x = 1
          IF (middle_plot_info.domain EQ 0) THEN middle_plot_info.time_auto_scale_y = 1 ELSE $
         middle_plot_info.freq_auto_scale_y = 1
       middle_plot_info.isZoomed = 0
       MIDDLE_DISPLAY_DATA
        ENDIF
        IF (Window_Flag EQ 3) THEN BEGIN
          bottom_plot_info.fft_recalc = 1
          IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_x = 1 ELSE $
         bottom_plot_info.freq_auto_scale_x = 1
          IF (bottom_plot_info.domain EQ 0) THEN bottom_plot_info.time_auto_scale_y = 1 ELSE $
         bottom_plot_info.freq_auto_scale_y = 1
       bottom_plot_info.isZoomed= 0
       BOTTOM_DISPLAY_DATA
        ENDIF
END




;=======================================================================================================;
; Name:  EV_MZ_CUR_OFF                           ;
; Purpose:  To turn on the multi zoom feature.   This will make the zoom apply to all three windows.    ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_MZ_CUR_ON, event
    COMMON common_vars
    COMMON common_widgets

    plot_info.mz_cursor_active = 1
    middle_plot_info.mz_cursor_active = 1
    bottom_plot_info.mz_cursor_active = 1
END

;=======================================================================================================;
; Name:  EV_MZ_CUR_OFF                           ;
; Purpose:  To turn off the multi zoom feature.   This will set the zoom back to a single window zoom.  ;
; Parameters:  event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_MZ_CUR_OFF, event
    COMMON common_vars
    COMMON common_widgets

     plot_info.mz_cursor_active = 0
     middle_plot_info.mz_cursor_active = 0
     bottom_plot_info.mz_cursor_active = 0
END


;=======================================================================================================;
; Name:  EV_UNDO                             ;
; Purpose:  To allow a user to undo 1 zoom.  This will allow for if the user zoomed in wrong area.      ;
;           This will undo the active window normally, unless the all window zoom is on, un which case, ;
;       it will undo the last move for all 3 windows.                 ;
; Parameters:  Event - The event which called this procedure.               ;
; Return:  None.                             ;
;=======================================================================================================;
PRO EV_UNDO, event
    COMMON common_widgets
    COMMON common_vars
    COMMON DRAW1_Comm

        WIDGET_CONTROL, event.top, GET_UVALUE = pstate

        ;u_array = (*pstate).undo->pop()

        ;help,u_array
        ;print, u_array

    ; If the All Zoom cursor is active (on) then move all prev co-ords into plot_info.
    IF (plot_info.mz_cursor_active OR middle_plot_info.mz_cursor_active OR $
       bottom_plot_info.mz_cursor_active) THEN BEGIN
       IF (plot_info.domain EQ 0) THEN BEGIN
         plot_info.time_xmin =undo_array[0,0]
         plot_info.time_xmax =undo_array[0,1]
         plot_info.time_ymin =undo_array[0,2]
         plot_info.time_ymax =undo_array[0,3]

       ENDIF
       IF (plot_info.domain EQ 1) THEN BEGIN
         plot_info.freq_xmin =undo_array[0,0]
         plot_info.freq_xmax =undo_array[0,1]
         plot_info.freq_ymin =undo_array[0,2]
         plot_info.freq_ymax =undo_array[0,3]
       ENDIF
       WSET, Draw1_Id
       Window_Flag=1
       DISPLAY_DATA

       IF (middle_plot_info.domain EQ 0) THEN BEGIN
         middle_plot_info.time_xmin =undo_array[1,0]
         middle_plot_info.time_xmax =undo_array[1,1]
         middle_plot_info.time_ymin =undo_array[1,2]
         middle_plot_info.time_ymax =undo_array[1,3]

       ENDIF
       IF (middle_plot_info.domain EQ 1) THEN BEGIN
         middle_plot_info.freq_xmin =undo_array[1,0]
         middle_plot_info.freq_xmax =undo_array[1,1]
         middle_plot_info.freq_ymin =undo_array[1,2]
         middle_plot_info.freq_ymax =undo_array[1,3]
       ENDIF
       WSET, Draw2_Id
       Window_Flag=2
       MIDDLE_DISPLAY_DATA

       IF (bottom_plot_info.domain EQ 0) THEN BEGIN
         bottom_plot_info.time_xmin =undo_array[2,0]
         bottom_plot_info.time_xmax =undo_array[2,1]
         bottom_plot_info.time_ymin =undo_array[2,2]
         bottom_plot_info.time_ymax =undo_array[2,3]
       ENDIF
       IF (bottom_plot_info.domain EQ 1) THEN BEGIN
         bottom_plot_info.freq_xmin =undo_array[2,0]
         bottom_plot_info.freq_xmax =undo_array[2,1]
         bottom_plot_info.freq_ymin =undo_array[2,2]
         bottom_plot_info.freq_ymax =undo_array[2,3]
       ENDIF
       WSET, Draw3_Id
       Window_Flag=3
       BOTTOM_DISPLAY_DATA
    ; Otherwise, set the previous co-ord for the active window only.
    ENDIF ELSE BEGIN
       IF (Window_Flag EQ 1) THEN BEGIN
         IF (plot_info.domain EQ 0) THEN BEGIN
          plot_info.time_xmin =undo_array[0,0]
          plot_info.time_xmax =undo_array[0,1]
          plot_info.time_ymin =undo_array[0,2]
          plot_info.time_ymax =undo_array[0,3]
         ENDIF
         IF (plot_info.domain EQ 1) THEN BEGIN
          plot_info.freq_xmin =undo_array[0,0]
          plot_info.freq_xmax =undo_array[0,1]
          plot_info.freq_ymin =undo_array[0,2]
          plot_info.freq_ymax =undo_array[0,3]
         ENDIF
         DISPLAY_DATA
       ENDIF
       IF (Window_Flag EQ 2) THEN BEGIN
         IF (middle_plot_info.domain EQ 0) THEN BEGIN
          middle_plot_info.time_xmin =undo_array[1,0]
          middle_plot_info.time_xmax =undo_array[1,1]
          middle_plot_info.time_ymin =undo_array[1,2]
          middle_plot_info.time_ymax =undo_array[1,3]
         ENDIF
         IF (middle_plot_info.domain EQ 1) THEN BEGIN
          middle_plot_info.freq_xmin =undo_array[1,0]
          middle_plot_info.freq_xmax =undo_array[1,1]
          middle_plot_info.freq_ymin =undo_array[1,2]
          middle_plot_info.freq_ymax =undo_array[1,3]
         ENDIF
         MIDDLE_DISPLAY_DATA
       ENDIF
       IF (Window_Flag EQ 3) THEN BEGIN
         IF (bottom_plot_info.domain EQ 0) THEN BEGIN
          bottom_plot_info.time_xmin =undo_array[2,0]
          bottom_plot_info.time_xmax =undo_array[2,1]
          bottom_plot_info.time_ymin =undo_array[2,2]
          bottom_plot_info.time_ymax =undo_array[2,3]
         ENDIF
         IF (bottom_plot_info.domain EQ 1) THEN BEGIN
          bottom_plot_info.freq_xmin =undo_array[2,0]
          bottom_plot_info.freq_xmax =undo_array[2,1]
          bottom_plot_info.freq_ymin =undo_array[2,2]
          bottom_plot_info.freq_ymax =undo_array[2,3]
         ENDIF
         BOTTOM_DISPLAY_DATA
       ENDIF
    ENDELSE
END



;=======================================================================================================;
; Name:  ERROR_MESSAGE
; Purpose:  To provide a visual error delivery window that can be called whenever a user must be told
;       they did something wrong.
; Parameters:  Msg - The message that we would like printed on the error window.
; Return:  None.
;=======================================================================================================;
PRO ERROR_MESSAGE, Msg,TITLE=t
   COMMON common_widgets
   COMMON common_vars
   title = "ERROR!"

   if(keyword_set(t)) then begin
      title = t
   endif

   error_base = WIDGET_BASE(COL=2, MAP=1, TITLE=title, UVALUE='E_base', UNAME='ERROR_BASE', /BASE_ALIGN_CENTER, $
		TLB_FRAME_ATTR=1, XOFFSET=200, YOFFSET=150, XPAD=30, YPAD=30 )
   error_msg = WIDGET_LABEL(error_base, VALUE=msg, UVALUE='E_MSG', /FRAME)
   if(title NE "CONVERSION") THEN BEGIN
	   error_button = WIDGET_BUTTON(error_base, VALUE='Ok', UVALUE='E_OK', EVENT_PRO = 'EV_E_OK', $
			/ALIGN_CENTER)
   END

   error_window_ID = error_base

   WIDGET_CONTROL, error_base, /REALIZE
   XMANAGER, "ERROR", error_base
END

;=======================================================================================================;
; Name:  EV_E_OK                                 
; Purpose:  Called when the user selects ok in the error message.  Simply gets rid of the error window. 
; Parameters:  event - The event that called this procedure.                             
; Return:  None.                             
;=======================================================================================================
PRO EV_E_OK, event
        WIDGET_CONTROL, event.top, /DESTROY
END

;=======================================================================================================;
; Name:  HELP_ABOUT_EVENT                               
; Purpose:  Called when About button is pressed in the help menu.             
; Parameters:  event - The event that called this procedure.                             
; Return:  None.                             
; Note:  It calls the about window and it is dafaulted to 1 hour unless the ok button is pressed.       
;=======================================================================================================;
PRO HELP_ABOUT_EVENT , event
    ABOUT_FITMAN, 3600
END
