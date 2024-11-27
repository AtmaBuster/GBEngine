INCLUDE "constants.asm"

SECTION "Vectors", ROM0[$0000]
Reset:
	jp _Reset

POP_HLDEBCAF_RET:
	pop hl
POP_DEBCAF_RET:
	pop de
POP_BCAF_RET:
	pop bc
	pop af
	ret

	ds $08 - @
BankSwitch:
	ld [MBC5RomBank], a
	ldh [hROMBank], a
	ret

	ds $10 - @
FarCall:
	push af
	push af
	push hl
	ld hl, sp+5
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
	di
	jp Crash_rst38

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
	push af
	push bc
	push de
	push hl
	jp Serial

	ds $60 - @
_Joypad:
	jp Crash_JoypadInt

SECTION "Low ROM", ROM0[$0063]

INCLUDE "home/copy.asm"
INCLUDE "home/lcd_onoff.asm"
INCLUDE "home/speed.asm"
INCLUDE "home/delay.asm"

	ds $ED - @

BuildString:
PUSHC
SETCHARMAP ascii
	db STRFMT("%04u-%02u-%02u %02u:%02u:%02u", __UTC_YEAR__, __UTC_MONTH__, __UTC_DAY__, __UTC_HOUR__, __UTC_MINUTE__, __UTC_SECOND__)
POPC

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

	farcall DSX_Init

; seed RNG
	ld a, 1
	ldh [hRandomA], a

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
	call LoadFont
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
	call .draw_screen
	jr .mainloop

.draw_screen
	ld a, [wHelloWorld_MyNameIndex]
	swap a
	add LOW(.name_list)
	ld e, a
	ld a, HIGH(.name_list)
	adc 0
	ld d, a
	ld hl, wHelloWorld_MyName
	ld bc, 16
	call MemCpy

	ld de, wHelloWorld_MyName
	hlcoord 1, 10
	ld bc, 16
	call MemCpy

	ld de, wHelloWorld_TheirName
	hlcoord 1, 12
	ld bc, 16
	call MemCpy

	ret

.name_list
	db "0000000011111111"
	db "2222222233333333"
	db "4444444455555555"
	db "6666666677777777"
	db "8888888899999999"
	db "AAAAAAAABBBBBBBB"
	db "CCCCCCCCDDDDDDDD"
	db "EEEEEEEEFFFFFFFF"
	db "GGGGGGGGHHHHHHHH"
	db "IIIIIIIIJJJJJJJJ"
	db "KKKKKKKKLLLLLLLL"
	db "MMMMMMMMNNNNNNNN"
	db "OOOOOOOOPPPPPPPP"
	db "QQQQQQQQRRRRRRRR"
	db "SSSSSSSSTTTTTTTT"
	db "UUUUUUUUVVVVVVVV"

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
	bit F_A_BUTTON, a
	jr nz, .a_button
	bit F_B_BUTTON, a
	jr nz, .b_button
	bit F_START, a
	jr nz, .start
	bit F_SELECT, a
	jr nz, .select
	ret

.up
	ld hl, wHelloWorld_MyNameIndex
	ld a, [hl]
	inc a
	and $F
	ld [hl], a
	ret

.down
	ld hl, wHelloWorld_MyNameIndex
	ld a, [hl]
	dec a
	and $F
	ld [hl], a
	ret

.start
	jr Test_HelloWorld_LinkTransfer

.right
.left
.a_button
.b_button
.select
	ret

Test_HelloWorld_LinkTransfer:
	ld a, 3
	call Test_HelloWorld_DrawStatusString
	call Serial_EstablishConnection
	ldh a, [hSerialConnectionStatus]
	bit F_SERIAL_CONNECTION_OK, a
	jr nz, .connection_ok
	bit F_SERIAL_CONNECTION_TIMEOUT, a
	jr nz, .timeout_on_establish
	ld a, 1
	call Test_HelloWorld_DrawStatusString
	ldh a, [hSerialGet]
	hlcoord 1, 16
	call THW_DrawHex
	ret

.timeout_on_establish
	ld a, 2
	call Test_HelloWorld_DrawStatusString
	ldh a, [hSerialGet]
	hlcoord 1, 16
	call THW_DrawHex
	ret

.connection_ok
	ld c, 16
.xfer_loop
	push bc
	ld a, LOW(wHelloWorld_MyName)
	add c
	ld c, a
	ld b, HIGH(wHelloWorld_MyName)
	dec bc
	ld a, [bc]
	ldh [hSerialSend], a

	call Serial_SendAndReceiveByte
	ldh a, [hSerialConnectionStatus]
	bit F_SERIAL_CONNECTION_OK, a
	pop bc
	jr nz, .byte_ok
	ld a, 2
	call Test_HelloWorld_DrawStatusString
	ret

.byte_ok
	push bc
	ld a, LOW(wHelloWorld_TheirName)
	add c
	ld c, a
	ld b, HIGH(wHelloWorld_TheirName)
	ldh a, [hSerialGet]
	dec bc
	ld [bc], a
	pop bc

	dec c
	jr nz, .xfer_loop

	call Serial_CloseConnection
	ld a, 4
	call Test_HelloWorld_DrawStatusString
	ret

THW_DrawHex:
; put hex(a) -> hl
	push af
	swap a
	call .put_digit
	pop af
.put_digit
	and $0F
	add "0"
IF "9" != "A" - 1
	cp "9" + 1
	jr c, .got_digit
	add "A" - "9" - 1
.got_digit
ENDC
	ld [hli], a
	ret

Test_HelloWorld_DrawStatusString:
	ld hl, .str_list
	and a
	jr z, .gotit
	ld de, 38
:
	add hl, de
	dec a
	jr nz, :-
.gotit
	ld d, h
	ld e, l
	hlcoord 1, 14
	ld bc, 38
	call MemCpy
	ret

.str_list
;           001122334455667788..99AABBCCDDEEFF0011
	db "                                      "
	db "Failed to estab-    lish connection.  "
	db "Connection timed    out.              "
	db "Awaiting link...                      "
	db "Link transfer       completed!        "

Str_HelloWorld:
	text "This is a test of"
	line "the link routines."
	line
	line "It trades a name"
	line "between games."
	line
	line "Choose a name w/"
	line "the D-pad."
	text_end

INCLUDE "home/math.asm"
INCLUDE "home/string.asm"
INCLUDE "home/call.asm"
INCLUDE "home/flag.asm"
INCLUDE "home/font.asm"
INCLUDE "home/audio.asm"
INCLUDE "home/random.asm"
INCLUDE "home/serial.asm"

INCLUDE "home/crash.asm"
