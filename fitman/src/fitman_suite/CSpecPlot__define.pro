pro CSpecPlot__define
    maxPoints = 8200
    
    plot_info = {plot_information, domain:0, fft_initial:0.0, fft_final:0.0, data_file:'', $
			time_ymax:0.0, time_ymin:0.0, time_xmax:0.0, time_xmin:0.0, freq_ymax:0.0, $
			freq_ymin:0.0, freq_xmax:0.0, freq_xmin:0.0, first_freq:0, phase:0.0, display:0,$ 
			guess_file:'', traces:0, current_phase:0.0, first_trace:0, last_trace:0, $
			current_curve:0, grouping:3, expon_filter:0.0, gauss_filter:0.0, delay_time:0.0, $
			read_file_type:0, const_file:'', num_linked_groups:0, max_colours:15, $
			time_auto_scale_x:1, time_auto_scale_y:1, freq_auto_scale_x:1, freq_auto_scale_y:1,$
			view:0, axis_colour:15, xaxis:0, fft_recalc:1, cursor_active:0, x1:0.0, y1:0.0, $
			x2:0.0, y2:0.0,mz_cursor_active:0, sx:0.0,sy:0.0,dx:0.0,dy:0.0, isZoomed:0, down:0}

    data_file_header = {Data_header, points:0, components:0, dwell:0.0, frequency:0.0, scans:0, $
			comment1:'', comment2:'', comment3:'', comment4:'', acq_type:'', increment:0.0, $
			empty:''}

    color_struct = {c_struct, creal:15, cimag:15, offset:0.0, thick:1.0} 

    void = {CSpecPlot,fileHeader:REPLICATE(data_file_header,1),$
              info:REPLICATE(plot_info,1), plotColor:REPLICATE(color_struct, 300),$
            timeDataPoints:complexarr(3,maxPoints), freqDataPoints:complexarr(3,maxPoints),$
            actualFreqDataPoints:ptr_new(),point_index:ptr_new(), freq:ptr_new(),$
            originalData:complexarr(3,maxPoints),view:0,zCoords:ptr_new(),zCreated:0,min:0.0,$
            max:0.0, print:0}
end

function readfLine,unit
   parms = ''

   repeat begin
     null_string = 1
     readf, unit, parms 
     if parms EQ "" THEN null_string = 0
   endrep until null_string ;reads next line of file.
        
   return, parms
end

;=============================================================
; Public Methods
;=============================================================

pro CSpecPlot::setDomain,domain
   self.info[0].domain = domain
end

function CSpecPlot::getDomain
   return, self.info[0].domain 
end

pro CSpecPlot::setView, NORMAL=norm,V3D=v3d
   if(keyword_set(norm)) then begin
     self.view = 0
   endif else if(keyword_set(v3d)) then begin
     self.view = 1
   endif
end

function CSpecPlot::getAxisColor
   return, self.info[0].axis_colour
end

