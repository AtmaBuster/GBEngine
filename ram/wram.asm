SECTION "WRAM Stack", WRAM0

	ds $100

wStack:: ds $100
wStackPointer::

wTileMap:: ds SCREEN_WIDTH * SCREEN_HEIGHT
IF CGB_SUPPORT == 1
wAttrMap:: ds SCREEN_WIDTH * SCREEN_HEIGHT
ENDC

wPrintNumBuffer:: ds 9

wHelloWorldNum1:: dw
