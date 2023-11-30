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
SMultiply::
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
SDivide::
; divide-by-zero check
	ld b, a
	ld a, c
	and a
	jp z, Crash_div0
	ld a, b
	ld b, 0
.loop
	inc b
	sub c
	jr nc, .loop
	dec b
	add c
	ret

; ================================================
; Multiply
; ================================================
; Takes the 3-byte, big-endian value in hMultiplicand, multiplies it by
;     the 1-byte value in hMultiplier, and returns it as a 4-byte,
;     big-endian value in hProduct
; ================================================
;   input
;       actual values are in hMultiplier and hMultiplicand
;   output
;       a  - Current ROM Bank
Multiply::
	push bc
	push hl

	farcall _Multiply

	pop hl
	pop bc
	ret

; ================================================
; Divide
; ================================================
; Takes the 4-byte, big-endian value in hDividend, divides it by the
;     1-byte value in hDivisor, and return the quotient as a 4-byte,
;     big-endian value in hQuotient, and the remainder as a 1-byte
;     value in hRemainder
; ================================================
;   input
;       b  - precision
;       actual values are in hDivisor and hDividend
;   output
;       a  - Current ROM Bank
Divide::
	push bc
	push de
	push hl

	farcall _Divide

	pop hl
	pop de
	pop bc
	ret