pro CSpecPlot::loadFitmanData, fileName
 
  ;This procedure reads the parameters from the data file's procpar file that are 
  ;required for the dw.pro main procedure. 
  ;COMMON common_vars
  
  self->_initStruct

  parms = ''	;variable for reading in lines of code of variable lengths
  realv = ''
  imagv = ''
  
  self.info[0].data_file = fileName
  openr, unit, self.info[0].data_file, /GET_LUN	;opens data file  
  
  ;Read header information
    
  self.fileHeader[0].points = FIX(STRMID(readfLine(unit), 0))
  self.fileHeader[0].components = FIX(STRMID(readfLine(unit), 0))
  self.fileHeader[0].dwell = FLOAT(STRMID(readfLine(unit), 0))
  self.fileHeader[0].frequency = FLOAT(STRMID(readfLine(unit), 0))
  self.fileHeader[0].scans = FIX(STRMID(readfLine(unit), 0))
  self.fileHeader[0].comment1 = (STRMID(readfLine(unit), 0))
  self.fileHeader[0].comment2 = (STRMID(readfLine(unit), 0))
  self.fileHeader[0].comment3 = (STRMID(readfLine(unit), 0))
  self.fileHeader[0].comment4 = (STRMID(readfLine(unit), 0))
  self.fileHeader[0].acq_type = (STRMID(readfLine(unit), 0))
  self.fileHeader[0].increment = FLOAT(STRMID(readfLine(unit), 0))
  self.fileHeader[0].empty = (STRMID(readfLine(unit), 0))
  
  index = ((self.fileHeader[0].points/2))
 
  for i = 1, index do begin
     realv = readfLine(unit)
     imagv = readfLine(unit)      

     self.timeDataPoints[0, i] = COMPLEX(FLOAT(STRMID(realv,0)), FLOAT(STRMID(imagv,0)))  
 
  endfor  
  
  CLOSE, unit 
  FREE_LUN, unit

  self.freq = ptr_new(complexarr(index))
  self.point_index = ptr_new(fltarr(index))
  self.actualFreqDataPoints = ptr_new(complexarr(index))

  self.originalData = REFORM(self.timeDataPoints[0,*])
  self.info[0].fft_final = float(self.fileHeader[0].points/2 * self.fileHeader[0].dwell)

  self->_autoScale 

  self.timeDataPoints[0,0] = complex(1,0)

  self->setDomain,1
  self->phaseTimeDomainData
  self->generateFrequency

  self.info[0].traces = 0  
end 

pro CSpecPlot::displayData 
	  ;This procedure displays the data 

  	COMMON common_vars
  	COMMON common_widgets
        COMMON draw1_comm
         
        if(self.info[0].data_file eq '') then begin
           return
        endif

  	first_fft = fix(self.info[0].fft_initial/self.fileHeader[0].dwell)
  	last_fft = fix(self.info[0].fft_final/self.fileHeader[0].dwell)-1 

  	first_trace_plot1 = 0   
  	first_trace_plot2 = 0   
        
        self->_setUpPlot
 
        i = 0        
     	self.info[0].current_curve = i       

     	IF (ABS(self.timeDataPoints[i,0]) GT 0 AND i LE 2) THEN BEGIN

           IF (self.info[0].domain EQ 0) THEN BEGIN
                ; time
           	self->_autoScale

                dummy = self.timeDataPoints
                actualTimeDataPoints = REFORM(dummy[i, $
		fix(self.info[0].time_xmin/self.fileHeader[0].dwell)+1:$
		(fix(self.info[0].time_xmax/self.fileHeader[0].dwell)+1)])
      
           	time = (*self.point_index) * self.fileHeader[0].dwell

	      	actual_time = EXTRAC(time, self.info[0].time_xmin/self.fileHeader[0].dwell, $
              	self.info[0].time_xmax/self.fileHeader[0].dwell-self.info[0].time_xmin/self.fileHeader[0].dwell)
                
                if(self.view eq 0) then begin 
                   display_plot,i,self.info[0].time_xmin,self.info[0].time_xmax,$
                       self.info[0].time_ymin,self.info[0].time_ymax,'Time (s)',actual_time,$
                       actualTimeDataPoints,first_trace_plot1,self.info[0].data_file,0,0,0,$
                       self.plotColor[i],0, self.plotColor[i],self.info[0],self.timeDataPoints,reverse_flag2 
                endif else if(self.view eq 1) then begin
                    self->_3DPlot,i,actual_time,actualTimeDataPoints 
                endif   

	    ENDIF ELSE BEGIN
  
                ;Switch the data so that the lowest frequency information is at the beginning
                N_middle = (last_fft - first_fft)/2+1
                N_end = (last_fft - first_fft)

                temp1 = self.freqDataPoints[i, N_middle : N_end]
                temp2 = self.freqDataPoints[i, 1: N_middle]
                temp1 = REFORM(temp1)
                temp2 = REFORM(temp2)
                (*self.actualFreqDataPoints) = [temp1, temp2] 
            
                ;Create the frequency axis in units of HZ
                bandwidth = 1/self.fileHeader[0].dwell
                delta_freq = bandwidth/ (last_fft - first_fft+1)
                temp3 = FINDGEN((last_fft - first_fft)/2+2)
                temp4 = REVERSE(temp3)
                temp5 = temp4 * (-1.0)
                temp6 = FINDGEN((last_fft - first_fft)/2+1)
                temp7 = temp6[1: (last_fft - first_fft)/2]
                freqPointIndex = [temp5 , temp7]

	        IF (reverse_flag2 EQ 0) THEN BEGIN
		  (*self.freq) = ((-1*freqPointIndex)) * delta_freq
	        ENDIF ELSE BEGIN
	   	  (*self.freq) = (freqPointIndex) * delta_freq
	        ENDELSE

                self->_autoScale

	        freq_x_axis_title = 'Frequency (Hz)'
		
                ;Check to see if the data is plotted in Hz or PPM
                IF (self.info[0].xaxis EQ 1) THEN BEGIN
                   (*self.freq) = (*self.freq) / self.fileHeader[0].frequency
                   freq_x_axis_title = 'Frequency (ppm)'
                ENDIF
           
                if(self.view eq 0) then begin     
                   display_plot,i,self.info[0].freq_xmin,self.info[0].freq_xmax,$
                       self.info[0].freq_ymin,self.info[0].freq_ymax,freq_x_axis_title,(*self.freq),$
                       (*self.actualFreqDataPoints),first_trace_plot1,self.info[0].data_file,1,1,0,$
                       self.plotColor[i],0,self.plotColor[i],self.info[0],self.timeDataPoints,reverse_flag2     
                endif else if(self.view eq 1) then begin
                   ptsIndex = where( ((*self.freq) ge self.info[0].freq_xmin) AND ((*self.freq) le $
                                self.info[0].freq_xmax))   
                   xpts = (*self.freq)[ptsIndex]
                   ypts = (*self.actualFreqDataPoints)[ptsIndex]

                   ;self->_3DPlot,i,(*self.freq),(*self.actualFreqDataPoints) 
                   self->_3DPlot,i,xpts,ypts 
               endif   
         ENDELSE     
   ENDIF 
