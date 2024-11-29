; ================================================
; _Random
; ================================================
; Ticks the RNG, returns hRandomA in a
; Implementation of https://github.com/edrosten/8bit_rng/blob/master/rng-4261412736.c
; ================================================
_Random::
	ldh a, [hRandomX]
	ld b, a
	add a
	add a
	xor b
	ld b, a
	ldh a, [hRandomY]
	ldh [hRandomX], a
	ldh a, [hRandomZ]
	ldh [hRandomY], a
	ldh a, [hRandomA]
	ldh [hRandomZ], a
	ld c, a
	xor b
	ld d, a
	ld a, b
	add a
	xor d
	ld b, a
	ld a, c
	srl a
	xor b
	ldh [hRandomA], a
	ret

; ================================================
; Random
; ================================================
; Same as _Random, but preserves registers other than a
; ================================================
Random::
	push bc
	push de
	call _Random
	pop de
	pop bc
	ret

; ================================================
; RandomRange
; ================================================
; Ticks the RNG one or more times, returns a random number between 0 and a, inclusive, in a
; ================================================
RandomRange::
	push bc
	ld c, a
.loop
	call Random
	cp c
	jr c, .loop
	pop bc
	ret
