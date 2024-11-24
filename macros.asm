INCLUDE "macros/text.asm"

; calls

MACRO farcall
	ld a, BANK(\1)
	ld hl, \1
	rst FarCall
ENDM

; syntax

MACRO lb ; r, hi, lo
	ld \1, ((\2) & $FF) << 8 | ((\3) & $FF)
ENDM

MACRO ln ; r, hi, lo
	ld \1, ((\2) & $F) << 4 | ((\3) & $F)
ENDM

; helpers

MACRO load_multiplicand
; args
;     num. bytes
;     value
; if num. bytes = 0, value will be treated as an immediate
; otherwise, load num. bytes from value (little endian) to hMultiplicand
IF \1 == 0
	ld a, (\2 >> 16)
	ldh [hMultiplicand], a
	ld a, (\2 >> 8) & $FF
	ldh [hMultiplicand + 1], a
	ld a, \2 & $FF
	ldh [hMultiplicand + 2], a
ELSE

IF \1 == 1
	xor a
	ldh [hMultiplicand], a
	ldh [hMultiplicand + 1], a
	ld a, [\2]
	ldh [hMultiplicand + 2], a
ELIF \1 == 2
	xor a
	ldh [hMultiplicand], a
	ld a, [\2 + 1]
	ldh [hMultiplicand + 1], a
	ld a, [\2]
	ldh [hMultiplicand + 2], a
ELSE
	ld a, [\2 + 2]
	ldh [hMultiplicand], a
	ld a, [\2 + 1]
	ldh [hMultiplicand + 1], a
	ld a, [\2]
	ldh [hMultiplicand + 2], a
ENDC

ENDC

ENDM

MACRO load_product
; args
;     num. bytes (max 4)
;     location
; copies num. bytes from hProduct (big-endian) to location (little-endian)
IF \1 >= 1
	ldh a, [hProduct + 3]
	ld [\2], a
IF \1 >= 2
	ldh a, [hProduct + 2]
	ld [\2 + 1], a
IF \1 >= 3
	ldh a, [hProduct + 1]
	ld [\2 + 2], a
IF \1 >= 4
	ldh a, [hProduct]
	ld [\2 + 3], a
ENDC
ENDC
ENDC
ENDC
ENDM

MACRO load_dividend
; args
;     num. bytes (max 4)
;     value
; if num. bytes = 0, value will be treated as an immediate
; otherwise, load num. bytes from value (little endian) to the hDividend
IF \1 == 0
	ld a, (\2 >> 24)
	ldh [hDividend], a
	ld a, (\2 >> 16) & $FF
	ldh [hDividend + 1], a
	ld a, (\2 >> 8) & $FF
	ldh [hDividend + 2], a
	ld a, \2 & $FF
	ldh [hDividend + 3], a
ELSE

IF \1 == 1
	xor a
	ldh [hDividend], a
	ldh [hDividend + 1], a
	ldh [hDividend + 2], a
	ld a, [\2]
	ldh [hDividend + 3], a
ELIF \1 == 2
	xor a
	ldh [hDividend], a
	ldh [hDividend + 1], a
	ld a, [\2 + 1]
	ldh [hDividend + 2], a
	ld a, [\2]
	ldh [hDividend + 3], a
ELIF \1 == 3
	xor a
	ldh [hDividend], a
	ld a, [\2 + 2]
	ldh [hDividend + 1], a
	ld a, [\2 + 1]
	ldh [hDividend + 2], a
	ld a, [\2]
	ldh [hDividend + 3], a
ELSE
	ld a, [\2 + 3]
	ldh [hDividend], a
	ld a, [\2 + 2]
	ldh [hDividend + 1], a
	ld a, [\2 + 1]
	ldh [hDividend + 2], a
	ld a, [\2]
	ldh [hDividend + 3], a
ENDC

ENDC

ENDM

MACRO load_quotient
; args
;     num. bytes (max 4)
;     location
; copies num. bytes from hQuotient (big-endian) to location (little-endian)
IF \1 >= 1
	ldh a, [hQuotient + 3]
	ld [\2], a
IF \1 >= 2
	ldh a, [hQuotient + 2]
	ld [\2 + 1], a
IF \1 >= 3
	ldh a, [hQuotient + 1]
	ld [\2 + 2], a
IF \1 >= 4
	ldh a, [hQuotient]
	ld [\2 + 3], a
ENDC
ENDC
ENDC
ENDC
ENDM

; ram

MACRO bitfield
	ds (\1 + 7) / 8
ENDM




MACRO RGB
rept _NARG / 3
	dw palred (\1) + palgreen (\2) + palblue (\3)
	shift 3
endr
ENDM

DEF palred   EQUS "(1 << 0) *"
DEF palgreen EQUS "(1 << 5) *"
DEF palblue  EQUS "(1 << 10) *"

DEF hlcoord EQUS "coord hl,"
DEF bccoord EQUS "coord bc,"
DEF decoord EQUS "coord de,"

MACRO coord
; register, x, y[, origin]
	if _NARG < 4
	ld \1, (\3) * SCREEN_WIDTH + (\2) + wTileMap
	else
	ld \1, (\3) * SCREEN_WIDTH + (\2) + \4
	endc
ENDM

DEF hlbgcoord EQUS "bgcoord hl,"
DEF bcbgcoord EQUS "bgcoord bc,"
DEF debgcoord EQUS "bgcoord de,"

MACRO bgcoord
; register, x, y[, origin]
	if _NARG < 4
	ld \1, (\3) * BG_MAP_WIDTH + (\2) + $9800
	else
	ld \1, (\3) * BG_MAP_WIDTH + (\2) + \4
	endc
ENDM

MACRO dba
	db BANK(\1)
	dw \1
ENDM

; enumerate constants

MACRO flag_const
DEF F_\1 EQU \2
DEF \1 EQU (1 << \2)
ENDM

MACRO const_def
IF _NARG >= 1
const_value = \1
ELSE
const_value = 0
ENDC
IF _NARG >= 2
const_inc = \2
ELSE
const_inc = 1
ENDC
ENDM

MACRO const
DEF \1 EQU const_value
const_value = const_value + const_inc
ENDM

MACRO const_skip
IF _NARG >= 1
const_value = const_value + const_inc * (\1)
ELSE
const_value = const_value + const_inc
ENDC
ENDM
