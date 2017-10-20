;=================================================================================================
; Name: FitmanHelp.pro 
;
;=================================================================================================

pro helpData__define
   define = {helpData,title:'',fileName:''}
end                                                                       

pro EVHELP,event
  XDISPLAYFILE,'./help/welcome.txt' 
end

pro EV_HELP, event
   COMMON help_comm, hData,title,txt
   
   FORWARD_FUNCTION getFileNames
   FORWARD_FUNCTION getTitles
   
   fnames = getFileNames()
   values = getTitles(fnames)
   
   hbase = WIDGET_BASE(COL=2, MAP=1, TITLE="Help Topics", UVALUE='d_base')
    
   lbase = widget_base(hbase,ROW=2)
   sbase = widget_base(lbase,ROW=3,/FRAME)
   
   se_label = CW_FIELD(sbase,TITLE='',/STRING)
   sbtn = widget_button(sbase,VALUE='Search',EVENT_PRO='EV_SEARCH')   
   list = widget_list(sbase,VALUE=values,YSIZE=10,XSIZE=10,EVENT_PRO='LIST_EVENT')
   ebtn = widget_button(lbase,VALUE='Close',EVENT_PRO='EV_HELPEXIT')
   
   vbase = widget_base(hbase,ROW=2,/FRAME)
   title = widget_label(hbase,VALUE='Text Title',/DYNAMIC_RESIZE)
   txt = widget_text(hbase,/SCROLL,YSIZE=30,XSIZE=50,/WRAP)
   
   
   state = { se:se_label,list:list}
   pstate = ptr_new(state, /NO_COPY)

   WIDGET_CONTROL,hbase, SET_UVALUE=pstate
   WIDGET_CONTROL, hbase, /REALIZE
   XMANAGER, 'FitHelp', hbase
    
end

pro LIST_EVENT,event
   COMMON help_comm
     
   WIDGET_CONTROL,title,SET_VALUE=hData[event.index].title
   
   file = hData[event.index].fileName
   WIDGET_CONTROL,txt,SET_VALUE=''
   
   openr,unit,file,/GET_LUN
   
   line=''
   readf,unit,line
   
   while(not(EOF(unit))) do begin
     line = ''
     readf,unit,line
     WIDGET_CONTROL,txt,SET_VALUE=line,/APPEND
   endwhile
   
   CLOSE, unit
   FREE_LUN, unit
   
end

pro EV_SEARCH,event


end

pro EV_HELPEXIT, event
  WIDGET_CONTROL, event.top, /DESTROY
end


function getFileNames
   name = "helpFiles.txt"
   openr, unit, name, /GET_LUN
   
   flist = obj_new('List')
   
   while(not(EOF(unit))) do begin
      line = ''
      readf,unit,line
      flist->add,line
   endwhile
   
   CLOSE, unit
   FREE_LUN, unit
   
   fnames = STRARR(flist->size())
   
   size = flist->size()
   
   for i = 0, size-1 do begin
     fnames[i] = flist->getData(i)
   endfor   
  
   obj_destroy,flist 
  
   return, fnames
end

function getTitles,fnames
   COMMON help_comm
   
   size = n_elements(fnames)
   titles = STRARR(size)
   hData = REPLICATE({helpData},size) 
   
   for i = 0, size-1 do begin
       file = fnames[i]
       openr, unit, file,/GET_LUN
       
       name = ''
       readf,unit, name
       titles[i] = name 
       hData[i].title = name
       hData[i].fileName = file    
   
       CLOSE, unit
       FREE_LUN, unit
   endfor    
   
   return, titles
end