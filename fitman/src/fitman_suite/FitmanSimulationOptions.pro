;=================================================================================================;
;  File:  FitmanSimulationOptions.pro                                                              ;
;  Purpose:  Provides all the procedures which are called when a user performs actions on the      ;
;            Domain menu.                                                                          ;
;  Dependencies:  FitmanDomainOptions, FitmanGui_Sep2000, Display, FitmanStatisticOptions          ;
;  Written by:  Tim Orr, Co-Op Student (September 2002)                                            ;
;==================================================================================================;

;==================================================================================================;
;                       MENU OPTION 1 FROM SIMULATIONS PULLDOWN MENU                               ;
;==================================================================================================;

;==================================================================================================;
;  Name: EV_NOISE                                                                                  ;
;  Purpose: To allow a user to characterize the noise of a particular data set.  This will         ;
;           specifically give the user the ability to get statistical information regarding the    ;
;           data set, and to compare it with known noise levels.                                   ;
;  Parameters:  Event - The event which called this procedure.                                     ;
;  Return:  None.                                                                                  ;
;==================================================================================================;
PRO EV_NOISE, event

    ; sharing common variables
    COMMON common_vars
    COMMON draw1_comm
    COMMON DrawNoise

    noResize = 1

    ; creating the main windows in the GUI - divided into the plot screen and the text screen
    noise_window = WIDGET_BASE(ROW=3, MAP=1, TITLE='Noise Characterization', TLB_FRAME_ATTR=8)
    noise_draw = WIDGET_DRAW(noise_window, RETAIN=1, UVALUE='N_DRAW', XSIZE=1050, YSIZE=300)
    text_base = WIDGET_BASE(noise_window,COLUMN=3, MAP=1, UVALUE='T_BASE')

    ; creating the base widgets making up the text screen
    slider_base = WIDGET_BASE(text_base, MAP=1)
    value_base = WIDGET_BASE (text_base, COLUMN=1, MAP=1, UVALUE='V_BASE')
    min_base = WIDGET_BASE(text_base, ROW=6, MAP=1, UVALUE='V_BASE',/FRAME)
        buttons_base = WIDGET_BASE(text_base,COLUMN=3, MAP=1, UVALUE='N_BUTTONS',/FRAME)

    ; creating the 3 base widgets that make up the buttons portion of the text screen
    domain_base = WIDGET_BASE (buttons_base, COLUMN=1, MAP=1, UVALUE = 'D_BASE')
        plot_base = WIDGET_BASE(buttons_base, COLUMN=1, MAP=1, UVALUE='PLOT_BASE')
    calc_base = WIDGET_BASE (buttons_base, COLUMN=1, MAP=1, UVALUE='CALC_BASE')

    ; creating the fields for the statistical portion of the screen
    s_min = CW_FIELD(value_base, TITLE='Minimum Value',VALUE=0.0, /FRAME)
        s_max = CW_FIELD(value_base, TITLE='Maximum Value',VALUE=0.0, /FRAME)
        std_box = CW_FIELD (min_base, TITLE='Std Dev Real: ', VALUE=0.0)
        std_boxim = CW_FIELD (min_base, TITLE='Std Dev Imaginary: ', VALUE=0.0)
        avg_box = CW_FIELD (min_base, TITLE='Average Real: ', VALUE=0.0)
        avg_boxim = CW_FIELD (min_base, TITLE='Average Imaginary: ', VALUE=0.0)
        maxval_box = CW_FIELD(min_base, TITLE='Max Real Value:', VALUE=0.0)
        minval_box = CW_FIELD(min_base, TITLE='Min Real Value:', VALUE=0.0)

    ; creating the buttons and their labels
    domain_label = WIDGET_LABEL(domain_base, VALUE='Domain:')
        time_button = WIDGET_BUTTON(domain_base, VALUE='Time', /FRAME, EVENT_PRO='EV_TIME_NOISE')
    frequency_button = WIDGET_BUTTON(domain_base, VALUE='Frequency', /FRAME, EVENT_PRO='EV_FREQUENCY_NOISE')
    plot_label = WIDGET_LABEL(plot_base, VALUE='Generate:')
    histogram_button = WIDGET_BUTTON(plot_base, VALUE='Histogram',/FRAME,EVENT_PRO='EV_PLOT_HISTO')
    options_label = WIDGET_LABEL(calc_base, VALUE='Actions:')
    calculate_button = WIDGET_BUTTON(calc_base, VALUE='Calculate', /FRAME, EVENT_PRO='EV_STDDEV_CALC')
        print_button = WIDGET_BUTTON(calc_base,VALUE='Print',/FRAME,EVENT_PRO='EV_STDDEV_PRINT')
        cancel_button = WIDGET_BUTTON(calc_base, VALUE="Exit", /FRAME, EVENT_PRO='EV_NOISE_EXIT')

    ; the state structure, which will be passed in during widget events.
    ; Note:  this MUST be the same as the StatisticOptions, in order for code to be reused.
    state = {s_min:s_min, s_max:s_max, std_box:std_box, maxval_box:maxval_box, $
        minval_box:minval_box,avg_box:avg_box,avg_boxim:avg_boxim,std_boxim:std_boxim}
    pstate = ptr_new(state, /NO_COPY)
    WIDGET_CONTROL, noise_window, SET_UVALUE=pstate

    WIDGET_CONTROL, noise_window, /REALIZE
    WIDGET_CONTROL, noise_draw, GET_VALUE=n_drawId

    DRAW_NOISE  ; calling the procedure that actually draws the plot in the Noise Characterization
           ; window

    XMANAGER, 'noise', noise_window

    ; the widget created will be allowed to be resized, if necessary
    noResize = 0
END

;==================================================================================================;
;  Name: DRAW_NOISE                                                                                ;
;  Purpose: This procedure is used to draw the plot of the noise in the Noise Characterization     ;
;           window.  This is mainly used in the EV_TIME_NOISE and EV_FREQUENCY_NOISE, which allow  ;
;           users to see the noise plot in either the frequency or time domains.                   ;
;  Parameters:  None                                                                               ;
;  Return:  None.                                                                                  ;
;==================================================================================================;

PRO DRAW_NOISE

    COMMON common_vars
    COMMON Draw1_comm
    COMMON DrawNoise  ; shares these common variables, since n_drawId is used

    wset,n_drawId ; identifying the draw plot in the Noise Characterization window

    AUTO_SCALE ; thus, AUTO_SCALE and REDISPLAY will be called on the draw plot with ID above
    REDISPLAY  ; (i.e. n_drawId)
END

;==================================================================================================;
;  Name:  EV_TIME_NOISE                                                                            ;
;  Purpose:  Allows the user to switch the domain of the plot being displayed in the Noise         ;
;            Characterization window to the time domain.  If the plot is already in the time       ;
;            domain, the plot will not change.                                                     ;
;  Parameters:  Event - The event which called this procedure.                                     ;
;  Return:  None.                                                                                  ;
;==================================================================================================;
PRO EV_TIME_NOISE, event

    COMMON common_vars
    COMMON draw1_comm
    COMMON DrawNoise ; shares these common variables, since noise_flag is used

    ; common variable (used since only events can be passed) to store current domain of plot
    COMMON temp_domains, temp_domain, temp_domain_middle, temp_domain_bottom

    ; if the plot was displayed in the 1st window, change to the time domain, and display
    ; this plot in the draw widget in the Noise Characterization Window
    IF ((Window_Flag EQ 1) AND (plot_info.data_file NE '')) THEN BEGIN
       temp_domain = plot_info.domain ; storing the domain value before changing it
       plot_info.domain = 0
       o_xmax=plot_info.time_xmax
       wset, n_drawId ;  selecting current window
       DISPLAY_DATA
       DRAW_NOISE
    ENDIF

    ; if the plot was displayed in the 2nd window, change to the time domain, and display
    ; this plot in the draw widget in the Noise Characterization Window
        ; also, use noise_flag to ignore resizing of middle window
    IF ((Window_Flag EQ 2) AND (middle_plot_info.data_file NE '')) THEN BEGIN
       noise_flag = 1
       temp_domain_middle = middle_plot_info.domain ; storing domain before changing it
       middle_plot_info.domain = 0
       o_xmax2=middle_plot_info.time_xmax
       wset, n_drawId ; selecting current window (noise window)
       MIDDLE_DISPLAY_DATA
       DRAW_NOISE
       noise_flag = 0
    ENDIF

    ; if the plot was displayed in the 3rd window, change to the time domain, and display
    ; this plot in the draw widget in the Noise Characterization Window
    IF ((Window_Flag EQ 3) AND (bottom_plot_info.data_file NE '')) THEN BEGIN
       temp_domain_bottom = bottom_plot_info.domain ; storing domain before changing it
       bottom_plot_info.domain = 0
       o_xmax3=bottom_plot_info.time_xmax
       wset, n_drawId ;  selecting current window
       BOTTOM_DISPLAY_DATA
       DRAW_NOISE
    ENDIF
END

;==================================================================================================;
;  Name:  EV_FREQUENCY_NOISE                                                                       ;
;  Purpose:  Allows the user to switch the domain of the plot being displayed in the Noise         ;
;            Characterization window to the frequency domain.  If the plot is already in the freq  ;
;            domain, the plot will not change.                                                     ;
;  Parameters:  Event - The event which called this procedure.                                     ;
;  Return:  None.                                                                                  ;
;==================================================================================================;

