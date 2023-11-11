; ================================
; DelayFrame
; ================================
; Waits for one VBlank to occur
; ================================
;   input  - none
;   output
;       a  = 0
DelayFrame:
.loop
	halt
	nop
	ldh a, [hVBlank]
	and a
	jr z, .loop
	xor a
	ldh [hVBlank], a
	ret

; ================================
; DelayFrames
; ================================
; Waits for <c> frames
; ================================
;   input
;     c  = num. frames
;   output
;     a  = 0
;     a  = c
DelayFrames:
.loop
	call DelayFrame
	dec c
	jr nz, .loop
	ret
