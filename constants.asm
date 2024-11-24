INCLUDE "build_constants.asm"
INCLUDE "charmap.asm"

INCLUDE "constants/hardware_constants.asm"
INCLUDE "constants/function_constants.asm"

INCLUDE "macros.asm"

INCLUDE "ram/constants.asm"

DEF NULL EQU 0

DEF SCREEN_WIDTH  EQU 20
DEF SCREEN_HEIGHT EQU 18

DEF BG_MAP_WIDTH  EQU 32
DEF BG_MAP_HEIGHT EQU 32

DEF NUM_BGMAP_SECTIONS EQU 3

	flag_const A_BUTTON, 0
	flag_const B_BUTTON, 1
	flag_const SELECT,   2
	flag_const START,    3
	flag_const D_RIGHT,  4
	flag_const D_LEFT,   5
	flag_const D_UP,     6
	flag_const D_DOWN,   7

DEF R_DPAD    EQU %00100000
DEF R_BUTTONS EQU %00010000
