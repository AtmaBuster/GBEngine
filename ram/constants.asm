; for hConsoleType
DEF HW_DMG EQU 0
DEF HW_SGB EQU 1
DEF HW_CGB EQU 2
DEF HW_AGB EQU 3

; for vram offsets
DEF tile      EQUS " + $10 * "
DEF tiles     EQUS " * $10"

DEF tile1bpp  EQUS " + $08 * "
DEF tiles1bpp EQUS " * $08"

; for hCrashType
DEF ERR_RST38  EQU 0
DEF ERR_DIV0   EQU 1
DEF ERR_JOYINT EQU 2
