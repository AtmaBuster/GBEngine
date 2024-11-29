SECTION "Stack RAM", WRAM0

wStack:: ds $100
wStackPointer::



SECTION "OAM RAM", WRAM0

wOAMRAM::
FOR N, 40
wOAMSprite{02d:N}:: ds 4
ENDR
wOAMRAMEnd::



SECTION "Tile Map RAM", WRAM0

wTileMap:: ds SCREEN_WIDTH * SCREEN_HEIGHT
IF CGB_SUPPORT == 1
wAttrMap:: ds SCREEN_WIDTH * SCREEN_HEIGHT
ENDC



SECTION "Line Offset RAM", WRAM0, ALIGN[4]

wLineOffsetCommands:: ds 16
wLineOffsetPos:: db



SECTION "String RAM", WRAM0

wPrintNumBuffer:: ds 9



SECTION "Program RAM", WRAM0, ALIGN[4]

UNION
wHelloWorld_MyNameIndex:: db
wHelloWorld_MyName:: ds 16
wHelloWorld_TheirName:: ds 16
NEXTU
wSprTest::
FOR N, 5
wSprTest_S{1d:N}::
wSprTest_S{1d:N}_XPos:: db
wSprTest_S{1d:N}_YPos:: db
wSprTest_S{1d:N}_XVel:: db
wSprTest_S{1d:N}_YVel:: db
ENDR
ENDU
