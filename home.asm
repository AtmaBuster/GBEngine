INCLUDE "constants.asm"
INCLUDE "charmap.asm"

SECTION "Vectors", ROM0[$0000]
Reset:
	jp _Reset

	ds $08 - @
BankSwitch:
	ld [MBC5RomBank], a
	ldh [hROMBank], a
	ret

	ds $10 - @
FarCall:
	ldh [hFarCallStoreA], a
	ldh a, [hROMBank]
	push af
	jp _FarCall

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
	push af
	jp LCD

	ds $50 - @
_Timer:
	reti

	ds $58 - @
_Serial:
	reti

	ds $60 - @
_Joypad:
	reti

SECTION "Low ROM", ROM0[$0061]

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

_Reset::
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

; load bank 1 by default
	ld a, 1
	rst BankSwitch

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
	call PrintString

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

	hlcoord 0, 10
	ld bc, SCREEN_WIDTH * 4
	ld a, " "
	call MemFill

	hlcoord 2, 11
	ld a, [wHelloWorld_Cursor]
	cp 4
	jr nz, .got_cursor_pos
	inc a
.got_cursor_pos
	ld c, a
	ld b, 0
	add hl, bc
	ld [hl], "^"

	load_multiplicand 2, wHelloWorld_Input

	ld a, 100
	ldh [hMultiplier], a
	call Multiply

	ld a, 125
	ldh [hMultiplier], a
	call Multiply

	ld a, 81
	ldh [hDivisor], a
	ld b, 4
	call Divide

	ld a, 7
	ldh [hDivisor], a
	ld b, 4
	call Divide

	ldh a, [hDividend + 3]
	add 5
	ldh [hDividend + 3], a
	ld a, 10
	ldh [hDivisor], a
	ld b, 4
	call Divide

	ld a, 10
	ldh [hDivisor], a
	ld b, 4
	call Divide

	load_quotient 2, wHelloWorld_Output
	ldh a, [hRemainder]
	ld [wHelloWorld_OutputR], a

	ld de, wHelloWorld_Input
	hlcoord 2, 10
	ld b, PRINTNUM_2BYTE
	call PrintNum

	ld de, wHelloWorld_Output
	hlcoord 1, 13
	ld b, PRINTNUM_2BYTE
	call PrintNum

	hlcoord 6, 13
	ld [hl], "."
	ld de, wHelloWorld_OutputR
	hlcoord 7, 13
	ld b, PRINTNUM_1BYTE | (1 << F_PRINTNUM_LALIGN)
	call PrintNum

	hlcoord 6, 10
	ld a, [hli]
	ld [hld], a
	ld [hl], "."
	dec hl
	ld a, [hl]
	cp " "
	jr nz, .ok_space
	ld [hl], "0"
.ok_space
	hlcoord 9, 10
	ld a, "k"
	ld [hli], a
	ld a, "g"
	ld [hl], a

	hlcoord 9, 13
	ld a, "l"
	ld [hli], a
	ld a, "b"
	ld [hli], a
	ld a, "s"
	ld [hl], a

	jp .mainloop

.handle_joypad
	ldh a, [hJoypadDown]
	bit F_D_LEFT, a
	jr nz, .left
	bit F_D_RIGHT, a
	jr nz, .right
	bit F_D_UP, a
	jr nz, .up
	bit F_D_DOWN, a
	jr nz, .down
	ret

.up
	ld b, 0
	jr .change_value

.down
	ld b, 2
.change_value
	ld a, [wHelloWorld_Cursor]
	add a
	add a
	add b
	ld c, a
	ld b, 0
	ld hl, .diff_table
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wHelloWorld_Input]
	ld c, a
	ld a, [wHelloWorld_Input + 1]
	ld b, a
	add hl, bc
	ld a, l
	ld [wHelloWorld_Input], a
	ld a, h
	ld [wHelloWorld_Input + 1], a
	ret

.right
	ld a, [wHelloWorld_Cursor]
	inc a
	cp 5
	jr nz, .set_cursor
	xor a
	jr .set_cursor

.left
	ld a, [wHelloWorld_Cursor]
	dec a
	cp -1
	jr nz, .set_cursor
	ld a, 4
.set_cursor
	ld [wHelloWorld_Cursor], a
	ret

.diff_table
	dw 10000, -10000
	dw 1000,  -1000
	dw 100,   -100
	dw 10,    -10
	dw 1,     -1

Str_HelloWorld:
	text "This is a test of"
	line "the math routines."
	line
	line "It converts from"
	line "kg to lbs."
	line
	line "Change the number"
	line "with the D-pad."
	text_end
	;~ str "Hello, world!\n\nWelcome to\nthe game :D\n\nPress \"A\" to make\nthe number go up."

AsciiFont: INCBIN "gfx/ascii_font.1bpp"

INCLUDE "home/math.asm"
INCLUDE "home/string.asm"
INCLUDE "home/call.asm"
