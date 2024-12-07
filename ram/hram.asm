SECTION "HRAM Console Info", HRAM

hConsoleType:: db



SECTION "HRAM Data", HRAM

hROMBank:: db
hRAMBank:: db

hSerialTransferStatus:: db
; R.TTTTTT
; R = Received byte
; T = Timeout timer
hSerialConnectionStatus:: db
; KT.....C
; K = Connection OK
; T = Timeout error
; C = Using external clock
hSerialGet:: db

hSPStore:: dw

hJoypadDown:: db ; pressed this frame
hJoypadUp::   db ; released this frame
hJoypadHeld:: db ; held down

hVBlank:: db ; VBlank sets this to 1
hUseLCDInt:: db

hCopyWRAMTileMap:: db
hBGMapThird:: db

hScrollTargetX:: db
hScrollSpeedX:: db
hScrollTargetY:: db
hScrollSpeedY:: db
hScrollSpeedDiv:: db
hScrollSpeedDivTimer:: db

assert hScrollSpeedX == hScrollTargetX + 1
assert hScrollSpeedY == hScrollTargetY + 1

UNION

hWkBuffer::

NEXTU

hCrashStoreAF:: dw
hCrashType:: db
hCrashStoreBC:: dw
hCrashStoreDE:: dw
hCrashStoreHL:: dw
hCrashStoreStackContents::

NEXTU

hPrintNumBuffer:: ds 3
hPrintNumDivBuffer:: ds 3

NEXTU

UNION
; Multiply input
	ds 1
hMultiplicand:: ds 3
hMultiplier::   db

NEXTU
; Multiply output
hProduct:: ds 4

NEXTU
; Divide input
hDividend:: ds 4
hDivisor::  db

NEXTU
; Divide output
hQuotient::  ds 4
hRemainder:: db

ENDU

; math work
hMathBuffer:: ds 5

ENDU

; Random number generator
hRandomX:: db
hRandomY:: db
hRandomZ:: db
hRandomA:: db

IF INCLUDE_SOFT_RESET
hDisableSoftReset:: db
ENDC
