;====================================================================================
;Name: List__define.pro
;Description: A class that is an ADT List implementation using a singly-linked list
;Use: To create a List object, simply o = obj_new('List'), to destroy the class, call
;     o->destroy
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================== 



;===================================================================================
;Name: List__define
;Purpose: defines the List class (constructor)
;Pre-condition: none
;Post-condition: the List class is defined
;
;Author: John-Paul Lobos
;Date: 04/29/02
;===================================================================================
pro List__define
   llist = {Node,data:'',next:ptr_new()}
   
   define = {List,llist:llist,length:0L,first:ptr_new()}
end

;==================================================================================
;Name: List::add
;Purpose: adds data to this List
;Param - data: the data to add to this List
;Pre-condition: data has a value
;Post-condition: data is added to the end of this List
;Returns: none
;
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================
pro List::add, data
  if(not(ptr_valid(self.first))) then begin
      self.first = ptr_new(self.llist)
      current = self.first
  endif else begin
      current = self.first
      
      while ptr_valid((*current).next) do begin
          current = (*current).next
      endwhile
      
      (*current).next = ptr_new(self.llist)
      current = (*current).next
  endelse  
  
  (*current).data = data
  (*current).next = ptr_new()
  self.length = self.length + 1
end


;==================================================================================
;Name: List::print
;Purpose: prints the data contained in the list out
;Pre-condition: none
;Post-condition: prints the elements in this list in the console
;Returns: none
;
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================
pro List::print

   c = self.first
   
   while ptr_valid(c) do begin
       print, (*c).data
       c = (*c).next
   endwhile
   
end


;==================================================================================
;Name: List::findIndex
;Purpose: given 'data' this method finds the index that data is located at in this
;         list
;Param - data: the data element to find the index
;Pre-condition: data is not empty
;Post-condition: if this contains data then the index is returned, but if this does
;                not contain data then the size of the List is returned
;Returns: the index as an integer value
;
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================
function List::findIndex, data
   index = 0L
   
   c = self.first
   
   while ptr_valid(c) do begin
       if((*c).data eq data) then begin
          break
       endif
       index = index + 1
       c = (*c).next
   endwhile    
    
   return, index   
end

;==================================================================================
;Name: List::size
;Purpose: determines how many elements are in this list
;
;Pre-condition: none.
;Post-condition: returns the number of elements in the list
;Returns: an integer value
;
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================
function List::size
   return, self.length
end

;==================================================================================
;Name: List::get
;Purpose: given 'index' this method returns the node at the index in this list
;Param - index: the index of the element
;Pre-condition: 0 <= index < self->size()
;Post-condition: if 0 <= index < self->size() then the method returns the element
;                at the index, returns null otherwise
;Returns: a node type, to get the data, do: (*var).data. 
;
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================
function List::get, index
    
    s = self->size()  
    
    if(index gt s-1) then return, ptr_new()
    
    c = self.first
    
    for i = 0, index-1 do begin
      c = (*c).next    
    endfor
    
    return, c  
end

function List::getData,index
   m = self->get(index)
   return, (*m).data
end


;==================================================================================
;Name: List::delete
;Purpose: given 'index' this method deletes the element at the index from this
;         list
;Param - data: the data element to find the index
;Pre-condition: 0 <= index < self->size()
;Post-condition: if 0 <= index < self->size() then the element at index is 
;                deleted from the list
;Returns: the index as an integer value
;
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================
pro List::delete, index
   
   if(index eq 0) then begin
      ; delete the head
      self.first = (*(self.first)).next  
   endif else begin
      prev = self->get(index-1)
      current = (*prev).next
      
      (*prev).next = (*current).next
   endelse
   self.length = self.length-1
end


;==================================================================================
;Name: List::destroy
;Purpose: the destructor for this class
;Param - data: the data element to find the index
;Pre-condition: none
;Post-condition: all the data is freed
;
;Author: John-Paul Lobos
;Date: 04/29/02
;==================================================================================
pro List::destroy

  ptr_free, first 
end

function List::isEmpty
  return, self.length eq 0
end