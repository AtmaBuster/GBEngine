; ================================================
; CopyBGPalettes
; ================================================
; Copies <c> palettes from <hl> to the <b>th BG palette
; ================================================
CopyBGPalettes::
	call CheckColorHardware
	ret z
	call WaitForLCDAvaialable
	ld a, b
	ld b, c
	ld c, LOW(rBGPI)
	jr CopyPals

; ================================================
; CopyOBPalettes
; ================================================
; Copies <c> palettes from <hl> to the <b>th OBJ palette
; ================================================
CopyOBPalettes::
	call CheckColorHardware
	ret z
	call WaitForLCDAvaialable
	ld a, b
	ld b, c
	ld c, LOW(rOBPI)

; Fallthrough
CopyPals:
	add a
	add a
	add a
	or (1 << rBGPI_AUTO_INCREMENT)
	ldh [c], a
	inc c
	ld a, b
	add a
	add a
	add a
	ld b, a
.pal_loop
	ld a, [hli]
	ldh [c], a
	dec b
	jr nz, .pal_loop
	ret

; ================================================
; ClearPalettes
; ================================================
; Sets all BG and OBJ palettes to white (31, 31, 31)
; ================================================
ClearPalettes::
	call CheckColorHardware
	ret z
	call WaitForLCDAvaialable
	ld c, LOW(rBGPI)
	call .ClearPals
	ld c, LOW(rOBPI)
.ClearPals:
	ld a, (1 << rBGPI_AUTO_INCREMENT)
	ldh [c], a
	inc c
	ld b, 32 ; colors
.clear_loop
	ld a, $FF ; LOW(RGB 31, 31, 31)
	ldh [c], a
	ld a, $7F ; HIGH(RGB 31, 31, 31)
	ldh [c], a
	dec b
	jr nz, .clear_loop
	ret
