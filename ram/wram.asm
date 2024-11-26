SECTION "Link RAM", WRAM0

wLinkBufferPos:: db
wLinkBufferChecksum:: db
wLinkTransferBuffer:: ds $10

SECTION "Stack RAM", WRAM0

wStack:: ds $100
wStackPointer::

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

SECTION "Program RAM", WRAM0

wHelloWorld_Input:: dw
wHelloWorld_Output:: ds 2
wHelloWorld_OutputR:: db
wHelloWorld_Cursor:: db

wHelloWorld_Flags:: bitfield 300
