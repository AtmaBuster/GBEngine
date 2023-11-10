INCLUDE "constants.asm"
INCLUDE "charmap.asm"

SECTION "Vectors", ROM0[$0000]
_rst00:
	ret

	ds $08 - @
_rst08:
	ret

	ds $10 - @
_rst10:
	ret

	ds $18 - @
_rst18:
	ret

	ds $20 - @
_rst20:
	ret

	ds $28 - @
_rst28:
	ret

	ds $30 - @
_rst30:
	ret

	ds $38 - @
_rst38:
	ret

	ds $40 - @
_VBlank:
	reti

	ds $48 - @
_LCD:
	reti

	ds $50 - @
_Timer:
	reti

	ds $58 - @
_Serial:
	reti

	ds $60 - @
_Joypad:
	reti

MemCpy2BPP:
; copies c tiles of 2bpp graphics data from de to hl
	ld b, 0
	and a
	rl c
	rl b
	rl c
	rl b
	rl c
	rl b
	inc b
	inc c
MemCpy:
; copies bc bytes from de to hl
	inc b
	inc c
	jr .loop
.put
	ld a, [de]
	inc de
	ld [hli], a
.loop
	dec c
	jr nz, .put
	dec b
	jr nz, .put
	ret

MemFill:
; fills bc bytes at hl with a
	inc b
	inc c
	jr .loop
.put
	ld [hli], a
.loop
	dec c
	jr nz, .put
	dec b
	jr nz, .put
	ret

MemCpy1BPP:
; copies c tiles of 1bpp graphics data from de to hl
	ld b, 0
	and a
	rl c
	rl b
	rl c
	rl b
	rl c
	rl b
	inc b
	inc c
.put
	ld a, [de]
	inc de
	ld [hli], a
	ld [hli], a
.loop
	dec c
	jr nz, .put
	dec b
	jr nz, .put
	ret

StrCpy:
; copies a \0 terminated string from de to hl
.loop
	ld a, [de]
	and a
	ret z
	ld [hli], a
	inc de
	jr .loop

DisableLCD:
	ld hl, rLCDC
	bit rLCDC_ENABLE, [hl]
	ret z
; Wait for *start of* VBlank, to guarantee time to disable
; Disabling outside of VBlank can damage the LCD, hence the strict wait
.wait_for_vblank
	ldh a, [rLY]
	cp 144 ; past bottom line
	jr nz, .wait_for_vblank
	res rLCDC_ENABLE, [hl]
	ret

EnableLCD:
	ld hl, rLCDC
	set rLCDC_ENABLE, [hl]
	ret

SECTION "Home", ROM0[$0100]

Start::
	nop
	jp _Start

	ds $150 - @
_Start::
; check hardware: DMG, SGB, or CGB
	cp $11
	jr z, .cgb
	ld a, c
	cp $14
	jr z, .sgb
	xor a ; ld a, HW_DMG
	ldh [hConsoleType], a
	jr .done_hw_check

.sgb
	ld a, HW_SGB
	ldh [hConsoleType], a
	jr .done_hw_check

.cgb
	ld a, HW_CGB
	ldh [hConsoleType], a

.done_hw_check

; clear first 2 pages of WRAM
	ld hl, $C000
	ld bc, $0200
.clear_loop
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .clear_loop

; set up stack
	ld sp, wStackPointer

; quick "Hello, world" program

; disable LCD, for easy VRAM access
	call DisableLCD

; copy font graphics to VRAM
	ld hl, $8200
	ld c, 16 * 14
	ld de, AsciiFont
	call MemCpy1BPP

; draw a string
	ld de, Str_HelloWorld
	ld hl, $9821
	call StrCpy

; if on CGB, set up simple palettes
	ldh a, [hConsoleType]
	cp HW_CGB
	jr nz, .skip_palettes

	ld a, 1 << rBGPI_AUTO_INCREMENT
	ldh [rBGPI], a
	ld c, LOW(rBGPD)

	ld a, $FF
	ldh [c], a
	ld a, $7F
	ldh [c], a
	xor a
	ldh [c], a
	ldh [c], a
	ldh [c], a
	ldh [c], a
	ldh [c], a
	ldh [c], a

.skip_palettes

; enable LCD, so we can actually see
	call EnableLCD

	jr @

Str_HelloWorld:
	str "Hello, world!"

AsciiFont: INCBIN "gfx/ascii_font.1bpp"
