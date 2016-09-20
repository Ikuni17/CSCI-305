;Bradley White
;CSCI 305
;Lab #3 Scheme
;4-9-2016

;member? function, checks if an element e is a member of a list
(define (member? e list)
(cond
;If the list is null, hit the base case and element not found, return false
((null? list) #f)
;If the first element of the list equals the element searched for, return true
((eq? e (car list)) #t)
;Else recursively iterate through the rest of the list
(else (member? e (cdr list)))))

;set? function, checks if a set contains no duplicate elements
(define (set? list)
(cond
;If the list is null, hit the base case without finding duplicates, return true
((null? list) #t)
;Call member? function to check if the first element is repeated in the rest of the list, if so return false
((member? (car list) (cdr list)) #f)
;Else recursively call set? on the remainder of the list
(else (set? (cdr list)))))

;union function, returns the union of two lists
(define (union list1 list2)
;check if list2 is empty to stop recursion
(cond ((null? list2) list1)
;check is the first element of list2 is in list1 to avoid duplicates
((member? (car list2) list1)
;if a duplicate is found, skip the element and call union again on the remainder of list2
(union list1 (cdr list2)))
;Else concantenate the first element onto list1 and call union again on the two lists
(else (union (cons (car list2) list1) (cdr list2)))))

;intersect function, returns the intersection of two lists
(define (intersect list1 list2)
;if list1 is empty return the empty list, also the base case
(cond ((null? list1)(quote ()))
;check if the first element of list1 is a member of list2
((member? (car list1) list2)
;if so concatenate the element with the recrusive call
(cons (car list1)
(intersect (cdr list1) list2)))
;Else the element is not in both lists, call intersect again on the remainder of list1
(else (intersect (cdr list1) list2))))

