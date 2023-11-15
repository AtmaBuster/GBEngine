SECTION "W Audio", WRAM0[$C000]

	ds $100 ; TODO

SECTION "W Stack", WRAM0[$C100]

wStack:: ds $100
wStackPointer::

SECTION "W Tile Map", WRAM0

wTileMap:: ds SCREEN_WIDTH * SCREEN_HEIGHT
IF CGB_SUPPORT == 1
wAttrMap:: ds SCREEN_WIDTH * SCREEN_HEIGHT
ENDC

SECTION "W Line Offset", WRAM0, ALIGN[4]

wLineOffsetCommands:: ds 16
wLineOffsetPos:: db

SECTION "W String", WRAM0

wPrintNumBuffer:: ds 9

SECTION "W Program", WRAM0

wHelloWorld_Input:: dw
wHelloWorld_Output:: ds 2
wHelloWorld_OutputR:: db
wHelloWorld_Cursor:: db

wHelloWorld_Flags:: bitfield 300
