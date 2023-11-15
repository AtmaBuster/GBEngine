; ================================================
; SetFlag
; ================================================
; Sets flag <de> in bit array at <hl>
; ================================================
;   input
;       de - flag number
;       hl - flag array
;   output
;       a  - [hl.in + de.in / 8]
;       b  - FLAG_SET
;       c  - 1 << (de.in / 8)
;       de - de.in / 8
;       hl - hl.in + de.in / 8
SetFlag:
	ld b, FLAG_SET
	jr FlagAction

; ================================================
; ClearFlag
; ================================================
; Clears flag <de> in bit array at <hl>
; ================================================
;   input
;       de - flag number
;       hl - flag array
;   output
;       a  - [hl.in + de.in / 8]
;       b  - FLAG_CLR
;       c  - 1 << (de.in / 8)
;       de - de.in / 8
;       hl - hl.in + de.in / 8
ClearFlag:
	ld b, FLAG_CLR
	jr FlagAction

; ================================================
; CheckFlag
; ================================================
; Checks flag <de> in bit array at <hl>, returns status in carry
; ================================================
;   input
;       de - flag number
;       hl - flag array
;   output
;       a  - [hl.in + de.in / 8] & 1 << (de.in / 8)
;       b  - FLAG_CHK
;       c  - 1 << (de.in / 8)
;       de - de.in / 8
;       hl - hl.in + de.in / 8
CheckFlag:
	ld b, FLAG_CHK

; ================================================
; FlagAction
; ================================================
; Takes action <b> on flag <de> in bit array at <hl>
; ================================================
;   input
;       b  - action (FLAG_SET, FLAG_CLR, or FLAG_CHK)
;       de - flag number
;       hl - flag array
;   output
;       a  - varies
;       c  - 1 << (de.in / 8)
;       de - de.in / 8
;       hl - hl.in + de.in / 8
FlagAction:
; get bit-in-byte
	ld a, e
	and %111
; get flag mask
	ld c, 1
	inc a
.mask_loop
	dec a
	jr z, .got_mask
	sla c
	jr .mask_loop
.got_mask
; get byte-in-array
REPT 3
	srl d
	rr e
ENDR
	add hl, de
	ld a, b
	and a ; cp FLAG_SET
	jr z, .set
	dec a ; cp FLAG_CLR
	jr z, .clr
; chk
	ld a, [hl]
	and c
	ret z
	scf
	ret

.set
	ld a, [hl]
	or c
	ld [hl], a
	ret

.clr
	ld a, [hl]
	or c
	xor c
	ld [hl], a
	ret
