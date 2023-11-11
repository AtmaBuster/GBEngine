; ================================================
; AbsoluteValue
; ================================================
; Returns abs(<a>)
; ================================================
;   input
;       a  - signed value
;   output
;       a  - |a.in|
AbsoluteValue:
	bit 7, a
	ret z
	cpl
	inc a
	ret
