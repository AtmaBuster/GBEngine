INCLUDE "constants.asm"

INCLUDE "home/header.asm"
INCLUDE "home/init.asm"
INCLUDE "home/interrupt.asm"
INCLUDE "home/oam.asm"

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

Test_SpriteTest:

	call LoadFont

	ld hl, .bg_pal_data
	lb bc, 0, 1
	call CopyBGPalettes

	ld hl, .pal_data
	lb bc, 0, 8
	call CopyOBPalettes

	ld hl, $8010
	ld de, .TestingTile
	ld bc, 16
	call MemCpy

	call SPRT_Joypad.select
	call SPRT_Joypad.select
	call SPRT_Joypad.select

	ld de, .InfoString
	hlcoord 1, 1
	call PrintString

	ld a, 1
	ldh [hCopyWRAMTileMap], a

	ld hl, rLCDC
	set rLCDC_SPRITES_ENABLE, [hl]
	call EnableLCD
	ld a, (1 << VBLANK)
	ldh [rIE], a
	ei
.loop
	call DelayFrame
	call SPRT_UpdateSprites
	call SPRT_CopySprites
	call SPRT_Joypad
	call SPRT_UpdateScrollTargetY
	call SPRT_UpdateScrollTargetX
	jr .loop

.TestingTile:
	db %11111111, %11111111
	db %10000001, %10000001
	db %10000001, %10000001
	db %10000001, %10000001
	db %10000001, %10000001
	db %10000001, %10000001
	db %10000001, %10000001
	db %11111111, %11111111

.bg_pal_data
	dw $7FFF, $7FFF, $7FFF, $0000

.pal_data
	dw $7FFF, $7FFF, $7FFF, $0000
	dw $7FFF, $7FFF, $7FFF, $000F
	dw $7FFF, $7FFF, $7FFF, $01E0
	dw $7FFF, $7FFF, $7FFF, $3C00
	dw $7FFF, $7FFF, $7FFF, $001F
	dw $7FFF, $7FFF, $7FFF, $03E0
	dw $7FFF, $7FFF, $7FFF, $7C00
	dw $7FFF, $7FFF, $7FFF, $3DFF

.InfoString:
	text "Press START to"
	line "jostle."
	text_end

SPRT_UpdateScrollTargetY:
	ld a, [wSprTestJostleTimer]
	and a
	ret z
	ld hl, .ScrollTargets
	ld c, a
.loop
	ld a, [hli]
	cp -1
	ret z
	cp c
	jr nz, .next
	ld a, [hli]
	ldh [hScrollTargetY], a
	ld a, [hl]
	ldh [hScrollSpeedY], a
	ret

.next
	inc hl
	inc hl
	jr .loop

.ScrollTargets:
	db  0,  0,  0
	db  4,  0, -1
	db 12,  4,  1
	db 16, -4, -1
	db -1

SPRT_UpdateScrollTargetX:
	ld hl, wSprTestJostleTimer
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ld hl, .ScrollTargets
	ld c, a
.loop
	ld a, [hli]
	cp -1
	ret z
	cp c
	jr nz, .next
	ld a, [hli]
	ldh [hScrollTargetX], a
	ld a, [hl]
	ldh [hScrollSpeedX], a
	ret

.next
	inc hl
	inc hl
	jr .loop

.ScrollTargets:
	db  0,  0,  0
	db  2,  0, -2
	db  6,  4,  2
	db 10, -4, -2
	db 14,  4,  2
	db 16, -4, -2
	db -1

DEF SPRTEST_CT EQU 10
SPRT_Joypad:
	ldh a, [hJoypadDown]
	bit F_START, a
	jr nz, SPRT_JoyStart
	ret

.select
	ld hl, wSprTest
	ld c, SPRTEST_CT ; num sprites
.loop
	call Random
	and %00001111
	ld [hli], a
	call Random
	and %00000011
	ld [hli], a
	call Random
	and %10000111
	cp 80
	jr c, .ok
	and %01111111
	cpl
	inc a
.ok
	ld [hli], a
	call Random
	and %00000011
	ld [hli], a
	dec c
	jr nz, .loop
	ret

SPRT_JoyStart:
	ld a, [wSprTestJostleTimer]
	and a
	ret nz
	call .Nudge
	call .Jump
	ld a, 16
	ld [wSprTestJostleTimer], a
	ret

