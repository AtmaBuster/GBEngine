; ================================================
; SetDoubleSpeed
; ================================================
; Sets the CPU to double speed mode  -CGB Only
; ================================================
;   input  - none
;   output
;       varies for a, hl
SetDoubleSpeed::
	ldh a, [hConsoleType]
	cp 2
	ret c
	ld hl, rKEY1
	bit 7, [hl]
	ret nz
	jr SwitchSpeed

; ================================================
; SetSingleSpeed
; ================================================
; Sets the CPU to single speed mode  -CGB Only
; ================================================
;   input  - none
;   output
;       varies for a, hl
SetSingleSpeed::
	ldh a, [hConsoleType]
	cp 2
	ret c
	ld hl, rKEY1
	bit 7, [hl]
	ret nz
SwitchSpeed:
	set 0, [hl]
	di
	ldh a, [rIE]
	push af
	xor a
	ldh [rIF], a
	ldh [rIE], a
	ld a, $30
	ldh [rJOYP], a
	stop
	pop af
	ldh [rIE], a
	ei
	ret
