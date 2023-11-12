; ================================================
; PrintString
; ================================================
; Prints a string from <de> to <hl>
; ================================================
;   input
;       de - source
;       hl - destination
;   output
;       a  - 0
;       bc - varies
;       de - de.in + <length of string>
;       hl - left of last printed line
PrintString:
	push hl
.char_loop
	ld a, [de]
	inc de
	and a
	jr nz, .put_char
	pop hl
	ret

.put_char
; control chars
	cp "\n"
	jr z, .new_line
; printable char
	ld [hli], a
	jr .char_loop

.new_line
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	push hl
	jr .char_loop

PRINTNUM_1BYTE EQU %01
PRINTNUM_2BYTE EQU %10
PRINTNUM_3BYTE EQU %11
F_PRINTNUM_LALIGN   EQU 2
F_PRINTNUM_ZPAD     EQU 3
F_PRINTNUM_BIGEND   EQU 4
F_PRINTNUM_HEX      EQU 5
F_PRINTNUM_COMMASEP EQU 6
; ================================================
; PrintNum
; ================================================
; Prints a number at <de> to <hl>, with flags <b>
; ================================================
;   input
;       b  - flags : 0             1
;           .0-1   - 1, 2, or 3 bytes
;           .2     - right align : left align
;           .3     - pad w/ "\0" : pad w/ "0"
;           .4     - little end. : big end.
;           .5     - decimal     : hex
;           .6     - no comma    : comma sep.
;       de - *number
;       hl - destination
;   output
;       ???
PrintNum:
	push hl
; clear hPrintNumBuffer
	xor a
	ldh [hPrintNumBuffer], a
	ldh [hPrintNumBuffer + 1], a
	ldh [hPrintNumBuffer + 2], a
; copy number to hPrintNumBuffer (make it little endian)
	ld a, b
	and %11
	ld c, a
	bit F_PRINTNUM_BIGEND, b
	ld hl, hPrintNumBuffer
	jr nz, .copy_big_endian
.copy_little_endian_loop
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .copy_little_endian_loop
	jr .done_copy

.copy_big_endian
	push bc
	ld b, 0
	dec c
	add hl, bc
	pop bc
.copy_big_endian_loop
	ld a, [de]
	inc de
	ld [hld], a
	dec c
	jr nz, .copy_big_endian_loop

.done_copy

	ld hl, wPrintNumBuffer
	xor a
	ld [hli], a
	push bc
	ld bc, 8
	call MemFill
	pop bc

	dec hl
.put_char_loop
	call .DivideBuffer
	add "0"
	cp "9" + 1
	jr c, .got_char
	add "A" - "9" - 1
.got_char
	ld [hld], a
	call .CheckBufferZero
	jr nz, .put_char_loop

	bit F_PRINTNUM_LALIGN, b
	jr nz, .left_align
; right align
	pop hl
	call .ZeroPad
	jr .copy_string

.left_align
	ld de, (-wPrintNumBuffer - 7) & $FFFF
	add hl, de
	xor a
	sub l
	call .GetNumChars
	pop hl
	ld e, a
	ld d, 0
	add hl, de
.copy_string
	ld de, wPrintNumBuffer + 8
	ld c, 4
.copy_string_loop
	ld a, [de]
	and a
	ret z
	dec c
	jr nz, .skip_comma
	ld c, 3
	bit F_PRINTNUM_COMMASEP, b
	jr z, .skip_comma
	push af
	ld a, ","
	ld [hld], a
	pop af
.skip_comma
	ld [hld], a
	dec de
	jr .copy_string_loop

.DivideBuffer
	push bc
	bit F_PRINTNUM_HEX, b
	jr nz, .DivideBufferBy16
.DivideBufferBy10
	push hl
	ld c, 24
	xor a
	ldh [hPrintNumDivBuffer], a
	ldh [hPrintNumDivBuffer + 1], a
	ldh [hPrintNumDivBuffer + 2], a
.div_loop
; rotate left
	rla
	ld hl, hPrintNumBuffer
REPT 6
	ld a, [hl]
	rla
	ld [hli], a
ENDR
; check sub
	ldh a, [hPrintNumDivBuffer]
	cp 10
	jr c, .lt_10
	sub 10
	ldh [hPrintNumDivBuffer], a
	ldh a, [hPrintNumDivBuffer + 1]
	sbc 0
	ldh [hPrintNumDivBuffer + 1], a
	ldh a, [hPrintNumDivBuffer + 2]
	sbc 0
	ldh [hPrintNumDivBuffer + 2], a
	ld a, $80
	jr .next_rotate

.lt_10
	xor a
.next_rotate
	dec c
	jr nz, .div_loop

; final rotation
	rla
	ld hl, hPrintNumBuffer
REPT 3
	ld a, [hl]
	rla
	ld [hli], a
ENDR

	ld a, [hPrintNumDivBuffer]
	pop hl
	pop bc
	ret

.DivideBufferBy16
	ldh a, [hPrintNumBuffer + 2]
	swap a
	ld b, a
	and $F
	ldh [hPrintNumBuffer + 2], a
	ld a, b
	swap a
	and $F

	ldh a, [hPrintNumBuffer + 1]
	swap a
	ld c, a
	and $F
	or b
	ldh [hPrintNumBuffer + 1], a
	ld a, c
	and $F0
	ld c, a

	ldh a, [hPrintNumBuffer]
	swap a
	ld b, a
	and $F
	or c
	ldh [hPrintNumBuffer], a
	ld a, b
	swap a
	and $F

	pop bc
	ret

.CheckBufferZero
	ldh a, [hPrintNumBuffer]
	ld c, a
	ldh a, [hPrintNumBuffer + 1]
	or c
	ld c, a
	ldh a, [hPrintNumBuffer + 2]
	or c
	ret

.ZeroPad
	call .GetMaxNumSize
	ld a, c
	call .GetNumChars
	ld c, a
	bit F_PRINTNUM_ZPAD, b
	jr z, .shift_dest
	ld a, "0"
.zero_pad_loop
	ld [hli], a
	dec c
	jr nz, .zero_pad_loop
	ret

.shift_dest
	push bc
	ld b, 0
	add hl, bc
	pop bc
	ret

.GetNumChars
	bit F_PRINTNUM_COMMASEP, b
	ret z
	cp 3
	ret c
	inc a
	cp 7
	ret c
	inc a
	ret

.GetMaxNumSize
	ld a, b
	and %11
	bit F_PRINTNUM_HEX, b
	jr nz, .max_num_hex
	ld c, 2
	dec a
	ret z
	ld c, 4
	dec a
	ret z
	ld c, 7
	ret

.max_num_hex
	ld c, 1
	dec a
	ret z
	inc c
	inc c
	dec a
	ret c
	inc c
	inc c
	ret