.Jump:
	ld hl, wSprTest
	ld c, SPRTEST_CT
:
	inc hl
	ld a, [hli]
	inc hl
	cp 136
	jr nz, .not_on_ground
	ld a, [hl]
	and a
	jr nz, .not_on_ground
	call Random
	and %0000011
	or %00001000
	add 4
	cpl
	inc a
	ld [hl], a
.not_on_ground
	inc hl
	dec c
	jr nz, :-
	ret

.Nudge:
	ld hl, wSprTest
	ld c, SPRTEST_CT
:
	inc hl
	ld a, [hli]
	cp 136
	jr nz, .skip_nudge
	ld a, [hl]
	and a
	jr nz, .skip_nudge
	call Random
	and %10000111
	cp $80
	jr c, .set_nudge
	xor %10000000
	cpl
	inc a
.set_nudge
	ld [hl], a
.skip_nudge
	inc hl
	inc hl
	dec c
	jr nz, :-
	ret

SPRT_UpdateSprites:
	ld de, wSprTest
	ld c, SPRTEST_CT ; num sprites
.loop
	push bc
	push de
	call .UpdateSprite
	pop hl
	ld bc, 4
	add hl, bc
	ld d, h
	ld e, l
	pop bc
	dec c
	jr nz, .loop
	ret

DEF SPR_X_POS EQU 0
DEF SPR_Y_POS EQU 1
DEF SPR_X_VEL EQU 2
DEF SPR_Y_VEL EQU 3
MACRO getval
	ld hl, \1
	add hl, de
	ld a, [hl]
ENDM
MACRO setval
	ld hl, \1
	add hl, de
	ld [hl], a
ENDM
.UpdateSprite:
	getval SPR_X_VEL
	ld c, a
	getval SPR_X_POS
	add c
	cp 153
	jr c, .got_new_x_pos
	sub c
	sub c
	push af
	ld a, c
	cpl
	inc a
	setval SPR_X_VEL
	pop af
.got_new_x_pos
	setval SPR_X_POS
	getval SPR_Y_VEL
	inc a
	setval SPR_Y_VEL
	ld c, a
	getval SPR_Y_POS
	add c
	cp 137
	jr c, .no_hit_bottom
.hit_bottom
	getval SPR_Y_VEL
	dec a
	jr z, .got_new_y_vel
	dec a
.got_new_y_vel
	cpl
	inc a
	setval SPR_Y_VEL
	ld c, a
	getval SPR_Y_POS
	add c
.no_hit_bottom
	setval SPR_Y_POS

	getval SPR_Y_POS
	cp 136
	ret nz
	getval SPR_Y_VEL
	and a
	ret nz
	getval SPR_X_VEL
	and a
	ret z
	cp $80
	jr c, .dec_xvel
	inc a
	jr :+
.dec_xvel
	dec a
:
	setval SPR_X_VEL
	ret

SPRT_CopySprites:
	ld de, wSprTest
	ld c, SPRTEST_CT ; num sprites
.loop
	push bc
	push de
	call .CopySprite
	pop hl
	ld bc, 4
	add hl, bc
	ld d, h
	ld e, l
	pop bc
	dec c
	jr nz, .loop
	ret

.CopySprite:
	ld a, SPRTEST_CT
	sub c
	push af
	add a
	add a
	ld l, a
	ld h, HIGH(wOAMRAM)
	push hl
	ldh a, [rSCY]
	ld b, a
	getval SPR_Y_POS
	add 16
	sub b
	ld b, a
	ldh a, [rSCX]
	ld c, a
	getval SPR_X_POS
	add 8
	sub c
	pop hl
	ld [hl], b
	inc hl
	ld [hli], a
	ld a, 1
	ld [hli], a
	pop af
	and %111
	ld [hl], a
	ret

INCLUDE "home/math.asm"
INCLUDE "home/string.asm"
INCLUDE "home/call.asm"
INCLUDE "home/flag.asm"
INCLUDE "home/font.asm"
INCLUDE "home/audio.asm"
INCLUDE "home/random.asm"
INCLUDE "home/serial.asm"
INCLUDE "home/color.asm"

INCLUDE "home/crash.asm"
