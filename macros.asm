; syntax

MACRO lb ; r, hi, lo
	ld \1, ((\2) & $FF) << 8 | ((\3) & $FF)
ENDM

MACRO ln ; r, hi, lo
	ld \1, ((\2) & $F) << 4 | ((\3) & $F)
ENDM

MACRO RGB
rept _NARG / 3
	dw palred (\1) + palgreen (\2) + palblue (\3)
	shift 3
endr
ENDM

palred   EQUS "(1 << 0) *"
palgreen EQUS "(1 << 5) *"
palblue  EQUS "(1 << 10) *"

MACRO farcall
	ld a, BANK(\1)
	ld hl, \1
	rst Farcall
ENDM

hlcoord EQUS "coord hl,"
bccoord EQUS "coord bc,"
decoord EQUS "coord de,"

MACRO coord
; register, x, y[, origin]
	if _NARG < 4
	ld \1, (\3) * SCREEN_WIDTH + (\2) + wTileMap
	else
	ld \1, (\3) * SCREEN_WIDTH + (\2) + \4
	endc
ENDM

hlbgcoord EQUS "bgcoord hl,"
bcbgcoord EQUS "bgcoord bc,"
debgcoord EQUS "bgcoord de,"

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

MACRO str
	db \1
	db 0
ENDM

; enumerate constants

MACRO flag_const
F_\1 EQU \2
\1 EQU (1 << \2)
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
\1 EQU const_value
const_value = const_value + const_inc
ENDM

MACRO const_skip
IF _NARG >= 1
const_value = const_value + const_inc * (\1)
ELSE
const_value = const_value + const_inc
ENDC
ENDM