PRO EV_FREQUENCY_NOISE, event
    COMMON common_vars
    COMMON draw1_comm
    COMMON DrawNoise ; again, since noise_flag is used
    COMMON temp_domains

    ; depending on which window the plot is occupying, the characteristics controlling the
    ; domain of the plot will be changed to reflect that of frequency.  Then, the new plot
    ; will be displayed in the Noise Characterization window.
    IF ((Window_Flag EQ 1) AND (plot_info.data_file NE '')) THEN BEGIN
       temp_domain = plot_info.domain ; again, storing the temp_domain
       plot_info.domain = 1
       o_max=plot_info.freq_xmax
       wset, n_drawId ; selecting current window
       DISPLAY_DATA
       DRAW_NOISE
    ENDIF
    IF ((Window_Flag EQ 2) AND (middle_plot_info.data_file NE '')) THEN BEGIN
       noise_flag = 1
       temp_domain_middle = middle_plot_info.domain ; storing the domain
       middle_plot_info.domain = 1
       o_max2=middle_plot_info.freq_xmax
       wset, n_drawId ; selecting current window
       MIDDLE_DISPLAY_DATA
       DRAW_NOISE
       noise_flag = 0
       ENDIF
    IF ((Window_Flag EQ 3) AND (bottom_plot_info.data_file NE '')) THEN BEGIN
       temp_domain_bottom = bottom_plot_info.domain ; storing the domain
       bottom_plot_info.domain = 1
       o_max3=bottom_plot_info.freq_xmax
       wset, n_drawId ; selecting current window
       BOTTOM_DISPLAY_DATA
       DRAW_NOISE
    ENDIF
END

;==================================================================================================;
; Name:  EV_NOISE_EXIT                                                                             ;
; Purpose: Exits out of the Noise Characterization window.                                         ;
; Parameters: Event - the event which called this procedure.                                       ;
; Return: None.                                                                                    ;
;==================================================================================================;

PRO EV_NOISE_EXIT, event
    COMMON common_vars
    COMMON draw1_comm
    COMMON temp_domains ; sharing these variables, so that plots can be returned to proper domain

    WIDGET_CONTROL, event.top, /DESTROY ; first, the current window is "destroyed"

    ; the plot in the original windows are returned to their proper domain (temp_domain)
    ; then, the window id of the currently occupied window is selected
    ; if any of the temp domains haven't been set, the first IF statement handles this case
    IF(Window_Flag EQ 1) THEN BEGIN
       IF (N_ELEMENTS(temp_domain) EQ 0) THEN BEGIN
         temp_domain = plot_info.domain
       ENDIF
       plot_info.domain = temp_domain
       wset, draw1_id
    ENDIF ELSE IF (Window_Flag EQ 2) THEN BEGIN
       IF (N_ELEMENTS(temp_domain_middle) EQ 0) THEN BEGIN
         temp_domain_middle=middle_plot_info.domain
       ENDIF
       middle_plot_info.domain = temp_domain_middle
       wset, draw2_id
    ENDIF ELSE IF (Window_Flag EQ 3) THEN BEGIN
       IF (N_ELEMENTS(temp_domain_bottom) EQ 0) THEN BEGIN
         temp_domain_bottom=bottom_plot_info.domain
       ENDIF
       bottom_plot_info.domain = temp_domain_bottom
       wset, draw3_id
    ENDIF
END

;==================================================================================================;
; Name:  SET_INITIAL_VALUES (Function)                                                             ;
; Purpose:  To get the initial values for binsize, min slider range, and max slider range.         ;
;           These are determined based on the domain the plot is in, and are stored in the above   ;
;           order in an array.  This array is returned by the function, and is used in the         ;
;           EV_PLOT_HISTO procedure.                                                               ;
; Parameters:  None                                                                                ;
; Return: initial_data - a floating point array containing the information specified above         ;
;==================================================================================================;

FUNCTION SET_INITIAL_VALUES
    COMMON common_vars
    COMMON common_widgets

    initial_data = FLTARR(3)
    min_slider_value = 0.001 ; make sure this isn't 0, since it will mess up the plotting of the
                                 ; ideal Gaussian curve

    ; depending on what domain the plot is in, the following values are chosen.
    ; I chose these values based on the in-vivo noise data files
    ; note that these values may be inaccurate if other values are used
    ; but binsize can be changed within the interface
    IF (Window_Flag EQ 1) THEN BEGIN
       IF (plot_info.domain EQ 0) THEN BEGIN
         binsize = 0.1
         max_slider_value = 1.0
       ENDIF ELSE IF (plot_info.domain EQ 1) THEN BEGIN
         binsize = 0.005
         max_slider_value = 0.05
       ENDIF
    ENDIF ELSE IF (Window_Flag EQ 2) THEN BEGIN
       IF (middle_plot_info.domain EQ 0) THEN BEGIN
         binsize = 0.1
         max_slider_value = 1.0
       ENDIF ELSE IF (middle_plot_info.domain EQ 1) THEN BEGIN
         binsize = 0.005
         max_slider_value = 0.05
       ENDIF
    ENDIF ELSE IF (Window_Flag EQ 3) THEN BEGIN
       IF (bottom_plot_info.domain EQ 0) THEN BEGIN
         binsize = 0.1
         max_slider_value = 1.0
       ENDIF ELSE IF (bottom_plot_info.domain EQ 1) THEN BEGIN
         binsize = 0.005
         max_slider_value = 0.05
       ENDIF
    ENDIF
    initial_data = [binsize, min_slider_value, max_slider_value]
    return, initial_data
END

;==================================================================================================;
; Name:  EV_PLOT_HISTO                                                                             ;
; Purpose:  When the "Histogram" button is pressed in the Noise Characterization window, this      ;
;           procedure opens up a new widget (titled "Histogram") and draws all other widgets       ;
;           associated with this new window.  It also calls the WINDOW_SELECTION procedure, so that;
;           the histogram can be immediately plotted on the screen.                                ;
; Parameters: Event - the event which called this procedure.                                       ;
; Return: None.                                                                                    ;
;==================================================================================================;

PRO EV_PLOT_HISTO, event
    COMMON common_vars
    COMMON common_widgets
    COMMON draw1_comm
    COMMON plot_variables ; this is needed so that the actual points can be used to generate
               ; the histogram
    noResize = 1
    set_r_i_flag = 0 ; setting the real-imaginary flag to 0 (Real)

    ; getting the initial values for binsize, min slider value, max slider value
    initial_values = SET_INITIAL_VALUES()

    ; the first hierarchy of widgets: overal window, draw window, and options window
    histogram_window = WIDGET_BASE(ROW=3, MAP=1, TITLE='Histogram', TLB_FRAME_ATTR=8)
    histogram_draw = WIDGET_DRAW(histogram_window, RETAIN=1, UVALUE='H_DRAW', XSIZE=1150,YSIZE=375)
    options_base = WIDGET_BASE(histogram_window,COLUMN=4, MAP=1,UVALUE='O_BASE')

    ; the second hierarchy of widgets: plot base, stats base, analysis base, actions base
    plotting_base = WIDGET_BASE(options_base, COLUMN=1, MAP=1, UVALUE='PLOTTING_BASE')
    statistics_base = WIDGET_BASE(options_base, ROW=2, MAP=1, UVALUE='STATS_BASE',/FRAME)
    analysis_base = WIDGET_BASE(options_base, COLUMN=1,MAP=1,UVALUE='ANALYSIS_BASE',/FRAME)
    actions_base = WIDGET_BASE(options_base, COLUMN=1, MAP=1, UVALUE='ACTIONS_BASE')

    ; the third hierarchy of widgets: plot options, min-max, histogram stats, binsize,
    ; real-imaginary and distribution options
    plot_options_base = WIDGET_BASE(plotting_base, ROW=4, MAP=1, UVALUE='PLOT_OPTIONS',/FRAME)
    min_max_base = WIDGET_BASE(statistics_base, ROW=2,MAP=1,/FRAME,UVALUE='MIN_MAX')
    histo_stats_base = WIDGET_BASE(statistics_base, ROW=6,MAP=1,/FRAME,UVALUE='H_STATS')
    binsize_base = WIDGET_BASE(plot_options_base, COLUMN=1,MAP=1,UVALUE='BIN_BASE')
    scaling_base = WIDGET_BASE(plotting_base, ROW=1, MAP=1, UVALUE='SCALING_BASE')

    ; compound widgets used for binsize, real/img points, plot distributions and Gaussian scaling
    binsize_option = CW_FIELD(binsize_base, TITLE='Bin Size:',VALUE=0.0)
    values = ['Real','Imaginary']
    real_img_opt = WIDGET_DROPLIST(plot_options_base,VALUE=values,TITLE ='Data Points:',$
              EVENT_PRO='EV_REPLOT_HISTO',UVALUE = 'R_I_OPTS')
    distribution_options = CW_BGROUP(plot_options_base,['Ideal Gaussian Distribution', $
                     'Actual Gauss-Fit Distribution', 'Actual Distribution'], $
               /COLUMN, /NONEXCLUSIVE, LABEL_TOP='Plot Distributions:', $
               UVALUE='DIST_OPTS',/FRAME)
    WIDGET_CONTROL,distribution_options,SET_VALUE=[0,0,0] ; setting the initial values of the
                         ; distribution_options to 'OFF'
    scale_gaussian = CW_FSLIDER(scaling_base, TITLE='Scale Gaussian Curve', UVALUE='SCALE_G', $
                MINIMUM=initial_values[1],MAXIMUM=initial_values[2],/FRAME,/EDIT)
    WIDGET_CONTROL,scale_gaussian, SENSITIVE=0

    ; the compound widgets controlling the histogram statistics
    min_s = CW_FIELD(min_max_base, TITLE='Min. Value:', VALUE=0.0)
    max_s = CW_FIELD(min_max_base, TITLE='Max. Value:',VALUE=0.0)
    mean = CW_FIELD(histo_stats_base, TITLE='Mean:',VALUE = 0.0)
    median = CW_FIELD(histo_stats_base, TITLE='Median:',VALUE=0.0)
    mode = CW_FIELD(histo_stats_base, TITLE='Mode:',VALUE=0.0)
    std = CW_FIELD(histo_stats_base, TITLE='Std:',VALUE=0.0)
    range = CW_FIELD(histo_stats_base, TITLE='Range:', VALUE=0.0)

    ; the compound widgets controlling the plot analysis section
    skew = CW_FIELD(analysis_base, TITLE='Skewness:', VALUE=0.0)
    kurtosis = CW_FIELD(analysis_base, TITLE='Kurtosis:', VALUE=0.0)
    goodness_of_fit = CW_FIELD(analysis_base, TITLE='Goodness of Fit:', VALUE=0.0)

    ; the widget buttons: plot, calculate, print and exit
    plot_button = WIDGET_BUTTON(actions_base,VALUE='Plot',/FRAME,EVENT_PRO='EV_REPLOT_HISTO')
    calculate_stats = WIDGET_BUTTON(actions_base, VALUE='Calculate',/FRAME,EVENT_PRO='EV_CALC_HSTATS')
    analyze = WIDGET_BUTTON(actions_base, VALUE='Analyze Plot',/FRAME,EVENT_PRO='EV_H_ANALYZE')
    clear_button = WIDGET_BUTTON(actions_base, VALUE='Clear',/FRAME,EVENT_PRO='EV_CLEAR_STATS')
    exit_button = WIDGET_BUTTON(actions_base, VALUE='Exit',/FRAME,EVENT_PRO='EV_NOISE_EXIT')

    WIDGET_CONTROL, histogram_window, /REALIZE
    WIDGET_CONTROL, histogram_draw, GET_VALUE=h_drawId

    wset, h_drawId

    ; setting the initial values for binsize
    ; 0 - binsize
    WIDGET_CONTROL, binsize_option, SET_VALUE=initial_values[0]

    LOAD_COLORS
    WINDOW_SELECTION, initial_values[0], set_r_i_flag

    state1 = {binsize_option:binsize_option, distribution_options:distribution_options, real_img_opt:$
         real_img_opt, min_s:min_s, max_s:max_s, mean:mean, median:median, mode:mode, std:std,$
         range:range, skew:skew, kurtosis:kurtosis, goodness_of_fit:goodness_of_fit, scale_gaussian:$
         scale_gaussian}
    pstate1 = ptr_new(state1, /NO_COPY)

    ; setting UVALUE to pstate1, so that the pointer to state1 can be used in other event procs
    WIDGET_CONTROL, histogram_window, SET_UVALUE=pstate1
    XMANAGER, 'histo', histogram_window
