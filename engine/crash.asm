_CrashHandler::
; hard-disable all interrupts
	ld a, 0 ; don't optimize, keep flags
	ldh [rIE], a
; disable audio; no GBA crash sound please
	ldh [rNR52], a
; store bc, de, hl
	ld a, b
	ldh [hCrashStoreBC + 1], a
	ld a, c
	ldh [hCrashStoreBC], a
	ld a, d
	ldh [hCrashStoreDE + 1], a
	ld a, e
	ldh [hCrashStoreDE], a
	ld a, h
	ldh [hCrashStoreHL + 1], a
	ld a, l
	ldh [hCrashStoreHL], a
; af -> bc
	pop hl
	push af
	pop bc
	push hl
; store flag register
	ld a, c
	ldh [hCrashStoreAF], a
; store contents of stack (4 words above top)
	ld hl, sp - 8
	ld b, 8
	ld c, LOW(hCrashStoreStackContents)
.store_stack_loop
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .store_stack_loop
; set up a straight b/w palette
	ld a, 1 << rBGPI_AUTO_INCREMENT
	ldh [rBGPI], a
	ld c, LOW(rBGPD)
	ld a, $FF
	ldh [c], a
	ld a, $7F
	ldh [c], a
	xor a
REPT 6
	ldh [c], a
ENDR

	ld bc, Crash_BaseTilemap.end - Crash_BaseTilemap
	ld hl, wTileMap
	ld de, Crash_BaseTilemap
	call MemCpy

	call Crash_PutStackData
	call Crash_PutRegisters
	call Crash_PutVars

	ldh a, [hCrashType]
	ld c, a
	ld b, 0
	ld hl, Crash_ErrorStrings
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 5, 5
	call StrCpy

	call DisableLCD
	call Crash_CopyTileMap
	call LoadFont
	ld a, (1 << rLCDC_ENABLE) | (1 << rLCDC_TILE_DATA) | (1 << rLCDC_BG_PRIORITY)
	ldh [rLCDC], a
	call EnableLCD

	halt
	nop

Crash_PutStackData:
; put sp
	ld hl, sp + 2
	ld a, l
	push af
	ld a, h
	hlcoord 4, 11
	call Crash_PutHex
	pop af
	call Crash_PutHex
; put stored stack data
	ld de, hCrashStoreStackContents
	hlcoord 16, 7
	ld c, 4
	call .loop
; put current contents
	ld hl, sp + 2
	ld d, h
	ld e, l
	hlcoord 16, 11
	ld c, 9
.loop
	call Crash_PutWord
	push bc
	ld bc, SCREEN_WIDTH - 4
	add hl, bc
	pop bc
	dec c
	jr nz, .loop
	ret

Crash_PutRegisters:
	hlcoord 4, 7
	ld de, hCrashStoreAF
	ld c, 4
.loop
	call Crash_PutWord
	dec c
	ret z
	push bc
	ld bc, SCREEN_WIDTH - 4
	add hl, bc
	pop bc
	jr .loop

Crash_PutVars:
	hlcoord 6, 14
	ldh a, [hROMBank]
	call Crash_PutHex
	hlcoord 6, 15
	ldh a, [hConsoleType]
	call Crash_PutHex
	hlcoord 6, 16
	ldh a, [hRAMBank]
	jp Crash_PutHex

Crash_CopyTileMap:
	call .ClearAttrMap

	xor a
	ldh [rVBK], a
	ld hl, vBGMap0
	ld de, wTileMap
	ld b, SCREEN_HEIGHT
.row_loop
	ld c, SCREEN_WIDTH
.loop
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .loop
	push bc
	ld bc, BG_MAP_WIDTH - SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .row_loop
	ret

.ClearAttrMap
	ld a, 1
	ldh [rVBK], a
	ld hl, vBGMap0
	ld bc, BG_MAP_WIDTH * BG_MAP_HEIGHT
	xor a
	jp MemFill

Crash_PutWord:
	ld a, [de]
	push af
	inc de
	ld a, [de]
	inc de
	call Crash_PutHex
	pop af
Crash_PutHex:
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

Crash_BaseTilemap:
;       ....................
	db "An error has occur- "
	db "red. Please send a  "
	db "report & screenshot "
	db "to the developer.   "
	db "                    "
	db "ERR:                "
	db "                    "
	db "af= XX   sp- 8= XXXX"
	db "bc= XXXX   - 6= XXXX"
	db "de= XXXX   - 4= XXXX"
	db "hl= XXXX   - 2= XXXX"
	db "sp= XXXX      > XXXX"
	db "           + 2= XXXX"
	db "           + 4= XXXX"
	db "BANK :XX   + 6= XXXX"
	db "HW   :XX   + 8= XXXX"
	db "RAM  :XX   +10= XXXX"
	db "           +12= XXXX"
.end

Crash_ErrorStrings:
	dw .Err_rst38
	dw .Err_div0
	dw .Err_joyint

.Err_rst38
	str "0xFF EXEC"
.Err_div0
	str "DIVIDE BY ZERO"
.Err_joyint
	str "JOYPAD INT."