END

pro CSpecPlot::generateFrequency
     first_fft = fix(self.info[0].fft_initial/self.fileHeader[0].dwell)+1
     last_fft = fix(self.info[0].fft_final/self.fileHeader[0].dwell)

     for i=0, self.info[0].traces DO BEGIN

     	actualTimeDataPoints = REFORM(self.timeDataPoints[i, first_fft:last_fft])
 
        ; correction made by Tim Orr.  Although forcing the number of points to be Fourier transformed
        ; reduces the time for the FFT algorithm to complete, padding the time_data array with zeros 
        ; changes the shape of the graph.  As such, the code previously present that did this was
        ; removed.

        points_to_FFT = N_ELEMENTS(actualTimeDataPoints) 

	; FFT the data     
	self.freqDataPoints[i,1:N_ELEMENTS(actualTimeDataPoints)] = FFT(actualTimeDataPoints)     
     endfor
end

pro CSpecPlot::phaseTimeDomainData  
      	phase_applied =  (self.info[0].phase/180.0)*!PI - self.info[0].current_phase
        self.info[0].traces =1
   	self.info[0].current_phase = (self.info[0].phase/180)*!PI
   	
   	display_holder = self.timeDataPoints[0:self.info[0].traces,0]
   	
   	data_magnitude = ABS(self.timeDataPoints[0:self.info[0].traces,*])
   	data_phase = ATAN(imaginary(self.timeDataPoints[0:self.info[0].traces,*]), float(self.timeDataPoints[0:self.info[0].traces,*])) - phase_applied
   
   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)
   
   	self.timeDataPoints[0:self.info[0].traces, *] = complex(data_real, data_imag)
   
   	self.timeDataPoints[0:self.info[0].traces,0] = display_holder

   	data_magnitude = ABS(self.originalData)
   	data_phase = ATAN(imaginary(self.originalData), float(self.originalData)) - phase_applied
    
   	data_real = data_magnitude * COS(data_phase)
   	data_imag = data_magnitude * SIN(data_phase)

   	self.originalData = complex(data_real, data_imag)
      
   	;Reassign plot identifier from above
   	self.originalData[0] =self.timeDataPoints[0,0]
