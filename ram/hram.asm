SECTION "HRAM", HRAM

hConsoleType:: db
hROMBank:: db

hSPStore:: dw

hJoypadDown:: db ; pressed this frame
hJoypadUp::   db ; released this frame
hJoypadHeld:: db ; held down

hVBlank:: db ; VBlank sets this to 1
hUseLCDInt:: db

hCopyWRAMTileMap:: db
hBGMapThird:: db
IF CGB_SUPPORT == 1
hWhichMap:: db
ENDC

hScrollTargetX:: db
hScrollSpeedX:: db
hScrollTargetY:: db
hScrollSpeedY:: db

assert hScrollSpeedX == hScrollTargetX + 1
assert hScrollSpeedY == hScrollTargetY + 1

UNION

hPrintNumBuffer:: ds 3
hPrintNumDivBuffer:: ds 3

ENDU