END

;==================================================================================================;
; Name:  WINDOW_SELECTION                                                                          ;
; Purpose:  To select the appropriate plot (from either window 1, 2 or 3), and use that data to    ;
;           plot the necessary histogram.                                                          ;
; Parameters:  bin - the bin size of the histogram.                                                ;
;              real_or_img - boolean specifying whether the points to be plotted are real or img.  ;
; Return: None.                                                                                    ;
;==================================================================================================;

PRO WINDOW_SELECTION, bin, real_or_img
    COMMON common_vars
    COMMON common_widgets
    COMMON plot_variables ; needed so that the time/freq points can be passed into SETUP_HISTOGRAM

    IF (real_or_img EQ 0 ) THEN ri_flag=1 ; ri_flag=1 means that the real points are to be used
    IF (real_or_img EQ 1) THEN ri_flag=0 ; ri_flag=0 means that the img points are to be used

    ; depending on which plot is of interest, the SETUP_HISTOGRAM procedure will be called on
    ; that particular set of data points.
    IF (Window_Flag EQ 1) THEN BEGIN
       IF (plot_info.domain EQ 0) THEN BEGIN
         SETUP_HISTOGRAM, actual_time_data_points, bin, plot_info.domain, ri_flag
         HISTOGRAM_PLOT, bin
       ENDIF ELSE IF (plot_info.domain EQ 1) THEN BEGIN
         SETUP_HISTOGRAM, actual_freq_data_points, bin, plot_info.domain, ri_flag
         HISTOGRAM_PLOT, bin
       ENDIF
    ENDIF
    IF (Window_Flag EQ 2) THEN BEGIN
       IF(middle_plot_info.domain EQ 0) THEN BEGIN
         SETUP_HISTOGRAM, middle_actual_time_data_points, bin, middle_plot_info.domain, ri_flag
         HISTOGRAM_PLOT, bin
       ENDIF ELSE IF (middle_plot_info.domain EQ 1) THEN BEGIN
         SETUP_HISTOGRAM, middle_actual_freq_data_points, bin, middle_plot_info.domain, ri_flag
         HISTOGRAM_PLOT, bin
       ENDIF
    ENDIF
    IF (Window_Flag EQ 3) THEN BEGIN
       IF (bottom_plot_info.domain EQ 0) THEN BEGIN
         SETUP_HISTOGRAM, bottom_actual_time_data_points,bin,bottom_plot_info.domain, ri_flag
         HISTOGRAM_PLOT, bin
       ENDIF ELSE IF (bottom_plot_info.domain EQ 1) THEN BEGIN
         SETUP_HISTOGRAM, bottom_actual_freq_data_points, bin, bottom_plot_info.domain, ri_flag
         HISTOGRAM_PLOT, bin
       ENDIF
    ENDIF
END

;==================================================================================================;
; Name:  LOAD_COLORS                                                                               ;
; Purpose: Loads the appropriate color table, and assigns specific colours to common variables     ;
;          which are used in the histogram display.                                                ;
; Parameters: None.                                                                                ;
; Return: None.                                                                                    ;
;==================================================================================================;

PRO LOAD_COLORS
    COMMON common_vars
    COMMON colours, green_colour, yellow_colour, blue_colour, red_colour

    LOADCT, 0
    TVLCT, Red, Green, Blue

    green_colour = 1
    yellow_colour = 3
    blue_colour = 4
    red_colour = 5

END

;==================================================================================================;
; Name: SETUP_HISTOGRAM                                                                            ;
; Purpose: To set up the data to be plotted as a histogram.  This procedure uses the PLOTHIST      ;
;          procedure, since the built-in HISTOGRAM procedure has errors associated with it when    ;
;          floating-point numbers are involved.  Although PLOTHIST can also be used to actually    ;
;          plot the histogram, only the data generated from this procedure is needed.  Please make ;
;          sure that PLOTHIST.pro is included in the compile sequence for FitmanGUI                ;
; Parameters: data - the time/freq data of the plot in the Noise Characterization window           ;
;             bin_size - the binsize of the histogram to be plotted                                ;
;             domain - the domain of the plot in the Noise Characterization window                 ;
;             real_img_flag - Boolean describing which set of points to use in the histogram       ;
; Return: None.                                                                                    ;
;==================================================================================================;

PRO SETUP_HISTOGRAM, data, bin_size, domain, real_img_flag
    COMMON common_vars
    COMMON plot_variables
    COMMON common_widgets
    COMMON histo_variables, xAxis, yAxis, realArray, imgArray

    realArray = FLOAT(data)
    imgArray = IMAGINARY(data)

    ; if real_img_flag is 1, use real points | if real_img_flag is 0, use img points
    IF (real_img_flag EQ 1) THEN histogram_data = realArray
    IF (real_img_flag EQ 0) THEN histogram_data = imgArray

    PLOTHIST, histogram_data, xAxis, yAxis, bin=bin_size, HALFBIN=0,/NOPLOT
END

;==================================================================================================;
; Name:  MAKE_XAXIS_SYMMETRIC                                                                      ;
; Purpose:  To make the x-axis symmetric about 0, so that the Ideal and Gauss-fit plots can be     ;
;           better compared (i.e. the areas under each curve will be the same).                    ;
; Parameters: binsize - the bin size of the histogram, used to get the number of "bin differences" ;
;                       between either the max or min values                                       ;
; Brief Description:  This procedure looks for whether the max or min value on the x-axis is       ;
;                     greater.  Once it finds which one is greater, it uses that value to set the  ;
;                     other value (either min or max).  Then, it finds the number of "bin          ;
;                     "differences", so that it can pad the yAxis with zeroes appropriately.  This ;
;                     means that the yAxis will either be padded at the start or at the end,       ;
;                     depending on whether the x-min is greater than the x-max or vice versa.      ;
; Return:  None, just modifies the x and y axes.                                                   ;
;==================================================================================================;

PRO MAKE_XAXIS_SYMMETRIC, binsize
    COMMON histo_variables  ; since the x and y axes will be modified

    num_bins_temp = FIX(N_ELEMENTS(yAxis))

    ; getting the min and max on the xAxis.  If the minimum value is not negative, then the axis
    ; cannot be made symmetric about 0.  In this case, we should just let PLOTHIST calculate the
    ; x-axis scale
    x_min = xAxis[0]
    x_max = xAxis[num_bins_temp-1]
    IF (x_min GT 0) THEN RETURN

    ; to avoid floating point errors, we must compare the difference between x_max and x_min with
    ; a small value, called epsilon
    epsilon = 0.00001
    floating_point_test = ABS(x_max) - ABS(x_min)

    ; if the two values for x_max and x_min aren't the same (if they are the same, they are already
    ; symmetric about 0), then continue
    IF (ABS(floating_point_test) LT epsilon) THEN RETURN
    IF (ABS(floating_point_test) GT epsilon) THEN BEGIN
       IF (ABS(x_min) GT ABS(x_max)) THEN BEGIN
         IF (x_max GT 0) THEN BEGIN
          ; set x_max to the corresponding value
          ; make a new xAxis, and pad the yAxis with zeroes at the END
          x_max = ABS(x_min)
          difference = ROUND((x_max - xAxis[num_bins_temp-1])/binsize)
          new_xAxis = LINDGEN(num_bins_temp+difference)*binsize + x_min
          padded_zeroes = LONARR(difference)
          new_yAxis = LONARR(num_bins_temp+difference)
          new_yAxis = [yAxis, padded_zeroes]
         ENDIF
       ENDIF ELSE IF (ABS(x_min) LT ABS(x_max)) THEN BEGIN
         IF (x_min LT 0) THEN BEGIN
          ; set x_min to the corresponding value
          ; make a new xAxis, and pad the yAxis with zeroes at the START
          x_min = -1.*(ABS(x_max))
          difference = ROUND((ABS(x_min) - ABS(xAxis[0]))/binsize)
          new_xAxis = LINDGEN(num_bins_temp+difference)*binsize + x_min
          padded_zeroes = LONARR(difference)
          new_yAxis = LONARR(num_bins_temp+difference)
          new_yAxis = [padded_zeroes, yAxis]
         ENDIF
       ENDIF

       ; changing the x and y axes appropriately
       ; if the plot is already symmetric, or if it cannot be made symmetric, nothing will
       ; be done
       xAxis = new_xAxis
       yAxis = new_yAxis
    ENDIF