end

pro CSpecPlot::setPrint,ENABLE=enable,DISABLE=disable
   if(keyword_set(enable)) then begin
      self.print = 1
   endif else if(keyword_set(disable)) then begin
      self.print = 0
   endif      
end

pro CSpecPlot::setXMin,xmin
  IF (self.info[0].domain EQ 0) THEN begin 
      self.info[0].time_auto_scale_x = 0 
      self.info[0].time_xmin = xmin
  endif ELSE begin 
      self.info[0].freq_auto_scale_x = 0
      self.info[0].freq_xmin = xmin
  endelse
  self.info[0].fft_recalc = 1
end

pro CSpecPlot::setXMax,xmax
  IF (self.info[0].domain EQ 0) THEN begin 
      self.info[0].time_auto_scale_x = 0 
      self.info[0].time_xmax = xmax
  endif ELSE begin
      self.info[0].freq_auto_scale_x = 0
      self.info[0].freq_xmax = xmax
  endelse
  self.info[0].fft_recalc = 1
end

pro CSpecPlot::setYMin,ymin
  IF (self.info[0].domain EQ 0) THEN begin 
      self.info[0].time_auto_scale_y = 0 
      self.info[0].time_ymin = ymin
  endif ELSE begin
      self.info[0].freq_auto_scale_y = 0
      self.info[0].freq_ymin = ymin
  endelse
  self.info[0].fft_recalc = 1
end

pro CSpecPlot::setYMax,ymax
  IF (self.info[0].domain EQ 0) THEN begin 
      self.info[0].time_auto_scale_y = 0 
      self.info[0].time_ymax = ymax
  endif ELSE begin
      self.info[0].freq_auto_scale_y = 0
      self.info[0].freq_ymax = ymax
  endelse
  self.info[0].fft_recalc = 1
end

function CSpecPlot::getXMin
  val = 0.0
  if(self.info[0].domain eq 0) then begin
    val = self.info[0].time_xmin
  endif else begin
    val = self.info[0].freq_xmin
  endelse
  return, val
end

function CSpecPlot::getXMax
  val = 0.0
  if(self.info[0].domain eq 0) then begin
    val = self.info[0].time_xmax
  endif else begin
    val = self.info[0].freq_xmax
  endelse
  return, val
end

function CSpecPlot::getYMin
  val = 0.0
  if(self.info[0].domain eq 0) then begin
    val = self.info[0].time_ymin
  endif else begin
    val = self.info[0].freq_ymin
  endelse
  return, val
end

function CSpecPlot::getYMax
  val = 0.0
  if(self.info[0].domain eq 0) then begin
    val = self.info[0].time_ymax
  endif else begin
    val = self.info[0].freq_ymax
  endelse
  return, val
end

pro CSpecPlot::setFFTInitial,fft_initial
   self.info[0].fft_recalc = 1
   self.info[0].fft_initial = fft_initial
   self->generateFrequency 
end

pro CSpecPlot::setFFTFinal, fft_final
   self.info[0].fft_recalc = 1
   self.info[0].fft_final = fft_final
   self->generateFrequency 
end

function CSpecPlot::getFFTInitial
   return, self.info[0].fft_initial
end

function CSpecPlot::getFFTFinal
   return, self.info[0].fft_final
end

pro CSpecPlot::setPhase,phase
   self.info[0].phase = phase
   self.info[0].fft_recalc = 1

   self->phaseTimeDomainData
   if (self.info[0].domain EQ 1) then self->generateFrequency 
end

function CSpecPlot::getPhase
   return, self.info[0].phase
end

pro CSpecPlot::setExponFilter, val
    self.info[0].expon_filter = val
    self->_setFilters
end

pro CSpecPlot::setGaussFilter,val
    self.info[0].gauss_filter = val
    self->_setFilters
end

function CSpecPlot::getExponFilter
    return, self.info[0].expon_filter
end

function CSpecPlot::getGaussFilter
    return, self.info[0].gauss_filter
end

