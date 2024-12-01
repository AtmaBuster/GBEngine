; ================================================
; DisableLCD
; ================================================
; Disables the LCD
; ================================================
;   input  - none
;   output
;       a  - 144
;       hl - rLCDC
DisableLCD::
	ld hl, rLCDC
	bit rLCDC_ENABLE, [hl]
	ret z
; Wait for *start of* VBlank, to guarantee time to disable
; Disabling outside of VBlank can damage the LCD, hence the strict wait
.wait_for_vblank
	ldh a, [rLY]
	cp 144 ; past bottom line
	jr c, .wait_for_vblank
	cp 152
	jr nc, .wait_for_vblank
.hit_vblank
	res rLCDC_ENABLE, [hl]
	ret

; ================================================
; EnableLCD
; ================================================
; Enables the LCD
; ================================================
;   input  - none
;   output
;       hl - rLCDC
EnableLCD::
	ld hl, rLCDC
	set rLCDC_ENABLE, [hl]
	ret
