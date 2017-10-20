;====================================================================================
;Name: Stack__define.pro
;Description: A class that is an ADT Stack implementation using a singly-linked list
;Use: To create a Stack object, simply o = obj_new('Stack'), to destroy the class, call
;      obj_destroy,o
;Author: John-Paul Lobos
;Date: 05/10/02
;==================================================================================== 


;====================================================================================
; Name: Stack__define
; Purpose: Stack class' contructor
; Pre-Condition: none
; Post-Condition: an empty stack is created
; Author: John-Paul Lobos
; Date: 05/10/02
;====================================================================================
pro Stack__define
   lstack = {Node,data:ptr_new(),next:ptr_new()}
   
   define = {Stack,lstack:lstack,length:0L,first:ptr_new()}
end

;====================================================================================
; Name: Stack::push
; Purpose: the push operation of the ADT Stack
; Pre-Condition: none
; Post-Condition: data is added to the stack
;
; Parameter - data: the data to add to the stack
; Author: John-Paul Lobos
; Date: 05/10/02
;====================================================================================
pro Stack::push,data
   if(not(ptr_valid(self.first)))then begin
     self.first = ptr_new(self.lstack)
     (*(self.first)).data = ptr_new(data)
     (*(self.first)).next = ptr_new()
   endif else begin
     newNode = ptr_new(self.lstack)
     (*newNode).data = ptr_new(data)
     (*newNode).next = self.first
     self.first = newNode  
   endelse
   self.length = self.length + 1
end

;====================================================================================
; Name: Stack::isEmpty
; Purpose: the isEmpty operation of an ADT Stack
; Pre-Condition: none
; Post-Condition: returns true (1) if the stack is empty (has no elements)
; 
; Returns: 1 if the stack has no elements and 0 if the stack has elements
; Author: John-Paul Lobos
; Date: 05/10/02
;====================================================================================
function Stack::isEmpty
   return, self.length eq 0
end

;====================================================================================
; Name: Stack::pop
; Purpose: Stack pop operation of an ADT Stack
; Pre-Condition: not(self->isEmpty())
; Post-Condition: the top element is removed from the stack
;
; Returns: the element on the top of the stack
; Author: John-Paul Lobos
; Date: 05/10/02
;====================================================================================
function Stack::pop
   dat = 'stack empty'
   
   if(not(self->isEmpty())) then begin
     node = self.first
     dat = *((*node).data) 
     self.first = (*(self.first)).next
     self.length = self.length-1
   endif
   
   return, dat
end

;====================================================================================
; Name: Stack::size
; Purpose: to determine how many elements are in the stack
; Pre-Condition: none
; Post-Condition: returns the number of elements in this stack
;
; Author: John-Paul Lobos
; Date: 05/10/02
;====================================================================================
function Stack::size
  return, self.length
end

;==================================================================================
;Name: Stack::print
;Purpose: prints the data contained in the stack out
;Pre-condition: none
;Post-condition: prints the elements in this stack in the console
;Returns: none
;
;Author: John-Paul Lobos
;Date: 05/10/02
;==================================================================================
pro Stack::print   
   c = self.first
   
   while ptr_valid(c) do begin
       print, *((*c).data)
       c = (*c).next
   endwhile
end

;====================================================================================
; Name: Stack::peek
; Purpose: to look at the top element
; Pre-Condition: none
; Post-Condition: the top element is returned
;
; Return: the element at the top of the list
; Author: John-Paul Lobos
; Date: 05/10/02
;====================================================================================
function Stack::peek
   return, *((*(self.first)).data)
end
