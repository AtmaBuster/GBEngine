; ================================================
; CopyBGPalettes
; ================================================
; Copies <c> palettes from <hl> to the <b>th BG palette
; ================================================
CopyBGPalettes::
	call CheckColorHardware
	ret z
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
