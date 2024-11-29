INCLUDE "constants.asm"

INCLUDE "home/header.asm"
INCLUDE "home/init.asm"
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
	db "Satoshi Tajiri  "
	db "Junichi Masuda  "
	db "Sousuke Tamada  "
	db "Hisashi Sogabe  "
	db "Yoshinori Matsu."
	db "Shigeki Morimoto"
	db "Tetsuya Watanabe"
	db "Takenori Oota   "
	db "Ken Sugimori    "
	db "Motofumi Fujiwa."
	db "Hironobu Yoshida"
	db "Atsuko Nishida  "
	db "Muneo Saito     "
	db "Rena Yoshikawa  "
	db "Jun Okutani     "
	db "Asuka Iwashita  "

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
	ld hl, wHelloWorld_MyName
	ld de, wHelloWorld_TheirName
	call Serial_SendAndReceiveBytes
	jr c, .got_name

	ld a, 1
	call Test_HelloWorld_DrawStatusString
	ret

.got_name
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
