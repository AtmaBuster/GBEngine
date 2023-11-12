; ================================================
; SMultiply
; ================================================
; Calculates <a> * <c>, returns 
; ================================================
;   input
;       a  - multiplicand
;       c  - multiplicand
;   output
;       a  - product % 256
SMultiply:
	and a
	ret z

	push bc
	ld b, a
	xor a
.loop
	add c
	dec b
	jr nz, .loop
	pop bc
	ret

; ================================================
; SDivide
; ================================================
; Calculates <a> / <c>, returns quotient <b> and remainder <a>
; ================================================
;   input
;       a  - dividend
;       c  - divisor
;   output
;       a  - remainder
;       b  - quotient
SDivide:
; divide-by-zero check
	ld b, a
	ld a, c
	and a
	jr z, .divide_by_zero
	ld a, b
	ld b, 0
.loop
	inc b
	sub c
	jr nc, .loop
	dec b
	add c
	ret

.divide_by_zero
	jr @
