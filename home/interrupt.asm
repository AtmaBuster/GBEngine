VBlank:
	call VBlank_CopyTileAndAttrMap
	call Random
	call Joypad
	call VBlank_HandleScroll

	ld a, 1
	ldh [hVBlank], a

	pop hl
	pop de
	pop bc
	pop af
	reti

VBlank_CopyTileAndAttrMap:
	ldh a, [hCopyWRAMTileMap]
	and a
	ret z

	ldh a, [hBGMapThird]
	inc a
	cp 3
	jr c, .got_map_third
	xor a
.got_map_third
	ldh [hBGMapThird], a

IF CGB_SUPPORT == 1
	call .CopyTileMap
	jr .CopyAttrMap

.CopyTileMap
	xor a
	ldh [rVBK], a
	ld bc, wTileMap
	jr .CopyMapThird

.CopyAttrMap
	ldh a, [hConsoleType]
	cp HW_CGB
	ret c
	ld a, 1
	ldh [rVBK], a
	ld bc, wAttrMap
ELSE
	ld bc, wTileMap
ENDC

.CopyMapThird:
	ldh a, [hBGMapThird]
	ld hl, 0
	ld de, $9800
	and a
	jr z, .got_addr
	ld l, 120
	ld de, $98C0
	dec a
	jr z, .got_addr
	ld l, 240
	ld de, $9980
.got_addr
	add hl, bc

	ld [hSPStore], sp
	ld sp, hl
	ld h, d
	ld l, e

REPT 6
REPT 10
	pop de
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR
	ld bc, $20 - SCREEN_WIDTH
	add hl, bc
ENDR

	ldh a, [hSPStore]
	ld l, a
	ldh a, [hSPStore + 1]
	ld h, a
	ld sp, hl

	ret

Random:
; NYI
	ret

Joypad:
; get D-Pad
	ld a, R_DPAD
	ldh [rJOYP], a
; read twice, allows the value to stabilize
	ldh a, [rJOYP]
	ldh a, [rJOYP]

; put this into the high nibble
	cpl
	and $0F
	swap a
	ld b, a

; get Buttons
	ld a, R_BUTTONS
	ldh [rJOYP], a
; read six times, same reason
REPT 6
	ldh a, [rJOYP]
ENDR

; put this into the low nibble
	cpl
	and $0F
	or b
	ld b, a

; reset register
	ld a, R_DPAD | R_BUTTONS
	ldh [rJOYP], a

; set joypad memory in HRAM
	ldh a, [hJoypadHeld] ; last frame status
	ld e, a
	xor b
	ld d, a ; store for later
	and e ; same as "a & !b"
	ldh [hJoypadUp], a
	ld a, d
	and b ; same as "!a & b"
	ldh [hJoypadDown], a
	ld a, b
	ldh [hJoypadHeld], a

	ret

; TODO - better register management (?)
VBlank_HandleScroll:
	lb de, LOW(hScrollTargetX), LOW(rSCX)
	call .handle_scroll
	lb de, LOW(hScrollTargetY), LOW(rSCY)
.handle_scroll
	ld c, e
	ldh a, [c]
	ld b, a ; b = scroll position
	ld c, d
	ldh a, [c] ; a = scroll target
	inc c
	cp b
	jr z, .done_scroll
; need to scroll
	ld d, a
	ldh a, [c]
	and a
	ret z
; apply scroll
	ld h, a
	ld l, c
	call AbsoluteValue
	ld c, a
	ld a, d
	sub b
	call AbsoluteValue
	cp c
	ld a, d
	jr c, .set_scroll
	ld a, h
	add b
.set_scroll
	ld c, e
	ldh [c], a
	cp d
	ret nz
	ld c, l
.done_scroll
	xor a
	ldh [c], a
	ret

LCD:
	ldh a, [hUseLCDInt]
	and a
	jr z, .exit
	push hl
	push de
	push bc

	pop bc
	pop de
	pop hl
.exit
	pop af
	reti
