_Multiply::
	ld b, 8

; clear used memory
	xor a
	ldh [hMultiplicand - 1], a
	ldh [hMathBuffer + 1], a
	ldh [hMathBuffer + 2], a
	ldh [hMathBuffer + 3], a
	ldh [hMathBuffer + 4], a

.loop
; divide multiplier by 2
	ldh a, [hMultiplier]
	srl a
	ldh [hMultiplier], a
; if it was even, skip
	jr nc, .next

; otherwise, add multiplicand to output
	and a ; clear carry flag
FOR I, 4
	ldh a, [hMathBuffer + 4 - I]
	ld c, a
	ldh a, [hMultiplicand + 2 - I]
	adc c
	ldh [hMathBuffer + 4 - I], a
ENDR

.next
	dec b
	jr z, .done

; shift multiplicand left 1 bit
	and a ; clear carry flag
FOR I, 4
	ldh a, [hMultiplicand + 2 - I]
	rla
	ldh [hMultiplicand + 2 - I], a
ENDR
	jr .loop

.done
; copy buffer to output
FOR I, 4
	ldh a, [hMathBuffer + 4 - I]
	ldh [hProduct + 3 - I], a
ENDR

	ret

_Divide::
	ld e, 9

; clear used memory
	xor a
	ldh [hMathBuffer + 0], a
	ldh [hMathBuffer + 1], a
	ldh [hMathBuffer + 2], a
	ldh [hMathBuffer + 3], a
	ldh [hMathBuffer + 4], a

.loop
; try substract dividend from divisor
	ldh a, [hMathBuffer + 0]
	ld c, a
	ldh a, [hDividend + 1]
	sub c
	ld d, a

	ldh a, [hDivisor]
	ld c, a
	ldh a, [hDividend + 0]
	sbc c
; if dividend > divisor, don't keep the result
	jr c, .next

; otherwise, keep the result and increase the quotient
	ldh [hDividend + 0], a
	ld a, d
	ldh [hDividend + 1], a

	ldh a, [hMathBuffer + 4]
	inc a
	ldh [hMathBuffer + 4], a

	jr .loop

.next
	ld a, b
	cp 1
	jr z, .done

	and a ; clear carry flag
FOR I, 4
	ldh a, [hMathBuffer + 4 - I]
	rla
	ldh [hMathBuffer + 4 - I], a
ENDR

	dec e
	jr nz, .next2

	ld e, 8
	ldh a, [hMathBuffer + 0]
	ldh [hDivisor], a
	xor a
	ldh [hMathBuffer + 0], a

FOR I, 3
	ldh a, [hDividend + 1 + I]
	ldh [hDividend + I], a
ENDR

.next2
	ld a, e
	cp 1
	jr nz, .okay
	dec b

.okay
	ldh a, [hDivisor]
	srl a
	ldh [hDivisor], a

	ldh a, [hMathBuffer + 0]
	rr a
	ldh [hMathBuffer + 0], a

	jr .loop

.done
; copy buffer to output
	ldh a, [hDividend + 1]
	ldh [hRemainder], a

FOR I, 4
	ldh a, [hMathBuffer + 4 - I]
	ldh [hQuotient + 3 - I], a
ENDR

	ret