pro CSpecPlot::setZCoord,z
  if(self.zCreated eq 0) then begin
    self.zCoords = ptr_new(fltarr(n_elements((*self.point_index))))
    self.zCreated = 1
  endif
  for i = 0, n_elements((*self.zCoords))-1 do begin
     (*self.zCoords)[i] = z
  end 
end

pro CSpecPlot::saveYMinMax
    self.min = self->getYMin()
    self.max = self->getYMax()
end

pro CSpecPlot::restoreYMinMax
   self->setYMin,self.min
   self->setYMax,self.max
end

;===========================================================
; Private Methods
;===========================================================

pro CSpecPlot::_setFilters
    G_FWHM_C = !PI / (4*ALOG10(2))
    TIME = (*self.point_index) * self.fileHeader[0].dwell

    EXPON_LOR = exp(DOUBLE(-1.0 * !PI * (self.info[0].expon_filter) * ABS(TIME + self.info[0].delay_time)))        
    EXPON_GAU = exp(DOUBLE(-1.0 * !PI * G_FWHM_C * (self.info[0].gauss_filter) * (self.info[0].gauss_filter) * ABS(TIME + self.info[0].delay_time) * ABS(TIME + self.info[0].delay_time)))

    EXPON = EXPON_LOR * EXPON_GAU
    ;print, EXPON

    real_data = FLOAT(self.originalData[1:N_ELEMENTS((*self.point_index))]) * EXPON
    imag_data = IMAGINARY(self.originalData[1:N_ELEMENTS((*self.point_index))]) * EXPON
      
    self.timeDataPoints[0,1:N_ELEMENTS(real_data)] = complex(real_data, imag_data)
    
    if(self.info[0].domain eq 1) then begin
       self->generateFrequency
    endif
end

pro CSpecPlot::_3DPlot, i,xPoints, yPoints
  if(self.zCreated eq 1) then begin
    if(self.info[0].domain eq 1) then begin 
      plots, (*self.zCoords),xPoints,yPoints,/T3D, $
		color = self.plotColor[i].creal, THICK =  self.plotColor[i].thick
    endif else if(self.info[0].domain eq 0) then begin
      plots, xPoints,(*self.zCoords),yPoints,/T3D, $
		color = self.plotColor[i].creal, THICK =  self.plotColor[i].thick
    endif
  endif 
end

pro CSpecPlot::_setUpPlot
     common common_vars
     
     if(self.print eq 0) then begin
        TVLCT, Red, Green, Blue
        self.info[0].axis_colour = 2
        self.plotColor[0].creal = 3
        self.plotColor[0].cimag = 1
        self.plotColor[1].creal = 5  ;Plot the reconstructed curves in RED
        self.plotColor[1].cimag = 5  ;Plot the reconstructed curves in RED
        self.plotColor[2].creal = 4  ;Plot the residual  in BLUE
        self.plotColor[2].cimag = 4  ;Plot the residual  in BLUE
     
        !P.BACKGROUND = 0
     endif else begin
        loadct, 0
  	stretch, 0, plot_info.max_colours
  	; Load in a standard color table to use for plotting lines
	self.info[0].axis_colour = 0		
   	self.plotColor[0].creal = 7
   	self.plotColor[0].cimag = 12
   	self.plotColor[1].creal = 0  ;Plot the reconstructed curves in RED
   	self.plotColor[1].cimag = 0  ;Plot the reconstructed curves in RED
   	self.plotColor[2].creal = 7  ;Plot the residual  in BLUE
   	self.plotColor[2].cimag = 12  ;Plot the residual  in BLUE

        !P.BACKGROUND = 15
     endelse 

     self.plotColor[1].thick = 1.25

     !X.CHARSIZE = 1.2
     !Y.CHARSIZE = 1.2
     !P.CHARSIZE = 1.2
     !Y.STYLE = 9
     !X.STYLE = 9
     !X.MARGIN = [12, 3]
     !Y.MARGIN = [4, 2]
     !Y.TICKLEN = -.01
end

