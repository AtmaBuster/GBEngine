INCLUDE "constants.asm"
INCLUDE "charmap.asm"

SECTION "Vectors", ROM0[$0000]
_rst00:
Reset:
	jp _Reset

	ds $08 - @
_rst08:
BankSwitch:
	ld [MBC5RomBank], a
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

	hlcoord 1, 9
	ld bc, 5
	ld a, " "
	call MemFill

	ld de, wHelloWorldNum1
	hlcoord 1, 9
	ld b, (1 << F_PRINTNUM_LALIGN) | PRINTNUM_2BYTE
	call PrintNum

	jr .mainloop

.handle_joypad
	ldh a, [hJoypadDown]
	and A_BUTTON
	jr nz, .a_button
	ret

.a_button
	ld a, [wHelloWorldNum1]
	inc a
	ld [wHelloWorldNum1], a
	ret nz
	ld a, [wHelloWorldNum1 + 1]
	inc a
	ld [wHelloWorldNum1 + 1], a
	ret

Str_HelloWorld:
	str "Hello, world!\n\nWelcome to\nthe game :D\n\nPress \"A\" to make\nthe number go up."

AsciiFont: INCBIN "gfx/ascii_font.1bpp"

INCLUDE "home/math.asm"
INCLUDE "home/string.asm"
