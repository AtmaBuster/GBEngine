; for hConsoleType
HW_DMG EQU 0
HW_SGB EQU 1
HW_CGB EQU 2
HW_AGB EQU 3

; for vram offsets
tile      EQUS " + $10 * "
tiles     EQUS " * $10"

tile1bpp  EQUS " + $08 * "
tiles1bpp EQUS " * $08"

; for hCrashType
ERR_RST38 EQU 0
ERR_DIV0  EQU 1