pro CSpecPlot::_autoScale

   	COMMON common_vars
        COMMON common_widgets
   	;Generate x-axis
   	(*self.point_index) = FINDGEN(self.fileHeader[0].points/2)

   	IF (self.info[0].domain EQ 0) AND (self.info[0].time_auto_scale_x EQ 1) AND $
	   (self.info[0].current_curve EQ 0) THEN BEGIN
	      time = (*self.point_index) * self.fileHeader[0].dwell
	      time = [0, time]

      	      self.info[0].time_xmin = time[0]
      	      self.info[0].time_xmax = MAX(time)
   	ENDIF

   	IF (self.info[0].domain EQ 0) AND (self.info[0].time_auto_scale_y EQ 1) AND $
	   (self.info[0].current_curve EQ 0) THEN BEGIN
      			self.info[0].time_ymin = MIN(self.timeDataPoints[0,*]) + 0.1*MIN(self.timeDataPoints[0,*])
      			self.info[0].time_ymax = MAX(self.timeDataPoints[0,*]) + 0.3*MAX(self.timeDataPoints[0,*])
   	ENDIF

   	IF (self.info[0].domain EQ 1) AND (self.info[0].freq_auto_scale_x EQ 1) AND $
	   (self.info[0].current_curve EQ 0) THEN BEGIN
      		IF (self.info[0].xaxis EQ 0) THEN BEGIN
         	    self.info[0].freq_xmin = MIN((*self.freq))
         	    self.info[0].freq_xmax = MAX((*self.freq))
      		ENDIF ELSE BEGIN
        	    self.info[0].freq_xmin = MIN((*self.freq))/self.fileHeader[0].frequency
         	    self.info[0].freq_xmax = MAX((*self.freq))/self.fileHeader[0].frequency
      		ENDELSE
   	ENDIF		

   	IF (self.info[0].domain EQ 1) AND (self.info[0].freq_auto_scale_y EQ 1) AND $
	   (self.info[0].current_curve EQ 0) THEN BEGIN
	   self.info[0].freq_ymin = MIN((*self.actualFreqDataPoints)) + 0.1*MIN((*self.actualFreqDataPoints))
	   self.info[0].freq_ymax = MAX((*self.actualFreqDataPoints)) + 0.3*MAX((*self.actualFreqDataPoints))
   	ENDIF		

   	; Set offset of the residual so that it appears at the top
   	; First determine the maximum value in the residual

   	IF (self.info[0].domain EQ 0) AND (self.info[0].time_auto_scale_y EQ 1) AND $
	   (self.info[0].current_curve EQ 2) THEN BEGIN
      	   max_residual_value = MAX(self.timeDataPoints[2,*])
      	   self.plotColor[2].offset = -1*(self.info[0].time_ymax -max_residual_value)
   	ENDIF

   	IF (self.info[0].domain EQ 1) AND (self.info[0].freq_auto_scale_y EQ 1) AND $
	   (self.info[0].current_curve EQ 2) THEN BEGIN
      	    max_residual_value = MAX((*self.actualFreqDataPoints))
      	    self.plotColor[2].offset = -1*(self.info[0].freq_ymax -max_residual_value)
   	ENDIF	
end

pro CSpecPlot::_initStruct
      self.info[0].domain=0
      self.info[0].fft_initial=0.0
      self.info[0].fft_final=0.0
      self.info[0].first_freq=0
      self.info[0].phase=0.0
      self.info[0].display=0 
      self.info[0].traces=0 
      self.info[0].current_phase=0.0
      self.info[0].first_trace=0
      self.info[0].last_trace=0
      self.info[0].current_curve=0
      self.info[0].grouping=3
      self.info[0].expon_filter=0.0
      self.info[0].gauss_filter=0.0
      self.info[0].delay_time=0.0
      self.info[0].read_file_type=0
      self.info[0].num_linked_groups=0
      self.info[0].max_colours=15 
      self.info[0].time_auto_scale_x=1
      self.info[0].time_auto_scale_y=1
      self.info[0].freq_auto_scale_x=1
      self.info[0].freq_auto_scale_y=1
      self.info[0].view=0
      self.info[0].axis_colour=15
      self.info[0].xaxis=0
      self.info[0].fft_recalc=1
end
