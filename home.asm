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
	push af
	push bc
	push de
	push hl
	jp VBlank

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

INCLUDE "home/copy.asm"
INCLUDE "home/lcd_onoff.asm"
INCLUDE "home/speed.asm"
INCLUDE "home/delay.asm"
INCLUDE "home/simple_math.asm"

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
	jr .done_hw_check

.sgb
	ld a, HW_SGB
	jr .done_hw_check

.cgb
	bit 0, b
	jr nz, .agb
	ld a, HW_CGB
	jr .done_hw_check

.agb
	ld a, HW_AGB

.done_hw_check
	ldh [hConsoleType], a

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

; clear HRAM
	ld hl, $FF81 ; don't clear hConsoleType
	ld bc, $007E
	xor a
	call MemFill

; clear the rest of WRAM
	ld hl, $C200
	ld bc, $E000 - $C200
	xor a
	call MemFill

	ldh a, [hConsoleType]
	cp HW_CGB
	jr c, .skip_clear_cgb_wram

	ld a, 7
.clear_cgb_wram_loop
	ldh [rSVBK], a
	ld hl, $D000
	ld bc, $1000
	push af
	xor a
	call MemFill
	pop af
	dec a
	cp 1
	jr nz, .clear_cgb_wram_loop

	ldh [rSVBK], a
.skip_clear_cgb_wram

; clear VRAM
	call DisableLCD

	ld hl, $8000
	ld bc, $2000
	xor a
	call MemFill

	ldh a, [hConsoleType]
	cp HW_CGB
	jr c, .skip_clear_cgb_vram

	ld a, 1
	ldh [rVBK], a
	ld hl, $8000
	ld bc, $2000
	xor a
	call MemFill
	; a is still 0
	ldh [rVBK], a

.skip_clear_cgb_vram

	jp Test_HelloWorld

INCLUDE "home/interrupt.asm"

Test_HelloWorld:
; quick "Hello, world" program

; double speed, for extra fast printing :D
	call SetDoubleSpeed

; disable LCD, for easy VRAM access
	call DisableLCD

; copy font graphics to VRAM
	ld hl, $8200
	ld b, 16 * 14
	ld de, AsciiFont
	call MemCpy1BPP
; if on CGB, set up simple palettes
	ldh a, [hConsoleType]
	cp HW_CGB
	jr c, .skip_palettes

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

; draw a string
	ld de, Str_HelloWorld
	hlcoord 1, 1
	call StrCpy

; enable vblank interrupt
	ld a, (1 << VBLANK)
	ldh [rIE], a
	ei

; enable auto tilemap copy
	ld a, 1
	ldh [hCopyWRAMTileMap], a

.mainloop
	call DelayFrame
	call .handle_joypad
	jr .mainloop

.handle_joypad
	ld c, LOW(hJoypadHeld)
	ldh a, [c]
	bit F_D_DOWN, a
	call nz, .dpad_down
	ldh a, [c]
	bit F_D_UP, a
	call nz, .dpad_up
	ldh a, [c]
	bit F_D_LEFT, a
	call nz, .dpad_left
	ldh a, [c]
	bit F_D_RIGHT, a
	call nz, .dpad_right
	ret

.dpad_down
	ldh a, [hScrollSpeedY]
	and a
	ret nz
	ldh a, [hScrollTargetY]
	add 8
	ldh [hScrollTargetY], a
	ld a, 3
	ldh [hScrollSpeedY], a
	ret

.dpad_up
	ldh a, [hScrollSpeedY]
	and a
	ret nz
	ldh a, [hScrollTargetY]
	sub 8
	ldh [hScrollTargetY], a
	ld a, -3
	ldh [hScrollSpeedY], a
	ret

.dpad_left
	ldh a, [hScrollSpeedX]
	and a
	ret nz
	ldh a, [hScrollTargetX]
	sub 8
	ldh [hScrollTargetX], a
	ld a, -1
	ldh [hScrollSpeedX], a
	ret

.dpad_right
	ldh a, [hScrollSpeedX]
	and a
	ret nz
	ldh a, [hScrollTargetX]
	add 8
	ldh [hScrollTargetX], a
	ld a, 1
	ldh [hScrollSpeedX], a
	ret

Str_HelloWorld:
	str "Hello, world!"

AsciiFont: INCBIN "gfx/ascii_font.1bpp"