END

;==================================================================================================;
; Name: HISTOGRAM_PLOT                                                                             ;
; Purpose: To actually plot the histogram on the screen.  Uses the COMMON variables "colours"      ;
;          to assign the appropriate colours to the histogram.                                     ;
; Parameters:  bin_size - the bin size of the histogram.                                           ;
; Return:  None.                                                                                   ;
;==================================================================================================;

PRO HISTOGRAM_PLOT, bin_size

    COMMON common_vars
    COMMON histo_variables
    COMMON colours

    ; procedure used to make the xAxis symmetric about 0
    MAKE_XAXIS_SYMMETRIC, bin_size

    num_bins = FIX(N_ELEMENTS(yAxis))

    ; if the number of bins is <= 3, the Gaussian fit cannot be performed, as such, an error is
    ; thrown.
    IF (num_bins LE 3) THEN BEGIN
       ;ERROR_MESSAGE, "Invalid bin size.  Please re-enter the value."
        err_result = DIALOG_MESSAGE('Invalid bin size.  Please re-enter the value.', $
                        Title = 'WARNING')
       RETURN
    ENDIF

    ; plot the scales for the x and y axes
    PLOT, [xAxis[0],xAxis[num_bins-1]],[0, MAX(yAxis)], XTITLE = 'Intensity (a.u)', $
    YTITLE = 'Relative Frequency (P(x))', XRANGE=[xAxis[0],xAxis[num_bins-1]], /NODATA

    ; plot the points, using histogram mode (PSYM = 10)
    OPLOT, xAxis, yAxis, LINESTYLE=0, COLOR=blue_colour,THICK=2.5,PSYM=10
END

;==================================================================================================;
; Name:  GET_SCALE_FACTOR (Function)                                                               ;
; Purpose:  To obtain the correct scale parameter for the ideal normal distribution.  This is      ;
;           determined by getting the max value on the xAxis (which is symmetric at this point)    ;
;           and then dividing this by 3 (see below)                                                ;
; Parameters:  xaxis - the x-axis from which the max value is determined from                      ;
; Return:  scaling_factor - the scale parameter for the normal distribution of interest.           ;
;==================================================================================================;

FUNCTION GET_SCALE_FACTOR, xaxis

    ; the original Gaussian curve (without scale_factor) is centered around 0 and goes from
    ; +3 to -3, so in order to define a new scaling factor, we divide by 3.
    x_max = FLOAT(MAX(xaxis))
    scaling_factor = x_max/3.

    return, scaling_factor
END

;==================================================================================================;
; Name: EV_REPLOT_HISTO                                                                            ;
; Purpose:  To allow the user to re-plot the histogram with varying bin sizes.  Note that if the   ;
;           plot distributions have been selected, they too will be plotted.                       ;
; Parameters: Event - The event which called this procedure.                                       ;
; Return: None.                                                                                    ;
;==================================================================================================;

PRO EV_REPLOT_HISTO, event
    COMMON common_vars
    COMMON plot_variables
    COMMON common_widgets
    COMMON histo_variables

    ; getting the binsize and the real or imaginary points from their respective widgets
    WIDGET_CONTROL, event.top, GET_UVALUE=pstate1
    WIDGET_CONTROL, (*pstate1).binsize_option, GET_VALUE=binsize
    WIDGET_CONTROL, (*pstate1).real_img_opt, GET_UVALUE=real_or_img

    ; setting this flag equal to the position of either "Real" or "Imaginary"
    r_i_flag = WIDGET_INFO((*pstate1).real_img_opt, /DROPLIST_SELECT)

    ; must have these two lines to ensure that binsize is a floating-point number
    binsize = binsize[0]
    binsize = FLOAT(binsize)

    WINDOW_SELECTION, binsize, r_i_flag

    ; setting the scale_factor value for Gaussian scaling BEFORE the PLOT_DISTRIBUTIONS pro
    ; this is to ensure that the switch from real to img points is handled
    WIDGET_CONTROL, (*pstate1).scale_gaussian, SET_VALUE=GET_SCALE_FACTOR(xAxis)

    PLOT_DISTRIBUTIONS, r_i_flag, pstate1
END

;==================================================================================================;
; Name: HISTO_EVENT                                                                                ;
; Purpose:  To process the event of clicking on either of the plot distribution check-boxes.       ;
; Parameters:  Event - The event which called this procedure.                                      ;
; Return:  None.                                                                                   ;
;==================================================================================================;

PRO HISTO_EVENT, event
    COMMON common_vars
    COMMON common_widgets
    COMMON histo_variables

    WIDGET_CONTROL,event.top, GET_UVALUE=pstate1
    WIDGET_CONTROL, event.Id, GET_UVALUE=event_happening

    ; if the event isn't the scale_gaussian, then re-set the scale value
    IF (event_happening NE 'SCALE_G') THEN BEGIN
       WIDGET_CONTROL, (*pstate1).scale_gaussian, SET_VALUE=GET_SCALE_FACTOR(xAxis)
    ENDIF

    ; gets the real_or_img flag and passes it into PLOT_DISTRIBUTIONS
    WIDGET_CONTROL, (*pstate1).real_img_opt, GET_UVALUE=real_or_img

    ; setting this flag equal to the position of either "Real" or "Imaginary"
    r_i_flag = WIDGET_INFO((*pstate1).real_img_opt, /DROPLIST_SELECT)

    PLOT_DISTRIBUTIONS, r_i_flag, pstate1
END

;==================================================================================================;
; Name: IDEAL_GAUSSIAN (function)                                                                  ;
; Purpose: To plot an ideal Gaussian curve, based on data from the x and y axes.  The formula      ;
;          used to obtain this ideal curve was obtained from the Engineering Statistics Handbook   ;
;          Online, at http://www.itl.nist.gov/div898/handbook/.                                    ;
; Parameters: xdata - the data used for the x-axis                                                 ;
;             gauss_max - the maximum frequency of the Gauss-Fit curve.  This is used to better    ;
;                         the visual comparision between the two curves.                           ;
;             scale_factor - value obtained from SET_INITIAL VALUES, however can be changed by     ;
;                            altering the scaling widget within the interface                      ;
;==================================================================================================;

FUNCTION IDEAL_GAUSSIAN, xdata, gauss_max, scale_factor

    ; defining the Gaussian curve and then returning it
    y_gaussian = 1/SQRT(2. *!PI*scale_factor) * EXP(-(xdata^2)/(2*(scale_factor)^2))

    ; to determine the amplitude of the curve, we find the max of the Gauss-fit, and normalize
    ; it
    y_max = FLOAT(MAX(y_gaussian))
    factor = gauss_max/y_max

    ; defining the new normal curve, and then returning it
    y_normal = y_gaussian*factor
    return, y_normal

END

;==================================================================================================;
; Name:  PLOT_DISTRIBUTIONS                                                                        ;
; Purpose: To plot the distributions on the same plot as the histogram.  This will allow the user  ;
;          to observe if the ideal distribution somewhat matches the Gauss-fit distribution.       ;
; Parameters: value - the array of two values which represent whether or not the plot distribution ;
;                     checkboxes are turned on or off (ON - 1 and OFF - 0).                        ;
;             pstate1 - the pointer to the state of the histogram window.  This is required to     ;
;                       control the appearance (sensitivity) and operation of the scaling option   ;
; Return:  None.                                                                                   ;
;==================================================================================================;

PRO PLOT_DISTRIBUTIONS, r_i_flag, pstate1

    COMMON common_vars
    COMMON plot_variables
    COMMON histo_variables
    COMMON colours

    ; if there are 3 bins or less, Gaussian fit cannot be performed.
    bins = FIX(N_ELEMENTS(yAxis))
    IF (bins LE 3) THEN BEGIN
       RETURN
    ENDIF

    ; getting the distribution options from the widget specified
    WIDGET_CONTROL, (*pstate1).distribution_options, GET_VALUE=value
    WIDGET_CONTROL, (*pstate1).binsize_option, GET_VALUE=bin_size
    bin_size = FLOAT(bin_size[0])

    ; fitting the Gaussian distribution on the set of points, and storing the coefficients in A
    ; for some reason, GAUSSFIT causes some underflow arithmetic errors, but these can be ignored
    yfit = GAUSSFIT(xAxis, yAxis,A, NTERMS=3)
    max_y_value = MAX(yfit)

    ; depending on which plot distribution checkboxes are on or off, plot the correct points
    ; accordingly. These are all determined by the value stored in distribution array (1x3)
    ; The Guassian scaling will only become SENSITIVE if the Ideal Gaussian curve checkbox is selected
    IF (value[0] EQ 0) THEN BEGIN
       WIDGET_CONTROL, (*pstate1).scale_gaussian, SENSITIVE=0
       IF (value[1] EQ 0) THEN BEGIN
         IF (value[2] EQ 0) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
         ENDIF ELSE IF (value[2] EQ 1) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
          OPLOT, xAxis, yAxis, COLOR=yellow_colour
         ENDIF
       ENDIF ELSE IF (value[1] EQ 1) THEN BEGIN
         IF (value[2] EQ 0) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
          OPLOT, xAxis, yfit, COLOR=red_colour,THICK=2.0
         ENDIF ELSE IF (value[2] EQ 1) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
          OPLOT, xAxis, yfit, COLOR=red_colour,THICK=2.0
          OPLOT, xAxis, yAxis, COLOR=yellow_colour
         ENDIF
       ENDIF
    ENDIF ELSE IF (value[0] EQ 1) THEN BEGIN
       WIDGET_CONTROL, (*pstate1).scale_gaussian, GET_VALUE=scale
       WIDGET_CONTROL, (*pstate1).scale_gaussian, SENSITIVE=1

       ; storing the ideal Gaussian curve in y_normal
       y_normal = IDEAL_GAUSSIAN(xAxis, max_y_value, scale)

       IF (value[1] EQ 0) THEN BEGIN
         IF (value[2] EQ 0) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
          OPLOT, xAxis, y_normal, COLOR=green_colour,THICK=2.0
         ENDIF ELSE IF (value[2] EQ 1) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
          OPLOT, xAxis, y_normal, COLOR=green_colour,THICK=2.0
          OPLOT, xAxis, yAxis, COLOR=yellow_colour
         ENDIF
       ENDIF ELSE IF (value[1] EQ 1) THEN BEGIN
         IF (value[2] EQ 0) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
          OPLOT, xAxis, y_normal, COLOR=green_colour,THICK=2.0
          OPLOT, xAxis, yfit, COLOR=red_colour,THICK=2.0
         ENDIF ELSE IF (value[2] EQ 1) THEN BEGIN
          HISTOGRAM_PLOT, bin_size
          OPLOT, xAxis, y_normal, COLOR=green_colour,THICK=2.0
          OPLOT, xAxis, yfit, COLOR=red_colour,THICK=2.0
          OPLOT, xAxis, yAxis, COLOR=yellow_colour
         ENDIF
       ENDIF
    ENDIF
END

;==================================================================================================;
; Name:  setHistoCalculations (function)                                                           ;
; Purpose: Gets the appropriate data (within the min and max values) from the array used in        ;
;          plotting the histogram.  It does this by storing the necessary data in a new vector     ;
;          and then returning this vector.  The result is a vector with appropriate data values    ;
;          within in the min and max specified by the user.                                        ;
; Parameters: min - the minimum value specified by the user.                                       ;
;             max - the maximum value specified by the user.                                       ;
;             time_data - the data in the time domain                                              ;
;             freq_data - the data in the frequency domain                                         ;
;             domain - the domain of the data                                                      ;
;             real_or_img - a boolean specifying whether the data is real or imaginary             ;
; Return: new_window_vector - a vector containing the necessary data (within max and min values)   ;
;==================================================================================================;

FUNCTION setHistoCalculations, min, max, time_data, freq_data, domain, real_or_img

    COMMON common_vars
    COMMON plot_variables

    counter = 0 ; variable specifying the size of the vector being extracted
    epsilon = 0.000001 ; used for floating-point comparison

    ; the following uses a FOR loop to extract the necessary data within the maximum and minimum
    ; values.  Comparision is made with the max and min (which are floating point numbers) using
    ; subtraction and epsilon (this avoids any floating-point precision errors that may result)
    ; the resulting vector will contain all the values within the specified range
    IF (domain EQ 0) THEN first_data = time_data
    IF (domain EQ 1) THEN first_data = freq_data

    IF (real_or_img EQ 0) THEN data = FLOAT(first_data)
    IF (real_or_img EQ 1) THEN data = IMAGINARY(first_data)

    window_vector = FLTARR(N_ELEMENTS(data))
    FOR I=0, N_ELEMENTS(data)-1 DO BEGIN
       sub = ABS(data[I]-min)
       sub1 = ABS(data[I]-max)
       IF ((data[I] GT min OR sub LT epsilon) AND (data[I] LT max OR sub1 $
       LT epsilon)) THEN BEGIN
         window_vector[counter] = data[I]
         counter=counter+1
       ENDIF
    ENDFOR
    new_window_vector=EXTRAC(window_vector, 0, counter) ; extracting the necessary data from the
                       ; window_vector (since it has a pre-determined
                       ; size
    return, new_window_vector
END

;==================================================================================================;
; Name: setUPHistoCalculations (function)                                                          ;
; Purpose: Gets the min and max values from the widget (user) and calls on setHistoCalculations    ;
;          to get the necessary vector.                                                            ;
; Parameters:  Event - the event which called this function                                        ;
; Return: window_vector - the vector containing all the necessary data between the min and max     ;
;                         values.                                                                  ;
;==================================================================================================;

FUNCTION setUPHistoCalculations,event

    COMMON common_vars
    COMMON plot_variables

    ; uses the copy of state1 (pstate1) to get the min, max and real_img from the widget
    WIDGET_CONTROL, event.top, GET_UVALUE=pstate1
    WIDGET_CONTROL, (*pstate1).min_s, GET_VALUE=mins
    WIDGET_CONTROL, (*pstate1).max_s, GET_VALUE=maxs
    WIDGET_CONTROL, (*pstate1).real_img_opt, GET_UVALUE=real_img

    ; ensuring that the min and max values taken from the widget are floating-point numbers
    mins = mins[0]
    maxs = maxs[0]
    mins = FLOAT(mins)
    maxs = FLOAT(maxs)

    ; getting the value (0 or 1) from the REAL/IMAGINARY droplist
    r_i_flag = WIDGET_INFO((*pstate1).real_img_opt, /DROPLIST_SELECT)

    IF (Window_Flag EQ 1) THEN BEGIN
       window_vector = setHistoCalculations(mins,maxs,actual_time_data_points, $
          actual_freq_data_points, plot_info.domain, r_i_flag)
    ENDIF ELSE IF (Window_Flag EQ 2) THEN BEGIN
       window_vector = setHistoCalculations(mins,maxs,middle_actual_time_data_points, $
          middle_actual_freq_data_points, middle_plot_info.domain, $
          r_i_flag)
    ENDIF ELSE IF (Window_Flag EQ 3) THEN BEGIN
       window_vector = setHistoCalculations(mins,maxs,bottom_actual_time_data_points, $
          bottom_actual_freq_data_points, bottom_plot_info.domain, $
          r_i_flag)
    ENDIF

    return, window_vector
END

;==================================================================================================;
; Name:  MODE (function)                                                                           ;
; Purpose:  To find and return the value that has the highest relative frequency (appears the most);
; Parameters: bin_size - the size of the bin used to plot the histogram                            ;
;             max - the maximum value taken from the widget (user)                                 ;
;             min - the minimum value taken from the widget (user)                                 ;
;             real_img - a boolean specifying whether the data is real or imaginary                ;
; Return: mode - the element with the highest relative frequency                                   ;
;==================================================================================================;

FUNCTION MODE, data, binsize

    COMMON plot_variables
    COMMON histo_variables

    mode_count = 0 ; the highest relative frequency will be stored in this variable

    ; taking the histogram values for the data within the specified range
    PLOTHIST, data, xhist, yhist, BIN=binsize, HALFBIN=1, /NOPLOT

    ; algorithm for finding the mode.  The "mode_count" records the frequency of occurrence,
    ; while mode_position records the position for where the "mode_count" occurred on the
    ; y-axis.
    FOR I=0, (N_ELEMENTS(yhist)-1) DO BEGIN
       IF(yhist[I] GT mode_count) THEN BEGIN
         mode_count = yhist[I]
         mode_position = I
       ENDIF
    ENDFOR

    ; now the mode should be located on the same position on the x-axis
    mode = xhist[mode_position]
    RETURN, mode
END

;==================================================================================================;
; Name: EV_CALC_HSTATS                                                                             ;
; Purpose: To calculate the mean, median, mode, standard deviation, and range of the data within   ;
;          the specified minimum and maximum values.  This procedure is called when the CALCULATE  ;
;          button is clicked.                                                                      ;
; Parameters:  Event - the event which called the procedure                                        ;
; Return: None                                                                                     ;
;==================================================================================================;

PRO EV_CALC_HSTATS, event
    COMMON common_vars
    COMMON plot_variables
    COMMON histo_variables

    ; getting the min, max, binsize, real_img boolean from the widget
    WIDGET_CONTROL, event.top, GET_UVALUE=pstate1
    WIDGET_CONTROL, (*pstate1).min_s, GET_VALUE=minimum
    WIDGET_CONTROL, (*pstate1).max_s, GET_VALUE=maximum
    WIDGET_CONTROL, (*pstate1).binsize_option, GET_VALUE=binsize

    ; ensuring that the values taken from the widget are in correct form
    minimum = minimum[0]
    minimum = FLOAT(minimum)
    maximum = maximum[0]
    maximum = FLOAT(maximum)
    binsize = binsize[0]
    binsize = FLOAT(binsize)

    epsilon = 0.000001 ; variable used for floating-point comparison

    ; if the minimum is greater than or equal to the maximum, there is an error thrown
    IF (ABS(maximum - minimum) LT epsilon OR maximum LT minimum) THEN BEGIN
       ;ERROR_MESSAGE, "The range specified is invalid. Please re-enter the max and min values."
       err_result = DIALOG_MESSAGE('The range specified is invalid. Please re-enter the max and min values.', $
                        Title = 'WARNING')
       RETURN
    ENDIF

    window_data = setUPHistoCalculations(event)

    ; once the appropriate data is received, the statistics can be calculated
    ; the MOMENT function was used to do this (p. 604 of Reference Guide)
    IF (N_ELEMENTS(FLOAT(window_data)) NE 1) THEN BEGIN
       temp_moment = MOMENT(FLOAT(window_data), SDEV=temp_std)
       temp_mean = temp_moment[0]
       temp_median = MEDIAN(FLOAT(window_data))
       temp_mode = MODE(FLOAT(window_data), binsize)
       temp_range = maximum - minimum
    ENDIF

    ; returning the values calculated to the widget
    WIDGET_CONTROL, (*pstate1).mean, SET_VALUE=temp_mean
    WIDGET_CONTROL, (*pstate1).median, SET_VALUE=temp_median
    WIDGET_CONTROL, (*pstate1).mode, SET_VALUE=temp_mode
    WIDGET_CONTROL, (*pstate1).std, SET_VALUE=temp_std
    WIDGET_CONTROL, (*pstate1).range, SET_VALUE=temp_range

END

;==================================================================================================;
; Name:  EV_H_ANALYZE                                                                              ;
; Purpose: Analyzes the difference between the ideal and Gauss-fit curves.  Does this by           ;
;          calculating the skewness, kurtosis, and goodness-of-fit (uses Chi-Square test).  The    ;
;          Chi-Square test will return a decimal number inbetween 0.0 and 1.0, where 0.0 indicates ;
;          "no correlation", while a 1.0 indicates a "perfect correlation".                        ;
; Parameters:  Event - the event which called this procedure.                                      ;
; Return:  None.                                                                                   ;
;==================================================================================================;
PRO EV_H_ANALYZE, event

    COMMON common_vars
    COMMON histo_variables

    ; getting the real_img flag from the DROPLIST
    WIDGET_CONTROL, event.top, GET_UVALUE=pstate1
    WIDGET_CONTROL, (*pstate1).scale_gaussian, GET_VALUE=scale_factor
    WIDGET_CONTROL, (*pstate1).real_img_opt, GET_UVALUE=real_or_img
    real_img = WIDGET_INFO((*pstate1).real_img_opt, /DROPLIST_SELECT)

    IF (real_img EQ 0) THEN data = realArray
    IF (real_img EQ 1) THEN data = imgArray

    ; calculating the skewness, kurtosis and goodness of fit.  XSQ_TEST performs the Chi-Square
    ; goodness of fit test.
    IF(N_ELEMENTS(data) NE 1) THEN BEGIN
       temp_moment = MOMENT(FLOAT(data))
       temp_skew = temp_moment[2]
       temp_kurtosis = temp_moment[3]
       gauss_fit = GAUSSFIT(xAxis, yAxis,A, NTERMS=3)
       gauss_ideal = IDEAL_GAUSSIAN(xAxis, MAX(gauss_fit), scale_factor)
       chi_square_test = XSQ_TEST(gauss_fit,gauss_ideal)
       temp_goodness = chi_square_test[1]
                print, 'chi_square_test',chi_square_test
    ENDIF

    ; writing the values back to the compound widgets
    WIDGET_CONTROL, (*pstate1).skew, SET_VALUE=temp_skew
    WIDGET_CONTROL, (*pstate1).kurtosis, SET_VALUE=temp_kurtosis
    WIDGET_CONTROL, (*pstate1).goodness_of_fit, SET_VALUE=temp_goodness
END

;==================================================================================================;
; Name:  EV_CLEAR_STATS                                                                            ;
; Purpose: To clear the values stored in the compound widgets for mean, mode, median, range, std,  ;
;          skewness, kurtosis and goodness-of-fit.                                                 ;
; Parameters:  None.                                                                               ;
; Return:  None.                                                                                   ;
;==================================================================================================;

PRO EV_CLEAR_STATS, event

    COMMON common_vars

    ; setting all the widget values to zero
    WIDGET_CONTROL, event.top, GET_UVALUE=pstate1
    WIDGET_CONTROL, (*pstate1).mean, SET_VALUE=0.0
    WIDGET_CONTROL, (*pstate1).median, SET_VALUE=0.0
    WIDGET_CONTROL, (*pstate1).mode, SET_VALUE=0.0
    WIDGET_CONTROL, (*pstate1).std, SET_VALUE=0.0
    WIDGET_CONTROL, (*pstate1).range, SET_VALUE=0.0
    WIDGET_CONTROL, (*pstate1).skew, SET_VALUE=0.0
    WIDGET_CONTROL, (*pstate1).kurtosis, SET_VALUE=0.0
    WIDGET_CONTROL, (*pstate1).goodness_of_fit, SET_VALUE=0.0
END

pro printTime,str
   common common_vars

   time = REFORM(middle_time_data_points[1, $
               fix(middle_plot_info.time_xmin/middle_data_file_header.dwell)+1:$
               (fix(middle_plot_info.time_xmax/middle_data_file_header.dwell)+1)])
   print,str, time[0:10]
end

;==================================================================================================;
;                       MENU OPTION 2 FROM SIMULATIONS PULLDOWN MENU                               ;
;==================================================================================================;
PRO EV_SIMULATE, event
    COMMON common_vars
    COMMON DrawR_Comm, r_drawId ; the Id of the draw window
    COMMON metabolite_vars, metabolites

    IF (Window_Flag NE 2) THEN BEGIN
       ;ERROR_MESSAGE, "Please load a data set, constraints and guess file into the middle window."
       err_result = DIALOG_MESSAGE('Please load a data set, constraints and guess file into the middle window.', $
                        Title = 'ERROR', /ERROR)
       RETURN
    ENDIF

    IF (Window_Flag EQ 2 AND (middle_plot_info.data_file EQ '' OR middle_plot_info.guess_file EQ '' OR $
    middle_plot_info.const_file EQ '')) THEN BEGIN
       ;ERROR_MESSAGE, "Cannot run simulations!  Please load a data set, constraints and guess file in the middle window."
       err_result = DIALOG_MESSAGE('Cannot run simulations!  Please load a data set, constraints and guess file in the middle window.', $
                        Title = 'ERROR', /ERROR)
       RETURN
    ENDIF

    IF (middle_plot_info.last_trace NE 1) THEN BEGIN
       ;ERROR_MESSAGE, "Please select the second option under Display"
       err_result = DIALOG_MESSAGE('Please select the second option under Display.', $
                        Title = 'ERROR', /ERROR)
       RETURN
    ENDIF

        printTime,"In EV_SIMULATE- Top"

    simulate_base = WIDGET_BASE(COLUMN=2, MAP=1, TITLE='Noise Simulations', TLB_FRAME_ATTR=8)
    simulate_base1 = WIDGET_BASE(simulate_base, ROW=2)
    simulate_base2 = WIDGET_BASE(simulate_base, ROW=1, /FRAME)
    simulate_draw = WIDGET_DRAW(simulate_base1, RETAIN=1, UVALUE='R_DRAW', XSIZE=750, $
         YSIZE=300)
    sim_opts_base = WIDGET_BASE(simulate_base1, COLUMN=3, MAP=1, UVALUE='SIM_OPTS_BASE')
    metabolite_base = WIDGET_BASE(simulate_base2,COLUMN=1, MAP=1, UVALUE='METABOLITE_BASE')

    create_noise_base = WIDGET_BASE(sim_opts_base, ROW=2, MAP=1, /FRAME, UVALUE='CREATE_NOISE')
    time_freq_base = WIDGET_BASE(sim_opts_base, COLUMN=1, MAP=1, UVALUE='TIME_FREQ_BASE')
    actions_base = WIDGET_BASE(sim_opts_base, COLUMN=1, MAP=1, UVALUE='ACTION_BASE')

    user_options = WIDGET_BASE(create_noise_base, COLUMN=1, MAP=1,UVALUE='USER_OPT')
    type_of_noise = WIDGET_BASE(create_noise_base, COLUMN=1, MAP=1, UVALUE='TYPE_NOISE')
    first_options = WIDGET_BASE(user_options, COLUMN=2, MAP=1, UVALUE='DIR_OPTS')
    ratio_base = WIDGET_BASE(user_options, COLUMN=3, MAP=1, UVALUE='RATIO_BASE')
    range_base = WIDGET_BASE(user_options, COLUMN=3, MAP=1, UVALUE='RANGE_BASE')

    simulations = CW_FIELD(user_options, TITLE='Number of Simulations:', VALUE=0, /INTEGER, $
             UVALUE='SIMULATIONS')
    output_directory = CW_FIELD(first_options, TITLE='Output Directory:', VALUE='', /STRING)
    browse_output = WIDGET_BUTTON(first_options, VALUE='Browse', EVENT_PRO='EV_BROWSE_OUTPUT')

    number_points = CW_FIELD(user_options, TITLE='Number of Points:', VALUE=middle_data_file_header.points,$
                    /INTEGER)
    dwell_time_field = CW_FIELD(user_options, TITLE='Dwell Time:', VALUE=middle_data_file_header.dwell,$
                  UVALUE='DWELL_T',/FLOATING,/ALL_EVENTS)
    bandwidth_field = CW_FIELD(user_options, TITLE='Bandwidth:',UVALUE='BANDWIDTH', $
                 VALUE=1/middle_data_file_header.dwell,/FLOATING, /ALL_EVENTS)
    noise_options = CW_BGROUP(type_of_noise, ['Normal Distribution', 'Real Noise Data Set'], $
               /COLUMN, /EXCLUSIVE, LABEL_LEFT='Noise Generation:', /FRAME, /RETURN_NAME, UVALUE='NOISE_OPTS')
    WIDGET_CONTROL, noise_options, SET_VALUE=[0]

    signal_ratio1 = CW_FIELD(ratio_base, TITLE='Signal-To-Noise Ratio:', VALUE=1, /INTEGER, XSIZE=4, UVALUE='RATIO1')
    signal_ratio_middle = WIDGET_TEXT(ratio_base, VALUE=':', XSIZE=1)
    signal_ratio2 = CW_FIELD(ratio_base, VALUE=1,TITLE='', /INTEGER, XSIZE=4, UVALUE='RATIO2')

    range1 = CW_FIELD(range_base, TITLE='Intensity Range:', VALUE=-500, /INTEGER, XSIZE=4, UVALUE='RANGE1')
    range_middle = WIDGET_TEXT(range_base, VALUE='To', XSIZE=2)
    range2 = CW_FIELD(range_base, VALUE=0, TITLE='', /INTEGER, XSIZE=4, UVALUE='RANGE2')

    time_freq_label = WIDGET_LABEL(time_freq_base, VALUE='Domain:')
    time_domain_button = WIDGET_BUTTON(time_freq_base, VALUE='Time', /FRAME, EVENT_PRO='EV_TIME_RECON')
    freq_domain_button = WIDGET_BUTTON(time_freq_base, VALUE='Frequency', /FRAME, EVENT_PRO='EV_FREQ_RECON')

    actions_label = WIDGET_LABEL(actions_base, VALUE='Actions:')
    re_plot_button = WIDGET_BUTTON(actions_base, VALUE='Re-Plot', /FRAME, EVENT_PRO='EV_REPLOT_META_DATA')
    ok_create = WIDGET_BUTTON(actions_base, VALUE='Simulate', /FRAME, EVENT_PRO='EV_CREATE_NOISE')
    cancel_create = WIDGET_BUTTON(actions_base, VALUE='Cancel', /FRAME, EVENT_PRO='EV_CANCEL_CREATE')

    ; the function, GET_METABOLITE_VALUES was written for this .pro file, but was moved to
        ; FitmanViewOptions.pro on Nov. 12 2002.  Reason being, this function needed to be used
        ; there, and FitmanViewOptions.pro is built before FitmanSimulationOptions.pro.
    metabolites = GET_METABOLITE_VALUES()
    metabolite_widgets = INTARR(N_ELEMENTS(metabolites))

    FOR I=0, N_ELEMENTS(metabolites)-1 DO BEGIN
       metabolite_widgets[I] = CW_FIELD(metabolite_base, TITLE=metabolites[I].const_name + ':', $
                  VALUE=metabolites[I].pvalue, /FLOAT)
    ENDFOR
    metabolite_widgets = LONG(metabolite_widgets)

    which_noise_option = 0
    structure = {simulations:simulations,number_points:number_points, dwell_time_field:dwell_time_field, $
                 bandwidth_field:bandwidth_field, noise_options:noise_options, which_noise_option: $
            which_noise_option, metabolite_widgets:metabolite_widgets, domain_flag: $
            middle_plot_info.domain, output_directory:output_directory, signal_ratio1:signal_ratio1, $
            signal_ratio2:signal_ratio2, range1:range1, range2:range2}
    p_struct = ptr_new(structure, /NO_COPY)

    WIDGET_CONTROL, simulate_base, /REALIZE
    WIDGET_CONTROL, simulate_draw, GET_VALUE=r_drawId

    PLOT_RECONSTRUCTION, (*p_struct).domain_flag

    WIDGET_CONTROL, simulate_base, SET_UVALUE=p_struct
    XMANAGER, 'simulate', simulate_base

        printTime,"In EV_SIMULATE- Bottom"
END

PRO PLOT_RECONSTRUCTION, domain
    COMMON common_vars
    COMMON DrawR_Comm
    COMMON plot_variables

    WSET, r_drawId

    IF (domain EQ 0) THEN data = middle_actual_time_data_points
    IF (domain EQ 1) THEN data = middle_actual_freq_data_points

    IF (FLOAT(middle_time_data_points[1,0]) EQ 1 AND IMAGINARY(middle_time_data_points[1,0]) EQ 0) THEN BEGIN
       min = MIN(FLOAT(data))
       max = MAX(FLOAT(data))
    ENDIF
    IF (FLOAT(middle_time_data_points[1,0]) EQ 0 AND IMAGINARY(middle_time_data_points[1,0]) EQ 1) THEN BEGIN
       min = MIN(IMAGINARY(data))
       max = MAX(IMAGINARY(data))
    ENDIF
    IF (FLOAT(middle_time_data_points[1,0]) EQ 1 AND IMAGINARY(middle_time_data_points[1,0]) EQ 1) THEN BEGIN
       IF (MAX(FLOAT(data)) GT MAX(IMAGINARY(data))) THEN BEGIN
         max = MAX(FLOAT(data))
       ENDIF ELSE BEGIN
         max = MAX(IMAGINARY(data))
       ENDELSE

       IF (MIN(FLOAT(data)) LT MIN(IMAGINARY(data))) THEN BEGIN
         min = MIN(FLOAT(data))
       ENDIF ELSE BEGIN
         min = MIN(IMAGINARY(data))
       ENDELSE
    ENDIF

    IF (domain EQ 1) THEN BEGIN
       display_plot, 1, middle_plot_info.freq_xmin, middle_plot_info.freq_xmax, min, max, 'Frequency (Hz)', $,
         middle_freq, data, 0, middle_plot_info.data_file, 0, 1, 0, middle_plot_color[1], 0, $
         middle_plot_color[1], middle_plot_info, middle_time_data_points, 0
    ENDIF ELSE IF (domain EQ 0) THEN BEGIN
       display_plot, 1, middle_plot_info.time_xmin, middle_plot_info.time_xmax, min, max, 'Time (s)', $
         actual_time, data, 0, middle_plot_info.data_file, 0,0,0, middle_plot_color[1], 0, $
         middle_plot_color[1], middle_plot_info, middle_time_data_points, 0
    ENDIF

END

PRO EV_BROWSE_OUTPUT, event
    COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=p_struct
    path_name = DIALOG_PICKFILE(/READ, GET_PATH=path)
    WIDGET_CONTROL, (*p_struct).output_directory, SET_VALUE=path
END

PRO SIMULATE_EVENT, event

    WIDGET_CONTROL, event.top, GET_UVALUE=p_struct
    WIDGET_CONTROL, event.Id, GET_UVALUE=choice

    CASE choice OF

    'DWELL_T' : BEGIN
       WIDGET_CONTROL, (*p_struct).bandwidth_field, SENSITIVE=0
       WIDGET_CONTROL, (*p_struct).dwell_time_field, GET_VALUE=dwell_time
       dwell_time = FLOAT(dwell_time[0])
       IF (dwell_time NE 0.0) THEN BEGIN
         band_width = 1/dwell_time
       ENDIF ELSE band_width = 0.0
       WIDGET_CONTROL, (*p_struct).bandwidth_field, SENSITIVE=1
       WIDGET_CONTROL, (*p_struct).bandwidth_field, SET_VALUE=band_width
    END

    'BANDWIDTH' : BEGIN
       WIDGET_CONTROL, (*p_struct).dwell_time_field, SENSITIVE=0
       WIDGET_CONTROL, (*p_struct).bandwidth_field, GET_VALUE=band_width
       band_width = FLOAT(band_width[0])
       IF (band_width NE 0.0) THEN BEGIN
         dwell_time = 1/band_width
       ENDIF ELSE dwell_time = 0.0
       WIDGET_CONTROL, (*p_struct).dwell_time_field, SENSITIVE=1
       WIDGET_CONTROL, (*p_struct).dwell_time_field, SET_VALUE=dwell_time
    END

    'NOISE_OPTS' : BEGIN
       WIDGET_CONTROL, (*p_struct).noise_options, GET_VALUE=option
       IF (option EQ 0) THEN (*p_struct).which_noise_option = 1
       IF (option EQ 1) THEN (*p_struct).which_noise_option = 2
    END
    ENDCASE
END

PRO EV_REPLOT_META_DATA, event
    COMMON common_vars
    COMMON plot_variables
    WIDGET_CONTROL, event.top, GET_UVALUE=p_struct
    WIDGET_CONTROL, /HOURGLASS

    metabolite_array = GET_METABOLITE_VALUES()
    metabolite_peaks = FLTARR(N_ELEMENTS(metabolite_array))

    count_position = WHERE(middle_peak[3,*].const_name NE '')
    count_position = FIX(count_position)

    FOR I=0, N_ELEMENTS(metabolite_array)-1 DO BEGIN
       WIDGET_CONTROL, (*p_struct).metabolite_widgets[I], GET_VALUE=temp
       metabolite_peaks[I] = temp
       middle_peak[3,count_position[I]].pvalue = metabolite_peaks[I]
    ENDFOR

    UPDATE_LINKS
    GENERATE_FIT_CURVE
    GENERATE_NEW_DATA
    PHASE_TIME_DOMAIN_DATA
    GENERATE_RESIDUAL
    IF((*p_struct).domain_flag EQ 1) THEN GENERATE_FREQUENCY
    MIDDLE_DISPLAY_DATA

    PLOT_RECONSTRUCTION, (*p_struct).domain_flag
END

PRO EV_TIME_RECON, event
    COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=p_struct

    (*p_struct).domain_flag = 0
    middle_plot_info.domain = (*p_struct).domain_flag
    MIDDLE_DISPLAY_DATA
    PLOT_RECONSTRUCTION, (*p_struct).domain_flag

END

PRO EV_FREQ_RECON, event
    COMMON common_vars

    WIDGET_CONTROL, event.top, GET_UVALUE=p_struct
    WIDGET_CONTROL, /HOURGLASS

    (*p_struct).domain_flag = 1
    middle_plot_info.domain = (*p_struct).domain_flag
    middle_plot_info.first_trace = 0
    middle_plot_info.last_trace = 1
    REDISPLAY
    PLOT_RECONSTRUCTION, (*p_struct).domain_flag
END

PRO EV_CANCEL_CREATE, event
    COMMON common_vars
    COMMON draw1_comm
    COMMON metabolite_vars

        WIDGET_CONTROL, /HOURGLASS
    position = WHERE(middle_peak[3,*].const_name NE '')
    position = FIX(position)
    FOR I=0, N_ELEMENTS(metabolites)-1 DO BEGIN
       middle_peak[3,position[I]].pvalue = metabolites[I].pvalue
    ENDFOR

        WIDGET_CONTROL, event.top, /DESTROY

    UPDATE_LINKS
    GENERATE_FIT_CURVE
    GENERATE_NEW_DATA
    PHASE_TIME_DOMAIN_DATA
    GENERATE_RESIDUAL
    IF (middle_plot_info.domain EQ 1) THEN GENERATE_FREQUENCY
    middle_plot_info.first_trace = 1
    MIDDLE_DISPLAY_DATA

    wset, draw2_id
END

FUNCTION SET_FACTOR, min,max,metabolite_data, ratio_top, ratio_bottom

    COMMON common_vars
    COMMON plot_variables

        printTime,"In SET_FACTOR- Top"

    count_position = WHERE(metabolite_data.const_name EQ 'PCR')
    count_position = count_position[0]
        IF (count_position EQ -1) THEN BEGIN
       ;ERROR_MESSAGE, "There is an error in the constraints file.  Please verify that this file contains all necessary data."
       err_result = DIALOG_MESSAGE('There is an error in the constraints file.  Please verify that this file contains all necessary data.', $
                        Title = 'ERROR', /ERROR)
    ENDIF

        print, metabolite_data.const_name

    ; bottom factor
    count = 0
    epsilon = 0.000001

    std_array = FLTARR(N_ELEMENTS(middle_freq))
    FOR I=0, N_ELEMENTS(std_array)-1 DO BEGIN
       test_subtract = ABS(middle_freq[I]-min)
       test_subtract1 = ABS(middle_freq[I]-max)
       IF ((middle_freq[I] GT min OR test_subtract LT epsilon) AND (middle_freq[I] LT max OR $
            test_subtract1 LT epsilon)) THEN BEGIN
         std_array[count] = middle_freq[I]
         count = count + 1
       ENDIF
    ENDFOR
    bottom_factor_vector = EXTRAC(std_array, 0, count)
    std_dev = STDDEV(bottom_factor_vector)

        printTime,"In SET_FACTOR- after for loop"

    NAA_peak_value = (ratio_top*std_dev)/ratio_bottom

        print, "count_position",count_position
    middle_peak[3,count_position].pvalue = NAA_peak_value

        printTime,"In SET_FACTOR- before fitman calls"

    UPDATE_LINKS
    GENERATE_FIT_CURVE
    GENERATE_NEW_DATA
    PHASE_TIME_DOMAIN_DATA
    GENERATE_RESIDUAL
    time_array = middle_actual_time_data_points

        printTime,"In SET_FACTOR- Bottom"

    return, time_array
END

FUNCTION ADD_NOISE, noise, data

    temp_array = FLTARR(N_ELEMENTS(noise)+1)
        index = 0
    FOR I=0, N_ELEMENTS(data)-1 DO BEGIN
       temp_array[index] = FLOAT(data[I]) + noise[I]
            index = index + 2
    ENDFOR

    index = 1
    FOR I=0, N_ELEMENTS(data)-1 DO BEGIN
       temp_array[index] = IMAGINARY(data[I]) + noise[I+N_ELEMENTS(data)+1]
       index = index + 2
    ENDFOR
    return, temp_array

END

FUNCTION findRange, min, max, data_header, p_info, freq_points

    COMMON common_vars

    count = 0
    epsilon = 0.000001

    ;max = MAX(freq_points)

    storage_vector=FLTARR(N_ELEMENTS(freq_points))

    FOR I=0, N_ELEMENTS(freq_points)-1 DO BEGIN
       diff = ABS(middle_freq[I]-min)
       diff1 = ABS(middle_freq[I]-max)

       IF ((middle_freq[I] GT min OR diff LT epsilon) AND (middle_freq[I] LT max OR diff1 $
       LT epsilon)) THEN BEGIN
         storage_vector[count] = I
         count = count+1
       ENDIF
    ENDFOR

    window_vect=COMPLEXARR(N_ELEMENTS(storage_vector))
    FOR I=0, N_ELEMENTS(storage_vector)-1 DO BEGIN
       window_vect[I] = freq_points[storage_vector[I]]
    ENDFOR

    new_window_vector=EXTRAC(window_vect, 0, count)
    return, new_window_vector
END


FUNCTION CALCULATE_SIGNAL_TO_NOISE, smin, smax, num_pts, sigtop, sigbottom

    COMMON recon
    COMMON common_vars

    window_vector = findRange(smin, smax, middle_data_file_header, middle_plot_info,$
            middle_recon)

    std_noise_freq = (sigbottom*MAX(FLOAT(window_vector)))/sigtop
    std_noise_time = SQRT(num_pts/2)*std_noise_freq

    return, std_noise_time
END

FUNCTION GET_TIME_ARRAY,data, p_info, header

    time_pts = REFORM(data[0, fix(p_info.time_xmin/header.dwell)+1:$
          (fix(p_info.time_xmax/header.dwell)+1)])
    return, time_pts

END

PRO EV_CREATE_NOISE, event

    COMMON common_vars
    COMMON plot_variables
    COMMON recon

        printTime,"In EV_CREATE_NOISE- Top"

    WIDGET_CONTROL, event.top, GET_UVALUE=p_struct
    WIDGET_CONTROL, (*p_struct).simulations, GET_VALUE=simulations
    WIDGET_CONTROL, (*p_struct).number_points, GET_VALUE=pts
    WIDGET_CONTROL, (*p_struct).dwell_time_field, GET_VALUE=dwell_time
    WIDGET_CONTROL, (*p_struct).output_directory, GET_VALUE=directory
    WIDGET_CONTROL, (*p_struct).signal_ratio1, GET_VALUE=top
    WIDGET_CONTROL, (*p_struct).signal_ratio2, GET_VALUE=bottom
    WIDGET_CONTROL, (*p_struct).range1, GET_VALUE=smin
    WIDGET_CONTROL, (*p_struct).range2, GET_VALUE=smax
    dwell_time = FLOAT(dwell_time[0])
    smin = FLOAT(smin[0])
    smax = FLOAT(smax[0])
    directory = directory[0]

    IF (simulations LE 0) THEN BEGIN
       ;ERROR_MESSAGE, "The number of simulations must be greater than 0.  Please re-enter the value."
       err_result = DIALOG_MESSAGE('The number of simulations must be greater than 0.  Please re-enter the value.', $
                        Title = 'ERROR', /ERROR)
    ENDIF

    IF (pts LE 0) THEN BEGIN
       ;ERROR_MESSAGE, "The number of points is INVALID!  Please re-enter the value."
       err_result = DIALOG_MESSAGE('The number of points is INVALID!  Please re-enter the value.', $
                        Title = 'ERROR', /ERROR)
       RETURN
    ENDIF

    IF (directory NE '') THEN BEGIN
       position = RSTRPOS(directory, '/')
       IF ((position+1) NE STRLEN(directory)) THEN BEGIN
         message = 'The output directory has been specified incorrectly.  Please re-enter a valid directory name.'
         ;ERROR_MESSAGE, message
         err_result = DIALOG_MESSAGE('The output directory has been specified incorrectly.  Please re-enter a valid directory name.', $
                        Title = 'ERROR', /ERROR)
         RETURN
       ENDIF
    ENDIF ELSE BEGIN
       ;ERROR_MESSAGE, "A directory must be specified in order to run the simulations."
       err_result = DIALOG_MESSAGE('A directory must be specified in order to run the simulations.', $
                        Title = 'ERROR', /ERROR)
       RETURN
    ENDELSE

        ;printTime,"In EV_SIMULATE- Before GET_METABOLITE_VALUES() call"

    metabolite_array = GET_METABOLITE_VALUES()
        printTime,"In EV_SIMULATE- Before SET_FACTOR(..) call"
    ;peak_array = SET_FACTOR(smin,smax,metabolite_array, top, bottom)

        ;printTime,"In EV_SIMULATE- Before for loop"

    FOR I=0, simulations-1 DO BEGIN
       IF ((*p_struct).which_noise_option=1) THEN BEGIN
         factor = CALCULATE_SIGNAL_TO_NOISE(smin, smax, pts, top, bottom)
                        print, 'factor:',factor
         noise = factor*RANDOMU(seed, pts-1, /NORMAL)
                        print,'std:' ,STDDEV(noise)


                        ;time = GET_TIME_ARRAY(middle_time_data_points,middle_plot_info, middle_data_file_header)
                        time = REFORM(middle_time_data_points[1, $
               fix(middle_plot_info.time_xmin/middle_data_file_header.dwell)+1:$
               (fix(middle_plot_info.time_xmax/middle_data_file_header.dwell)+1)])
                        ;print, time[0:10]
                        noise_add = ADD_NOISE(noise, time)

         file = directory+'simulation_'+STRCOMPRESS(STRING(I),/REMOVE_ALL)+'.dat'
         ADD_HEADER_INFORMATION, file, pts, dwell_time, noise_add,middle_data_file_header.frequency
       ENDIF
    ENDFOR
        ;ERROR_MESSAGE,"Simulation Complete!",TITLE="Noise Simulation"
        err_result = DIALOG_MESSAGE('Simulation complete.', $
                        Title = 'NOISE SIMULATION', /INFORMATION)
END

PRO ADD_HEADER_INFORMATION, temp_file, points, dwell, data,frequency

    pos = RSTRPOS(temp_file, '/')
    file_name = STRMID(temp_file, pos+1, STRLEN(temp_file))
    openw, unit, temp_file, /GET_LUN
    PRINTF, unit, points
    PRINTF, unit, '1'
    PRINTF, unit, dwell
    PRINTF, unit, frequency
    PRINTF, unit, '2'
    PRINTF, unit, file_name
    month_day = STRMID(SYSTIME(0), 4, 6)
    year = STRMID(SYSTIME(0), 20, 4)
    PRINTF, unit, '"' + month_day + ' '  + year + '"'
    PRINTF, unit, 'MachS=0 ConvS=1.00e-01 V1=60.000 V2=60.000 V3=60.000 vtheta=31.6'
    PRINTF, unit, 'TE=0.008 s TM=0.080 s P1=0.00000 P2=0.00000 P3=0.00000 Gain=30.00'
    PRINTF, unit, 'SIMULTANEOUS'
    PRINTF, unit, '0.0'
    PRINTF, unit, 'EMPTY'
    FOR I=0, N_ELEMENTS(data)-1 DO BEGIN
       PRINTF, unit, data[I]
    ENDFOR
    CLOSE, unit
    FREE_LUN, unit
END

